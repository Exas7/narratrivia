// lib/controllers/progression_controller.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/core/models/user_stats.dart';
import '/core/models/medium_type.dart';
import '/core/services/firestore_service.dart';
import '/core/services/mascot_service.dart';

class ProgressionController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final MascotService _mascotService = MascotService();

  // User data
  String? _currentUserId;
  UserStats? _userStats;
  WeeklyChallenge? _weeklyChallenge;

  // Local cache
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  bool _isLoading = false;

  // Getters
  String? get currentUserId => _currentUserId;
  UserStats? get userStats => _userStats;
  WeeklyChallenge? get weeklyChallenge => _weeklyChallenge;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // Level thresholds for titles
  static const Map<int, String> levelTitles = {
    1: 'Principiante',
    5: 'Novizio',
    10: 'Apprendista',
    25: 'Esperto',
    50: 'Maestro',
    75: 'Gran Maestro',
    100: 'Leggenda',
    105: 'Mitico',
  };

  // Initialize controller
  Future<void> initialize(String userId) async {
    if (_isInitialized && _currentUserId == userId) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentUserId = userId;
      _prefs = await SharedPreferences.getInstance();

      // Load user stats from Firestore
      _userStats = await _firestoreService.getUserStats(userId);

      // Initialize stats if new user
      if (_userStats == null) {
        _userStats = UserStats(userId: userId);
        await _firestoreService.updateUserStats(_userStats!);
      }

      // Check and update streak
      _updateStreak();

      // Load weekly challenge
      _weeklyChallenge = await _firestoreService.getCurrentWeeklyChallenge();

      // Check if challenge is expired
      if (_weeklyChallenge != null && _weeklyChallenge!.isExpired) {
        // Reset weekly challenge
        _weeklyChallenge = await _firestoreService.getCurrentWeeklyChallenge();
      }

      _isInitialized = true;
    } catch (e) {
      print('Error initializing progression controller: $e');
      // Create default offline stats
      _userStats = UserStats(userId: userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update streak
  void _updateStreak() {
    if (_userStats == null) return;

    final now = DateTime.now();
    final lastPlayDate = _userStats!.lastPlayDate;

    if (lastPlayDate != null) {
      final daysSinceLastPlay = now.difference(lastPlayDate).inDays;

      if (daysSinceLastPlay == 1) {
        // Consecutive day - increase streak
        _userStats!.currentStreak++;

        // Check for streak milestones
        final message = _mascotService.checkStreakMilestone(_userStats!.currentStreak);
        if (message != null) {
          // Show mascot message (handled by UI)
        }
      } else if (daysSinceLastPlay > 1) {
        // Streak broken - reset to 1
        _userStats!.currentStreak = 1;
      }
      // If same day (daysSinceLastPlay == 0), streak stays the same
    } else {
      // First time playing
      _userStats!.currentStreak = 1;
    }

    _userStats!.lastPlayDate = now;
  }

  // Add XP and update level
  Future<void> addXP(int xp, MediumType medium) async {
    if (_userStats == null || _currentUserId == null) return;

    final oldGlobalLevel = _userStats!.globalLevel;
    final oldMediumLevel = _userStats!.mediumProgress[medium]?.level ?? 1;

    // Add XP
    _userStats!.addXP(xp, medium);

    // Check for level up
    if (_userStats!.globalLevel > oldGlobalLevel) {
      final message = _mascotService.checkLevelUp(oldGlobalLevel, _userStats!.globalLevel);
      if (message != null) {
        // Show mascot message (handled by UI)
      }

      // Check for title unlock
      final newTitle = getTitle(_userStats!.globalLevel);
      final oldTitle = getTitle(oldGlobalLevel);
      if (newTitle != oldTitle) {
        // Title unlocked! (handled by UI)
      }
    }

    // Check for medium level up
    final newMediumLevel = _userStats!.mediumProgress[medium]?.level ?? 1;
    if (newMediumLevel > oldMediumLevel) {
      // Medium level up! (handled by UI)
    }

    // Update Firestore
    await _firestoreService.updateUserStats(_userStats!);

    notifyListeners();
  }

  // Add quiz session results
  Future<void> addQuizSession(
      MediumType medium,
      int xpEarned,
      int correctAnswers,
      int totalQuestions,
      ) async {
    if (_userStats == null || _currentUserId == null) return;

    // Update medium progress
    final progress = _userStats!.mediumProgress[medium];
    if (progress != null) {
      progress.questionsAnswered += totalQuestions;
      progress.correctAnswers += correctAnswers;
    }

    // Add XP
    await addXP(xpEarned, medium);

    // Update weekly challenge if applicable
    if (_weeklyChallenge != null && !_weeklyChallenge!.completed) {
      // Check if challenge conditions are met
      // For now, simple increment
      _weeklyChallenge!.currentProgress++;

      if (_weeklyChallenge!.currentProgress >= _weeklyChallenge!.targetValue) {
        _weeklyChallenge!.completed = true;

        // Add bonus XP
        await addXP(500, medium);

        // Show completion message
        final message = _mascotService.checkWeeklyChallengeComplete(_weeklyChallenge!);
        if (message != null) {
          // Show mascot message (handled by UI)
        }
      }

      // Update Firestore
      await _firestoreService.updateWeeklyChallengeProgress(
        _currentUserId!,
        _weeklyChallenge!,
      );
    }

    notifyListeners();
  }

  // Check and unlock achievements
  Future<List<Achievement>> checkAchievements() async {
    if (_userStats == null || _currentUserId == null) return [];

    final newAchievements = _userStats!.checkAchievements();

    // Save to Firestore if new achievements
    if (newAchievements.isNotEmpty) {
      for (final achievement in newAchievements) {
        await _firestoreService.addAchievement(_currentUserId!, achievement);
      }
    }

    notifyListeners();
    return newAchievements;
  }

  // Get current title based on level
  String getTitle(int level) {
    String title = 'Principiante';

    for (final entry in levelTitles.entries) {
      if (level >= entry.key) {
        title = entry.value;
      } else {
        break;
      }
    }

    return title;
  }

  // Get current title
  String get currentTitle => getTitle(_userStats?.globalLevel ?? 1);

  // Get progress to next level
  double get progressToNextLevel {
    if (_userStats == null) return 0;
    return _userStats!.levelProgress;
  }

  // Get XP needed for next level
  int get xpForNextLevel {
    if (_userStats == null) return 100;
    return _userStats!.xpForNextLevel;
  }

  // Get medium statistics
  Map<String, dynamic> getMediumStats(MediumType medium) {
    if (_userStats == null) return {};

    final progress = _userStats!.mediumProgress[medium];
    if (progress == null) return {};

    return {
      'level': progress.level,
      'xp': progress.xp,
      'accuracy': progress.accuracy,
      'questionsAnswered': progress.questionsAnswered,
      'correctAnswers': progress.correctAnswers,
      'favoriteMode': progress.favoriteMode,
    };
  }

  // Get global statistics
  Map<String, dynamic> getGlobalStats() {
    if (_userStats == null) return {};

    int totalQuestions = 0;
    int totalCorrect = 0;

    for (final progress in _userStats!.mediumProgress.values) {
      totalQuestions += progress.questionsAnswered;
      totalCorrect += progress.correctAnswers;
    }

    return {
      'globalLevel': _userStats!.globalLevel,
      'globalXP': _userStats!.globalXP,
      'currentStreak': _userStats!.currentStreak,
      'totalQuestions': totalQuestions,
      'totalCorrect': totalCorrect,
      'globalAccuracy': totalQuestions > 0
          ? (totalCorrect / totalQuestions * 100).round()
          : 0,
      'achievementsCount': _userStats!.achievements.length,
      'title': currentTitle,
    };
  }

  // Get leaderboard position
  Future<int?> getLeaderboardPosition() async {
    if (_currentUserId == null) return null;

    final leaderboard = await _firestoreService.getGlobalLeaderboard();

    for (int i = 0; i < leaderboard.length; i++) {
      if (leaderboard[i]['userId'] == _currentUserId) {
        return i + 1;
      }
    }

    return null;
  }

  // Reset daily messages (call on app start)
  void resetDailyMessages() {
    _mascotService.resetDailyMessages();
  }

  // Save local progress (for offline mode)
  Future<void> saveLocalProgress() async {
    if (_userStats == null) return;

    await _prefs.setInt('localGlobalXP', _userStats!.globalXP);
    await _prefs.setInt('localGlobalLevel', _userStats!.globalLevel);
    await _prefs.setInt('localStreak', _userStats!.currentStreak);

    // Save last play date
    if (_userStats!.lastPlayDate != null) {
      await _prefs.setString(
        'localLastPlayDate',
        _userStats!.lastPlayDate!.toIso8601String(),
      );
    }
  }

  // Load local progress (for offline mode)
  Future<void> loadLocalProgress() async {
    if (_userStats == null) return;

    final localXP = _prefs.getInt('localGlobalXP');
    final localLevel = _prefs.getInt('localGlobalLevel');
    final localStreak = _prefs.getInt('localStreak');
    final localLastPlay = _prefs.getString('localLastPlayDate');

    if (localXP != null) {
      _userStats!.globalXP = localXP;
    }
    if (localLevel != null) {
      _userStats!.globalLevel = localLevel;
    }
    if (localStreak != null) {
      _userStats!.currentStreak = localStreak;
    }
    if (localLastPlay != null) {
      _userStats!.lastPlayDate = DateTime.parse(localLastPlay);
    }

    notifyListeners();
  }

  // Sync local progress with Firestore
  Future<void> syncProgress() async {
    if (_userStats == null || _currentUserId == null) return;

    try {
      await _firestoreService.updateUserStats(_userStats!);
      // Clear local cache after successful sync
      await _prefs.remove('localGlobalXP');
      await _prefs.remove('localGlobalLevel');
      await _prefs.remove('localStreak');
      await _prefs.remove('localLastPlayDate');
    } catch (e) {
      print('Error syncing progress: $e');
      // Keep local cache if sync fails
    }
  }

  @override
  void dispose() {
    // Save local progress before disposing
    saveLocalProgress();
    super.dispose();
  }
}