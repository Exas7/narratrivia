import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'hub_constants.dart';

/// Enum for gesture directions
enum SwipeDirection {
  left,
  right,
  up,
  down,
  none,
}

/// Controller for managing gesture recognition in the hub
class GestureController {
  // Tracking variables
  Offset? _startPosition;
  Offset? _currentPosition;
  DateTime? _startTime;

  // Gesture state
  bool _isTracking = false;

  /// Start tracking a gesture
  void startGesture(DragStartDetails details) {
    _startPosition = details.globalPosition;
    _currentPosition = details.globalPosition;
    _startTime = DateTime.now();
    _isTracking = true;
  }

  /// Update gesture tracking
  void updateGesture(DragUpdateDetails details) {
    if (!_isTracking) return;
    _currentPosition = details.globalPosition;
  }

  /// End gesture and determine final action
  SwipeDirection endGesture(DragEndDetails details) {
    if (!_isTracking || _startPosition == null || _currentPosition == null || _startTime == null) {
      _resetGesture();
      return SwipeDirection.none;
    }

    final dx = _currentPosition!.dx - _startPosition!.dx;
    final dy = _currentPosition!.dy - _startPosition!.dy;
    final velocity = details.primaryVelocity ?? 0;
    final angle = math.atan2(dy.abs(), dx.abs()) * (180 / math.pi);
    final isQuickSwipe = DateTime.now().difference(_startTime!).inMilliseconds < 500;

    SwipeDirection finalDirection = SwipeDirection.none;

    if (dx.abs() > dy.abs()) {
      if (angle <= HubConstants.horizontalSwipeMaxAngle) {
        if (dx.abs() >= HubConstants.horizontalSwipeThreshold || (velocity.abs() >= HubConstants.velocityThreshold && isQuickSwipe)) {
          finalDirection = dx > 0 ? SwipeDirection.right : SwipeDirection.left;
        }
      }
    } else {
      if (angle >= (90 - HubConstants.verticalSwipeMaxAngle)) {
        if (dy.abs() >= HubConstants.verticalSwipeThreshold || (velocity.abs() >= HubConstants.velocityThreshold && isQuickSwipe)) {
          finalDirection = dy > 0 ? SwipeDirection.down : SwipeDirection.up;
        }
      }
    }

    _resetGesture();
    return finalDirection;
  }

  /// Reset all tracking variables
  void _resetGesture() {
    _startPosition = null;
    _currentPosition = null;
    _startTime = null;
    _isTracking = false;
  }

  /// NEW: Check if a tap is in the central arc area (for entering rooms)
  bool isCenterArcTap(BuildContext context, Offset tapPosition) {
    final screenSize = MediaQuery.of(context).size;

    // Define the tappable area based on screen proportions (approximates the red rectangle)
    final topBoundary = screenSize.height * 0.25;
    final bottomBoundary = screenSize.height * 0.75;
    final leftBoundary = screenSize.width * 0.2;
    final rightBoundary = screenSize.width * 0.8;

    return (tapPosition.dy > topBoundary && tapPosition.dy < bottomBoundary) &&
        (tapPosition.dx > leftBoundary && tapPosition.dx < rightBoundary);
  }

  /// Check if a tap is in the selector area
  bool isSelectorTap(BuildContext context, Offset tapPosition) {
    final screenSize = MediaQuery.of(context).size;
    final selectorTop = screenSize.height - HubConstants.selectorHeight - 40;
    return tapPosition.dy >= selectorTop;
  }

  /// Get selector index from tap position
  int? getSelectorIndex(BuildContext context, Offset tapPosition) {
    if (!isSelectorTap(context, tapPosition)) return null;

    final screenWidth = MediaQuery.of(context).size.width;
    final itemCount = HubConstants.mediums.length;
    final totalWidth = screenWidth - 40; // Assuming 20 padding on each side
    final itemWidth = totalWidth / itemCount;

    final relativeX = tapPosition.dx - 20;
    if (relativeX < 0) return null;

    final index = (relativeX / itemWidth).floor();
    return (index >= 0 && index < itemCount) ? index : null;
  }
}