// lib/core/services/mascot_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_stats.dart';
import '../models/medium_type.dart';

enum MascotMood {
  happy,
  sad,
  excited,
  thinking,
  neutral,
  celebration,
}

class MascotMessage {
  final String text;
  final MascotMood mood;
  final Duration displayDuration;
  final bool isImportant;

  MascotMessage({
    required this.text,
    this.mood = MascotMood.neutral,
    this.displayDuration = const Duration(seconds: 3),
    this.isImportant = false,
  });
}

class MascotService {
  static final MascotService _instance = MascotService._internal();
  factory MascotService() => _instance;
  MascotService._internal();

  // Track shown messages to avoid repetition
  final Set<String> _shownMessages = {};

  // Track first-time events
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Initialize service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  // Get mascot mood image path
  String getMascotImagePath(MascotMood mood) {
    switch (mood) {
      case MascotMood.happy:
        return 'assets/images/mascot/happy.png';
      case MascotMood.sad:
        return 'assets/images/mascot/sad.png';
      case MascotMood.excited:
        return 'assets/images/mascot/excited.png';
      case MascotMood.thinking:
        return 'assets/images/mascot/thinking.png';
      case MascotMood.neutral:
        return 'assets/images/mascot/neutral.png';
      case MascotMood.celebration:
        return 'assets/images/mascot/celebration.png';
    }
  }

  // --- TUTORIAL/ONBOARDING MESSAGES ---

  // Check for first hub access
  Future<MascotMessage?> checkFirstHubAccess() async {
    await initialize();

    final key = 'first_hub_access';
    if (_prefs.getBool(key) ?? true) {
      await _prefs.setBool(key, false);
      return MascotMessage(
        text: 'Benvenuto nella stazione Narratrivia! Questa è la sala centrale da cui puoi accedere a tutti i mondi narrativi.',
        mood: MascotMood.excited,
        displayDuration: const Duration(seconds: 5),
        isImportant: true,
      );
    }
    return null;
  }

  // Check for first room access
  Future<MascotMessage?> checkFirstRoomAccess(String mediumName) async {
    await initialize();

    final key = 'first_room_$mediumName';
    if (_prefs.getBool(key) ?? true) {
      await _prefs.setBool(key, false);
      return MascotMessage(
        text: 'Questa è la stanza dei $mediumName! Esplora la vista panoramica e tocca la seduta centrale per iniziare un quiz.',
        mood: MascotMood.happy,
        displayDuration: const Duration(seconds: 4),
      );
    }
    return null;
  }

  // Check for first quiz
  Future<MascotMessage?> checkFirstQuiz() async {
    await initialize();

    final key = 'first_quiz';
    if (_prefs.getBool(key) ?? true) {
      await _prefs.setBool(key, false);
      return MascotMessage(
        text: 'È il momento del tuo primo quiz! Rispondi correttamente per guadagnare XP e salire di livello. Buona fortuna!',
        mood: MascotMood.thinking,
        displayDuration: const Duration(seconds: 4),
        isImportant: true,
      );
    }
    return null;
  }

  // --- PROGRESSION MESSAGES ---

  // Check for level up
  MascotMessage? checkLevelUp(int oldLevel, int newLevel) {
    if (newLevel > oldLevel) {
      // Special messages for milestone levels
      if (newLevel == 5) {
        return MascotMessage(
          text: 'Incredibile! Hai raggiunto il livello 5! Hai sbloccato il titolo "Novizio"!',
          mood: MascotMood.celebration,
          displayDuration: const Duration(seconds: 4),
          isImportant: true,
        );
      } else if (newLevel == 10) {
        return MascotMessage(
          text: 'Livello 10! Sei ufficialmente un Apprendista! Continua così!',
          mood: MascotMood.celebration,
          displayDuration: const Duration(seconds: 4),
          isImportant: true,
        );
      } else if (newLevel == 25) {
        return MascotMessage(
          text: 'Livello 25! Sei diventato un Esperto! La tua dedizione è ammirevole!',
          mood: MascotMood.celebration,
          displayDuration: const Duration(seconds: 5),
          isImportant: true,
        );
      } else if (newLevel == 50) {
        return MascotMessage(
          text: 'Livello 50! Maestro! Pochi raggiungono queste vette!',
          mood: MascotMood.celebration,
          displayDuration: const Duration(seconds: 5),
          isImportant: true,
        );
      } else if (newLevel == 100) {
        return MascotMessage(
          text: 'LIVELLO 100! SEI UNA LEGGENDA! Hai raggiunto la vetta assoluta!',
          mood: MascotMood.celebration,
          displayDuration: const Duration(seconds: 6),
          isImportant: true,
        );
      } else if (newLevel % 5 == 0) {
        // Generic message every 5 levels
        return MascotMessage(
          text: 'Fantastico! Hai raggiunto il livello $newLevel!',
          mood: MascotMood.excited,
          displayDuration: const Duration(seconds: 3),
        );
      }
    }
    return null;
  }

  // Check for new achievement
  MascotMessage? checkNewAchievement(Achievement achievement) {
    return MascotMessage(
      text: 'Nuovo badge sbloccato: ${achievement.name}!\n${achievement.description}',
      mood: MascotMood.celebration,
      displayDuration: const Duration(seconds: 4),
      isImportant: true,
    );
  }

  // --- DATABASE VAULT MESSAGES ---

