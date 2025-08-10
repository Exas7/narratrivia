// lib/screens/hub_navigation/special_rooms/database_vault.dart

import 'package:flutter/material.dart';
import '../../../core/services/audio_manager.dart';
import '../../../core/models/questions.dart';
import '../../../core/models/medium_type.dart';

class DatabaseVault extends StatefulWidget {
  const DatabaseVault({super.key});

  @override
  State<DatabaseVault> createState() => _DatabaseVaultState();
}

class _DatabaseVaultState extends State<DatabaseVault> {
  final Color vaultColor = const Color(0xFF9C27B0);

  // Impostazioni quiz personalizzato
  QuestionType? selectedType;
  QuestionDifficulty? selectedDifficulty;
  MediumType? selectedMedium;
  int numberOfQuestions = 10;
  bool mixMediums = false;
  bool timerEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/backgrounds/special_rooms/database_vault.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay scuro
          Container(
            color: Colors.black.withOpacity(0.5),
          ),

          // Contenuto principale
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildModeSection(),
                        const SizedBox(height: 30),
                        _buildCustomQuizSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () {
              AudioManager().playReturnBack();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(0.5),
              padding: const EdgeInsets.all(12),
            ),
          ),

          const Spacer(),

          // Title
          Text(
            'DATABASE VAULT',
            style: TextStyle(
              color: vaultColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              shadows: [Shadow(blurRadius: 20, color: vaultColor)],
            ),
          ),

          const Spacer(),
          const SizedBox(width: 54), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildModeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: vaultColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MODALITÀ SPECIALI',
            style: TextStyle(
              color: vaultColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          _buildSpecialModeButton('SURVIVAL MODE', 'Continua fino al primo errore', Icons.favorite, Colors.red),
          const SizedBox(height: 12),
          _buildSpecialModeButton('TIME ATTACK', 'Più risposte possibili in 2 minuti', Icons.timer, Colors.orange),
          const SizedBox(height: 12),
          _buildSpecialModeButton('BOSS RUSH', 'Solo domande difficoltà massima', Icons.whatshot, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildCustomQuizSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: vaultColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUIZ PERSONALIZZATO',
            style: TextStyle(
              color: vaultColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),

          // Numero domande
          _buildSliderOption(
            'Numero Domande',
            numberOfQuestions.toDouble(),
            5, 50,
                (value) => setState(() => numberOfQuestions = value.toInt()),
          ),

          // Mix mediums toggle
          _buildToggleOption(
            'Mix Multi-Medium',
            'Domande da tutti i medium',
            mixMediums,
                (value) => setState(() => mixMediums = value),
          ),

          // Timer toggle
          _buildToggleOption(
            'Timer',
            'Limite di tempo per risposta',
            timerEnabled,
                (value) => setState(() => timerEnabled = value),
          ),

          const SizedBox(height: 20),

          // Start button
          Center(
            child: ElevatedButton(
              onPressed: _startCustomQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: vaultColor,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'AVVIA QUIZ PERSONALIZZATO',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialModeButton(String title, String subtitle, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        AudioManager().playButtonClick();
        // TODO: Implementa modalità speciali
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: color.withOpacity(0.7), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderOption(String title, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
            Text('${value.toInt()}', style: TextStyle(color: vaultColor, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          activeColor: vaultColor,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildToggleOption(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: vaultColor,
          ),
        ],
      ),
    );
  }

  void _startCustomQuiz() {
    AudioManager().playNavigateForward();
    // TODO: Implementa avvio quiz personalizzato
  }
}