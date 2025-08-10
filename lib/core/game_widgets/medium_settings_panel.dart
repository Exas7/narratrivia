// lib/widgets/quiz/medium_settings_panel.dart

import 'package:flutter/material.dart';
import '../../core/models/medium_type.dart';
import '../../core/models/questions.dart';

class MediumSettingsPanel extends StatefulWidget {
  final MediumType medium;
  final Map<String, dynamic> currentSettings;
  final Function(Map<String, dynamic>) onSettingsChanged;
  final VoidCallback onClose;

  const MediumSettingsPanel({
    super.key,
    required this.medium,
    required this.currentSettings,
    required this.onSettingsChanged,
    required this.onClose,
  });

  @override
  State<MediumSettingsPanel> createState() => _MediumSettingsPanelState();
}

class _MediumSettingsPanelState extends State<MediumSettingsPanel> {
  late Map<String, dynamic> _settings;

  @override
  void initState() {
    super.initState();
    _settings = Map<String, dynamic>.from(widget.currentSettings);

    // Initialize default settings if not present
    _settings['difficulty'] ??= QuestionDifficulty.medium;
    _settings['numberOfQuestions'] ??= 10;
    _settings['enableTimer'] ??= true;
    _settings['showHints'] ??= false;
    _settings['enabledModes'] ??= {
      QuestionType.truefalse: true,
      QuestionType.multiple: true,
      QuestionType.uglyImages: false,
      QuestionType.misleading: false,
    };
  }

  Color _getMediumColor() {
    switch (widget.medium) {
      case MediumType.videogames:
        return const Color(0xFF63FF47);
      case MediumType.books:
        return const Color(0xFFFFBF00);
      case MediumType.comics:
        return const Color(0xFFFFFF00);
      case MediumType.manga:
        return const Color(0xFFFF0800);
      case MediumType.anime:
        return const Color(0xFFFFB7C5);
      case MediumType.tvSeries:
        return const Color(0xFF007BFF);
      case MediumType.movies:
        return const Color(0xFFBD00FF);
    }
  }

  void _updateSetting(String key, dynamic value) {
    setState(() {
      _settings[key] = value;
    });
    widget.onSettingsChanged(_settings);
  }

  @override
  Widget build(BuildContext context) {
    final mediumColor = _getMediumColor();
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width * 0.85,
      height: screenSize.height * 0.7,
      constraints: const BoxConstraints(
        maxWidth: 500,
        maxHeight: 600,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: mediumColor.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: mediumColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: mediumColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              border: Border(
                bottom: BorderSide(
                  color: mediumColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: mediumColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Impostazioni ${widget.medium.displayName}',
                      style: TextStyle(
                        color: mediumColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white70,
                  ),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          // Settings content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Difficulty selection
                  _buildSectionTitle('Difficoltà'),
                  const SizedBox(height: 12),
                  _buildDifficultySelector(),
                  const SizedBox(height: 24),

                  // Number of questions
                  _buildSectionTitle('Numero Domande'),
                  const SizedBox(height: 12),
                  _buildQuestionCountSelector(),
                  const SizedBox(height: 24),

                  // Game modes
                  _buildSectionTitle('Modalità di Gioco'),
                  const SizedBox(height: 12),
                  _buildGameModesSelector(),
                  const SizedBox(height: 24),

                  // Additional options
                  _buildSectionTitle('Opzioni Aggiuntive'),
                  const SizedBox(height: 12),
                  _buildToggleOption(
                    'Timer',
                    'Abilita il timer per le domande',
                    Icons.timer,
                    'enableTimer',
                  ),
                  const SizedBox(height: 12),
                  _buildToggleOption(
                    'Suggerimenti',
                    'Mostra suggerimenti dopo 10 secondi',
                    Icons.lightbulb_outline,
                    'showHints',
                  ),
                ],
              ),
            ),
          ),

          // Save button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: mediumColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              border: Border(
                top: BorderSide(
                  color: mediumColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mediumColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'SALVA IMPOSTAZIONI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDifficultySelector() {
    final mediumColor = _getMediumColor();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: QuestionDifficulty.values.map((difficulty) {
        final isSelected = _settings['difficulty'] == difficulty;

        return GestureDetector(
          onTap: () => _updateSetting('difficulty', difficulty),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? mediumColor.withOpacity(0.3)
                  : Colors.grey[800],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? mediumColor
                    : Colors.grey[700]!,
                width: 2,
              ),
            ),
            child: Text(
              difficulty.displayName,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionCountSelector() {
    final mediumColor = _getMediumColor();
    final options = [5, 10, 15, 20, 25];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((count) {
        final isSelected = _settings['numberOfQuestions'] == count;

        return GestureDetector(
          onTap: () => _updateSetting('numberOfQuestions', count),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected
                  ? mediumColor.withOpacity(0.3)
                  : Colors.grey[800],
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? mediumColor
                    : Colors.grey[700]!,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGameModesSelector() {
    final mediumColor = _getMediumColor();
    final enabledModes = _settings['enabledModes'] as Map<QuestionType, bool>;

    return Column(
      children: QuestionType.values.map((type) {
        final isEnabled = enabledModes[type] ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              final newModes = Map<QuestionType, bool>.from(enabledModes);
              newModes[type] = !isEnabled;
              _updateSetting('enabledModes', newModes);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isEnabled
                    ? mediumColor.withOpacity(0.1)
                    : Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isEnabled
                      ? mediumColor.withOpacity(0.5)
                      : Colors.grey[800]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isEnabled ? mediumColor : Colors.grey[600]!,
                        width: 2,
                      ),
                      color: isEnabled
                          ? mediumColor.withOpacity(0.3)
                          : Colors.transparent,
                    ),
                    child: isEnabled
                        ? Icon(
                      Icons.check,
                      size: 16,
                      color: mediumColor,
                    )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.displayName,
                          style: TextStyle(
                            color: isEnabled ? Colors.white : Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getTypeDescription(type),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildToggleOption(
      String title,
      String description,
      IconData icon,
      String settingKey,
      ) {
    final mediumColor = _getMediumColor();
    final isEnabled = _settings[settingKey] as bool;

    return InkWell(
      onTap: () => _updateSetting(settingKey, !isEnabled),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isEnabled ? mediumColor : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isEnabled,
              onChanged: (value) => _updateSetting(settingKey, value),
              activeColor: mediumColor,
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeDescription(QuestionType type) {
    switch (type) {
      case QuestionType.truefalse:
        return '2 opzioni: Vero o Falso';
      case QuestionType.multiple:
        return '4 opzioni di risposta';
      case QuestionType.uglyImages:
        return 'Identifica da immagini brutte';
      case QuestionType.misleading:
        return 'Descrizioni fuorvianti';
    }
  }
}