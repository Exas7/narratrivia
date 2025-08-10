// lib/widgets/quiz/mascot_card.dart

import 'package:flutter/material.dart';
import '../../core/services/mascot_service.dart';

class MascotCard extends StatefulWidget {
  final MascotMessage message;
  final VoidCallback? onDismiss;

  const MascotCard({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  State<MascotCard> createState() => _MascotCardState();
}

class _MascotCardState extends State<MascotCard> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  bool _isAutoClosing = false;

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

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Bounce animation for mascot
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _bounceController.forward();

    // Auto-close after display duration
    if (!widget.message.isImportant) {
      Future.delayed(widget.message.displayDuration, () {
        if (mounted && !_isAutoClosing) {
          _close();
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _close() async {
    if (_isAutoClosing) return;
    _isAutoClosing = true;

    await Future.wait([
      _fadeController.reverse(),
      _slideController.reverse(),
    ]);

    if (mounted) {
      widget.onDismiss?.call();
    }
  }

  Color _getMoodColor() {
    switch (widget.message.mood) {
      case MascotMood.happy:
        return Colors.green;
      case MascotMood.sad:
        return Colors.blue[700]!;
      case MascotMood.excited:
        return Colors.orange;
      case MascotMood.thinking:
        return Colors.purple;
      case MascotMood.neutral:
        return Colors.grey;
      case MascotMood.celebration:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final moodColor = _getMoodColor();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        alignment: Alignment.center,
        child: SlideTransition(
          position: _slideAnimation,
          child: GestureDetector(
            onTap: widget.message.isImportant ? _close : null,
            child: Container(
              width: screenSize.width * 0.85,
              constraints: const BoxConstraints(
                maxWidth: 400,
                minHeight: 120,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: moodColor.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: moodColor.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  const BoxShadow(
                    color: Colors.black54,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Mascot image
                  Container(
                    width: 100,
                    height: 120,
                    padding: const EdgeInsets.all(12),
                    child: ScaleTransition(
                      scale: _bounceAnimation,
                      child: Image.asset(
                        MascotService().getMascotImagePath(widget.message.mood),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback if image not found
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: moodColor.withOpacity(0.2),
                            ),
                            child: Center(
                              child: Text(
                                _getMoodEmoji(),
                                style: const TextStyle(fontSize: 40),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Message content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Message text
                          Text(
                            widget.message.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),

                          // Tap to dismiss hint (for important messages)
                          if (widget.message.isImportant) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Tocca per continuare',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Close button (for important messages)
                  if (widget.message.isImportant)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.5),
                          size: 20,
                        ),
                        onPressed: _close,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getMoodEmoji() {
    switch (widget.message.mood) {
      case MascotMood.happy:
        return '😊';
      case MascotMood.sad:
        return '😢';
      case MascotMood.excited:
        return '🤩';
      case MascotMood.thinking:
        return '🤔';
      case MascotMood.neutral:
        return '😐';
      case MascotMood.celebration:
        return '🎉';
    }
  }
}

// Overlay widget to show mascot card above everything
class MascotOverlay extends StatefulWidget {
  final Widget child;

  const MascotOverlay({
    super.key,
    required this.child,
  });

  static MascotOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<MascotOverlayState>();
  }

  @override
  State<MascotOverlay> createState() => MascotOverlayState();
}

class MascotOverlayState extends State<MascotOverlay> {
  MascotMessage? _currentMessage;
  final List<MascotMessage> _messageQueue = [];
  bool _isShowingMessage = false;

  void showMessage(MascotMessage message) {
    if (_isShowingMessage) {
      // Add to queue if already showing a message
      _messageQueue.add(message);
    } else {
      // Show immediately
      setState(() {
        _currentMessage = message;
        _isShowingMessage = true;
      });
    }
  }

  void _dismissCurrent() {
    setState(() {
      _currentMessage = null;
      _isShowingMessage = false;
    });

    // Check if there are queued messages
    if (_messageQueue.isNotEmpty) {
      final nextMessage = _messageQueue.removeAt(0);
      Future.delayed(const Duration(milliseconds: 200), () {
        showMessage(nextMessage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_currentMessage != null)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: MascotCard(
                  message: _currentMessage!,
                  onDismiss: _dismissCurrent,
                ),
              ),
            ),
          ),
      ],
    );
  }
}