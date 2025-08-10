import 'package:flutter/material.dart';
import '/core/services/audio_manager.dart';
import '/screens/hub_navigation/widgets/panoramic_rooms_view.dart';

class MangaRoom extends StatelessWidget {
  const MangaRoom({super.key});

  // Costanti per la stanza manga
  static const Color mangaColor = Color(0xFFFF0800);
  static const String roomTitle = 'MANGA';
  static const String imagePath = 'assets/images/backgrounds/rooms/manga_room.png';
  static const double imageWidth = 2560.0;
  static const double imageHeight = 1440.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PanoramicRoomsView(
        imagePath: imagePath,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        primaryColor: mangaColor,
        overlayContent: Stack(
          children: [
            // Pulsante back
            Positioned(
              top: 40,
              left: 16,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: mangaColor,
                    size: 30,
                  ),
                  onPressed: () async {
                    await AudioManager().playReturnBack();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ),

            // Titolo della stanza
            Positioned(
              top: 50,
              right: 20,
              child: SafeArea(
                child: Text(
                  roomTitle,
                  style: const TextStyle(
                    color: mangaColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: mangaColor,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Qui puoi aggiungere altri elementi UI specifici della stanza
            // come pulsanti per iniziare quiz, statistiche, etc.
          ],
        ),
      ),
    );
  }
}