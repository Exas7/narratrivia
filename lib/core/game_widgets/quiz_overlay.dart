// lib/widgets/quiz/quiz_overlay.dart

import 'package:flutter/material.dart';
import '../../core/controllers/quiz_controller.dart';
import '../../core/models/questions.dart';
import 'question_card.dart';
import 'answer_button.dart';
import 'timer_bar.dart';
import 'score_display.dart';

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

  /// Gestisce la sottomissione della risposta chiamando il controller.
  void _handleAnswer(dynamic answer) {
    // La logica è ora gestita interamente dal controller.
    widget.controller.submitAnswer(answer);
  }

  /// Gestisce il timeout chiamando il controller.
  void _handleTimeout() {
    widget.controller.skipQuestion();
  }

  /// Gestisce l'uscita dal quiz chiamando il controller.
  void _handleExit() async {
    await _fadeController.reverse();
    widget.controller.endSession();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Lo stato del quiz viene letto direttamente dal controller.
    final session = widget.controller.currentSession;
    final question = session?.currentQuestion;

    if (session == null || question == null) {
      // Mostra un caricamento o uno stato vuoto se la sessione non è pronta.
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
                      // Punteggio
                      ScoreDisplay(
                        currentQuestion: session.currentQuestionIndex + 1,
                        totalQuestions: session.totalQuestions,
                        correctAnswers: session.correctAnswers,
                        currentStreak: widget.controller.correctStreak,
                      ),
                      const SizedBox(height: 20),

                      // Barra del timer
                      TimerBar(
                        duration: question.timerDuration,
                        onTimeout: _handleTimeout,
                        // La pausa è gestita dallo stato di caricamento del controller.
                        isPaused: widget.controller.isLoading,
                        key: ValueKey('timer_${session.currentQuestionIndex}'),
                      ),
                      const SizedBox(height: 20),

                      // Card della domanda
                      QuestionCard(
                        question: question,
                        questionNumber: session.currentQuestionIndex + 1,
                        totalQuestions: session.totalQuestions,
                      ),
                      const SizedBox(height: 30),

                      // Pulsanti di risposta
                      _buildAnswerButtons(question),
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

  Widget _buildAnswerButtons(Question question) {
    final options = question.options;
    // Lo stato "disabilitato" è letto dal controller.
    final bool isAnswering = widget.controller.isLoading;

    if (question.type == QuestionType.truefalse) {
      // Layout per Vero/Falso
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: AnswerButton(
              answer: true,
              label: 'VERO',
              onTap: () => _handleAnswer(true),
              isDisabled: isAnswering,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: AnswerButton(
              answer: false,
              label: 'FALSO',
              onTap: () => _handleAnswer(false),
              isDisabled: isAnswering,
              color: Colors.red,
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
                child: AnswerButton(
                  answer: options[0],
                  label: options[0].toString(),
                  onTap: () => _handleAnswer(options[0]),
                  isDisabled: isAnswering,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AnswerButton(
                  answer: options[1],
                  label: options[1].toString(),
                  onTap: () => _handleAnswer(options[1]),
                  isDisabled: isAnswering,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (options.length > 2)
            Row(
              children: [
                Expanded(
                  child: AnswerButton(
                    answer: options[2],
                    label: options[2].toString(),
                    onTap: () => _handleAnswer(options[2]),
                    isDisabled: isAnswering,
                  ),
                ),
                const SizedBox(width: 16),
                if (options.length > 3)
                  Expanded(
                    child: AnswerButton(
                      answer: options[3],
                      label: options[3].toString(),
                      onTap: () => _handleAnswer(options[3]),
                      isDisabled: isAnswering,
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
}