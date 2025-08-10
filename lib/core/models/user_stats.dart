// lib/core/models/user_stats.dart

import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'medium_type.dart';
import 'questions.dart';

class UserStats {
  final String userId;
  int globalXP;
  int globalLevel;
  int currentStreak;
  DateTime? lastPlayDate;
  Map<MediumType, MediumProgress> mediumProgress;
  List<Achievement> achievements;
  WeeklyChallenge? weeklyChallenge;

  UserStats({
    required this.userId,
    this.globalXP = 0,
    this.globalLevel = 1,
    this.currentStreak = 0,
    this.lastPlayDate,
    Map<MediumType, MediumProgress>? mediumProgress,
    List<Achievement>? achievements,
    this.weeklyChallenge,
  }) : mediumProgress = mediumProgress ?? _initializeMediumProgress(),
        achievements = achievements ?? [];

  // Initialize empty progress for all mediums
  static Map<MediumType, MediumProgress> _initializeMediumProgress() {
    final progress = <MediumType, MediumProgress>{};
    for (final medium in MediumType.values) {
      progress[medium] = MediumProgress(medium: medium);
    }
    return progress;
  }

  // Factory constructor from Firestore
  factory UserStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse medium progress
    final mediumProgressMap = <MediumType, MediumProgress>{};
    final progressData = data['mediumProgress'] as Map<String, dynamic>?;

    if (progressData != null) {
      progressData.forEach((key, value) {
        try {
          final medium = MediumType.values.firstWhere(
                (m) => m.name == key,
            orElse: () => MediumType.videogames,
          );
          mediumProgressMap[medium] = MediumProgress.fromMap(
            value as Map<String, dynamic>,
            medium,
          );
        } catch (e) {
          // Skip invalid medium data
        }
      });
    }

    // Parse achievements
    final achievementsList = <Achievement>[];
    final achievementsData = data['achievements'] as List<dynamic>?;

    if (achievementsData != null) {
      for (final achData in achievementsData) {
        achievementsList.add(
          Achievement.fromMap(achData as Map<String, dynamic>),
        );
      }
    }

    // Parse weekly challenge
    WeeklyChallenge? challenge;
    if (data['weeklyChallenge'] != null) {
      challenge = WeeklyChallenge.fromMap(
        data['weeklyChallenge'] as Map<String, dynamic>,
      );
    }

    return UserStats(
      userId: doc.id,
      globalXP: data['globalXP'] ?? 0,
      globalLevel: data['globalLevel'] ?? 1,
      currentStreak: data['currentStreak'] ?? 0,
      lastPlayDate: (data['lastPlayDate'] as Timestamp?)?.toDate(),
      mediumProgress: mediumProgressMap,
      achievements: achievementsList,
      weeklyChallenge: challenge,
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    final mediumProgressData = <String, dynamic>{};
    mediumProgress.forEach((medium, progress) {
      mediumProgressData[medium.name] = progress.toMap();
    });

    return {
      'globalXP': globalXP,
      'globalLevel': globalLevel,
      'currentStreak': currentStreak,
      'lastPlayDate': lastPlayDate != null
          ? Timestamp.fromDate(lastPlayDate!)
          : null,
      'mediumProgress': mediumProgressData,
      'achievements': achievements.map((a) => a.toMap()).toList(),
      'weeklyChallenge': weeklyChallenge?.toMap(),
    };
  }

  // Calculate level from XP
  static int calculateLevel(int xp) {
    int level = 1;
    int requiredXP = 100;
    int totalXP = 0;

    while (totalXP + requiredXP <= xp) {
      totalXP += requiredXP;
      level++;
      // Formula: baseXP * (level ^ 1.5)
      requiredXP = (100 * math.pow(level, 1.5)).round();
    }

    return level;
  }

  // Get XP required for next level
  int get xpForNextLevel {
    int requiredXP = (100 * math.pow(globalLevel + 1, 1.5)).round();
    return requiredXP;
  }

  // Get current XP progress in current level
  int get currentLevelXP {
    int totalXPForCurrentLevel = 0;
    for (int i = 1; i < globalLevel; i++) {
      totalXPForCurrentLevel += (100 * math.pow(i, 1.5)).round();
    }
    return globalXP - totalXPForCurrentLevel;
  }

  // Get XP progress percentage for current level
  double get levelProgress {
    return (currentLevelXP / xpForNextLevel) * 100;
  }

  // Check if Database Vault is unlocked
  bool get isDatabaseVaultUnlocked {
    // Requires level 10+ in all mediums
    for (final progress in mediumProgress.values) {
      if (progress.level < 10) return false;
    }

    // Also check minimum quiz requirement
    int totalQuizzes = mediumProgress.values
        .fold(0, (total, p) => total + p.questionsAnswered);

    if (totalQuizzes < 100) return false;

    // Check account age (7 days) - this would need actual implementation
    // For now, return true if other conditions are met
    return true;
  }

