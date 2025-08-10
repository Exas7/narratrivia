// lib/widgets/quiz/answer_button.dart

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
      return widget.isCorrect
          ? Colors.green.withOpacity(0.3)
          : Colors.red.withOpacity(0.3);
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
      return widget.isCorrect ? Colors.green : Colors.red;
    }

    if (widget.isDisabled) {
      return Colors.grey[600]!;
    }

    return widget.color ?? Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Main label
                  Padding(
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

                  // Result indicator
                  if (widget.showResult)
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
      ),
    );
  }
}