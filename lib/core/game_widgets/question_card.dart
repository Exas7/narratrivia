// lib/widgets/quiz/question_card.dart

import 'package:flutter/material.dart';
import '../../core/models/questions.dart';
import '../../core/models/medium_type.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final int questionNumber;
  final int totalQuestions;

  const QuestionCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
  });

  Color _getMediumColor() {
    switch (question.medium) {
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

  String _getDifficultyEmoji() {
    switch (question.difficulty) {
      case QuestionDifficulty.veryEasy:
        return '😊';
      case QuestionDifficulty.easy:
        return '🙂';
      case QuestionDifficulty.medium:
        return '😐';
      case QuestionDifficulty.hard:
        return '😰';
      case QuestionDifficulty.veryHard:
        return '🔥';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediumColor = _getMediumColor();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: mediumColor.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: mediumColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with question number and difficulty
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Question counter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: mediumColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: mediumColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Domanda $questionNumber/$totalQuestions',
                  style: TextStyle(
                    color: mediumColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Difficulty indicator
              Row(
                children: [
                  Text(
                    question.difficulty.displayName,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getDifficultyEmoji(),
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Question type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  mediumColor.withOpacity(0.3),
                  mediumColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              question.type.displayName.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Question text
          Text(
            question.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          // Image if present (for ugly images mode)
          if (question.imageUrl != null) ...[
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                question.imageUrl!,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Hint if available (shown after some time)
          if (question.hint != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Suggerimento: ${question.hint}',
                      style: TextStyle(
                        color: Colors.amber[100],
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}