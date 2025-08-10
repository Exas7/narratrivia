import 'package:flutter/material.dart';
import '../core/services/audio_manager.dart';

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildSection(String title, List<Map<String, String>> roles, Gradient gradient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...roles.map((role) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                Text(
                  role['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role['role']!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/backgrounds/external_view_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await AudioManager().playReturnBack();
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.withOpacity(0.7),
                                  Colors.red.withOpacity(0.5),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.withOpacity(0.3),
                                  Colors.purple.withOpacity(0.3),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'CREDITS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 3,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(2, 2),
                                      blurRadius: 8,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 75), // Balance for back button
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _buildSection(
                              'DIREZIONE CREATIVA & LEADERSHIP',
                              [
                                {'name': 'Io', 'role': 'Creative Director & Game Designer'},
                                {'name': 'Io', 'role': 'Art Director & Vision Holder'},
                                {'name': 'Io', 'role': 'Project Management & Coordination'},
                                {'name': 'Io', 'role': 'Narrative Director & Worldbuilding'},
                              ],
                              const LinearGradient(
                                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                              ),
                            ),
                            _buildSection(
                              'SVILUPPO & PROGRAMMAZIONE',
                              [
                                {'name': 'Claude (Anthropic)', 'role': 'Senior Developer & Code Architecture'},
                                {'name': 'Claude (Anthropic)', 'role': 'Flutter & Mobile Development'},
                                {'name': 'Claude (Anthropic)', 'role': 'Firebase Integration & Backend'},
                                {'name': 'Claude (Anthropic)', 'role': 'Bug Fixing & Code Optimization'},
                                {'name': 'Claude (Anthropic)', 'role': 'Technical Documentation'},
                              ],
                              const LinearGradient(
                                colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                              ),
                            ),
                            _buildSection(
                              'ARTE & DESIGN VISIVO',
                              [
                                {'name': 'Sora (OpenAI)', 'role': 'All Visual Assets Creation'},
                                {'name': 'Sora (OpenAI)', 'role': 'Background Art & Environments'},
                                {'name': 'Sora (OpenAI)', 'role': 'UI/UX Design & Icons'},
                                {'name': 'Sora (OpenAI)', 'role': 'Logo Design & Branding'},
                                {'name': 'Sora (OpenAI)', 'role': 'Special Effects & Animations'},
                              ],
                              const LinearGradient(
                                colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                              ),
                            ),
                            _buildSection(
                              'AUDIO & MUSICA',
                              [
                                {'name': 'Suno AI', 'role': 'Music Composition & Soundtrack'},
                                {'name': 'Suno AI', 'role': 'Sound Effects & Interactive Audio'},
                                {'name': 'Suno AI', 'role': 'Ambient Sounds & Atmosphere'},
                                {'name': 'Suno AI', 'role': 'Audio Mixing & Mastering'},
                              ],
                              const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ),
                            ),
                            _buildSection(
                              'SUPPORTO & ASSISTENZA',
                              [
                                {'name': 'Claude (Anthropic)', 'role': 'Brainstorming & Creative Support'},
                                {'name': 'Claude (Anthropic)', 'role': 'Content Generation & Questions'},
                                {'name': 'Claude (Anthropic)', 'role': 'Localization & Translation'},
                                {'name': 'Claude (Anthropic)', 'role': 'Game Balance & Testing'},
                              ],
                              const LinearGradient(
                                colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                              ),
                            ),
                            const SizedBox(height: 30),
                            Container(
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.withOpacity(0.3),
                                    Colors.blue.withOpacity(0.3),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    '🚀 NARRATRIVIA',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    'Un progetto sviluppato con approccio AI-First\nDove un umano e le AI collaborano per creare magia',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 15,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    height: 1,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withOpacity(0.5),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    '© 2025 GagoFed Studio',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Powered by Human Creativity + AI Technology',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}