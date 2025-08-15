// lib/core/game_widgets/result_overlay.dart

import 'package:flutter/material.dart';
import '../../core/models/quiz_session.dart';
import '../../core/models/medium_type.dart';
import '../../core/services/audio_manager.dart';
import '../../core/controllers/quiz_controller.dart';

class ResultOverlay extends StatefulWidget {
  final QuizSession session;
  final VoidCallback onContinue;
  final VoidCallback onReplay;
  final VoidCallback onExit;
  final GameMode? gameMode;
  final double? streakMultiplier;

  const ResultOverlay({
    super.key,
    required this.session,
    required this.onContinue,
    required this.onReplay,
    required this.onExit,
    this.gameMode,
    this.streakMultiplier,
  });

  @override
  State<ResultOverlay> createState() => _ResultOverlayState();
}

class _ResultOverlayState extends State<ResultOverlay> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _scoreController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Scale animation for container
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Score counter animation
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.session.scorePercentage,
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scoreController.forward();
    });

    _playResultSound();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  void _playResultSound() async {
    final percentage = widget.session.scorePercentage;
    if (percentage == 100) {
      // Perfect game sound
      await AudioManager().playAchievementUnlock();
    } else if (percentage >= 80) {
      await AudioManager().playLevelUp();
    } else if (percentage >= 60) {
      await AudioManager().playCorrectAnswer();
    } else {
      await AudioManager().playWrongAnswer();
    }
  }

  Color _getMediumColor() {
    final medium = widget.session.medium;
    if (medium == MediumType.videogames) {
      return const Color(0xFF63FF47);
    } else if (medium == MediumType.books) {
      return const Color(0xFFFFBF00);
    } else if (medium == MediumType.comics) {
      return const Color(0xFFFFFF00);
    } else if (medium == MediumType.manga) {
      return const Color(0xFFFF0800);
    } else if (medium == MediumType.anime) {
      return const Color(0xFFFFB7C5);
    } else if (medium == MediumType.tvSeries) {
      return const Color(0xFF007BFF);
    } else if (medium == MediumType.movies) {
      return const Color(0xFFBD00FF);
    }
    return Colors.blue;
  }

  String _getPerformanceMessage() {
    final percentage = widget.session.scorePercentage;

    // Game mode specific messages
    if (widget.gameMode == GameMode.liar || widget.gameMode == GameMode.challenge) {
      if (percentage < 100) {
        return 'Game Over! 💀';
      }
    }

    if (percentage == 100) {
      return 'PERFETTO! 🎉';
    } else if (percentage >= 90) {
      return 'Eccellente! 🌟';
    } else if (percentage >= 80) {
      return 'Ottimo lavoro! 👏';
    } else if (percentage >= 70) {
      return 'Buon risultato! 👍';
    } else if (percentage >= 60) {
      return 'Non male! 🙂';
    } else if (percentage >= 50) {
      return 'Puoi fare meglio! 💪';
    } else {
      return 'Continua a provare! 🎯';
    }
  }

  String _getGameModeTitle() {
    if (widget.gameMode == null) return 'Quiz Completato!';

    switch (widget.gameMode!) {
      case GameMode.classic:
        return 'Classic Mode Completato!';
      case GameMode.timeAttack:
        return 'Time Attack Completato!';
      case GameMode.timeSurvival:
        return 'Time Survival Terminato!';
      case GameMode.liar:
        return 'Il Bugiardo Completato!';
      case GameMode.challenge:
        return 'Challenge Mode Completato!';
      case GameMode.zen:
        return 'Zen Mode Completato!';
    }
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediumColor = _getMediumColor();
    final finalXP = widget.streakMultiplier != null
        ? (widget.session.totalXpEarned * widget.streakMultiplier!).round()
        : widget.session.totalXpEarned;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: SafeArea(
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: mediumColor.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: mediumColor.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      _getGameModeTitle(),
                      style: TextStyle(
                        color: mediumColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Performance message
                    Text(
                      _getPerformanceMessage(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Score percentage circle with animation
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: mediumColor.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background circle
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              value: 1,
                              strokeWidth: 8,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey[800]!,
                              ),
                            ),
                          ),
                          // Animated progress circle
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: AnimatedBuilder(
                              animation: _scoreAnimation,
                              builder: (context, child) {
                                return CircularProgressIndicator(
                                  value: _scoreAnimation.value / 100,
                                  strokeWidth: 8,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _scoreAnimation.value >= 80
                                        ? Colors.green
                                        : _scoreAnimation.value >= 60
                                        ? Colors.yellow
                                        : Colors.red,
                                  ),
                                  backgroundColor: Colors.transparent,
                                );
                              },
                            ),
                          ),
                          // Percentage text
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedBuilder(
                                animation: _scoreAnimation,
                                builder: (context, child) {
                                  return Text(
                                    '${_scoreAnimation.value.round()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                              Text(
                                '${widget.session.correctAnswers}/${widget.session.totalQuestions}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'XP Totali',
                            '+$finalXP',
                            Icons.star,
                            Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Tempo Medio',
                            '${widget.session.averageResponseTime.toStringAsFixed(1)}s',
                            Icons.timer,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Additional stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Durata',
                            '${widget.session.sessionDuration ~/ 60}:${(widget.session.sessionDuration % 60).toString().padLeft(2, '0')}',
                            Icons.schedule,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Max Streak',
                            widget.session.currentStreak.toString(),
                            Icons.local_fire_department,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    // Show multiplier if present
                    if (widget.streakMultiplier != null && widget.streakMultiplier! > 1.0) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.purple.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.flash_on,
                              color: Colors.purple,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Moltiplicatore finale: x${widget.streakMultiplier!.toStringAsFixed(1)}',
                              style: const TextStyle(
                                color: Colors.purple,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Action buttons - Solo RIGIOCA e CONTINUA
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await AudioManager().playButtonClick();
                              widget.onReplay();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'RIGIOCA',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await AudioManager().playButtonClick();
                              widget.onContinue();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mediumColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'CONTINUA',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}