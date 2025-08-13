// lib/core/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/questions.dart';
import '../models/quiz_session.dart';
import '../models/user_stats.dart';
import '../models/medium_type.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _questionsCollection => _firestore.collection('questions');
  CollectionReference get _userStatsCollection => _firestore.collection('userStats');
  CollectionReference get _gameHistoryCollection => _firestore.collection('gameHistory');

  // --- QUESTIONS OPERATIONS ---

  // Get questions from Firestore
  Future<List<Question>> getQuestions({
    required MediumType medium,
    QuestionType? type,
    QuestionDifficulty? difficulty,
    String? opera,  // NUOVO: parametro per filtrare per opera
    int limit = 10,
    bool randomize = true,  // NUOVO: per randomizzare le domande
  }) async {
    try {
      Query query = _questionsCollection;

      // Filter by medium (nel DB è salvato come stringa diretta, non medium.name)
      query = query.where('medium', isEqualTo: 'videogames');  // Per ora solo videogames

      // Filter by type if specified
      if (type != null) {
        // Nel database è 'truefalse' o 'multiplechoice'
        String dbType = type == QuestionType.truefalse ? 'truefalse' :
        type == QuestionType.multiple ? 'multiplechoice' :
        type.name;
        query = query.where('type', isEqualTo: dbType);
      }

      // Filter by difficulty if specified (nel DB è numero diretto 1, 2, 3)
      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty.value);
      }

      // Filter by opera if specified (es: 'dragon_quest_8')
      if (opera != null && opera.isNotEmpty) {
        query = query.where('opera', isEqualTo: opera);
      }

      // Filter by active status
      query = query.where('metadata.isActive', isEqualTo: true);

      // Se vogliamo randomizzare, prendiamo più domande e le mescoliamo
      if (randomize) {
        query = query.limit(limit * 3);  // Prendi il triplo per avere varietà
      } else {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      print('Firestore query executed. Documents found: ${snapshot.docs.length}');

      // Converti i documenti in oggetti Question
      List<Question> questions = [];
      for (var doc in snapshot.docs) {
        try {
          final question = Question.fromFirestore(doc);
          questions.add(question);
          print('Loaded question: ${question.text.substring(0, 50 < question.text.length ? 50 : question.text.length)}...');
        } catch (e) {
          print('Error parsing question ${doc.id}: $e');
          print('Document data: ${doc.data()}');
        }
      }

      // Se abbiamo bisogno di randomizzare, mescoliamo e prendiamo solo il numero richiesto
      if (randomize && questions.length > limit) {
        questions.shuffle();
        questions = questions.take(limit).toList();
      }

      print('Returning ${questions.length} questions');
      return questions;

    } catch (e) {
      print('Error fetching questions from Firestore: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Get all available operas for a medium
  Future<List<String>> getAvailableOperas(MediumType medium) async {
    try {
      final snapshot = await _questionsCollection
          .where('medium', isEqualTo: medium == MediumType.videogames ? 'videogames' : medium.name)
          .where('metadata.isActive', isEqualTo: true)
          .get();

      Set<String> operas = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['opera'] != null) {
          operas.add(data['opera']);
        }
      }

      return operas.toList()..sort();
    } catch (e) {
      print('Error fetching operas: $e');
      return [];
    }
  }

  // Add a new question (for admin use)
  Future<void> addQuestion(Question question) async {
    try {
      await _questionsCollection.add(question.toFirestore());
    } catch (e) {
      print('Error adding question: $e');
    }
  }

  // Update question statistics after being answered
  Future<void> updateQuestionStats(String questionId) async {
    try {
      await _questionsCollection.doc(questionId).update({
        'metadata.timesAnswered': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error updating question stats: $e');
    }
  }

  // --- USER STATS OPERATIONS ---

  // Get user stats
  Future<UserStats?> getUserStats(String userId) async {
    try {
      final doc = await _userStatsCollection.doc(userId).get();

      if (!doc.exists) {
        // Create new user stats if doesn't exist
        final newStats = UserStats(userId: userId);
        await _userStatsCollection.doc(userId).set(newStats.toFirestore());
        return newStats;
      }

      return UserStats.fromFirestore(doc);
    } catch (e) {
      print('Error fetching user stats: $e');
      return null;
    }
  }

  // Update user stats
  Future<void> updateUserStats(UserStats stats) async {
    try {
      await _userStatsCollection
          .doc(stats.userId)
          .update(stats.toFirestore());
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }

  // Update specific medium progress
  Future<void> updateMediumProgress(
      String userId,
      MediumType medium,
      MediumProgress progress,
      ) async {
    try {
      await _userStatsCollection.doc(userId).update({
        'mediumProgress.${medium.name}': progress.toMap(),
      });
    } catch (e) {
      print('Error updating medium progress: $e');
    }
  }

  // Add achievement to user
  Future<void> addAchievement(String userId, Achievement achievement) async {
    try {
      await _userStatsCollection.doc(userId).update({
        'achievements': FieldValue.arrayUnion([achievement.toMap()]),
      });
    } catch (e) {
      print('Error adding achievement: $e');
    }
  }

  // Update streak
  Future<void> updateStreak(String userId, int streak, DateTime lastPlayDate) async {
    try {
      await _userStatsCollection.doc(userId).update({
        'currentStreak': streak,
        'lastPlayDate': Timestamp.fromDate(lastPlayDate),
      });
    } catch (e) {
      print('Error updating streak: $e');
    }
  }

  // --- GAME HISTORY OPERATIONS ---

  // Save quiz session to history
  Future<void> saveQuizSession(String userId, QuizSession session) async {
    try {
      await _gameHistoryCollection
          .doc(userId)
          .collection('sessions')
          .doc(session.sessionId)
          .set(session.toFirestore());
    } catch (e) {
      print('Error saving quiz session: $e');
    }
  }

  // Get user's game history
  Future<List<Map<String, dynamic>>> getGameHistory(
      String userId, {
        int limit = 20,
      }) async {
    try {
      final snapshot = await _gameHistoryCollection
          .doc(userId)
          .collection('sessions')
          .orderBy('startTime', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching game history: $e');
      return [];
    }
  }

  // Get statistics for a specific medium
  Future<Map<String, dynamic>> getMediumStatistics(
      String userId,
      MediumType medium,
      ) async {
    try {
      final snapshot = await _gameHistoryCollection
          .doc(userId)
          .collection('sessions')
          .where('medium', isEqualTo: medium.name)
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'totalGames': 0,
          'totalQuestions': 0,
          'correctAnswers': 0,
          'totalXP': 0,
          'averageScore': 0.0,
          'bestScore': 0,
        };
      }

      int totalGames = snapshot.docs.length;
      int totalQuestions = 0;
      int correctAnswers = 0;
      int totalXP = 0;
      double bestScore = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        totalQuestions += (data['totalQuestions'] as int?) ?? 0;
        correctAnswers += (data['correctAnswers'] as int?) ?? 0;
        totalXP += (data['totalXpEarned'] as int?) ?? 0;

        final score = (data['scorePercentage'] as num?)?.toDouble() ?? 0.0;
        if (score > bestScore) {
          bestScore = score;
        }
      }

      return {
        'totalGames': totalGames,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'totalXP': totalXP,
        'averageScore': totalQuestions > 0
            ? (correctAnswers / totalQuestions * 100)
            : 0.0,
        'bestScore': bestScore,
      };
    } catch (e) {
      print('Error fetching medium statistics: $e');
      return {};
    }
  }

  // --- WEEKLY CHALLENGES ---

  // Get current weekly challenge
  Future<WeeklyChallenge?> getCurrentWeeklyChallenge() async {
    try {
      // For now, return a hardcoded challenge
      // In production, this would fetch from a challenges collection
      final now = DateTime.now();
      final nextMonday = now.add(Duration(days: (8 - now.weekday) % 7));

      return WeeklyChallenge(
        id: 'weekly_${now.year}_${now.weekday}',
        description: 'Completa 20 quiz di Scelta Multipla in almeno 3 medium diversi',
        targetValue: 20,
        expiresAt: nextMonday,
      );
    } catch (e) {
      print('Error fetching weekly challenge: $e');
      return null;
    }
  }

  // Update weekly challenge progress
  Future<void> updateWeeklyChallengeProgress(
      String userId,
      WeeklyChallenge challenge,
      ) async {
    try {
      await _userStatsCollection.doc(userId).update({
        'weeklyChallenge': challenge.toMap(),
      });
    } catch (e) {
      print('Error updating weekly challenge: $e');
    }
  }

  // --- LEADERBOARD ---

  // Get global leaderboard
  Future<List<Map<String, dynamic>>> getGlobalLeaderboard({
    int limit = 50,
  }) async {
    try {
      final snapshot = await _userStatsCollection
          .orderBy('globalXP', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'userId': doc.id,
          'globalXP': data['globalXP'],
          'globalLevel': data['globalLevel'],
          // Add username when authentication is implemented
        };
      }).toList();
    } catch (e) {
      print('Error fetching leaderboard: $e');
      return [];
    }
  }

  // Get medium-specific leaderboard
  Future<List<Map<String, dynamic>>> getMediumLeaderboard(
      MediumType medium, {
        int limit = 50,
      }) async {
    try {
      final snapshot = await _userStatsCollection
          .orderBy('mediumProgress.${medium.name}.xp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final mediumData = data['mediumProgress']?[medium.name] ?? {};

        return {
          'userId': doc.id,
          'xp': mediumData['xp'] ?? 0,
          'level': mediumData['level'] ?? 1,
          'accuracy': mediumData['accuracy'] ?? 0.0,
        };
      }).toList();
    } catch (e) {
      print('Error fetching medium leaderboard: $e');
      return [];
    }
  }

  // --- TEST CONNECTION ---

  // Test Firebase connection and queries
  Future<void> testFirebaseConnection() async {
    try {
      print('Testing Firebase connection...');

      // Test 1: Basic connection
      final testQuery = await _questionsCollection.limit(1).get();
      print('✅ Firebase connected! Found ${testQuery.docs.length} test document(s)');

      // Test 2: Count total questions
      final allQuestions = await _questionsCollection.get();
      print('📊 Total questions in database: ${allQuestions.docs.length}');

      // Test 3: Count by type
      final trueFalse = await _questionsCollection
          .where('type', isEqualTo: 'truefalse')
          .get();
      final multiple = await _questionsCollection
          .where('type', isEqualTo: 'multiplechoice')
          .get();

      print('📝 True/False questions: ${trueFalse.docs.length}');
      print('📝 Multiple choice questions: ${multiple.docs.length}');

      // Test 4: Check first question structure
      if (allQuestions.docs.isNotEmpty) {
        final firstDoc = allQuestions.docs.first;
        final data = firstDoc.data() as Map<String, dynamic>;
        print('🔍 Sample question structure:');
        print('   - Type: ${data['type']}');
        print('   - Medium: ${data['medium']}');
        print('   - Opera: ${data['opera']}');
        print('   - Difficulty: ${data['difficulty']}');
        print('   - Has statement: ${data['statement'] != null}');
        print('   - Has question: ${data['question'] != null}');
      }

    } catch (e) {
      print('❌ Firebase connection error: $e');
    }
  }
}