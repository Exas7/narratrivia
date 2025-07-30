import 'package:flutter/material.dart';

/// Overlay widget for smooth transitions between arcs and special rooms
class TransitionOverlay extends StatelessWidget {
  final Animation<double>? animation;
  final String? transitionImagePath;
  final String currentImagePath;
  final String? targetImagePath;
  final bool isHorizontalTransition;

  const TransitionOverlay({
    super.key,
    required this.animation,
    required this.transitionImagePath,
    required this.currentImagePath,
    this.targetImagePath,
    required this.isHorizontalTransition,
  });

  @override
  Widget build(BuildContext context) {
    if (animation == null || transitionImagePath == null || animation!.status == AnimationStatus.dismissed) {
      return Image.asset(
        currentImagePath,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return AnimatedBuilder(
      animation: animation!,
      builder: (context, child) {
        if (isHorizontalTransition) {
          // Horizontal transition with corridor blur
          return Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: 1.0 - animation!.value,
                child: Image.asset(
                  currentImagePath,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              if (animation!.value > 0)
                Opacity(
                  opacity: animation!.value,
                  child: Image.asset(
                    transitionImagePath!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
            ],
          );
        } else {
          // Vertical transition for special rooms
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                currentImagePath,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
              if (animation!.value > 0)
              // FIX: The offset parameter now correctly receives an Offset object
                Transform.translate(
                  offset: Offset(0, _getVerticalOffset(context, animation!.value)),
                  child: Image.asset(
                    transitionImagePath!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
            ],
          );
        }
      },
    );
  }

  // This method now correctly returns just the double value for the y-axis
  double _getVerticalOffset(BuildContext context, double animationValue) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (transitionImagePath!.contains('trophy')) {
      // Trophy Hall slides from top
      return (1.0 - animationValue) * -screenHeight;
    } else {
      // Control Room slides from bottom
      return (1.0 - animationValue) * screenHeight;
    }
  }
}