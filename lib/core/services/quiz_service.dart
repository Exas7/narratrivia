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
  final Map<MediumType, List<Question>> _questionsCache = {};

  // Sessione corrente
  QuizSession? _currentSession;

  // Get current session
  QuizSession? get currentSession => _currentSession;

  // Start a new quiz session
  Future<QuizSession> startQuizSession({
    required MediumType medium,
    required QuestionType questionType,
    int numberOfQuestions = 10,
    QuestionDifficulty? difficulty,
  }) async {
    // Generate session ID
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    // Fetch questions
    List<Question> questions = await _fetchQuestions(
      medium: medium,
      questionType: questionType,
      difficulty: difficulty,
      limit: numberOfQuestions,
    );

    // If not enough questions from database, use hardcoded ones
    if (questions.length < numberOfQuestions) {
      questions.addAll(_getHardcodedQuestions(
        medium: medium,
        questionType: questionType,
        needed: numberOfQuestions - questions.length,
      ));
    }

    // Shuffle questions for variety
    questions.shuffle(_random);

    // Create session
    _currentSession = QuizSession(
      sessionId: sessionId,
      medium: medium,
      questionType: questionType,
      questions: questions.take(numberOfQuestions).toList(),
    );

    return _currentSession!;
  }

  // Fetch questions from Firestore
  Future<List<Question>> _fetchQuestions({
    required MediumType medium,
    required QuestionType questionType,
    QuestionDifficulty? difficulty,
    required int limit,
  }) async {
    try {
      // Check cache first
      if (_questionsCache[medium] != null && _questionsCache[medium]!.isNotEmpty) {
        return _filterQuestions(
          _questionsCache[medium]!,
          questionType: questionType,
          difficulty: difficulty,
          limit: limit,
        );
      }

      // Fetch from Firestore
      final questions = await _firestoreService.getQuestions(
        medium: medium,
        type: questionType,
        difficulty: difficulty,
        limit: limit * 2, // Fetch more for variety
      );

      // Update cache
      _questionsCache[medium] = questions;

      return _filterQuestions(
        questions,
        questionType: questionType,
        difficulty: difficulty,
        limit: limit,
      );
    } catch (e) {
      // If error, return empty list (will use hardcoded)
      return [];
    }
  }

  // Filter questions based on criteria
  List<Question> _filterQuestions(
      List<Question> questions, {
        required QuestionType questionType,
        QuestionDifficulty? difficulty,
        required int limit,
      }) {
    var filtered = questions.where((q) => q.type == questionType);

    if (difficulty != null) {
      filtered = filtered.where((q) => q.difficulty == difficulty);
    }

    return filtered.take(limit).toList();
  }

  // Get hardcoded questions for testing
  List<Question> _getHardcodedQuestions({
    required MediumType medium,
    required QuestionType questionType,
    required int needed,
  }) {
    final questions = <Question>[];

    for (int i = 0; i < needed; i++) {
      questions.add(_generateHardcodedQuestion(
        medium: medium,
        type: questionType,
        index: i,
      ));
    }

    return questions;
  }

  // Generate a single hardcoded question
  Question _generateHardcodedQuestion({
    required MediumType medium,
    required QuestionType type,
    required int index,
  }) {
    switch (type) {
      case QuestionType.truefalse:
        return _generateTrueFalseQuestion(medium, index);
      case QuestionType.multiple:
        return _generateMultipleChoiceQuestion(medium, index);
      case QuestionType.uglyImages:
        return _generateUglyImagesQuestion(medium, index);
      case QuestionType.misleading:
        return _generateMisleadingQuestion(medium, index);
    }
  }

  // Generate True/False question
  Question _generateTrueFalseQuestion(MediumType medium, int index) {
    final questions = {
      MediumType.videogames: [
        'Mario è il protagonista di Super Mario Bros.',
        'Sonic è un personaggio Nintendo.',
        'Minecraft è stato creato da Mojang.',
        'Fortnite è un gioco single-player.',
        'The Legend of Zelda è ambientato a Hyrule.',
      ],
      MediumType.books: [
        'Harry Potter è stato scritto da J.K. Rowling.',
        'Il Signore degli Anelli è ambientato nella Terra di Mezzo.',
        '1984 è stato scritto da George Orwell.',
        'Romeo e Giulietta è una commedia.',
        'Don Chisciotte è stato scritto da Cervantes.',
      ],
      MediumType.movies: [
        'Titanic ha vinto l\'Oscar come miglior film.',
        'Star Wars è stato diretto da Steven Spielberg.',
        'Il Padrino è basato su un romanzo.',
        'Avatar è il film con maggior incasso di sempre.',
        'Pulp Fiction è diretto da Quentin Tarantino.',
      ],
    };

    final answers = {
      MediumType.videogames: [true, false, true, false, true],
      MediumType.books: [true, true, true, false, true],
      MediumType.movies: [true, false, true, true, true],
    };

    final mediumQuestions = questions[medium] ?? questions[MediumType.videogames]!;
    final mediumAnswers = answers[medium] ?? answers[MediumType.videogames]!;

    final questionIndex = index % mediumQuestions.length;

    return Question(
      id: 'hardcoded_tf_${medium.name}_$index',
      text: mediumQuestions[questionIndex],
      medium: medium,
      difficulty: QuestionDifficulty.medium,
      type: QuestionType.truefalse,
      correctAnswer: mediumAnswers[questionIndex],
      options: [true, false],
      metadata: {'language': 'it', 'isHardcoded': true},
    );
  }

  // Generate Multiple Choice question
  Question _generateMultipleChoiceQuestion(MediumType medium, int index) {
    final questions = {
      MediumType.videogames: [
        {
          'text': 'Chi è il protagonista di The Witcher 3?',
          'correct': 'Geralt di Rivia',
          'options': ['Geralt di Rivia', 'Ezio Auditore', 'Nathan Drake', 'Kratos'],
        },
        {
          'text': 'In quale anno è uscito il primo Super Mario Bros?',
          'correct': '1985',
          'options': ['1983', '1985', '1987', '1990'],
        },
      ],
      MediumType.books: [
        {
          'text': 'Chi ha scritto "Il Nome della Rosa"?',
          'correct': 'Umberto Eco',
          'options': ['Umberto Eco', 'Italo Calvino', 'Primo Levi', 'Alberto Moravia'],
        },
        {
          'text': 'Quale di questi NON è un romanzo di Agatha Christie?',
          'correct': 'Il Codice Da Vinci',
          'options': ['Dieci Piccoli Indiani', 'Assassinio sull\'Orient Express', 'Il Codice Da Vinci', 'Poirot a Styles Court'],
        },
      ],
      MediumType.movies: [
        {
          'text': 'Chi ha diretto "Inception"?',
          'correct': 'Christopher Nolan',
          'options': ['Christopher Nolan', 'Denis Villeneuve', 'David Fincher', 'Ridley Scott'],
        },
        {
          'text': 'Quale attore interpreta Iron Man nel MCU?',
          'correct': 'Robert Downey Jr.',
          'options': ['Chris Evans', 'Robert Downey Jr.', 'Chris Hemsworth', 'Mark Ruffalo'],
        },
      ],
    };

    final mediumQuestions = questions[medium] ?? questions[MediumType.videogames]!;
    final questionData = mediumQuestions[index % mediumQuestions.length];

    return Question(
      id: 'hardcoded_mc_${medium.name}_$index',
      text: questionData['text'] as String,
      medium: medium,
      difficulty: QuestionDifficulty.medium,
      type: QuestionType.multiple,
      correctAnswer: questionData['correct'],
      options: questionData['options'] as List<dynamic>,
      metadata: {'language': 'it', 'isHardcoded': true},
    );
  }

  // Generate Ugly Images question (text-based for now)
  Question _generateUglyImagesQuestion(MediumType medium, int index) {
    return Question(
      id: 'hardcoded_ui_${medium.name}_$index',
      text: 'Identifica il personaggio dalla descrizione mal disegnata: Un idraulico baffuto con cappello rosso che salta sui funghi.',
      medium: medium,
      difficulty: QuestionDifficulty.easy,
      type: QuestionType.uglyImages,
      correctAnswer: 'Mario',
      options: ['Mario', 'Luigi', 'Wario', 'Yoshi'],
      metadata: {'language': 'it', 'isHardcoded': true},
    );
  }

  // Generate Misleading Description question
  Question _generateMisleadingQuestion(MediumType medium, int index) {
    return Question(
      id: 'hardcoded_md_${medium.name}_$index',
      text: 'Un tizio verde molto arrabbiato che diventa più forte quando si arrabbia ancora di più. Odia i pantaloni.',
      medium: medium,
      difficulty: QuestionDifficulty.hard,
      type: QuestionType.misleading,
      correctAnswer: 'Hulk',
      options: ['Hulk', 'Shrek', 'Piccolo', 'Green Lantern'],
      metadata: {'language': 'it', 'isHardcoded': true},
    );
  }

  // Submit answer for current question
  bool submitAnswer(dynamic answer) {
    if (_currentSession == null || _currentSession!.isComplete) {
      return false;
    }

    final currentQuestion = _currentSession!.currentQuestion;
    if (currentQuestion == null) {
      return false;
    }

    // Check if answer is correct
    final isCorrect = answer == currentQuestion.correctAnswer;

    // Calculate response time (for now, use a random value)
    // In real implementation, this would be tracked by a timer
    final responseTime = 5.0 + _random.nextDouble() * 10;

    // Submit to session
    _currentSession!.submitAnswer(
      answer: answer,
      isCorrect: isCorrect,
      responseTime: responseTime,
    );

    return isCorrect;
  }

  // Skip current question
  void skipCurrentQuestion() {
    _currentSession?.skipQuestion();
  }

  // End current session
  Future<void> endSession(String userId) async {
    if (_currentSession == null) return;

    // Save session to Firestore
    await _firestoreService.saveQuizSession(userId, _currentSession!);

    // Clear current session
    _currentSession = null;
  }

  // Clear questions cache
  void clearCache() {
    _questionsCache.clear();
  }
}