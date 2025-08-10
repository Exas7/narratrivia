// lib/widgets/quiz/score_display.dart

import 'package:flutter/material.dart';

class ScoreDisplay extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final int correctAnswers;
  final int currentStreak;

  const ScoreDisplay({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = totalQuestions > 0
        ? (correctAnswers / (currentQuestion - 1) * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Correct answers
          _buildStatItem(
            icon: Icons.check_circle,
            iconColor: Colors.green,
            value: correctAnswers.toString(),
            label: 'Corrette',
          ),

          // Vertical divider
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withOpacity(0.2),
          ),

          // Accuracy
          _buildStatItem(
            icon: Icons.analytics,
            iconColor: Colors.blue,
            value: '$accuracy%',
            label: 'Precisione',
          ),

          // Vertical divider
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withOpacity(0.2),
          ),

          // Current streak
          _buildStreakItem(),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakItem() {
    Color streakColor = Colors.orange;
    IconData streakIcon = Icons.local_fire_department;

    if (currentStreak >= 10) {
      streakColor = Colors.red;
      streakIcon = Icons.whatshot;
    } else if (currentStreak >= 5) {
      streakColor = Colors.orange;
    } else if (currentStreak >= 3) {
      streakColor = Colors.yellow;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                streakIcon,
                key: ValueKey(streakIcon),
                color: streakColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Text(
                currentStreak.toString(),
                key: ValueKey(currentStreak),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Streak',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}