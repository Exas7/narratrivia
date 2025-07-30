import 'package:flutter/material.dart';

/// Constants for the hub navigation system
class HubConstants {
  // Prevent instantiation
  HubConstants._();

  // Animation durations
  static const Duration transitionDuration = Duration(milliseconds: 150);
  static const Duration selectorAnimationDuration = Duration(milliseconds: 200);

  // Gesture thresholds
  static const double horizontalSwipeThreshold = 50.0;
  static const double verticalSwipeThreshold = 50.0;
  static const double velocityThreshold = 200.0;

  // Swipe angle tolerances (in degrees)
  static const double horizontalSwipeMaxAngle = 30.0;
  static const double verticalSwipeMaxAngle = 30.0;

  // Visual constants
  static const double selectorHeight = 60.0;
  static const double selectorItemSize = 40.0;
  static const double selectorBorderRadius = 30.0;
  static const double selectorItemBorderRadius = 8.0;

  // Medium definitions
  static const List<GameMedium> mediums = [
    GameMedium(
      id: 'videogames',
      name: 'Videogiochi',
      color: Color(0xFF63FF47), // Neon green
      icon: Icons.sports_esports,
      arcPath: 'assets/images/backgrounds/arcs/videogames_arc.png',
      roomPath: 'assets/images/backgrounds/rooms/videogames_room.png',
    ),
    GameMedium(
      id: 'books',
      name: 'Libri',
      color: Color(0xFFFFBF00), // Amber
      icon: Icons.menu_book,
      arcPath: 'assets/images/backgrounds/arcs/books_arc.png',
      roomPath: 'assets/images/backgrounds/rooms/books_room.png',
    ),
    GameMedium(
      id: 'comics',
      name: 'Fumetti',
      color: Color(0xFFFFFF00), // Yellow
      icon: Icons.auto_stories,
      arcPath: 'assets/images/backgrounds/arcs/comics_arc.png',
      roomPath: 'assets/images/backgrounds/rooms/comics_room.png',
    ),
    GameMedium(
      id: 'manga',
      name: 'Manga',
      color: Color(0xFFFF0800), // Candy apple red
      icon: Icons.book,
      arcPath: 'assets/images/backgrounds/arcs/manga_arc.png',
      roomPath: 'assets/images/backgrounds/rooms/manga_room.png',
    ),
    GameMedium(
      id: 'anime',
      name: 'Anime',
      color: Color(0xFFFFB7C5), // Cherry blossom pink
      icon: Icons.play_circle_outline,
      arcPath: 'assets/images/backgrounds/arcs/anime_arc.png',
      roomPath: 'assets/images/backgrounds/rooms/anime_room.png',
    ),
    GameMedium(
      id: 'tvseries',
      name: 'Serie TV',
      color: Color(0xFF007BFF), // Azure
      icon: Icons.tv,
      arcPath: 'assets/images/backgrounds/arcs/tvseries_arc.png',
      roomPath: 'assets/images/backgrounds/rooms/tvseries_room.png',
    ),
    GameMedium(
      id: 'movies',
      name: 'Film',
      color: Color(0xFFBD00FF), // Electric purple
      icon: Icons.movie,
      arcPath: 'assets/images/backgrounds/arcs/movie_arc.png',
      roomPath: 'assets/images/backgrounds/rooms/movies_room.png',
    ),
  ];

  // Special rooms
  static const SpecialRoom trophyHall = SpecialRoom(
    id: 'trophy_hall',
    name: 'Sala Trofei',
    backgroundPath: 'assets/images/backgrounds/rooms/trophy_hall.png',
    transitionPath: 'assets/images/backgrounds/rooms/trophyhall_transition.png',
  );

  static const SpecialRoom controlRoom = SpecialRoom(
    id: 'control_room',
    name: 'Sala Controllo',
    backgroundPath: 'assets/images/backgrounds/rooms/control_room.png',
    transitionPath: 'assets/images/backgrounds/rooms/controlroom_transition.png',
  );

  // Transition assets
  static const String corridorTransitionPath = 'assets/images/backgrounds/arcs/corridor_transition.png';

  // Route names
  static const String routePrefix = '/hub';
  static const String routeVideogamesRoom = '$routePrefix/videogames_room';
  static const String routeBooksRoom = '$routePrefix/books_room';
  static const String routeComicsRoom = '$routePrefix/comics_room';
  static const String routeMangaRoom = '$routePrefix/manga_room';
  static const String routeAnimeRoom = '$routePrefix/anime_room';
  static const String routeTvSeriesRoom = '$routePrefix/tvseries_room';
  static const String routeMoviesRoom = '$routePrefix/movies_room';
}

/// Game medium model
class GameMedium {
  final String id;
  final String name;
  final Color color;
  final IconData icon;
  final String arcPath;
  final String roomPath;

  const GameMedium({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.arcPath,
    required this.roomPath,
  });
}

/// Special room model
class SpecialRoom {
  final String id;
  final String name;
  final String backgroundPath;
  final String transitionPath;

  const SpecialRoom({
    required this.id,
    required this.name,
    required this.backgroundPath,
    required this.transitionPath,
  });
}