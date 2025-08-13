// lib/screens/hub_navigation/controllers/hub_controller.dart

import 'package:flutter/material.dart';
import 'hub_constants.dart';
import 'gesture_controller.dart';
import '/core/services/audio_manager.dart';
import '../special_rooms/database_vault.dart';

class HubController extends ChangeNotifier {
  // Controllers
  final GestureController _gestureController = GestureController();

  // State variables
  int _currentArcIndex = 0;
  bool _isTransitioning = false;
  bool _isInSpecialRoom = false;
  String _currentSpecialRoom = '';
  bool lastTransitionWasHorizontal = true;
  bool _isDatabaseVaultUnlocked = false;

  // Animation controllers
  AnimationController? _transitionAnimationController;
  Animation<double>? _transitionAnimation;

  // Private variable for arc transitions
  int? _targetArcIndex;

  // Getters
  int get currentArcIndex => _currentArcIndex;
  bool get isTransitioning => _isTransitioning;
  bool get isInSpecialRoom => _isInSpecialRoom;
  String get currentSpecialRoom => _currentSpecialRoom;
  GameMedium get currentMedium => HubConstants.mediums[_currentArcIndex];
  Animation<double>? get transitionAnimation => _transitionAnimation;
  GestureController get gestureController => _gestureController;
  bool get isDatabaseVaultUnlocked => _isDatabaseVaultUnlocked;

  // NUOVO: Check Database Vault unlock status
  Future<void> checkDatabaseVaultStatus() async {
    // Per ora hardcoded, poi userà ProgressionController
    _isDatabaseVaultUnlocked = true; // Cambia in true per testare sbloccato
    notifyListeners();
  }

