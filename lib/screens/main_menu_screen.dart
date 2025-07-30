// lib/screens/main_menu_screen.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'hub_navigation/medium_hub.dart';
import 'settings_screen.dart';
import 'credits_screen.dart';
import '../services/audio_manager.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _settingsController;
  late AnimationController _creditsController;
  late Animation<double> _floatAnimation;
  late Animation<double> _settingsAnimation;
  late Animation<double> _creditsAnimation;

  final List<AnimationController> _twinkleControllers = [];
  final List<Animation<double>> _twinkleAnimations = [];
  final List<Offset> _starPositions = [];

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _floatAnimation = Tween<double>(
      begin: -20.0,
      end: 20.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _settingsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _settingsAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _settingsController,
      curve: Curves.easeInOut,
    ));

    _creditsController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _creditsAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _creditsController,
      curve: Curves.easeInOut,
    ));

    _initializeTwinkleStars();

    _floatController.repeat(reverse: true);
    _settingsController.repeat(reverse: true);
    _creditsController.repeat(reverse: true);
  }

  void _initializeTwinkleStars() {
    final random = math.Random();

    for (int i = 0; i < 30; i++) {
      double x = random.nextDouble();
      double y = random.nextDouble();

      if (y < 0.2) {
        y = 0.2 + random.nextDouble() * 0.8;
      }

      if (y > 0.4 && y < 0.6) {
        if (random.nextBool()) {
          y = 0.2 + random.nextDouble() * 0.2;
        } else {
          y = 0.7 + random.nextDouble() * 0.3;
        }
      }

      _starPositions.add(Offset(x, y));

      final controller = AnimationController(
        duration: Duration(milliseconds: 1000 + random.nextInt(2000)),
        vsync: this,
      );

      final animation = Tween<double>(
        begin: 0.2,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));

      _twinkleControllers.add(controller);
      _twinkleAnimations.add(animation);

      Future.delayed(Duration(milliseconds: random.nextInt(3000)), () {
        if (mounted) {
          controller.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _settingsController.dispose();
    _creditsController.dispose();
    for (var controller in _twinkleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/external_view_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            ..._buildTwinkleStars(),

            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 750,
                  height: 300,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logos/narratrivia_logo.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 450 - 75,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: GestureDetector(
                      onTap: () async {
                        await AudioManager().playNavigateForward();
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MediumHub()),
                          );
                        }
                      },
                      child: Container(
                        width: 900,
                        height: 900,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/backgrounds/external_view_spaceship.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              top: 620,
              right: 60,
              child: AnimatedBuilder(
                animation: _settingsAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _settingsAnimation.value),
                    child: GestureDetector(
                      onTap: () async {
                        await AudioManager().playNavigateForward();
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsScreen()),
                          );
                        }
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/icons/settings_icon.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              top: 720,
              left: 60,
              child: AnimatedBuilder(
                animation: _creditsAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _creditsAnimation.value),
                    child: GestureDetector(
                      onTap: () async {
                        await AudioManager().playNavigateForward();
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CreditsScreen()),
                          );
                        }
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/icons/credits_icon.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTwinkleStars() {
    List<Widget> stars = [];
    final screenSize = MediaQuery.of(context).size;

    for (int i = 0; i < _starPositions.length; i++) {
      stars.add(
        Positioned(
          left: _starPositions[i].dx * screenSize.width,
          top: _starPositions[i].dy * screenSize.height,
          child: AnimatedBuilder(
            animation: _twinkleAnimations[i],
            builder: (context, child) {
              return Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(_twinkleAnimations[i].value),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(_twinkleAnimations[i].value * 0.5),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }

    return stars;
  }
}