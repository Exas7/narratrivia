// lib/core/game_widgets/answer_button.dart

import 'package:flutter/material.dart';
import '../../core/services/audio_manager.dart';

class AnswerButton extends StatefulWidget {
  final dynamic answer;
  final String label;
  final VoidCallback onTap;
  final bool isDisabled;
  final Color? color;
  final bool showResult;
  final bool isCorrect;

  const AnswerButton({
    super.key,
    required this.answer,
    required this.label,
    required this.onTap,
    this.isDisabled = false,
    this.color,
    this.showResult = false,
    this.isCorrect = false,
  });

  @override
  State<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _flashAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Animation for flash effect when showing result
    _flashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start flash animation if showing result
    if (widget.showResult) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(AnswerButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger flash animation when result is shown
    if (!oldWidget.showResult && widget.showResult) {
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isDisabled) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.isDisabled) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  void _handleTap() async {
    if (!widget.isDisabled) {
      await AudioManager().playButtonClick();
      widget.onTap();
    }
  }

  Color _getBackgroundColor() {
    if (widget.showResult) {
      // Durante il feedback, mostra verde o rosso
      if (widget.isCorrect) {
        return Colors.green.withOpacity(0.3);
      } else {
        return Colors.red.withOpacity(0.3);
      }
    }

    if (widget.isDisabled) {
      return Colors.grey[800]!.withOpacity(0.5);
    }

    if (_isPressed) {
      return (widget.color ?? Colors.blue).withOpacity(0.3);
    }

    return Colors.grey[800]!.withOpacity(0.8);
  }

  Color _getBorderColor() {
    if (widget.showResult) {
      // Durante il feedback, bordo verde o rosso
      if (widget.isCorrect) {
        return Colors.green;
      } else {
        return Colors.red;
      }
    }

    if (widget.isDisabled) {
      return Colors.grey[600]!;
    }

    return widget.color ?? Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    // Se showResult è true, anima l'apparizione del risultato
    if (widget.showResult) {
      return AnimatedBuilder(
        animation: _flashAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.95 + (_flashAnimation.value * 0.05),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 60,
              decoration: BoxDecoration(
                color: widget.isCorrect
                    ? Colors.green.withOpacity(0.2 + _flashAnimation.value * 0.2)
                    : Colors.red.withOpacity(0.2 + _flashAnimation.value * 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isCorrect ? Colors.green : Colors.red,
                  width: 2 + _flashAnimation.value,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isCorrect
                        ? Colors.green.withOpacity(0.3 * _flashAnimation.value)
                        : Colors.red.withOpacity(0.3 * _flashAnimation.value),
                    blurRadius: 10 + (10 * _flashAnimation.value),
                    spreadRadius: 1 + (2 * _flashAnimation.value),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Main label
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Result indicator icon
                  Positioned(
                    right: 16,
                    child: Icon(
                      widget.isCorrect
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: widget.isCorrect
                          ? Colors.green
                          : Colors.red,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // Normal button (not showing result)
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? _scaleAnimation.value : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 60,
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getBorderColor(),
                  width: 2,
                ),
                boxShadow: [
                  if (!widget.isDisabled)
                    BoxShadow(
                      color: _getBorderColor().withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.isDisabled
                          ? Colors.grey[500]
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}