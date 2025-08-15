// lib/core/services/quiz_service.dart

import 'dart:math';
import '../models/questions.dart';
import '../models/quiz_session.dart';
import '../models/medium_type.dart';
import 'firestore_service.dart';

class QuizService {
  final FirestoreService _firestoreService = FirestoreService();
  final Random _random = Random();

  // Cache per domande locali (per offline mode)
  final Map<String, List<Question>> _questionsCache = {};

  // Sessione corrente
  QuizSession? _currentSession;

  // Get current session
  QuizSession? get currentSession => _currentSession;

  // Start a new quiz session (metodo legacy per compatibilità)
  Future<QuizSession> startQuizSession({
    required MediumType medium,
    required QuestionType questionType,
    int numberOfQuestions = 10,
    QuestionDifficulty? difficulty,
    String? opera,
  }) async {
    print('Starting quiz session - Medium: $medium, Type: $questionType, Questions: $numberOfQuestions');

    // Generate session ID
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    // Test Firebase connection first
    await _firestoreService.testFirebaseConnection();

    // Fetch questions from Firestore
    List<Question> questions = await _fetchQuestions(
      medium: medium,
      questionType: questionType,
      difficulty: difficulty,
      opera: opera,
      limit: numberOfQuestions,
    );

    // Se non abbiamo abbastanza domande, notifica l'utente
    if (questions.isEmpty) {
      print('⚠️ ATTENZIONE: Nessuna domanda trovata nel database!');
      throw Exception('Nessuna domanda disponibile per questa configurazione. Verifica che il database contenga domande.');
    }

    if (questions.length < numberOfQuestions) {
      print('⚠️ Trovate solo ${questions.length} domande su $numberOfQuestions richieste');
    }

    // Create session
    _currentSession = QuizSession(
      sessionId: sessionId,
      medium: medium,
      questionType: questionType,
      questions: questions,
    );

    print('✅ Quiz session created with ${questions.length} questions');
    return _currentSession!;
  }

  // Nuovo metodo per il fetch diretto delle domande con controllo difficoltà
  Future<List<Question>> fetchQuestionsDirectly({
    required MediumType medium,
    required QuestionType questionType,
    QuestionDifficulty? difficulty,
    String? opera,
    int limit = 10,
  }) async {
    try {
      print('🎯 Fetching questions directly - Type: ${questionType.name}, Difficulty: ${difficulty?.name ?? "all"}, Limit: $limit');

      // Fetch from Firestore con i parametri specifici
      final questions = await _firestoreService.getQuestions(
        medium: medium,
        type: questionType,
        difficulty: difficulty,
        opera: opera,
        limit: limit,
        randomize: true,
      );

      if (questions.isEmpty) {
        print('❌ No questions found for difficulty: ${difficulty?.name}');
      } else {
        print('✅ Found ${questions.length} questions for difficulty: ${difficulty?.name}');
      }

      return questions;

    } catch (e) {
      print('❌ Error in fetchQuestionsDirectly: $e');
      return [];
    }
  }

  // Fetch questions from Firestore (metodo privato interno)
  Future<List<Question>> _fetchQuestions({
    required MediumType medium,
    required QuestionType questionType,
    QuestionDifficulty? difficulty,
    String? opera,
    required int limit,
  }) async {
    try {
      // Creiamo una chiave cache unica
      final cacheKey = '${medium.name}_${questionType.name}_${difficulty?.name ?? "all"}_${opera ?? "all"}';

      // Check cache first (solo se abbiamo già domande in cache)
      if (_questionsCache.containsKey(cacheKey) && _questionsCache[cacheKey]!.isNotEmpty) {
        print('📦 Using cached questions for $cacheKey');
        final cachedQuestions = List<Question>.from(_questionsCache[cacheKey]!);
        cachedQuestions.shuffle(_random);
        return cachedQuestions.take(limit).toList();
      }

      print('🔍 Fetching questions from Firestore...');

      // Fetch from Firestore
      final questions = await _firestoreService.getQuestions(
        medium: medium,
        type: questionType,
        difficulty: difficulty,
        opera: opera,
        limit: limit,
        randomize: true,
      );

      if (questions.isNotEmpty) {
        // Update cache
        _questionsCache[cacheKey] = questions;
        print('✅ Fetched ${questions.length} questions from Firestore');
      } else {
        print('❌ No questions found in Firestore for this configuration');
      }

      return questions;

    } catch (e) {
      print('❌ Error fetching questions: $e');
      throw Exception('Errore nel caricamento delle domande: $e');
    }
  }