  // Update streak
  void updateStreak() {
    final now = DateTime.now();

    if (lastPlayDate != null) {
      final daysSinceLastPlay = now.difference(lastPlayDate!).inDays;

      if (daysSinceLastPlay == 1) {
        // Consecutive day - increase streak
        currentStreak++;
      } else if (daysSinceLastPlay > 1) {
        // Streak broken - reset to 1
        currentStreak = 1;
      }
      // If same day (daysSinceLastPlay == 0), streak stays the same
    } else {
      // First time playing
      currentStreak = 1;
    }

    lastPlayDate = now;
  }

  // Add XP and update level
  void addXP(int xp, MediumType medium) {
    globalXP += xp;
    globalLevel = calculateLevel(globalXP);

    // Also add to medium-specific progress
    mediumProgress[medium]?.addXP(xp);
  }

  // Check and unlock achievements
  List<Achievement> checkAchievements() {
    final newAchievements = <Achievement>[];

    // Check level-based achievements
    if (globalLevel >= 5 && !hasAchievement('novice')) {
      newAchievements.add(Achievement(
        id: 'novice',
        name: 'Novizio',
        description: 'Raggiungi il livello 5',
        unlockedAt: DateTime.now(),
      ));
    }

    if (globalLevel >= 10 && !hasAchievement('apprentice')) {
      newAchievements.add(Achievement(
        id: 'apprentice',
        name: 'Apprendista',
        description: 'Raggiungi il livello 10',
        unlockedAt: DateTime.now(),
      ));
    }

    // Check streak achievements
    if (currentStreak >= 7 && !hasAchievement('week_streak')) {
      newAchievements.add(Achievement(
        id: 'week_streak',
        name: 'Settimana Perfetta',
        description: '7 giorni di gioco consecutivo',
        unlockedAt: DateTime.now(),
      ));
    }

    // Add new achievements to the list
    achievements.addAll(newAchievements);

    return newAchievements;
  }

  // Check if user has specific achievement
  bool hasAchievement(String achievementId) {
    return achievements.any((a) => a.id == achievementId);
  }
}

// Medium-specific progress
class MediumProgress {
  final MediumType medium;
  int xp;
  int level;
  int questionsAnswered;
  int correctAnswers;
  QuestionType? favoriteMode;

  MediumProgress({
    required this.medium,
    this.xp = 0,
    this.level = 1,
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.favoriteMode,
  });

  factory MediumProgress.fromMap(Map<String, dynamic> map, MediumType medium) {
    QuestionType? favMode;
    if (map['favoriteMode'] != null) {
      final modeStr = map['favoriteMode'] as String;
      favMode = QuestionType.values.firstWhere(
            (t) => t.name == modeStr,
        orElse: () => QuestionType.multiple,
      );
    }

    return MediumProgress(
      medium: medium,
      xp: map['xp'] ?? 0,
      level: map['level'] ?? 1,
      questionsAnswered: map['questionsAnswered'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      favoriteMode: favMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'xp': xp,
      'level': level,
      'questionsAnswered': questionsAnswered,
      'correctAnswers': correctAnswers,
      'favoriteMode': favoriteMode?.name,
    };
  }

  // Calculate accuracy percentage
  double get accuracy {
    if (questionsAnswered == 0) return 0;
    return (correctAnswers / questionsAnswered) * 100;
  }

  // Add XP and update level
  void addXP(int newXP) {
    xp += newXP;
    // Medium levels cap at 15
    level = UserStats.calculateLevel(xp).clamp(1, 15);
  }

  // Record an answered question
  void recordAnswer(bool isCorrect) {
    questionsAnswered++;
    if (isCorrect) correctAnswers++;
  }
}

// Achievement model
class Achievement {
  final String id;
  final String name;
  final String description;
  final DateTime unlockedAt;
  bool viewed;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.unlockedAt,
    this.viewed = false,
  });

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      unlockedAt: (map['unlockedAt'] as Timestamp).toDate(),
      viewed: map['viewed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'unlockedAt': Timestamp.fromDate(unlockedAt),
      'viewed': viewed,
    };
  }
}

// Weekly challenge model
class WeeklyChallenge {
  final String id;
  final String description;
  final int targetValue;
  int currentProgress;
  bool completed;
  final DateTime expiresAt;

  WeeklyChallenge({
    required this.id,
    required this.description,
    required this.targetValue,
    this.currentProgress = 0,
    this.completed = false,
    required this.expiresAt,
  });

  factory WeeklyChallenge.fromMap(Map<String, dynamic> map) {
    return WeeklyChallenge(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      targetValue: map['targetValue'] ?? 0,
      currentProgress: map['currentProgress'] ?? 0,
      completed: map['completed'] ?? false,
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'targetValue': targetValue,
      'currentProgress': currentProgress,
      'completed': completed,
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  // Check if challenge is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // Get progress percentage
  double get progressPercentage {
    if (targetValue == 0) return 0;
    return (currentProgress / targetValue * 100).clamp(0, 100);
  }
}