import 'package:flutter/material.dart';
import '/core/services/audio_manager.dart';
import '../controllers/hub_constants.dart';

/// Control Room special room - swipe down to return to hub
class ControlRoom extends StatelessWidget {
  const ControlRoom({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragEnd: (details) async {
          // Check for downward swipe (positive velocity)
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > HubConstants.velocityThreshold) {
            await AudioManager().playReturnBack();
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              HubConstants.controlRoom.backgroundPath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}