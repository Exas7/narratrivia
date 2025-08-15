// lib/core/controllers/quiz_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '/core/models/questions.dart';
import '/core/models/quiz_session.dart';
import '/core/models/medium_type.dart';
import '/core/services/quiz_service.dart';
import '/core/services/firestore_service.dart';
import '/core/services/mascot_service.dart';
import 'progression_controller.dart';

// Modalità di gioco disponibili
enum GameMode {
  classic,      // Modalità standard
  timeAttack,   // A tempo con moltiplicatori (TF)
  timeSurvival, // Sopravvivenza a tempo (MC)
  liar,         // Il bugiardo (invertito) (TF)
  challenge,    // Sfida con game over (MC)
  zen,          // Senza timer/punti
}

// Stati del feedback
enum FeedbackState {
  none,
  correct,
  wrong,
  showingFeedback,
}

class QuizController extends ChangeNotifier {
  final QuizService _quizService = QuizService();
  final FirestoreService _firestoreService = FirestoreService();
  final MascotService _mascotService = MascotService();
  final ProgressionController _progressionController = ProgressionController();

  // Current quiz state
  QuizSession? _currentSession;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _questionStartTime;
  int _correctStreak = 0;

  // Timer management
  Timer? _questionTimer;
  Timer? _feedbackTimer;
  Timer? _globalTimer; // Per Time Attack e Time Survival
  int _remainingTime = 0;
  int _questionRemainingTime = 0;

  // Feedback state
  FeedbackState _feedbackState = FeedbackState.none;
  dynamic _lastSubmittedAnswer;

  // Modalità di gioco corrente
  GameMode _currentGameMode = GameMode.classic;

  // Moltiplicatori per Time Attack
  double _streakMultiplier = 1.0;
  int _consecutiveCorrect = 0;

  // Per gestire il loop delle domande in Time Attack e Zen
  List<Question> _allQuestionsForLoop = [];
  int _loopIndex = 0;

  // Zen mode stats
  int _zenCorrectAnswers = 0;
  int _zenTotalAnswers = 0;

  // Settings for current medium
  Map<String, dynamic> _mediumSettings = {};

  // Getters
  QuizSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Question? get currentQuestion => _currentSession?.currentQuestion;
  int get correctStreak => _correctStreak;
  Map<String, dynamic> get mediumSettings => _mediumSettings;
  GameMode get currentGameMode => _currentGameMode;
  int get remainingTime => _remainingTime;
  int get questionRemainingTime => _questionRemainingTime;
  FeedbackState get feedbackState => _feedbackState;
  dynamic get lastSubmittedAnswer => _lastSubmittedAnswer;
  double get streakMultiplier => _streakMultiplier;
  bool get isShowingFeedback => _feedbackState == FeedbackState.showingFeedback;

  // Initialize controller
  Future<void> initialize(String userId) async {
    await _progressionController.initialize(userId);
    await _mascotService.initialize();
  }

  // Load medium settings
  Future<void> loadMediumSettings(MediumType medium) async {
    _mediumSettings = {
      'difficulty': QuestionDifficulty.medium,
      'numberOfQuestions': 15,
      'enableTimer': true,
      'showHints': false,
      'enabledModes': {
        QuestionType.truefalse: true,
        QuestionType.multiple: true,
        QuestionType.uglyImages: false,
        QuestionType.misleading: false,
      },
    };
    notifyListeners();
  }

  // Update medium settings
  void updateMediumSettings(Map<String, dynamic> settings) {
    _mediumSettings = settings;
    notifyListeners();
  }

