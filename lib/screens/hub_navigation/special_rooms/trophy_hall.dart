// lib/screens/hub_navigation/special_rooms/trophy_hall.dart

import 'package:flutter/material.dart';
import '/core/services/audio_manager.dart';
import '../controllers/hub_constants.dart';

/// Trophy Hall special room - swipe up to return to hub
class TrophyHall extends StatelessWidget {
  const TrophyHall({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragEnd: (details) async {
          // Check for upward swipe (negative velocity)
          if (details.primaryVelocity != null &&
              details.primaryVelocity! < -HubConstants.velocityThreshold) {
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
              HubConstants.trophyHall.backgroundPath,
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