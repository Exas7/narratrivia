// lib/core/game_widgets/quiz_overlay.dart

import 'package:flutter/material.dart';
import '../../core/controllers/quiz_controller.dart';
import '../../core/models/questions.dart';
import '../../core/models/medium_type.dart';
import '../../core/services/audio_manager.dart';
import 'question_card.dart';
import 'answer_button.dart';
import 'timer_bar.dart';
import 'score_display.dart';
import 'result_overlay.dart';

class QuizOverlay extends StatefulWidget {
  final QuizController controller;

  const QuizOverlay({
    super.key,
    required this.controller,
  });

  @override
  State<QuizOverlay> createState() => _QuizOverlayState();
}

class _QuizOverlayState extends State<QuizOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Track which answer was selected for feedback display
  dynamic _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Gestisce la sottomissione della risposta
  void _handleAnswer(dynamic answer) async {
    if (widget.controller.isShowingFeedback) return;

    setState(() {
      _selectedAnswer = answer;
    });

    // Invia la risposta al controller
    await widget.controller.submitAnswer(answer);
  }

  /// Gestisce il timeout del timer
  void _handleTimeout() {
    widget.controller.skipQuestion();
  }

  /// Gestisce l'uscita dal quiz
  void _handleExit() async {
    // Se il quiz è completato, esci direttamente
    if (widget.controller.currentSession?.isComplete ?? false) {
      await _fadeController.reverse();
      widget.controller.endSession();
      return;
    }

    // Altrimenti mostra conferma
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: _getMediumColor().withOpacity(0.3),
            width: 2,
          ),
        ),
        title: const Text(
          'Uscire dal quiz?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Perderai i progressi di questa partita.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Continua',
              style: TextStyle(color: _getMediumColor()),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AudioManager().playReturnBack();
              await _fadeController.reverse();
              widget.controller.endSession();
            },
            child: const Text(
              'Esci',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMediumColor() {
    final session = widget.controller.currentSession;
    if (session == null) return Colors.blue;

    // Usa il nome completo dell'enum
    if (session.medium == MediumType.videogames) {
      return const Color(0xFF63FF47);
    } else if (session.medium == MediumType.books) {
      return const Color(0xFFFFBF00);
    } else if (session.medium == MediumType.comics) {
      return const Color(0xFFFFFF00);
    } else if (session.medium == MediumType.manga) {
      return const Color(0xFFFF0800);
    } else if (session.medium == MediumType.anime) {
      return const Color(0xFFFFB7C5);
    } else if (session.medium == MediumType.tvSeries) {
      return const Color(0xFF007BFF);
    } else if (session.medium == MediumType.movies) {
      return const Color(0xFFBD00FF);
    }
    return Colors.blue;
  }

  /// Determina se mostrare il timer e in che modalità
  bool _shouldShowTimer() {
    switch (widget.controller.currentGameMode) {
      case GameMode.classic:
      case GameMode.zen:
        return false; // Timer invisibile o assente
      case GameMode.timeAttack:
      case GameMode.liar:
      case GameMode.challenge:
      case GameMode.timeSurvival:
        return true; // Timer visibile
    }
  }

  /// Determina se è un timer globale o per domanda
  bool _isGlobalTimer() {
    return widget.controller.currentGameMode == GameMode.timeAttack ||
        widget.controller.currentGameMode == GameMode.timeSurvival;
  }

  /// Determina se il timer deve essere grande (Time Survival)
  bool _isLargeTimer() {
    return widget.controller.currentGameMode == GameMode.timeSurvival;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final session = widget.controller.currentSession;
    final question = session?.currentQuestion;

    // Se il quiz è completato, mostra i risultati
    if (session != null && session.isComplete) {
      // Per Zen mode, mostra statistiche speciali
      if (widget.controller.currentGameMode == GameMode.zen) {
        final stats = widget.controller.getZenStats();
        return _buildZenResults(stats);
      }

      // Per altre modalità, mostra risultati standard
      return ResultOverlay(
        session: session,
        gameMode: widget.controller.currentGameMode,
        streakMultiplier: widget.controller.currentGameMode == GameMode.timeAttack
            ? widget.controller.streakMultiplier
            : null,
        onContinue: () {
          Navigator.of(context).pop(); // Torna alla selezione modalità
        },
        onReplay: () {
          widget.controller.replayQuiz();
        },
        onExit: () {
          widget.controller.endSession();
          Navigator.of(context).pop();
        },
      );
    }

    if (session == null || question == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: SafeArea(
          child: Stack(
            children: [
              // Contenuto principale del quiz
              Center(
                child: Container(
                  width: screenSize.width * 0.9,
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Score e stats (non in Zen mode)
                      if (widget.controller.currentGameMode != GameMode.zen) ...[
                        ScoreDisplay(
                          currentQuestion: session.currentQuestionIndex + 1,
                          totalQuestions: session.totalQuestions,
                          correctAnswers: session.correctAnswers,
                          currentStreak: widget.controller.correctStreak,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Timer - gestione differenziata per modalità
                      if (_shouldShowTimer()) ...[
                        if (_isLargeTimer()) ...[
                          // Time Survival - timer grande centrale
                          _buildLargeTimer(),
                          const SizedBox(height: 30),
                        ] else ...[
                          // Altri timer
                          _buildStandardTimer(),
                          const SizedBox(height: 20),
                        ],
                      ],

                      // Question card
                      QuestionCard(
                        question: question,
                        questionNumber: session.currentQuestionIndex + 1,
                        totalQuestions: session.totalQuestions,
                      ),
                      const SizedBox(height: 30),

                      // Answer buttons con feedback visivo
                      _buildAnswerButtons(question),

                      // Moltiplicatore per Time Attack
                      if (widget.controller.currentGameMode == GameMode.timeAttack &&
                          widget.controller.streakMultiplier > 1.0) ...[
                        const SizedBox(height: 20),
                        _buildMultiplierIndicator(),
                      ],
                    ],
                  ),
                ),
              ),

              // Pulsante di uscita
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _handleExit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardTimer() {
    final duration = _isGlobalTimer()
        ? 0
        : widget.controller.questionRemainingTime;

    final globalDuration = _isGlobalTimer()
        ? widget.controller.remainingTime
        : null;

    return TimerBar(
      duration: duration,
      onTimeout: !_isGlobalTimer() ? _handleTimeout : () {},
      isPaused: widget.controller.isLoading || widget.controller.isShowingFeedback,
    );
  }

  Widget _buildLargeTimer() {
    final remainingTime = widget.controller.remainingTime;
    final maxTime = 100; // Time Survival starts with 100 seconds
    final percentage = remainingTime / maxTime;

    Color timerColor;
    if (percentage > 0.6) {
      timerColor = Colors.green;
    } else if (percentage > 0.3) {
      timerColor = Colors.yellow;
    } else {
      timerColor = Colors.red;
    }

    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: timerColor.withOpacity(0.3),
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
              value: percentage,
              strokeWidth: 8,
              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              backgroundColor: Colors.grey[800],
            ),
          ),
          // Time text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$remainingTime',
                style: TextStyle(
                  color: timerColor,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'secondi',
                style: TextStyle(
                  color: timerColor.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButtons(Question question) {
    final options = question.options;
    final isShowingFeedback = widget.controller.isShowingFeedback;
    final feedbackState = widget.controller.feedbackState;
    final correctAnswer = question.correctAnswer;

    // Per modalità Bugiardo, inverti la logica
    final actualCorrectAnswer = widget.controller.currentGameMode == GameMode.liar &&
        question.type == QuestionType.truefalse
        ? !(correctAnswer as bool)
        : correctAnswer;

    if (question.type == QuestionType.truefalse) {
      // Layout per Vero/Falso
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildAnswerButtonWithFeedback(
              answer: true,
              label: 'VERO',
              isCorrect: actualCorrectAnswer == true,
              isSelected: _selectedAnswer == true,
              isShowingFeedback: isShowingFeedback,
              feedbackState: feedbackState,
              baseColor: Colors.green,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildAnswerButtonWithFeedback(
              answer: false,
              label: 'FALSO',
              isCorrect: actualCorrectAnswer == false,
              isSelected: _selectedAnswer == false,
              isShowingFeedback: isShowingFeedback,
              feedbackState: feedbackState,
              baseColor: Colors.red,
            ),
          ),
        ],
      );
    } else {
      // Layout per Scelta Multipla (griglia 2x2)
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildAnswerButtonWithFeedback(
                  answer: options[0],
                  label: options[0].toString(),
                  isCorrect: correctAnswer == 0,
                  isSelected: _selectedAnswer == options[0],
                  isShowingFeedback: isShowingFeedback,
                  feedbackState: feedbackState,
                  baseColor: Colors.blue,
                  index: 0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAnswerButtonWithFeedback(
                  answer: options[1],
                  label: options[1].toString(),
                  isCorrect: correctAnswer == 1,
                  isSelected: _selectedAnswer == options[1],
                  isShowingFeedback: isShowingFeedback,
                  feedbackState: feedbackState,
                  baseColor: Colors.blue,
                  index: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (options.length > 2)
            Row(
              children: [
                Expanded(
                  child: _buildAnswerButtonWithFeedback(
                    answer: options[2],
                    label: options[2].toString(),
                    isCorrect: correctAnswer == 2,
                    isSelected: _selectedAnswer == options[2],
                    isShowingFeedback: isShowingFeedback,
                    feedbackState: feedbackState,
                    baseColor: Colors.blue,
                    index: 2,
                  ),
                ),
                const SizedBox(width: 16),
                if (options.length > 3)
                  Expanded(
                    child: _buildAnswerButtonWithFeedback(
                      answer: options[3],
                      label: options[3].toString(),
                      isCorrect: correctAnswer == 3,
                      isSelected: _selectedAnswer == options[3],
                      isShowingFeedback: isShowingFeedback,
                      feedbackState: feedbackState,
                      baseColor: Colors.blue,
                      index: 3,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
        ],
      );
    }
  }

  Widget _buildAnswerButtonWithFeedback({
    required dynamic answer,
    required String label,
    required bool isCorrect,
    required bool isSelected,
    required bool isShowingFeedback,
    required FeedbackState feedbackState,
    required Color baseColor,
    int? index,
  }) {
    // Durante il feedback
    if (isShowingFeedback) {
      // Se è la risposta corretta, mostra verde
      if (isCorrect) {
        return AnswerButton(
          answer: answer,
          label: label,
          onTap: () {}, // Disabilitato
          isDisabled: true,
          color: Colors.green,
          showResult: true,
          isCorrect: true,
        );
      }
      // Se è stata selezionata ma è sbagliata, mostra rosso
      else if (isSelected && feedbackState == FeedbackState.wrong) {
        return AnswerButton(
          answer: answer,
          label: label,
          onTap: () {}, // Disabilitato
          isDisabled: true,
          color: Colors.red,
          showResult: true,
          isCorrect: false,
        );
      }
      // Altre opzioni scompaiono
      else {
        return const SizedBox.shrink();
      }
    }

    // Durante la domanda normale
    return AnswerButton(
      answer: answer,
      label: label,
      onTap: () => _handleAnswer(answer),
      isDisabled: false,
      color: baseColor,
      showResult: false,
      isCorrect: false,
    );
  }

  Widget _buildMultiplierIndicator() {
    final multiplier = widget.controller.streakMultiplier;
    final color = multiplier >= 2.0 ? Colors.orange : Colors.yellow;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flash_on,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Moltiplicatore: x${multiplier.toStringAsFixed(1)}',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZenResults(Map<String, dynamic> stats) {
    final mediumColor = _getMediumColor();

    return Container(
      color: Colors.black.withOpacity(0.9),
      child: SafeArea(
        child: Center(
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
                  'Modalità Zen Completata',
                  style: TextStyle(
                    color: mediumColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Stats
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
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${stats['percentage']}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${stats['correctAnswers']}/${stats['totalAnswers']}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'risposte corrette',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.controller.replayQuiz();
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
                        onPressed: () {
                          widget.controller.endSession();
                          Navigator.of(context).pop();
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
    );
  }
}