// lib/core/controllers/quiz_controller.dart

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
  timeAttack,   // A tempo con moltiplicatori
  liar,         // Il bugiardo (invertito)
  zen,          // Senza timer/punti
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

  // Modalità di gioco corrente
  GameMode _currentGameMode = GameMode.classic;

  // Per gestire il loop delle domande in Time Attack
  List<Question> _allQuestionsForLoop = [];
  int _loopIndex = 0;

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

  // Initialize controller
  Future<void> initialize(String userId) async {
    await _progressionController.initialize(userId);
    await _mascotService.initialize();
  }

  // Load medium settings
  Future<void> loadMediumSettings(MediumType medium) async {
    _mediumSettings = {
      'difficulty': QuestionDifficulty.medium,
      'numberOfQuestions': 15,  // Classic mode default
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
    notifyListeners();

    try {
      // Check if this is first quiz
      final firstQuizMessage = await _mascotService.checkFirstQuiz();
      if (firstQuizMessage != null) {
        // Show mascot message (handled by UI)
      }

      // Determina il numero di domande basato sulla modalità
      int numberOfQuestions = _getQuestionsCountForMode(gameMode, questionType);

      // Per Classic Mode, dobbiamo caricare 5 domande per difficoltà
      List<Question> questions = [];

      if (gameMode == GameMode.classic && questionType == QuestionType.truefalse) {
        // Classic TF: 5 facili + 5 medie + 5 difficili
        print('Loading questions for Classic TF mode...');

        // Carica 5 domande facili
        final easyQuestions = await _quizService.fetchQuestionsDirectly(
          medium: medium,
          questionType: questionType,
          difficulty: QuestionDifficulty.easy,
          limit: 5,
        );

        // Carica 5 domande medie
        final mediumQuestions = await _quizService.fetchQuestionsDirectly(
          medium: medium,
          questionType: questionType,
          difficulty: QuestionDifficulty.medium,
          limit: 5,
        );

        // Carica 5 domande difficili
        final hardQuestions = await _quizService.fetchQuestionsDirectly(
          medium: medium,
          questionType: questionType,
          difficulty: QuestionDifficulty.hard,
          limit: 5,
        );

        // Combina tutte le domande nell'ordine: facili, medie, difficili
        questions = [...easyQuestions, ...mediumQuestions, ...hardQuestions];

        print('Loaded ${questions.length} questions total (${easyQuestions.length} easy, ${mediumQuestions.length} medium, ${hardQuestions.length} hard)');

        // Se non abbiamo abbastanza domande, usa quelle disponibili
        if (questions.length < 15) {
          print('⚠️ Only ${questions.length} questions available, will loop if needed');
          _allQuestionsForLoop = List.from(questions);
        }

      } else if (gameMode == GameMode.classic && questionType == QuestionType.multiple) {
        // Classic MC: 5 facili + 5 medie + 5 difficili
        print('Loading questions for Classic MC mode...');

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
        print('Loaded ${questions.length} questions total');

      } else if (gameMode == GameMode.timeAttack) {
        // Time Attack: carica tutte le domande disponibili per il loop
        print('Loading all questions for Time Attack mode...');

        questions = await _quizService.fetchQuestionsDirectly(
          medium: medium,
          questionType: questionType,
          limit: 100,  // Prendi tutte le disponibili
        );

        _allQuestionsForLoop = List.from(questions);
        print('Loaded ${questions.length} questions for looping');

      } else {
        // Altre modalità: usa il numero standard
        questions = await _quizService.fetchQuestionsDirectly(
          medium: medium,
          questionType: questionType,
          limit: numberOfQuestions,
        );
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

        // Start timer for first question
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

  // Determina il numero di domande per modalità
  int _getQuestionsCountForMode(GameMode mode, QuestionType type) {
    switch (mode) {
      case GameMode.classic:
        return 15;  // Sempre 15 per Classic
      case GameMode.timeAttack:
        return 60;  // 60 domande per Time Attack (con loop)
      case GameMode.liar:
        return 15;  // 15 per Il Bugiardo
      case GameMode.zen:
        return 100; // Molte domande per Zen (tutte disponibili)
    }
  }

  // Submit answer for current question
  Future<AnswerResult> submitAnswer(dynamic answer) async {
    if (_currentSession == null || _currentSession!.isComplete) {
      // Se siamo in Time Attack e finiamo le domande, ricomincia il loop
      if (_currentGameMode == GameMode.timeAttack && _allQuestionsForLoop.isNotEmpty) {
        _handleTimeAttackLoop();
        return submitAnswer(answer);  // Riprova con la nuova domanda
      }

      return AnswerResult(
        isCorrect: false,
        xpEarned: 0,
        message: 'Sessione non valida',
      );
    }

    // Calculate response time
    final responseTime = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inMilliseconds / 1000.0
        : 10.0;

    // Per modalità "Il Bugiardo", inverti la risposta corretta
    dynamic correctAnswer = _currentSession!.currentQuestion?.correctAnswer;
    if (_currentGameMode == GameMode.liar && _currentSession!.currentQuestion?.type == QuestionType.truefalse) {
      // Inverti true/false per Il Bugiardo
      correctAnswer = !(correctAnswer as bool);
    }

    // Check if answer is correct
    final isCorrect = answer == correctAnswer;

    // Update streak
    if (isCorrect) {
      _correctStreak++;
    } else {
      _correctStreak = 0;

      // In modalità Liar, una risposta sbagliata termina il gioco
      if (_currentGameMode == GameMode.liar) {
        await _handleGameOver();
      }
    }

    // Submit to session
    _currentSession!.submitAnswer(
      answer: answer,
      isCorrect: isCorrect,
      responseTime: responseTime,
    );

    // Calculate XP earned for this question
    final xpEarned = isCorrect
        ? _currentSession!.answers.last.xpEarned
        : 0;

    // Get mascot message
    String? mascotMessage;
    if (isCorrect && _correctStreak >= 3) {
      final message = _mascotService.getEncouragingMessage(_correctStreak);
      mascotMessage = message.text;
    } else if (!isCorrect) {
      final message = _mascotService.getWrongAnswerMessage();
      mascotMessage = message.text;
    }

    // Check if quiz is complete
    if (_currentSession!.isComplete) {
      // In Time Attack, continua con il loop
      if (_currentGameMode == GameMode.timeAttack && _allQuestionsForLoop.isNotEmpty) {
        _handleTimeAttackLoop();
      } else {
        await _handleQuizComplete();
      }
    } else {
      // Start timer for next question
      _questionStartTime = DateTime.now();
    }

    notifyListeners();

    return AnswerResult(
      isCorrect: isCorrect,
      xpEarned: xpEarned,
      message: mascotMessage,
    );
  }

  // Gestisce il loop delle domande in Time Attack
  void _handleTimeAttackLoop() {
    if (_allQuestionsForLoop.isEmpty) return;

    // Ricomincia dal primo set di domande
    _loopIndex = 0;

    // Aggiungi nuove domande alla sessione corrente
    final newQuestions = List<Question>.from(_allQuestionsForLoop);
    _currentSession!.questions.addAll(newQuestions);

    print('Looping questions in Time Attack mode. Total questions now: ${_currentSession!.questions.length}');
  }

  // Handle game over (for Liar mode)
  Future<void> _handleGameOver() async {
    // Salva punteggio parziale e termina
    await _handleQuizComplete();
  }

  // Skip current question
  void skipQuestion() {
    if (_currentSession == null || _currentSession!.isComplete) return;

    _currentSession!.skipQuestion();
    _correctStreak = 0;

    if (_currentSession!.isComplete) {
      _handleQuizComplete();
    } else {
      _questionStartTime = DateTime.now();
    }

    notifyListeners();
  }

  // Handle quiz completion
  Future<void> _handleQuizComplete() async {
    if (_currentSession == null) return;

    final userId = _progressionController.currentUserId;
    if (userId == null) return;

    // Save session to history
    await _firestoreService.saveQuizSession(userId, _currentSession!);

    // Update user stats
    await _progressionController.addQuizSession(
      _currentSession!.medium,
      _currentSession!.totalXpEarned,
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
    if (_currentSession != null) {
      final userId = _progressionController.currentUserId;
      if (userId != null) {
        await _quizService.endSession(userId);
      }
      _currentSession = null;
      _correctStreak = 0;
      _allQuestionsForLoop.clear();
      _loopIndex = 0;
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

  @override
  void dispose() {
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