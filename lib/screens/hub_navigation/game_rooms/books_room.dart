import 'package:flutter/material.dart';
import '/core/services/audio_manager.dart';
import '/screens/hub_navigation/widgets/panoramic_rooms_view.dart';

class BooksRoom extends StatelessWidget {
  const BooksRoom({super.key});

  // Costanti per la stanza books
  static const Color booksColor = Color(0xFFFFBF00);
  static const String roomTitle = 'BOOKS';
  static const String imagePath = 'assets/images/backgrounds/rooms/books_room.png';
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
        primaryColor: booksColor,
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
                    color: booksColor,
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
                    color: booksColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: booksColor,
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