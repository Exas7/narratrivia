// lib/controllers/quiz_controller.dart

import 'package:flutter/material.dart';
import '/core/models/questions.dart';
import '/core/models/quiz_session.dart';
import '/core/models/medium_type.dart';
import '/core/services/quiz_service.dart';
import '/core/services/firestore_service.dart';
import '/core/services/mascot_service.dart';
import 'progression_controller.dart';

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

  // Settings for current medium
  Map<String, dynamic> _mediumSettings = {};

  // Getters
  QuizSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Question? get currentQuestion => _currentSession?.currentQuestion;
  int get correctStreak => _correctStreak;
  Map<String, dynamic> get mediumSettings => _mediumSettings;

  // Initialize controller
  Future<void> initialize(String userId) async {
    await _progressionController.initialize(userId);
    await _mascotService.initialize();
  }

  // Load medium settings
  Future<void> loadMediumSettings(MediumType medium) async {
    // Load from SharedPreferences or use defaults
    _mediumSettings = {
      'difficulty': QuestionDifficulty.medium,
      'numberOfQuestions': 10,
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
    // Save to SharedPreferences
    notifyListeners();
  }

  // Start a new quiz
  Future<bool> startQuiz({
    required MediumType medium,
    required QuestionType questionType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _correctStreak = 0;
    notifyListeners();

    try {
      // Get settings
      final numberOfQuestions = _mediumSettings['numberOfQuestions'] ?? 10;
      final difficulty = _mediumSettings['difficulty'] as QuestionDifficulty?;

      // Check if this is first quiz
      final firstQuizMessage = await _mascotService.checkFirstQuiz();
      if (firstQuizMessage != null) {
        // Show mascot message (handled by UI)
      }

      // Start quiz session
      _currentSession = await _quizService.startQuizSession(
        medium: medium,
        questionType: questionType,
        numberOfQuestions: numberOfQuestions,
        difficulty: difficulty,
      );

      // Start timer for first question
      _questionStartTime = DateTime.now();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Errore nel caricamento del quiz: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Submit answer for current question
  Future<AnswerResult> submitAnswer(dynamic answer) async {
    if (_currentSession == null || _currentSession!.isComplete) {
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

    // Check if answer is correct
    final isCorrect = answer == _currentSession!.currentQuestion?.correctAnswer;

    // Update streak
    if (isCorrect) {
      _correctStreak++;
    } else {
      _correctStreak = 0;
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
      await _handleQuizComplete();
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
      notifyListeners();
    }
  }

  // Get game history for medium
  Future<List<Map<String, dynamic>>> getGameHistory(MediumType medium) async {
    final userId = _progressionController.currentUserId;
    if (userId == null) return [];

    // For now, return mock data
    // In production, this would fetch from Firestore
    return [
      {
        'startTime': DateTime.now().subtract(const Duration(days: 1)),
        'scorePercentage': 85.0,
        'totalXpEarned': 150,
        'questionType': 'multiple',
        'correctAnswers': 17,
        'totalQuestions': 20,
        'sessionDuration': 245,
        'averageResponseTime': 8.5,
      },
      {
        'startTime': DateTime.now().subtract(const Duration(days: 2)),
        'scorePercentage': 70.0,
        'totalXpEarned': 100,
        'questionType': 'truefalse',
        'correctAnswers': 7,
        'totalQuestions': 10,
        'sessionDuration': 120,
        'averageResponseTime': 6.2,
      },
    ];
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