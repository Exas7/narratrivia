import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  AudioManager._internal() {
    _initializeAppLifecycleListener();
    _initializePlayers();
  }

  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  double _musicVolume = 0.7;
  double _sfxVolume = 0.8;
  bool _isMusicActuallyPlaying = false;

  final List<String> _sfxQueue = [];
  bool _isSfxCurrentlyPlaying = false;
  Timer? _sfxTimeoutTimer;

  // Getters
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  bool get isMusicPlaying => _isMusicActuallyPlaying;

  void _initializePlayers() {
    _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
    _backgroundMusicPlayer.setPlayerMode(PlayerMode.mediaPlayer);

    _backgroundMusicPlayer.onPlayerStateChanged.listen((PlayerState state) {
      _isMusicActuallyPlaying = (state == PlayerState.playing);
    });

    _sfxPlayer.setReleaseMode(ReleaseMode.release);
    _sfxPlayer.setPlayerMode(PlayerMode.mediaPlayer);

    _sfxPlayer.onPlayerComplete.listen((_) {
      _cancelSfxTimeout();
      _isSfxCurrentlyPlaying = false;
      _processNextSfx();
    });
  }

  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled) {
      if (_isMusicActuallyPlaying) {
        _backgroundMusicPlayer.pause();
      }
    } else {
      if (_backgroundMusicPlayer.state == PlayerState.paused) {
        _backgroundMusicPlayer.resume();
      }
    }
  }

  Future<void> updateMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    try {
      await _backgroundMusicPlayer.setVolume(_musicVolume);
    } catch (e) {
      // Silent error handling
    }
  }

  Future<void> updateSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    try {
      await _sfxPlayer.setVolume(_sfxVolume);
    } catch (e) {
      // Silent error handling
    }
  }

  void setSfxEnabled(bool enabled) {
    _isSfxEnabled = enabled;
    if (!enabled) {
      _sfxQueue.clear();
      _sfxPlayer.stop();
      _cancelSfxTimeout();
      _isSfxCurrentlyPlaying = false;
    }
  }

  void _initializeAppLifecycleListener() {
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      switch (msg) {
        case 'AppLifecycleState.paused':
        case 'AppLifecycleState.inactive':
          if (_isMusicActuallyPlaying) {
            await _backgroundMusicPlayer.pause();
          }
          break;
        case 'AppLifecycleState.resumed':
          if (_isMusicEnabled && _backgroundMusicPlayer.state == PlayerState.paused) {
            await resumeBackgroundMusic();
          }
          break;
      }
      return null;
    });
  }

  Future<void> startBackgroundMusic() async {
    if (!_isMusicEnabled) return;

    try {
      if (_backgroundMusicPlayer.state == PlayerState.playing) {
        await _backgroundMusicPlayer.stop();
      }
      await _backgroundMusicPlayer.setVolume(_musicVolume);
      await _backgroundMusicPlayer.play(AssetSource('sounds/main_soundtrack.mp3'));
    } catch (e) {
      _isMusicActuallyPlaying = false;
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundMusicPlayer.stop();
    } catch (e) {
      // Silent error handling
    }
  }

  Future<void> pauseBackgroundMusic() async {
    if (_backgroundMusicPlayer.state == PlayerState.playing) {
      try {
        await _backgroundMusicPlayer.pause();
      } catch (e) {
        // Silent error handling
      }
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_isMusicEnabled) return;
    if (_backgroundMusicPlayer.state == PlayerState.paused) {
      try {
        await _backgroundMusicPlayer.resume();
      } catch (e) {
        // Silent error handling
      }
    }
  }

  Future<void> playNavigateForward() async {
    await _playSfx('sounds/sfx/ui/navigate_forward.wav');
  }

  Future<void> playReturnBack() async {
    await _playSfx('sounds/sfx/ui/return_back.wav');
  }

  Future<void> playNavigationBack() async {
    await playReturnBack();
  }

  Future<void> playButtonClick() async {
    await _playSfx('sounds/sfx/ui/button_click.wav');
  }

  Future<void> playTransitionSwoosh() async {
    if (!_isSfxCurrentlyPlaying) {
      await _playSfx('sounds/sfx/ui/transition_swoosh.wav');
    }
  }

  // ===== NUOVI METODI PER IL QUIZ SYSTEM =====

  // Play correct answer sound
  Future<void> playCorrectAnswer() async {
    if (_isSfxEnabled) {
      await _playSfx('assets/sounds/sfx/game/correct_answer.wav');
    }
  }

  // Play wrong answer sound
  Future<void> playWrongAnswer() async {
    if (_isSfxEnabled) {
      await _playSfx('assets/sounds/sfx/game/wrong_answer.wav');
    }
  }

  // Play timer tick sound
  Future<void> playTimerTick() async {
    if (_isSfxEnabled) {
      await _playSfx('assets/sounds/sfx/game/timer_tick.wav');
    }
  }

  // Play timer warning sound
  Future<void> playTimerWarning() async {
    if (_isSfxEnabled) {
      await _playSfx('assets/sounds/sfx/game/timer_warning.wav');
    }
  }

  // Play level up sound
  Future<void> playLevelUp() async {
    if (_isSfxEnabled) {
      await _playSfx('assets/sounds/sfx/game/level_up.wav');
    }
  }

  // Play achievement unlock sound
  Future<void> playAchievementUnlock() async {
    if (_isSfxEnabled) {
      await _playSfx('assets/sounds/sfx/game/achievement_unlock.wav');
    }
  }

  Future<void> _playSfx(String assetPath) async {
    if (!_isSfxEnabled) return;

    _sfxQueue.add(assetPath);
    if (!_isSfxCurrentlyPlaying) {
      _processNextSfx();
    }
  }

  Future<void> _processNextSfx() async {
    if (_sfxQueue.isEmpty || !_isSfxEnabled || _isSfxCurrentlyPlaying) {
      return;
    }

    _isSfxCurrentlyPlaying = true;
    final assetPath = _sfxQueue.removeAt(0);

    _startSfxTimeout();

    try {
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      _cancelSfxTimeout();
      _isSfxCurrentlyPlaying = false;
      _processNextSfx();
    }
  }

  void _startSfxTimeout() {
    _cancelSfxTimeout();
    _sfxTimeoutTimer = Timer(const Duration(milliseconds: 300), () {
      _isSfxCurrentlyPlaying = false;
      _processNextSfx();
    });
  }

  void _cancelSfxTimeout() {
    _sfxTimeoutTimer?.cancel();
    _sfxTimeoutTimer = null;
  }

  void dispose() {
    _cancelSfxTimeout();
    _backgroundMusicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}