  /// Initialize animation controllers
  void initAnimations(TickerProvider vsync) {
    _transitionAnimationController = AnimationController(
      duration: HubConstants.transitionDuration,
      vsync: vsync,
    );

    _transitionAnimation = CurvedAnimation(
      parent: _transitionAnimationController!,
      curve: Curves.easeInOut,
    );

    _transitionAnimationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _completeEnterTransition();
      } else if (status == AnimationStatus.dismissed) {
        _completeReturnTransition();
      }
    });

    checkDatabaseVaultStatus();
  }

  /// Handle drag start
  void onDragStart(DragStartDetails details) {
    if (_isTransitioning) return;
    _gestureController.startGesture(details);
  }

  /// Handle drag update
  void onDragUpdate(DragUpdateDetails details) {
    if (_isTransitioning) return;
    _gestureController.updateGesture(details);
  }

  /// Handle drag end
  Future<void> onDragEnd(DragEndDetails details) async {
    if (_isTransitioning) return;

    final direction = _gestureController.endGesture(details);

    switch (direction) {
      case SwipeDirection.left:
        await navigateToNextArc();
        break;
      case SwipeDirection.right:
        await navigateToPreviousArc();
        break;
      case SwipeDirection.up:
        await navigateToControlRoom();
        break;
      case SwipeDirection.down:
        await navigateToTrophyHall();
        break;
      case SwipeDirection.none:
        break;
    }
  }

  Future<void> onTap(BuildContext context, TapUpDetails details) async {
    if (_isTransitioning) return;

    final tapPosition = details.globalPosition;

    if (!_isInSpecialRoom && _gestureController.isSelectorTap(context, tapPosition)) {
      final index = _gestureController.getSelectorIndex(context, tapPosition);
      if (index != null && index != _currentArcIndex) {
        await navigateToArc(index);
      }
      return;
    }

    if (!_isInSpecialRoom && _gestureController.isCenterArcTap(context, tapPosition)) {
      await enterCurrentRoom(context);
    }
  }

  /// Navigate to next arc
  Future<void> navigateToNextArc() async {
    final nextIndex = (_currentArcIndex + 1) % HubConstants.mediums.length;
    await _startArcTransition(nextIndex);
  }

  /// Navigate to previous arc
  Future<void> navigateToPreviousArc() async {
    final previousIndex = (_currentArcIndex - 1 + HubConstants.mediums.length) % HubConstants.mediums.length;
    await _startArcTransition(previousIndex);
  }

  /// Navigate to a specific arc by index
  Future<void> navigateToArc(int index) async {
    if (index == _currentArcIndex || index < 0 || index >= HubConstants.mediums.length) return;
    await _startArcTransition(index);
  }

  Future<void> _startArcTransition(int targetIndex) async {
    if (_isTransitioning) return;
    _isTransitioning = true;
    _targetArcIndex = targetIndex;
    lastTransitionWasHorizontal = true;
    notifyListeners();

    await AudioManager().playTransitionSwoosh();
    _transitionAnimationController?.forward();
  }

  /// Navigate to Trophy Hall
  Future<void> navigateToTrophyHall() async {
    await _startSpecialRoomTransition(HubConstants.trophyHall.id);
  }

  /// Navigate to Control Room
  Future<void> navigateToControlRoom() async {
    await _startSpecialRoomTransition(HubConstants.controlRoom.id);
  }

  Future<void> _startSpecialRoomTransition(String roomId) async {
    if (_isTransitioning) return;
    _isTransitioning = true;
    _currentSpecialRoom = roomId;
    lastTransitionWasHorizontal = false;
    notifyListeners();

    await AudioManager().playTransitionSwoosh();
    _transitionAnimationController?.forward();
  }

  /// Return from special room with reverse animation
  Future<void> returnFromSpecialRoom() async {
    if (!_isInSpecialRoom || _isTransitioning) return;

    _isTransitioning = true;
    notifyListeners();

    await AudioManager().playTransitionSwoosh();
    _transitionAnimationController?.reverse();
  }

  /// Enter the room for the current medium - MODIFICATO
  Future<void> enterCurrentRoom(BuildContext context) async {
    if (_isTransitioning) return;

    // Check se è Database Vault (indice 7)
    if (_currentArcIndex == 7) {
      if (!_isDatabaseVaultUnlocked) {
        // Mostra messaggio locked
        await AudioManager().playReturnBack();
        return;
      }

      await AudioManager().playNavigateForward();
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DatabaseVault()),
        );
      }
      return;
    }

    // Codice esistente per altre stanze
    await AudioManager().playNavigateForward();
    final routeName = _getRouteForMedium(currentMedium.id);
    if (context.mounted && routeName != null) {
      Navigator.pushNamed(context, routeName);
    }
  }

  String? _getRouteForMedium(String mediumId) {
    switch (mediumId) {
      case 'videogames': return HubConstants.routeVideogamesRoom;
      case 'books': return HubConstants.routeBooksRoom;
      case 'comics': return HubConstants.routeComicsRoom;
      case 'manga': return HubConstants.routeMangaRoom;
      case 'anime': return HubConstants.routeAnimeRoom;
      case 'tvseries': return HubConstants.routeTvSeriesRoom;
      case 'movies': return HubConstants.routeMoviesRoom;
      default: return null;
    }
  }

  /// Called when the FORWARD animation is complete
  void _completeEnterTransition() {
    if (_currentSpecialRoom.isNotEmpty) {
      _isInSpecialRoom = true;
    } else if (_targetArcIndex != null) {
      _currentArcIndex = _targetArcIndex!;
      _targetArcIndex = null;
    }
    _isTransitioning = false;
    if (lastTransitionWasHorizontal) {
      _transitionAnimationController?.reset();
    }
    notifyListeners();
  }

  /// Called when the REVERSE animation is complete
  void _completeReturnTransition() {
    _isInSpecialRoom = false;
    _currentSpecialRoom = '';
    _isTransitioning = false;
    _transitionAnimationController?.reset();
    notifyListeners();
  }

  /// Get background path for the current state
  String getCurrentBackgroundPath() {
    if (_isTransitioning && _isInSpecialRoom) {
      return HubConstants.mediums[_currentArcIndex].arcPath;
    }
    if (_isInSpecialRoom) {
      return _currentSpecialRoom == HubConstants.trophyHall.id
          ? HubConstants.trophyHall.backgroundPath
          : HubConstants.controlRoom.backgroundPath;
    }

    // Check se è Database Vault e se è locked
    if (_currentArcIndex == 7 && !_isDatabaseVaultUnlocked) {
      return HubConstants.mediums[7].lockedArcPath ?? currentMedium.arcPath;
    }

    return currentMedium.arcPath;
  }

  /// Get the path for the transition overlay image
  String? getTransitionPath() {
    if (!_isTransitioning) return null;
    if (_currentSpecialRoom.isNotEmpty) {
      return _currentSpecialRoom == HubConstants.trophyHall.id
          ? HubConstants.trophyHall.transitionPath
          : HubConstants.controlRoom.transitionPath;
    }
    return HubConstants.corridorTransitionPath;
  }

  @override
  void dispose() {
    _transitionAnimationController?.dispose();
    super.dispose();
  }
}