  // Start a new quiz with specific game mode
  Future<bool> startQuiz({
    required MediumType medium,
    required QuestionType questionType,
    GameMode gameMode = GameMode.classic,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _correctStreak = 0;
    _currentGameMode = gameMode;
    _loopIndex = 0;
    _feedbackState = FeedbackState.none;
    _consecutiveCorrect = 0;
    _streakMultiplier = 1.0;
    _zenCorrectAnswers = 0;
    _zenTotalAnswers = 0;

    // Cancel any existing timers
    _cancelAllTimers();

    notifyListeners();

    try {
      // Check if this is first quiz
      final firstQuizMessage = await _mascotService.checkFirstQuiz();
      if (firstQuizMessage != null) {
        // Show mascot message (handled by UI)
      }

      // Determina il numero di domande basato sulla modalità
      List<Question> questions = [];

      if (gameMode == GameMode.classic || gameMode == GameMode.liar || gameMode == GameMode.challenge) {
        // Classic, Liar, Challenge: 5 facili + 5 medie + 5 difficili
        print('Loading questions for ${gameMode.name} mode...');

        final easyQuestions = await _quizService.fetchQuestionsDirectly(
          medium: medium,
          questionType: questionType,
          difficulty: QuestionDifficulty.easy,
          limit: 5,
        );

        final mediumQuestions = await _quizService.fetchQuestionsDirectly(
          medium: medium,
          questionType: questionType,
          difficulty: QuestionDifficulty.medium,
          limit: 5,
        );

        final hardQuestions = await _quizService.fetchQuestionsDirectly(
          medium: medium,
          questionType: questionType,
          difficulty: QuestionDifficulty.hard,
          limit: 5,
        );

        questions = [...easyQuestions, ...mediumQuestions, ...hardQuestions];
        print('Loaded ${questions.length} questions');

      } else if (gameMode == GameMode.timeAttack) {
        // Time Attack: 60 domande con loop se necessario
        print('Loading questions for Time Attack mode...');

        // Carica tutte le domande disponibili
        questions = await _quizService.fetchQuestionsDirectly(
          medium: medium,
          questionType: questionType,
          limit: 100,
        );

        // Se abbiamo meno di 60 domande, duplicale per il loop
        _allQuestionsForLoop = List.from(questions);
        while (questions.length < 60) {
          questions.addAll(_allQuestionsForLoop);
        }
        questions = questions.take(60).toList();

        // Inizializza timer globale per Time Attack (90 secondi)
        _remainingTime = 90;
        _startGlobalTimer();

      } else if (gameMode == GameMode.timeSurvival) {
        // Time Survival: Domande infinite con loop
        print('Loading questions for Time Survival mode...');

        questions = await _quizService.fetchQuestionsDirectly(
          medium: medium,
          questionType: questionType,
          limit: 100,
        );

        _allQuestionsForLoop = List.from(questions);

        // Inizializza timer globale per Time Survival (100 secondi)
        _remainingTime = 100;
        _startGlobalTimer();

      } else if (gameMode == GameMode.zen) {
        // Zen: Tutte le domande disponibili
        print('Loading all questions for Zen mode...');

        questions = await _quizService.getAllQuestionsForMedium(
          medium,
          questionType: questionType,
        );

        if (questions.isEmpty) {
          // Fallback: carica almeno alcune domande
          questions = await _quizService.fetchQuestionsDirectly(
            medium: medium,
            questionType: questionType,
            limit: 50,
          );
        }
      }

      // Se abbiamo domande, crea la sessione
      if (questions.isNotEmpty) {
        final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

        _currentSession = QuizSession(
          sessionId: sessionId,
          medium: medium,
          questionType: questionType,
          questions: questions,
        );

        // Start timer for first question (se non Zen mode)
        if (gameMode != GameMode.zen) {
          _startQuestionTimer();
        }

        _questionStartTime = DateTime.now();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Nessuna domanda disponibile per questa configurazione';
        _isLoading = false;
        notifyListeners();
        return false;
      }

    } catch (e) {
      _errorMessage = 'Errore nel caricamento del quiz: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Start global timer for Time Attack and Time Survival
  void _startGlobalTimer() {
    _globalTimer?.cancel();
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingTime--;

      if (_remainingTime <= 0) {
        timer.cancel();
        // Fine partita
        _handleQuizComplete();
      }

      notifyListeners();
    });
  }

  // Start question timer
  void _startQuestionTimer() {
    _questionTimer?.cancel();

    // Determina la durata del timer per domanda
    int duration = _getQuestionDuration();

    // Solo se il timer è visibile e non siamo in modalità globale
    if (_shouldShowQuestionTimer()) {
      _questionRemainingTime = duration;

      _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _questionRemainingTime--;

        if (_questionRemainingTime <= 0) {
          timer.cancel();
          // Tempo scaduto - risposta sbagliata
          skipQuestion();
        }

        notifyListeners();
      });
    } else if (_currentGameMode == GameMode.classic) {
      // Classic mode: timer invisibile
      _questionTimer = Timer(Duration(seconds: duration), () {
        skipQuestion();
      });
    }
  }

  // Get question duration based on mode
  int _getQuestionDuration() {
    if (_currentSession?.currentQuestion == null) return 20;

    final questionType = _currentSession!.currentQuestion!.type;

    switch (_currentGameMode) {
      case GameMode.classic:
        return questionType == QuestionType.truefalse ? 20 : 60;
      case GameMode.liar:
        return 45; // Timer sempre visibile
      case GameMode.challenge:
        return 10; // Timer sempre visibile
      case GameMode.timeAttack:
      case GameMode.timeSurvival:
        return 999; // Usa timer globale
      case GameMode.zen:
        return 0; // Nessun timer
    }
  }

  // Check if question timer should be visible
  bool _shouldShowQuestionTimer() {
    switch (_currentGameMode) {
      case GameMode.classic:
      case GameMode.zen:
        return false;
      case GameMode.liar:
      case GameMode.challenge:
        return true;
      case GameMode.timeAttack:
      case GameMode.timeSurvival:
        return false; // Usa timer globale
    }
  }

  // Submit answer for current question
  Future<AnswerResult> submitAnswer(dynamic answer) async {
    if (_currentSession == null || _currentSession!.isComplete || _isShowingFeedback) {
      return AnswerResult(
        isCorrect: false,
        xpEarned: 0,
        message: 'Sessione non valida',
      );
    }

    // Cancel question timer only for non-continuous timer modes
    if (_currentGameMode != GameMode.timeAttack && _currentGameMode != GameMode.timeSurvival) {
      _questionTimer?.cancel();
    }

    // Calculate response time
    final responseTime = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inMilliseconds / 1000.0
        : 10.0;

    // Per modalità "Il Bugiardo", inverti la risposta corretta
    dynamic correctAnswer = _currentSession!.currentQuestion?.correctAnswer;
    if (_currentGameMode == GameMode.liar && _currentSession!.currentQuestion?.type == QuestionType.truefalse) {
      // Per Il Bugiardo, la logica è invertita
      // Se correctAnswer è true (affermazione vera), la risposta giusta è FALSE
      // Se correctAnswer è false (affermazione falsa), la risposta giusta è TRUE
      correctAnswer = !(correctAnswer as bool);
    }

    // Check if answer is correct - FIX per Multiple Choice
    bool isCorrect = false;
    final question = _currentSession!.currentQuestion!;

    if (question.type == QuestionType.truefalse) {
      isCorrect = answer == correctAnswer;
    } else if (question.type == QuestionType.multiple) {
      // Il correctAnswer è un indice numerico
      if (question.correctAnswer is int) {
        final correctIndex = question.correctAnswer as int;

        if (answer is int) {
          isCorrect = answer == correctIndex;
        } else if (answer is String) {
          // Trova l'indice dell'opzione selezionata
          final selectedIndex = question.options.indexOf(answer);
          isCorrect = selectedIndex == correctIndex;
        }
      }
    }

    // Store answer for feedback
    _lastSubmittedAnswer = answer;
    _feedbackState = isCorrect ? FeedbackState.correct : FeedbackState.wrong;

    // Update streak and multipliers
    if (isCorrect) {
      _correctStreak++;
      _consecutiveCorrect++;

      // Update multiplier for Time Attack (solo per punti XP)
      if (_currentGameMode == GameMode.timeAttack) {
        if (_consecutiveCorrect >= 10) {
          _streakMultiplier = 2.0;
        } else if (_consecutiveCorrect >= 5) {
          _streakMultiplier = 1.5;
        }

        // Add time bonus based on difficulty
        final difficulty = question.difficulty.value;
        final timeBonus = difficulty == 1 ? 3 : difficulty == 2 ? 5 : 7;
        _remainingTime += timeBonus;
        notifyListeners();
      }

      // Add time for Time Survival
      if (_currentGameMode == GameMode.timeSurvival) {
        final difficulty = question.difficulty.value;
        final timeBonus = difficulty == 1 ? 3 : difficulty == 2 ? 5 : 7;
        _remainingTime += timeBonus;
        notifyListeners();
      }

      // Update Zen stats
      if (_currentGameMode == GameMode.zen) {
        _zenCorrectAnswers++;
      }
    } else {
      _correctStreak = 0;

      // Reset multiplier only if wrong answer in Time Attack
      if (_currentGameMode == GameMode.timeAttack) {
        _consecutiveCorrect = 0;
        _streakMultiplier = 1.0;
      }

      // Subtract time for Time Survival
      if (_currentGameMode == GameMode.timeSurvival) {
        _remainingTime -= 10;
        if (_remainingTime <= 0) {
          _remainingTime = 0;
          _handleQuizComplete();
          return AnswerResult(isCorrect: false, xpEarned: 0);
        }
        notifyListeners();
      }

      // Game over for Liar and Challenge modes
      if (_currentGameMode == GameMode.liar || _currentGameMode == GameMode.challenge) {
        _handleGameOver();
        return AnswerResult(isCorrect: false, xpEarned: 0);
      }
    }

    // Update Zen total
    if (_currentGameMode == GameMode.zen) {
      _zenTotalAnswers++;
    }

    // Submit to session
    _currentSession!.submitAnswer(
      answer: answer,
      isCorrect: isCorrect,
      responseTime: responseTime,
    );

    // Calculate XP earned (no XP in Zen mode)
    final xpEarned = (_currentGameMode != GameMode.zen && isCorrect)
        ? (_currentSession!.answers.last.xpEarned * _streakMultiplier).round()
        : 0;

    // Show feedback
    _feedbackState = FeedbackState.showingFeedback;
    notifyListeners();

    // Get feedback duration based on mode
    int feedbackDuration = _getFeedbackDuration();

    // Start feedback timer
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(Duration(milliseconds: feedbackDuration), () {
      _feedbackState = FeedbackState.none;
      _lastSubmittedAnswer = null;

      // Move to next question
      if (!_currentSession!.isComplete) {
        _questionStartTime = DateTime.now();

        // Restart question timer per ogni nuova domanda (non per Time Attack/Survival)
        if (_currentGameMode != GameMode.zen &&
            _currentGameMode != GameMode.timeAttack &&
            _currentGameMode != GameMode.timeSurvival) {
          _startQuestionTimer();
        }
      } else {
        // Quiz complete
        if (_currentGameMode != GameMode.timeAttack && _currentGameMode != GameMode.timeSurvival) {
          _handleQuizComplete();
        }
      }

      notifyListeners();
    });

    return AnswerResult(
      isCorrect: isCorrect,
      xpEarned: xpEarned,
      message: null,
    );
  }

  // Get feedback duration based on mode
  int _getFeedbackDuration() {
    switch (_currentGameMode) {
      case GameMode.classic:
      case GameMode.challenge:
        return 2000; // 2 secondi
      case GameMode.timeAttack:
      case GameMode.timeSurvival:
        return 1000; // 1 secondo
      case GameMode.liar:
        return 500; // 0.5 secondi
      case GameMode.zen:
        return 1500; // 1.5 secondi
    }
  }

  // Handle game over (for Liar and Challenge modes)
  Future<void> _handleGameOver() async {
    _cancelAllTimers();
    await _handleQuizComplete();
  }

  // Skip current question
  void skipQuestion() {
    if (_currentSession == null || _currentSession!.isComplete) return;

    _currentSession!.skipQuestion();
    _correctStreak = 0;
    _consecutiveCorrect = 0;
    _streakMultiplier = 1.0;

    // Show wrong feedback
    _feedbackState = FeedbackState.wrong;
    _lastSubmittedAnswer = null;
    notifyListeners();

    // Handle game over for certain modes
    if (_currentGameMode == GameMode.challenge) {
      _handleGameOver();
      return;
    }

    // Move to next question after feedback
    Timer(Duration(milliseconds: _getFeedbackDuration()), () {
      _feedbackState = FeedbackState.none;

      if (!_currentSession!.isComplete) {
        _questionStartTime = DateTime.now();
        _startQuestionTimer();
      } else {
        _handleQuizComplete();
      }

      notifyListeners();
    });
  }

  // Handle quiz completion
  Future<void> _handleQuizComplete() async {
    if (_currentSession == null) return;

    _cancelAllTimers();

    // For Zen mode, just show stats
    if (_currentGameMode == GameMode.zen) {
      // Stats are already tracked in _zenCorrectAnswers and _zenTotalAnswers
      notifyListeners();
      return;
    }

    final userId = _progressionController.currentUserId;
    if (userId == null) return;

    // Save session to history (except Zen mode)
    if (_currentGameMode != GameMode.zen) {
      await _firestoreService.saveQuizSession(userId, _currentSession!);
    }

    // Update user stats
    await _progressionController.addQuizSession(
      _currentSession!.medium,
      (_currentSession!.totalXpEarned * _streakMultiplier).round(),
      _currentSession!.correctAnswers,
      _currentSession!.totalQuestions,
    );

    // Check for perfect game
    if (_currentSession!.correctAnswers == _currentSession!.totalQuestions) {
      final message = _mascotService.checkPerfectGame(
        _currentSession!.correctAnswers,
        _currentSession!.totalQuestions,
      );
      if (message != null) {
        // Show mascot message (handled by UI)
      }
    }

    // Check for achievements
    final achievements = await _progressionController.checkAchievements();
    for (final achievement in achievements) {
      final message = _mascotService.checkNewAchievement(achievement);
      if (message != null) {
        // Show mascot message (handled by UI)
      }
    }

    notifyListeners();
  }

  // Cancel all timers
  void _cancelAllTimers() {
    _questionTimer?.cancel();
    _feedbackTimer?.cancel();
    _globalTimer?.cancel();
    _questionTimer = null;
    _feedbackTimer = null;
    _globalTimer = null;
  }

  // Replay quiz with same settings
  Future<bool> replayQuiz() async {
    if (_currentSession == null) return false;

    return startQuiz(
      medium: _currentSession!.medium,
      questionType: _currentSession!.questionType,
      gameMode: _currentGameMode,
    );
  }

  // End current session
  Future<void> endSession() async {
    _cancelAllTimers();

    if (_currentSession != null) {
      final userId = _progressionController.currentUserId;
      if (userId != null && _currentGameMode != GameMode.zen) {
        await _quizService.endSession(userId);
      }
      _currentSession = null;
      _correctStreak = 0;
      _allQuestionsForLoop.clear();
      _loopIndex = 0;
      _feedbackState = FeedbackState.none;
      _lastSubmittedAnswer = null;
      notifyListeners();
    }
  }

  // Get game history for medium
  Future<List<Map<String, dynamic>>> getGameHistory(MediumType medium) async {
    final userId = _progressionController.currentUserId;
    if (userId == null) return [];

    return await _firestoreService.getGameHistory(userId);
  }

  // Get medium statistics
  Future<Map<String, dynamic>> getMediumStatistics(MediumType medium) async {
    final userId = _progressionController.currentUserId;
    if (userId == null) return {};

    return await _firestoreService.getMediumStatistics(userId, medium);
  }

  // Check if Database Vault is unlocked
  bool isDatabaseVaultUnlocked() {
    return _progressionController.userStats?.isDatabaseVaultUnlocked ?? false;
  }

  // Handle Database Vault access attempt
  MascotMessage? checkDatabaseVaultAccess() {
    final stats = _progressionController.userStats;
    if (stats == null) return null;

    return _mascotService.checkDatabaseVaultAccess(
      stats.isDatabaseVaultUnlocked,
      stats,
    );
  }

  // Get Zen mode stats
  Map<String, dynamic> getZenStats() {
    final percentage = _zenTotalAnswers > 0
        ? (_zenCorrectAnswers / _zenTotalAnswers * 100).round()
        : 0;

    return {
      'correctAnswers': _zenCorrectAnswers,
      'totalAnswers': _zenTotalAnswers,
      'percentage': percentage,
    };
  }

  @override
  void dispose() {
    _cancelAllTimers();
    _progressionController.dispose();
    super.dispose();
  }
}

// Result class for answer submission
class AnswerResult {
  final bool isCorrect;
  final int xpEarned;
  final String? message;

  AnswerResult({
    required this.isCorrect,
    required this.xpEarned,
    this.message,
  });
}