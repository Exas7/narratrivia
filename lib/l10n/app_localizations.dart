import 'package:flutter/material.dart';

class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations('it');
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'it': {
      // Settings Screen
      'settings': 'IMPOSTAZIONI',
      'music_volume': 'Volume Musica',
      'sfx_volume': 'Volume Effetti Sonori',
      'brightness': 'Luminosità',
      'language': 'Lingua',
      'auto_save': 'Impostazioni salvate automaticamente',
      'panoramic_control': 'Controllo Vista Panoramica',
      'accelerometer': 'Accelerometro',
      'drag': 'Trascinamento',

      // Main Menu
      'play': 'GIOCA',
      'settings_menu': 'Impostazioni',
      'credits': 'Crediti',

      // General
      'back': 'Indietro',
      'loading': 'Caricamento...',
      'error': 'Errore',
      'yes': 'Sì',
      'no': 'No',

      // Splash
      'tagline': 'La tua avventura narrativa inizia qui',

      // Quiz UI
      'start_quiz': 'Inizia Quiz',
      'select_mode': 'Seleziona Modalità',
      'select_game_mode': 'Seleziona una modalità',
      'time_remaining': 'Tempo rimanente',
      'correct': 'Corretto!',
      'wrong': 'Sbagliato!',
      'quiz_complete': 'Quiz Completato!',
      'true': 'VERO',
      'false': 'FALSO',
      'continue': 'CONTINUA',
      'replay': 'RIGIOCA',
      'exit': 'ESCI',
      'score': 'Punteggio',
      'accuracy': 'Precisione',
      'streak': 'Streak',
      'xp_earned': 'XP Guadagnati',
      'average_time': 'Tempo Medio',
      'duration': 'Durata',
      'perfect': 'PERFETTO!',
      'excellent': 'Eccellente!',
      'good_job': 'Ottimo lavoro!',
      'good_result': 'Buon risultato!',
      'not_bad': 'Non male!',
      'can_do_better': 'Puoi fare meglio!',
      'keep_trying': 'Continua a provare!',
      'exit_quiz': 'Uscire dal quiz?',
      'lose_progress': 'Perderai i progressi di questa partita.',
      'confirm': 'Conferma',
      'cancel': 'Annulla',
      'question': 'Domanda',
      'correct_answers': 'Corrette',
      'history': 'Storico Partite',
      'no_games': 'Nessuna partita giocata',
      'start_playing': 'Inizia a giocare per vedere\nil tuo storico qui!',
      'games': 'Partite',
      'average': 'Media',
      'total_xp': 'XP Totale',
      'return_to_room': 'Torna alla stanza',

      // Game modes
      'true_false': 'Vero / Falso',
      'multiple_choice': 'Scelta Multipla',
      'ugly_images': 'Immagini Brutte',
      'misleading': 'Descrizioni Fuorvianti',
      'seconds_per_answer': 'secondi per risposta',
    },
    'en': {
      // Settings Screen
      'settings': 'SETTINGS',
      'music_volume': 'Music Volume',
      'sfx_volume': 'Sound Effects Volume',
      'brightness': 'Brightness',
      'language': 'Language',
      'auto_save': 'Settings saved automatically',
      'panoramic_control': 'Panoramic View Control',
      'accelerometer': 'Accelerometer',
      'drag': 'Drag',

      // Main Menu
      'play': 'PLAY',
      'settings_menu': 'Settings',
      'credits': 'Credits',

      // General
      'back': 'Back',
      'loading': 'Loading...',
      'error': 'Error',
      'yes': 'Yes',
      'no': 'No',

      // Splash
      'tagline': 'Your narrative adventure begins here',

      // Quiz UI
      'start_quiz': 'Start Quiz',
      'select_mode': 'Select Mode',
      'select_game_mode': 'Select a game mode',
      'time_remaining': 'Time remaining',
      'correct': 'Correct!',
      'wrong': 'Wrong!',
      'quiz_complete': 'Quiz Complete!',
      'true': 'TRUE',
      'false': 'FALSE',
      'continue': 'CONTINUE',
      'replay': 'REPLAY',
      'exit': 'EXIT',
      'score': 'Score',
      'accuracy': 'Accuracy',
      'streak': 'Streak',
      'xp_earned': 'XP Earned',
      'average_time': 'Average Time',
      'duration': 'Duration',
      'perfect': 'PERFECT!',
      'excellent': 'Excellent!',
      'good_job': 'Good job!',
      'good_result': 'Good result!',
      'not_bad': 'Not bad!',
      'can_do_better': 'You can do better!',
      'keep_trying': 'Keep trying!',
      'exit_quiz': 'Exit quiz?',
      'lose_progress': 'You will lose progress in this game.',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'question': 'Question',
      'correct_answers': 'Correct',
      'history': 'Game History',
      'no_games': 'No games played',
      'start_playing': 'Start playing to see\nyour history here!',
      'games': 'Games',
      'average': 'Average',
      'total_xp': 'Total XP',
      'return_to_room': 'Return to room',

      // Game modes
      'true_false': 'True / False',
      'multiple_choice': 'Multiple Choice',
      'ugly_images': 'Ugly Images',
      'misleading': 'Misleading Descriptions',
      'seconds_per_answer': 'seconds per answer',
    },
    'es': {
      // Settings Screen
      'settings': 'CONFIGURACIÓN',
      'music_volume': 'Volumen de Música',
      'sfx_volume': 'Volumen de Efectos de Sonido',
      'brightness': 'Brillo',
      'language': 'Idioma',
      'auto_save': 'Configuración guardada automáticamente',
      'panoramic_control': 'Control de Vista Panorámica',
      'accelerometer': 'Acelerómetro',
      'drag': 'Arrastrar',

      // Main Menu
      'play': 'JUGAR',
      'settings_menu': 'Configuración',
      'credits': 'Créditos',

      // General
      'back': 'Atrás',
      'loading': 'Cargando...',
      'error': 'Error',
      'yes': 'Sí',
      'no': 'No',

      // Splash
      'tagline': 'Tu aventura narrativa comienza aquí',

      // Quiz UI
      'start_quiz': 'Iniciar Quiz',
      'select_mode': 'Seleccionar Modo',
      'select_game_mode': 'Selecciona un modo de juego',
      'time_remaining': 'Tiempo restante',
      'correct': '¡Correcto!',
      'wrong': '¡Incorrecto!',
      'quiz_complete': '¡Quiz Completado!',
      'true': 'VERDADERO',
      'false': 'FALSO',
      'continue': 'CONTINUAR',
      'replay': 'REPETIR',
      'exit': 'SALIR',
      'score': 'Puntuación',
      'accuracy': 'Precisión',
      'streak': 'Racha',
      'xp_earned': 'XP Ganados',
      'average_time': 'Tiempo Promedio',
      'duration': 'Duración',
      'perfect': '¡PERFECTO!',
      'excellent': '¡Excelente!',
      'good_job': '¡Buen trabajo!',
      'good_result': '¡Buen resultado!',
      'not_bad': '¡No está mal!',
      'can_do_better': '¡Puedes hacerlo mejor!',
      'keep_trying': '¡Sigue intentando!',
      'exit_quiz': '¿Salir del quiz?',
      'lose_progress': 'Perderás el progreso de este juego.',
      'confirm': 'Confirmar',
      'cancel': 'Cancelar',
      'question': 'Pregunta',
      'correct_answers': 'Correctas',
      'history': 'Historial de Juegos',
      'no_games': 'No hay juegos jugados',
      'start_playing': '¡Empieza a jugar para ver\ntu historial aquí!',
      'games': 'Juegos',
      'average': 'Promedio',
      'total_xp': 'XP Total',
      'return_to_room': 'Volver a la sala',

      // Game modes
      'true_false': 'Verdadero / Falso',
      'multiple_choice': 'Opción Múltiple',
      'ugly_images': 'Imágenes Feas',
      'misleading': 'Descripciones Engañosas',
      'seconds_per_answer': 'segundos por respuesta',
    },
    'fr': {
      // Settings Screen
      'settings': 'PARAMÈTRES',
      'music_volume': 'Volume de la Musique',
      'sfx_volume': 'Volume des Effets Sonores',
      'brightness': 'Luminosité',
      'language': 'Langue',
      'auto_save': 'Paramètres enregistrés automatiquement',
      'panoramic_control': 'Contrôle de Vue Panoramique',
      'accelerometer': 'Accéléromètre',
      'drag': 'Glisser',

      // Main Menu
      'play': 'JOUER',
      'settings_menu': 'Paramètres',
      'credits': 'Crédits',

      // General
      'back': 'Retour',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'yes': 'Oui',
      'no': 'Non',

      // Splash
      'tagline': 'Votre aventure narrative commence ici',

      // Quiz UI
      'start_quiz': 'Commencer le Quiz',
      'select_mode': 'Sélectionner Mode',
      'select_game_mode': 'Sélectionnez un mode de jeu',
      'time_remaining': 'Temps restant',
      'correct': 'Correct!',
      'wrong': 'Faux!',
      'quiz_complete': 'Quiz Terminé!',
      'true': 'VRAI',
      'false': 'FAUX',
      'continue': 'CONTINUER',
      'replay': 'REJOUER',
      'exit': 'SORTIR',
      'score': 'Score',
      'accuracy': 'Précision',
      'streak': 'Série',
      'xp_earned': 'XP Gagnés',
      'average_time': 'Temps Moyen',
      'duration': 'Durée',
      'perfect': 'PARFAIT!',
      'excellent': 'Excellent!',
      'good_job': 'Bon travail!',
      'good_result': 'Bon résultat!',
      'not_bad': 'Pas mal!',
      'can_do_better': 'Tu peux faire mieux!',
      'keep_trying': 'Continue d\'essayer!',
      'exit_quiz': 'Quitter le quiz?',
      'lose_progress': 'Vous perdrez les progrès de ce jeu.',
      'confirm': 'Confirmer',
      'cancel': 'Annuler',
      'question': 'Question',
      'correct_answers': 'Correctes',
      'history': 'Historique des Jeux',
      'no_games': 'Aucun jeu joué',
      'start_playing': 'Commencez à jouer pour voir\nvotre historique ici!',
      'games': 'Jeux',
      'average': 'Moyenne',
      'total_xp': 'XP Total',
      'return_to_room': 'Retour à la salle',

      // Game modes
      'true_false': 'Vrai / Faux',
      'multiple_choice': 'Choix Multiple',
      'ugly_images': 'Images Laides',
      'misleading': 'Descriptions Trompeuses',
      'seconds_per_answer': 'secondes par réponse',
    },
    'de': {
      // Settings Screen
      'settings': 'EINSTELLUNGEN',
      'music_volume': 'Musiklautstärke',
      'sfx_volume': 'Soundeffekte Lautstärke',
      'brightness': 'Helligkeit',
      'language': 'Sprache',
      'auto_save': 'Einstellungen automatisch gespeichert',
      'panoramic_control': 'Panoramaansicht-Steuerung',
      'accelerometer': 'Beschleunigungsmesser',
      'drag': 'Ziehen',

      // Main Menu
      'play': 'SPIELEN',
      'settings_menu': 'Einstellungen',
      'credits': 'Credits',

      // General
      'back': 'Zurück',
      'loading': 'Laden...',
      'error': 'Fehler',
      'yes': 'Ja',
      'no': 'Nein',

      // Splash
      'tagline': 'Dein narratives Abenteuer beginnt hier',

      // Quiz UI
      'start_quiz': 'Quiz Starten',
      'select_mode': 'Modus Wählen',
      'select_game_mode': 'Spielmodus auswählen',
      'time_remaining': 'Verbleibende Zeit',
      'correct': 'Richtig!',
      'wrong': 'Falsch!',
      'quiz_complete': 'Quiz Abgeschlossen!',
      'true': 'WAHR',
      'false': 'FALSCH',
      'continue': 'WEITER',
      'replay': 'WIEDERHOLEN',
      'exit': 'BEENDEN',
      'score': 'Punktzahl',
      'accuracy': 'Genauigkeit',
      'streak': 'Serie',
      'xp_earned': 'XP Verdient',
      'average_time': 'Durchschnittliche Zeit',
      'duration': 'Dauer',
      'perfect': 'PERFEKT!',
      'excellent': 'Ausgezeichnet!',
      'good_job': 'Gute Arbeit!',
      'good_result': 'Gutes Ergebnis!',
      'not_bad': 'Nicht schlecht!',
      'can_do_better': 'Du kannst es besser!',
      'keep_trying': 'Weiter versuchen!',
      'exit_quiz': 'Quiz beenden?',
      'lose_progress': 'Sie verlieren den Fortschritt dieses Spiels.',
      'confirm': 'Bestätigen',
      'cancel': 'Abbrechen',
      'question': 'Frage',
      'correct_answers': 'Richtige',
      'history': 'Spielverlauf',
      'no_games': 'Keine Spiele gespielt',
      'start_playing': 'Beginne zu spielen um\ndeinen Verlauf hier zu sehen!',
      'games': 'Spiele',
      'average': 'Durchschnitt',
      'total_xp': 'Gesamt XP',
      'return_to_room': 'Zurück zum Raum',

      // Game modes
      'true_false': 'Wahr / Falsch',
      'multiple_choice': 'Multiple Choice',
      'ugly_images': 'Hässliche Bilder',
      'misleading': 'Irreführende Beschreibungen',
      'seconds_per_answer': 'Sekunden pro Antwort',
    },
    'pt': {
      // Settings Screen
      'settings': 'CONFIGURAÇÕES',
      'music_volume': 'Volume da Música',
      'sfx_volume': 'Volume dos Efeitos Sonoros',
      'brightness': 'Brilho',
      'language': 'Idioma',
      'auto_save': 'Configurações salvas automaticamente',
      'panoramic_control': 'Controle de Vista Panorâmica',
      'accelerometer': 'Acelerômetro',
      'drag': 'Arrastar',

      // Main Menu
      'play': 'JOGAR',
      'settings_menu': 'Configurações',
      'credits': 'Créditos',

      // General
      'back': 'Voltar',
      'loading': 'Carregando...',
      'error': 'Erro',
      'yes': 'Sim',
      'no': 'Não',

      // Splash
      'tagline': 'Sua aventura narrativa começa aqui',

      // Quiz UI
      'start_quiz': 'Iniciar Quiz',
      'select_mode': 'Selecionar Modo',
      'select_game_mode': 'Selecione um modo de jogo',
      'time_remaining': 'Tempo restante',
      'correct': 'Correto!',
      'wrong': 'Errado!',
      'quiz_complete': 'Quiz Completo!',
      'true': 'VERDADEIRO',
      'false': 'FALSO',
      'continue': 'CONTINUAR',
      'replay': 'REPETIR',
      'exit': 'SAIR',
      'score': 'Pontuação',
      'accuracy': 'Precisão',
      'streak': 'Sequência',
      'xp_earned': 'XP Ganhos',
      'average_time': 'Tempo Médio',
      'duration': 'Duração',
      'perfect': 'PERFEITO!',
      'excellent': 'Excelente!',
      'good_job': 'Bom trabalho!',
      'good_result': 'Bom resultado!',
      'not_bad': 'Nada mal!',
      'can_do_better': 'Você pode fazer melhor!',
      'keep_trying': 'Continue tentando!',
      'exit_quiz': 'Sair do quiz?',
      'lose_progress': 'Você perderá o progresso deste jogo.',
      'confirm': 'Confirmar',
      'cancel': 'Cancelar',
      'question': 'Pergunta',
      'correct_answers': 'Corretas',
      'history': 'Histórico de Jogos',
      'no_games': 'Nenhum jogo jogado',
      'start_playing': 'Comece a jogar para ver\nseu histórico aqui!',
      'games': 'Jogos',
      'average': 'Média',
      'total_xp': 'XP Total',
      'return_to_room': 'Voltar à sala',

      // Game modes
      'true_false': 'Verdadeiro / Falso',
      'multiple_choice': 'Múltipla Escolha',
      'ugly_images': 'Imagens Feias',
      'misleading': 'Descrições Enganosas',
      'seconds_per_answer': 'segundos por resposta',
    },
  };

  String translate(String key) {
    return _localizedValues[languageCode]?[key] ??
        _localizedValues['it']?[key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['it', 'en', 'es', 'fr', 'de', 'pt'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale.languageCode);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}