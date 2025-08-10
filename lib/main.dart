import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'core/services/settings_provider.dart';
import 'l10n/app_localizations.dart';

import 'screens/hub_navigation/controllers/hub_constants.dart';
import 'screens/hub_navigation/game_rooms/anime_room.dart';
import 'screens/hub_navigation/game_rooms/books_room.dart';
import 'screens/hub_navigation/game_rooms/comics_room.dart';
import 'screens/hub_navigation/game_rooms/manga_room.dart';
import 'screens/hub_navigation/game_rooms/movies_room.dart';
import 'screens/hub_navigation/game_rooms/tvseries_room.dart';
import 'screens/hub_navigation/game_rooms/videogames_room.dart';


void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive full-screen mode to handle system gestures
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Configure AudioContext for proper audio focus management
  try {
    await AudioPlayer.global.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          stayAwake: true,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
      ),
    );
  } catch (e) {
    // AudioContext configuration failed, continue with defaults
    debugPrint('AudioContext configuration failed: $e');
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Narratrivia',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.black,
              fontFamily: 'Roboto',
            ),
            locale: Locale(settings.languageCode),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('it'),
              Locale('en'),
              Locale('es'),
              Locale('fr'),
              Locale('de'),
              Locale('pt'),
            ],
            home: const _PreloadWrapper(),
            // The routes map enables named navigation
            routes: {
              HubConstants.routeVideogamesRoom: (context) => const VideogamesRoom(),
              HubConstants.routeBooksRoom: (context) => const BooksRoom(),
              HubConstants.routeComicsRoom: (context) => const ComicsRoom(),
              HubConstants.routeMangaRoom: (context) => const MangaRoom(),
              HubConstants.routeAnimeRoom: (context) => const AnimeRoom(),
              HubConstants.routeTvSeriesRoom: (context) => const TvSeriesRoom(),
              HubConstants.routeMoviesRoom: (context) => const MoviesRoom(),
            },
          );
        },
      ),
    );
  }
}

// Wrapper widget per gestire il pre-caricamento
class _PreloadWrapper extends StatefulWidget {
  const _PreloadWrapper();

  @override
  State<_PreloadWrapper> createState() => _PreloadWrapperState();
}

class _PreloadWrapperState extends State<_PreloadWrapper> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Avvia il pre-caricamento delle immagini pesanti in background
    _preloadImages();
  }

  void _preloadImages() {
    // Pre-carica le immagini pesanti in background senza bloccare l'UI
    precacheImage(const AssetImage('assets/images/backgrounds/splashscreen_narratrivia.png'), context);
    precacheImage(const AssetImage('assets/images/backgrounds/gagofed_logo.png'), context);
    precacheImage(const AssetImage('assets/images/backgrounds/external_view_background.png'), context);
    precacheImage(const AssetImage('assets/images/backgrounds/external_view_spaceship.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    // Mostra immediatamente la SplashScreen mentre le immagini si caricano in background
    return const SplashScreen();
  }
}