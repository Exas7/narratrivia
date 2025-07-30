// lib/screens/hub_navigation/medium_hub.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/hub_constants.dart';
import 'controllers/hub_controller.dart';
import 'widgets/arc_selector.dart';
import 'widgets/transition_overlay.dart';

class MediumHub extends StatefulWidget {
  const MediumHub({super.key});

  @override
  State<MediumHub> createState() => _MediumHubState();
}

class _MediumHubState extends State<MediumHub> with TickerProviderStateMixin {
  late HubController _hubController;

  @override
  void initState() {
    super.initState();
    _hubController = HubController();
    _hubController.initAnimations(this);
  }

  @override
  void dispose() {
    _hubController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HubController>.value(
      value: _hubController,
      child: Consumer<HubController>(
        builder: (context, controller, child) {
          // UPDATED: Wrapped with PopScope to disable native back gesture
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              // Do nothing, effectively disabling the gesture
              return;
            },
            child: Scaffold(
              body: Stack(
                children: [
                  _buildBackground(controller),

                  if (!controller.isInSpecialRoom)
                    _buildHubGestureLayer(controller),

                  if (controller.isInSpecialRoom)
                    _buildSpecialRoomGestureLayer(controller),

                  if (!controller.isInSpecialRoom)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: ArcSelector(
                        currentIndex: controller.currentArcIndex,
                        isVisible: !controller.isTransitioning,
                        onItemTap: (index) async {
                          await controller.navigateToArc(index);
                        },
                      ),
                    ),

                  if (controller.isInSpecialRoom)
                    Positioned(
                      bottom: 40,
                      left: 20,
                      child: IconButton(
                        onPressed: () => controller.returnFromSpecialRoom(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.5),
                          padding: const EdgeInsets.all(12),
                        ),
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

  Widget _buildBackground(HubController controller) {
    return TransitionOverlay(
      animation: controller.transitionAnimation,
      transitionImagePath: controller.getTransitionPath(),
      currentImagePath: controller.getCurrentBackgroundPath(),
      targetImagePath: null,
      isHorizontalTransition: controller.lastTransitionWasHorizontal,
    );
  }

  Widget _buildHubGestureLayer(HubController controller) {
    return GestureDetector(
      onPanStart: controller.onDragStart,
      onPanUpdate: controller.onDragUpdate,
      onPanEnd: controller.onDragEnd,
      // UPDATED: Added onTapUp to handle both central arc and selector taps
      onTapUp: (details) {
        if (controller.gestureController.isCenterArcTap(context, details.globalPosition)) {
          controller.enterCurrentRoom(context);
        } else if (controller.gestureController.isSelectorTap(context, details.globalPosition)) {
          final index = controller.gestureController.getSelectorIndex(context, details.globalPosition);
          if (index != null) {
            controller.navigateToArc(index);
          }
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildSpecialRoomGestureLayer(HubController controller) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity;
        if (velocity == null) return;

        if (controller.currentSpecialRoom == HubConstants.trophyHall.id && velocity < -HubConstants.velocityThreshold) {
          controller.returnFromSpecialRoom();
        }

        if (controller.currentSpecialRoom == HubConstants.controlRoom.id && velocity > HubConstants.velocityThreshold) {
          controller.returnFromSpecialRoom();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}