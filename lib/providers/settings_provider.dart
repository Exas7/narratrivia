import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audio_manager.dart';

class SettingsProvider extends ChangeNotifier {
  double _musicVolume = 0.7;
  double _sfxVolume = 0.8;
  double _brightness = 0.8;
  String _languageCode = 'it';

  static const List<String> supportedLanguages = [
    'it',
    'en',
    'es',
    'fr',
    'de',
    'pt',
  ];

  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  double get brightness => _brightness;
  String get languageCode => _languageCode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _musicVolume = (prefs.getDouble('musicVolume') ?? 0.7).clamp(0.0, 1.0);
      _sfxVolume = (prefs.getDouble('sfxVolume') ?? 0.8).clamp(0.0, 1.0);
      _brightness = (prefs.getDouble('brightness') ?? 0.8).clamp(0.0, 1.0);
      _languageCode = prefs.getString('languageCode') ?? 'it';

      if (!supportedLanguages.contains(_languageCode)) {
        _languageCode = 'it';
      }

      // Apply loaded volumes to AudioManager
      await AudioManager().updateMusicVolume(_musicVolume);
      await AudioManager().updateSfxVolume(_sfxVolume);

      notifyListeners();
    } catch (e) {
      // Continue with defaults
    }
  }

  Future<void> setMusicVolume(double value) async {
    final newValue = value.clamp(0.0, 1.0);
    if (_musicVolume == newValue) return;

    _musicVolume = newValue;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('musicVolume', _musicVolume);
      await AudioManager().updateMusicVolume(_musicVolume);
      notifyListeners();
    } catch (e) {
      // Continue without saving
    }
  }

  Future<void> setSfxVolume(double value) async {
    final newValue = value.clamp(0.0, 1.0);
    if (_sfxVolume == newValue) return;

    _sfxVolume = newValue;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('sfxVolume', _sfxVolume);
      await AudioManager().updateSfxVolume(_sfxVolume);

      // Don't play test sound during continuous sliding
      // Let the settings screen handle when to play sounds

      notifyListeners();
    } catch (e) {
      // Continue without saving
    }
  }

  Future<void> setBrightness(double value) async {
    final newValue = value.clamp(0.0, 1.0);
    if (_brightness == newValue) return;

    _brightness = newValue;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('brightness', _brightness);
      notifyListeners();
    } catch (e) {
      // Continue without saving
    }
  }

  Future<void> setLanguageCode(String code) async {
    if (!supportedLanguages.contains(code) || _languageCode == code) return;

    _languageCode = code;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', _languageCode);
      notifyListeners();
    } catch (e) {
      // Continue without saving
    }
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'it': return 'Italiano';
      case 'en': return 'English';
      case 'es': return 'Español';
      case 'fr': return 'Français';
      case 'de': return 'Deutsch';
      case 'pt': return 'Português';
      default: return 'Unknown';
    }
  }

  String get currentLanguageName => getLanguageName(_languageCode);

  Future<void> resetToDefaults() async {
    await setMusicVolume(0.7);
    await setSfxVolume(0.8);
    await setBrightness(0.8);
    await setLanguageCode('it');
  }
}