  // Submit answer for current question - FIXED FOR MC
  bool submitAnswer(dynamic answer) {
    if (_currentSession == null || _currentSession!.isComplete) {
      return false;
    }

    final currentQuestion = _currentSession!.currentQuestion;
    if (currentQuestion == null) {
      return false;
    }

    bool isCorrect = false;

    // Per true/false, confronta booleani
    if (currentQuestion.type == QuestionType.truefalse) {
      isCorrect = answer == currentQuestion.correctAnswer;
      print('TF Answer check: User answered $answer, correct was ${currentQuestion.correctAnswer}, result: $isCorrect');
    }
    // Per multiple choice - FIX PRINCIPALE
    else if (currentQuestion.type == QuestionType.multiple) {
      // Il database salva correctAnswer come indice numerico (0-3)
      if (currentQuestion.correctAnswer is int) {
        final correctIndex = currentQuestion.correctAnswer as int;

        // Se l'utente ha passato l'indice
        if (answer is int) {
          isCorrect = answer == correctIndex;
        }
        // Se l'utente ha passato la stringa dell'opzione
        else if (answer is String) {
          // Trova l'indice dell'opzione selezionata
          final selectedIndex = currentQuestion.options.indexOf(answer);
          isCorrect = selectedIndex == correctIndex;
        }

        print('MC Answer check:');
        print('  - Correct index: $correctIndex');
        print('  - Correct option: ${currentQuestion.options[correctIndex]}');
        print('  - User answer: $answer');
        print('  - Result: $isCorrect');
      }
      // Fallback se correctAnswer è una stringa (vecchio formato)
      else if (currentQuestion.correctAnswer is String) {
        isCorrect = answer.toString() == currentQuestion.correctAnswer;
      }
    }

    // Calculate response time (per ora uso un valore casuale, in produzione sarebbe tracciato)
    final responseTime = 5.0 + _random.nextDouble() * 10;

    // Submit to session
    _currentSession!.submitAnswer(
      answer: answer,
      isCorrect: isCorrect,
      responseTime: responseTime,
    );

    print('Answer submitted - Correct: $isCorrect, Progress: ${_currentSession!.currentQuestionIndex}/${_currentSession!.totalQuestions}');
    return isCorrect;
  }

  // Skip current question
  void skipCurrentQuestion() {
    _currentSession?.skipQuestion();
    print('Question skipped - Progress: ${_currentSession?.currentQuestionIndex}/${_currentSession?.totalQuestions}');
  }

  // End current session
  Future<void> endSession(String userId) async {
    if (_currentSession == null) return;

    // Save session to Firestore
    await _firestoreService.saveQuizSession(userId, _currentSession!);

    // Clear current session
    _currentSession = null;
    print('Session ended and saved');
  }

  // Clear questions cache
  void clearCache() {
    _questionsCache.clear();
    print('🗑️ Questions cache cleared');
  }

  // Get available operas for a medium
  Future<List<String>> getAvailableOperas(MediumType medium) async {
    return await _firestoreService.getAvailableOperas(medium);
  }

  // Get all questions for a medium (for Zen mode)
  Future<List<Question>> getAllQuestionsForMedium(
      MediumType medium, {
        QuestionType? questionType,
      }) async {
    try {
      print('📚 Fetching all questions for medium: ${medium.name}, type: ${questionType?.name ?? "all"}');

      // Fetch all available questions
      final questions = await _firestoreService.getQuestions(
        medium: medium,
        type: questionType,  // Può essere null per prendere tutti i tipi
        difficulty: null,  // Tutte le difficoltà
        limit: 200,  // Limite alto per prendere tutte
        randomize: true,
      );

      print('✅ Found ${questions.length} total questions for ${medium.name}');
      return questions;

    } catch (e) {
      print('❌ Error fetching all questions: $e');
      return [];
    }
  }
}