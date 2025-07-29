import 'package:flutter/material.dart';

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSection(String title, List<Map<String, String>> roles) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15),
          ...roles.map((role) => Container(
            margin: const EdgeInsets.only(bottom: 8),
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
                Text(
                  role['role']!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        'CREDITS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 4,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: SingleChildScrollView(
                      controller: _scrollController,
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
                          ),
                          _buildSection(
                            'AUDIO & MUSICA',
                            [
                              {'name': 'Suno AI', 'role': 'Music Composition & Soundtrack'},
                              {'name': 'Suno AI', 'role': 'Sound Effects & Interactive Audio'},
                              {'name': 'Suno AI', 'role': 'Ambient Sounds & Atmosphere'},
                              {'name': 'Suno AI', 'role': 'Audio Mixing & Mastering'},
                            ],
                          ),
                          _buildSection(
                            'SUPPORTO & ASSISTENZA',
                            [
                              {'name': 'Claude (Anthropic)', 'role': 'Brainstorming & Creative Support'},
                              {'name': 'Claude (Anthropic)', 'role': 'Content Generation & Questions'},
                              {'name': 'Claude (Anthropic)', 'role': 'Localization & Translation'},
                              {'name': 'Claude (Anthropic)', 'role': 'Game Balance & Testing'},
                            ],
                          ),
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  '🚀 NARRATRIVIA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Un progetto sviluppato con approccio AI-First\nDove un umano e le AI collaborano per creare magia',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  '© 2025 GagoFed Studio\nPowered by Human Creativity + AI Technology',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 12,
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
    );
  }
}