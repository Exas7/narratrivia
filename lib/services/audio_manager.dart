import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal() {
    _initializeAppLifecycleListener();
  }

  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  double _musicVolume = 0.7;
  double _sfxVolume = 0.8;

  // Getters
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  // Setters per musica
  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled) {
      _backgroundMusicPlayer.pause();
    } else {
      _backgroundMusicPlayer.resume();
    }
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume;
    _backgroundMusicPlayer.setVolume(volume);
  }

  // Metodi per SettingsProvider
  Future<void> updateMusicVolume(double volume) async {
    _musicVolume = volume;
    await _backgroundMusicPlayer.setVolume(volume);
  }

  Future<void> updateSfxVolume(double volume) async {
    _sfxVolume = volume;
    await _sfxPlayer.setVolume(volume);
  }

  // Setters per SFX
  void setSfxEnabled(bool enabled) {
    _isSfxEnabled = enabled;
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume;
    _sfxPlayer.setVolume(volume);
  }

  // Gestione ciclo di vita app per soundtrack
  void _initializeAppLifecycleListener() {
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      switch (msg) {
        case 'AppLifecycleState.paused':
        case 'AppLifecycleState.inactive':
          await pauseBackgroundMusic();
          break;
        case 'AppLifecycleState.resumed':
          if (_isMusicEnabled) {
            await resumeBackgroundMusic();
          }
          break;
      }
      return null;
    });
  }

  // Musica di sottofondo
  Future<void> startBackgroundMusic() async {
    if (!_isMusicEnabled) return;

    try {
      await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundMusicPlayer.setVolume(_musicVolume);
      await _backgroundMusicPlayer.play(AssetSource('sounds/main_soundtrack.mp3'));
    } catch (e) {
      // Gestione errore silente
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundMusicPlayer.stop();
    } catch (e) {
      // Gestione errore silente
    }
  }

  Future<void> pauseBackgroundMusic() async {
    try {
      await _backgroundMusicPlayer.pause();
    } catch (e) {
      // Gestione errore silente
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_isMusicEnabled) return;

    try {
      await _backgroundMusicPlayer.resume();
    } catch (e) {
      // Gestione errore silente
    }
  }

  // Effetti sonori - PERCORSI CORRETTI
  Future<void> playNavigateForward() async {
    if (!_isSfxEnabled) return;
    await _playSfx('sounds/sfx/ui/navigate_forward.wav');
  }

  Future<void> playReturnBack() async {
    if (!_isSfxEnabled) return;
    await _playSfx('sounds/sfx/ui/return_back.wav');
  }

  // Metodo per SettingsScreen
  Future<void> playNavigationBack() async {
    await playReturnBack();
  }

  // Effetti sonori - PERCORSO CORRETTO
  Future<void> playButtonClick() async {
    if (!_isSfxEnabled) return;
    await _playSfx('sounds/sfx/ui/button_click.wav');
  }

  // Helper privato per riprodurre SFX
  Future<void> _playSfx(String assetPath) async {
    try {
      await _sfxPlayer.stop(); // Stop any current sound
      await _sfxPlayer.setVolume(_sfxVolume);
      await _sfxPlayer.play(AssetSource(assetPath), mode: PlayerMode.lowLatency);
    } catch (e) {
      // Gestione errore silente
      print('Error playing sound: $assetPath - $e'); // Debug only
    }
  }

  // Cleanup
  void dispose() {
    _backgroundMusicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}