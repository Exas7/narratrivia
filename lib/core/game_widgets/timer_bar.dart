// lib/widgets/quiz/timer_bar.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/audio_manager.dart';

class TimerBar extends StatefulWidget {
  final int duration; // in seconds
  final VoidCallback onTimeout;
  final bool isPaused;

  const TimerBar({
    super.key,
    required this.duration,
    required this.onTimeout,
    this.isPaused = false,
  });

  @override
  State<TimerBar> createState() => _TimerBarState();
}

class _TimerBarState extends State<TimerBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  Timer? _tickTimer;
  int _remainingSeconds = 0;
  bool _hasPlayedWarning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.duration;

    _animationController = AnimationController(
      duration: Duration(seconds: widget.duration),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onTimeout();
      }
    });

    _startTimer();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(TimerBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPaused && !oldWidget.isPaused) {
      _pauseTimer();
    } else if (!widget.isPaused && oldWidget.isPaused) {
      _resumeTimer();
    }
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!widget.isPaused && mounted) {
        setState(() {
          _remainingSeconds--;
        });

        // Play warning sound in last 5 seconds
        if (_remainingSeconds <= 5 && _remainingSeconds > 0) {
          if (!_hasPlayedWarning) {
            AudioManager().playTimerWarning();
            _hasPlayedWarning = true;
          }
          AudioManager().playTimerTick();
        }

        if (_remainingSeconds <= 0) {
          timer.cancel();
        }
      }
    });
  }

  void _pauseTimer() {
    _animationController.stop();
    _tickTimer?.cancel();
  }

  void _resumeTimer() {
    if (_remainingSeconds > 0) {
      _animationController.forward();
      _startTimer();
    }
  }

  Color _getProgressColor(double progress) {
    if (progress > 0.6) {
      return Colors.green;
    } else if (progress > 0.3) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Time remaining text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tempo rimanente',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                final color = _getProgressColor(_progressAnimation.value);
                return Text(
                  '${_remainingSeconds}s',
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final color = _getProgressColor(_progressAnimation.value);
              return Stack(
                children: [
                  // Background
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Progress
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressAnimation.value,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color,
                            color.withOpacity(0.7),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Pulsing effect for warning
                  if (_progressAnimation.value < 0.2)
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progressAnimation.value,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.5, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.withOpacity(value * 0.8),
                                  Colors.red.withOpacity(value * 0.4),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        },
                        onEnd: () {
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}