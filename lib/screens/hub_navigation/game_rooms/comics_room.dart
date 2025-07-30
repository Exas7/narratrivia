import 'package:flutter/material.dart';
import '../../../services/audio_manager.dart';
import '../controllers/hub_constants.dart';

class ComicsRoom extends StatelessWidget {
  const ComicsRoom({super.key});

  @override
  Widget build(BuildContext context) {
    final medium = HubConstants.mediums[2]; // Comics

    return Scaffold(
      body: Stack(
        children: [
          // Placeholder background with medium color
          Container(
            width: double.infinity,
            height: double.infinity,
            color: medium.color,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    medium.icon,
                    size: 120,
                    color: Colors.black.withOpacity(0.3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    medium.name.toUpperCase(),
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.3),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Back button
          Positioned(
            bottom: 40,
            left: 20,
            child: IconButton(
              onPressed: () async {
                await AudioManager().playReturnBack();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 30,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.5),
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}