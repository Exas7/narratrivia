import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../screens/main_menu_screen.dart';
import '../services/audio_manager.dart';

class CompanyLogoScreen extends StatefulWidget {
  const CompanyLogoScreen({super.key});

  @override
  State<CompanyLogoScreen> createState() => _CompanyLogoScreenState();
}

class _CompanyLogoScreenState extends State<CompanyLogoScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeInController;
  late AnimationController _fadeOutController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();

    _fadeInController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.elasticOut,
    ));

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeIn,
    ));

    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeOutController,
      curve: Curves.easeOut,
    ));

    _startLogoSequence();
  }

  void _startLogoSequence() async {
    // Fade-in from black (1 second)
    await _fadeInController.forward();

    // Hold visibility (1 second)
    await Future.delayed(const Duration(seconds: 1));

    // Start fade-out to black
    _fadeOutController.forward();

    // Start music 100ms after fade-out begins
    await Future.delayed(const Duration(milliseconds: 100));

    // FIX: Restored the full try-catch block for robust error handling
    try {
      await AudioManager().startBackgroundMusic();
    } catch (e) {
      // It's good practice to log errors during development
      if (kDebugMode) {
        print('Error starting background music: $e');
      }
    }

    // Wait for the rest of the fade-out (remaining 2400ms)
    await Future.delayed(const Duration(milliseconds: 2400));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainMenuScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([_fadeInController, _fadeOutController]),
        builder: (context, child) {
          final opacity = _fadeInAnimation.value * _fadeOutAnimation.value;

          return Opacity(
            opacity: opacity,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/backgrounds/gagofed_logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 60.0),
                        child: Column(
                          children: [
                            Text(
                              'GAGOFED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 3.0,
                                shadows: [
                                  Shadow(
                                    offset: Offset(2.0, 2.0),
                                    blurRadius: 4.0,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Game Development Studio',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 2.0,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}