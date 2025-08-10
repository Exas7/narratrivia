// lib/widgets/quiz/result_overlay.dart

import 'package:flutter/material.dart';
import '../../core/models/quiz_session.dart';
import '../../core/models/medium_type.dart';
import '../../core/services/audio_manager.dart';

class ResultOverlay extends StatefulWidget {
  final QuizSession session;
  final VoidCallback onContinue;
  final VoidCallback onReplay;
  final VoidCallback onExit;

  const ResultOverlay({
    super.key,
    required this.session,
    required this.onContinue,
    required this.onReplay,
    required this.onExit,
  });

  @override
  State<ResultOverlay> createState() => _ResultOverlayState();
}

class _ResultOverlayState extends State<ResultOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _playResultSound();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _playResultSound() async {
    final percentage = widget.session.scorePercentage;
    if (percentage >= 80) {
      await AudioManager().playLevelUp();
    } else if (percentage >= 60) {
      await AudioManager().playCorrectAnswer();
    } else {
      await AudioManager().playWrongAnswer();
    }
  }

  Color _getMediumColor() {
    switch (widget.session.medium) {
      case MediumType.videogames:
        return const Color(0xFF63FF47);
      case MediumType.books:
        return const Color(0xFFFFBF00);
      case MediumType.comics:
        return const Color(0xFFFFFF00);
      case MediumType.manga:
        return const Color(0xFFFF0800);
      case MediumType.anime:
        return const Color(0xFFFFB7C5);
      case MediumType.tvSeries:
        return const Color(0xFF007BFF);
      case MediumType.movies:
        return const Color(0xFFBD00FF);
    }
  }

  String _getPerformanceMessage() {
    final percentage = widget.session.scorePercentage;
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
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediumColor = _getMediumColor();
    final percentage = widget.session.scorePercentage.round();

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
                      'Quiz Completato!',
                      style: TextStyle(
                        color: mediumColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
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

                    // Score percentage circle
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
                          CircularProgressIndicator(
                            value: 1,
                            strokeWidth: 8,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.grey[800]!,
                            ),
                          ),
                          // Progress circle
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              value: widget.session.scorePercentage / 100,
                              strokeWidth: 8,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                mediumColor,
                              ),
                              backgroundColor: Colors.grey[800],
                            ),
                          ),
                          // Percentage text
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$percentage%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
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
                            'XP Guadagnati',
                            '+${widget.session.totalXpEarned}',
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
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onReplay,
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
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onContinue,
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
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: widget.onExit,
                      child: Text(
                        'Torna alla stanza',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
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