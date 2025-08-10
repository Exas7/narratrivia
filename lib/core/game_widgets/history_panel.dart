// lib/widgets/quiz/history_panel.dart

import 'package:flutter/material.dart';
import '../../core/models/medium_type.dart';

class HistoryPanel extends StatelessWidget {
  final MediumType medium;
  final List<Map<String, dynamic>> gameHistory;
  final VoidCallback onClose;

  const HistoryPanel({
    super.key,
    required this.medium,
    required this.gameHistory,
    required this.onClose,
  });

  Color _getMediumColor() {
    switch (medium) {
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  IconData _getQuestionTypeIcon(String type) {
    switch (type) {
      case 'truefalse':
        return Icons.check_box;
      case 'multiple':
        return Icons.list;
      case 'uglyImages':
        return Icons.image;
      case 'misleading':
        return Icons.psychology;
      default:
        return Icons.quiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediumColor = _getMediumColor();
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width * 0.85,
      height: screenSize.height * 0.7,
      constraints: const BoxConstraints(
        maxWidth: 500,
        maxHeight: 600,
      ),
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
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: mediumColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              border: Border(
                bottom: BorderSide(
                  color: mediumColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: mediumColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Storico Partite',
                      style: TextStyle(
                        color: mediumColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white70,
                  ),
                  onPressed: onClose,
                ),
              ],
            ),
          ),

          // History list
          Expanded(
            child: gameHistory.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox,
                    color: Colors.grey[600],
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nessuna partita giocata',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inizia a giocare per vedere\nil tuo storico qui!',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: gameHistory.length,
              itemBuilder: (context, index) {
                final game = gameHistory[index];
                final date = game['startTime'] as DateTime;
                final score = (game['scorePercentage'] as num).round();
                final xp = game['totalXpEarned'] as int;
                final questionType = game['questionType'] as String;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: mediumColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date and time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDate(date),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _formatTime(date),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Game info
                      Row(
                        children: [
                          // Question type icon
                          Icon(
                            _getQuestionTypeIcon(questionType),
                            color: mediumColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),

                          // Score
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: score >= 80
                                  ? Colors.green.withOpacity(0.2)
                                  : score >= 60
                                  ? Colors.yellow.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$score%',
                              style: TextStyle(
                                color: score >= 80
                                    ? Colors.green
                                    : score >= 60
                                    ? Colors.yellow
                                    : Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Correct answers
                          Text(
                            '${game['correctAnswers']}/${game['totalQuestions']} risposte',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),

                          const Spacer(),

                          // XP earned
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '+$xp XP',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Duration and average time
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: Colors.white.withOpacity(0.4),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Durata: ${game['sessionDuration'] ~/ 60}:${(game['sessionDuration'] % 60).toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Media: ${(game['averageResponseTime'] as num).toStringAsFixed(1)}s',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Summary stats
          if (gameHistory.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: mediumColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border(
                  top: BorderSide(
                    color: mediumColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryStat(
                    'Partite',
                    gameHistory.length.toString(),
                    Icons.gamepad,
                  ),
                  _buildSummaryStat(
                    'Media',
                    '${_calculateAverageScore(gameHistory)}%',
                    Icons.trending_up,
                  ),
                  _buildSummaryStat(
                    'XP Totale',
                    _calculateTotalXP(gameHistory).toString(),
                    Icons.star,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
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

  int _calculateAverageScore(List<Map<String, dynamic>> history) {
    if (history.isEmpty) return 0;
    final total = history.fold<double>(
      0,
          (sum, game) => sum + (game['scorePercentage'] as num).toDouble(),
    );
    return (total / history.length).round();
  }

  int _calculateTotalXP(List<Map<String, dynamic>> history) {
    return history.fold<int>(
      0,
          (sum, game) => sum + (game['totalXpEarned'] as int),
    );
  }
}