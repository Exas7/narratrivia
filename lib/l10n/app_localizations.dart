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
    },
    'en': {
      // Settings Screen
      'settings': 'SETTINGS',
      'music_volume': 'Music Volume',
      'sfx_volume': 'Sound Effects Volume',
      'brightness': 'Brightness',
      'language': 'Language',
      'auto_save': 'Settings saved automatically',

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
    },
    'es': {
      // Settings Screen
      'settings': 'CONFIGURACIÓN',
      'music_volume': 'Volumen de Música',
      'sfx_volume': 'Volumen de Efectos de Sonido',
      'brightness': 'Brillo',
      'language': 'Idioma',
      'auto_save': 'Configuración guardada automáticamente',

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
    },
    'fr': {
      // Settings Screen
      'settings': 'PARAMÈTRES',
      'music_volume': 'Volume de la Musique',
      'sfx_volume': 'Volume des Effets Sonores',
      'brightness': 'Luminosité',
      'language': 'Langue',
      'auto_save': 'Paramètres enregistrés automatiquement',

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
    },
    'de': {
      // Settings Screen
      'settings': 'EINSTELLUNGEN',
      'music_volume': 'Musiklautstärke',
      'sfx_volume': 'Soundeffekte Lautstärke',
      'brightness': 'Helligkeit',
      'language': 'Sprache',
      'auto_save': 'Einstellungen automatisch gespeichert',

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
    },
    'pt': {
      // Settings Screen
      'settings': 'CONFIGURAÇÕES',
      'music_volume': 'Volume da Música',
      'sfx_volume': 'Volume dos Efeitos Sonoros',
      'brightness': 'Brilho',
      'language': 'Idioma',
      'auto_save': 'Configurações salvas automaticamente',

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