  // Check Database Vault access attempt
  MascotMessage checkDatabaseVaultAccess(bool isUnlocked, UserStats stats) {
    if (isUnlocked) {
      final messageKey = 'vault_unlocked';
      if (!_shownMessages.contains(messageKey)) {
        _shownMessages.add(messageKey);
        return MascotMessage(
          text: 'Accesso concesso al Database Vault! Hai sbloccato modalità di gioco esclusive e statistiche avanzate!',
          mood: MascotMood.celebration,
          displayDuration: const Duration(seconds: 5),
          isImportant: true,
        );
      }
    } else {
      // Calculate what's missing
      List<String> requirements = [];

      for (final progress in stats.mediumProgress.values) {
        if (progress.level < 10) {
          requirements.add('${progress.medium.displayName}: Livello ${progress.level}/10');
        }
      }

      final totalQuizzes = stats.mediumProgress.values
          .fold(0, (total, p) => total + p.questionsAnswered);

      if (totalQuizzes < 100) {
        requirements.add('Quiz completati: $totalQuizzes/100');
      }

      String requirementsText = requirements.take(3).join('\n');

      return MascotMessage(
        text: 'Il Database Vault richiede livello 10 in tutti i medium!\n\n$requirementsText',
        mood: MascotMood.thinking,
        displayDuration: const Duration(seconds: 4),
      );
    }

    return MascotMessage(
      text: 'Continua a esplorare il Database Vault!',
      mood: MascotMood.happy,
    );
  }

  // --- SPECIAL ACHIEVEMENTS MESSAGES ---

  // Check for perfect game
  MascotMessage? checkPerfectGame(int correctAnswers, int totalQuestions) {
    if (correctAnswers == totalQuestions && totalQuestions >= 5) {
      final messageKey = 'perfect_game';
      if (!_shownMessages.contains(messageKey)) {
        _shownMessages.add(messageKey);
        return MascotMessage(
          text: 'PERFETTO! Nessun errore! Sei un vero campione!',
          mood: MascotMood.celebration,
          displayDuration: const Duration(seconds: 4),
          isImportant: true,
        );
      }
    }
    return null;
  }

  // Check for streak milestone
  MascotMessage? checkStreakMilestone(int streak) {
    if (streak == 3) {
      return MascotMessage(
        text: '3 giorni di fila! Stai creando una bella abitudine!',
        mood: MascotMood.happy,
        displayDuration: const Duration(seconds: 3),
      );
    } else if (streak == 7) {
      return MascotMessage(
        text: 'Una settimana intera di gioco consecutivo! Fantastico!',
        mood: MascotMood.celebration,
        displayDuration: const Duration(seconds: 4),
        isImportant: true,
      );
    } else if (streak == 30) {
      return MascotMessage(
        text: 'UN MESE INTERO! Sei inarrestabile! 30 giorni di dedizione!',
        mood: MascotMood.celebration,
        displayDuration: const Duration(seconds: 5),
        isImportant: true,
      );
    }
    return null;
  }

  // --- QUIZ FEEDBACK MESSAGES ---

  // Get encouraging message during quiz
  MascotMessage getEncouragingMessage(int correctStreak) {
    if (correctStreak == 3) {
      return MascotMessage(
        text: 'Tre di fila! Continua così!',
        mood: MascotMood.happy,
        displayDuration: const Duration(seconds: 2),
      );
    } else if (correctStreak == 5) {
      return MascotMessage(
        text: 'Cinque risposte corrette consecutive! Sei in fiamme!',
        mood: MascotMood.excited,
        displayDuration: const Duration(seconds: 2),
      );
    } else if (correctStreak == 10) {
      return MascotMessage(
        text: 'DIECI DI FILA! Incredibile!',
        mood: MascotMood.celebration,
        displayDuration: const Duration(seconds: 3),
      );
    }

    return MascotMessage(
      text: 'Ottimo lavoro!',
      mood: MascotMood.happy,
      displayDuration: const Duration(seconds: 1),
    );
  }

  // Get message for wrong answer
  MascotMessage getWrongAnswerMessage() {
    final messages = [
      'Non preoccuparti, capita a tutti!',
      'La prossima andrà meglio!',
      'Continua a provarci!',
      'Non mollare!',
      'Errare è umano, perseverare è divino!',
    ];

    final index = DateTime.now().millisecond % messages.length;

    return MascotMessage(
      text: messages[index],
      mood: MascotMood.thinking,
      displayDuration: const Duration(seconds: 2),
    );
  }

  // --- WEEKLY CHALLENGE MESSAGES ---

  // Check weekly challenge completion
  MascotMessage? checkWeeklyChallengeComplete(WeeklyChallenge challenge) {
    if (challenge.completed) {
      return MascotMessage(
        text: 'Sfida settimanale completata! Hai guadagnato 500 XP bonus!',
        mood: MascotMood.celebration,
        displayDuration: const Duration(seconds: 4),
        isImportant: true,
      );
    } else if (challenge.progressPercentage >= 50) {
      return MascotMessage(
        text: 'Sei a metà strada nella sfida settimanale! Continua così!',
        mood: MascotMood.happy,
        displayDuration: const Duration(seconds: 3),
      );
    }
    return null;
  }

  // Reset shown messages (call daily or on app restart)
  void resetDailyMessages() {
    _shownMessages.clear();
  }

  // Get random tip
  MascotMessage getRandomTip() {
    final tips = [
      'Sapevi che rispondendo velocemente guadagni più XP?',
      'Prova tutte le modalità di gioco per trovare la tua preferita!',
      'Il Database Vault nasconde sfide speciali per i giocatori più esperti!',
      'Completa la sfida settimanale per bonus XP extra!',
      'Gioca ogni giorno per mantenere il tuo streak!',
      'Esplora tutte le stanze per scoprire easter egg nascosti!',
    ];

    final index = DateTime.now().millisecond % tips.length;

    return MascotMessage(
      text: tips[index],
      mood: MascotMood.thinking,
      displayDuration: const Duration(seconds: 3),
    );
  }
}