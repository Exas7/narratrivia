// lib/core/models/quiz_session.dart

import 'questions.dart';
import 'medium_type.dart';

class QuizSession {
  final String sessionId;
  final MediumType medium;
  final QuestionType questionType;
  final List<Question> questions;
  final List<QuestionAnswer> answers;
  final DateTime startTime;
  DateTime? endTime;
  int currentQuestionIndex;
  int correctAnswers;
  int totalXpEarned;
  double averageResponseTime;
  int currentStreak;
  double timeBonus;
  double streakMultiplier;

  QuizSession({
    required this.sessionId,
    required this.medium,
    required this.questionType,
    required this.questions,
    List<QuestionAnswer>? answers,
    DateTime? startTime,
    this.endTime,
    this.currentQuestionIndex = 0,
    this.correctAnswers = 0,
    this.totalXpEarned = 0,
    this.averageResponseTime = 0.0,
    this.currentStreak = 0,
    this.timeBonus = 1.0,
    this.streakMultiplier = 1.0,
  }) : answers = answers ?? [],
        startTime = startTime ?? DateTime.now();

  // Get current question
  Question? get currentQuestion {
    if (currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null;
  }

  // Check if quiz is complete
  bool get isComplete => currentQuestionIndex >= questions.length;

  // Get total questions
  int get totalQuestions => questions.length;

  // Get score percentage
  double get scorePercentage {
    if (totalQuestions == 0) return 0;
    return (correctAnswers / totalQuestions) * 100;
  }

  // Calculate XP for a question answer
  int calculateQuestionXP(Question question, double responseTime) {
    int baseXP = question.baseXP;
    double difficultyMult = question.difficultyMultiplier;

    // Calculate time bonus (1.0 to 1.5 based on speed)
    double timeBonusCalc = 1.0;
    double maxTime = question.timerDuration.toDouble();
    if (responseTime < maxTime * 0.3) {
      timeBonusCalc = 1.5; // Very fast answer
    } else if (responseTime < maxTime * 0.6) {
      timeBonusCalc = 1.3; // Fast answer
    } else if (responseTime < maxTime * 0.9) {
      timeBonusCalc = 1.1; // Normal speed
    }

    // Apply all multipliers
    int finalXP = (baseXP * difficultyMult * timeBonusCalc * streakMultiplier).round();

    return finalXP;
  }

  // Submit an answer for the current question
  void submitAnswer({
    required dynamic answer,
    required bool isCorrect,
    required double responseTime,
  }) {
    if (currentQuestion == null) return;

    // Create answer record
    final questionAnswer = QuestionAnswer(
      questionId: currentQuestion!.id,
      questionIndex: currentQuestionIndex,
      userAnswer: answer,
      correctAnswer: currentQuestion!.correctAnswer,
      isCorrect: isCorrect,
      responseTime: responseTime,
      xpEarned: 0,
    );

    // Calculate XP if correct
    if (isCorrect) {
      correctAnswers++;
      currentStreak++;
      questionAnswer.xpEarned = calculateQuestionXP(currentQuestion!, responseTime);
      totalXpEarned += questionAnswer.xpEarned;

      // Update streak multiplier (max 2.0 at 10 streak)
      streakMultiplier = 1.0 + (currentStreak * 0.1).clamp(0.0, 1.0);
    } else {
      currentStreak = 0;
      streakMultiplier = 1.0;
    }

    // Add answer to list
    answers.add(questionAnswer);

    // Update average response time
    double totalTime = answers.fold(0.0, (total, a) => total + a.responseTime);
    averageResponseTime = totalTime / answers.length;

    // Move to next question
    currentQuestionIndex++;

    // Mark as complete if finished
    if (isComplete) {
      endTime = DateTime.now();
    }
  }

  // Skip current question (counts as wrong)
  void skipQuestion() {
    submitAnswer(
      answer: null,
      isCorrect: false,
      responseTime: currentQuestion?.timerDuration.toDouble() ?? 20.0,
    );
  }

  // Get session duration in seconds
  int get sessionDuration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime).inSeconds;
  }

  // Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'medium': medium.name,
      'questionType': questionType.name,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'scorePercentage': scorePercentage,
      'totalXpEarned': totalXpEarned,
      'averageResponseTime': averageResponseTime,
      'sessionDuration': sessionDuration,
      'startTime': startTime,
      'endTime': endTime,
      'answers': answers.map((a) => a.toMap()).toList(),
    };
  }
}

// Class to store individual question answers
class QuestionAnswer {
  final String questionId;
  final int questionIndex;
  final dynamic userAnswer;
  final dynamic correctAnswer;
  final bool isCorrect;
  final double responseTime;
  int xpEarned;

  QuestionAnswer({
    required this.questionId,
    required this.questionIndex,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.responseTime,
    this.xpEarned = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'questionIndex': questionIndex,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'responseTime': responseTime,
      'xpEarned': xpEarned,
    };
  }
}