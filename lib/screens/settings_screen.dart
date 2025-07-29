import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/audio_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<String, String> _languageNames = {
    'it': 'Italiano',
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'pt': 'Português',
  };

  // Track previous slider values to detect 10% changes
  double _previousMusicVolume = -1;
  double _previousSfxVolume = -1;
  double _previousBrightness = -1;

  @override
  void initState() {
    super.initState();
    // Initialize with current values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      _previousMusicVolume = settings.musicVolume;
      _previousSfxVolume = settings.sfxVolume;
      _previousBrightness = settings.brightness;
    });
  }

  bool _shouldPlayClickSound(double oldValue, double newValue) {
    // Convert to percentage and check if we crossed a 10% boundary
    int oldPercentage = (oldValue * 10).round();
    int newPercentage = (newValue * 10).round();
    return oldPercentage != newPercentage;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
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
          child: Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return Column(
                children: [
                  _buildHeader(localizations),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildVolumeSlider(
                            title: localizations.translate('music_volume'),
                            value: settings.musicVolume,
                            color: Colors.blue,
                            onChanged: (value) async {
                              if (_shouldPlayClickSound(_previousMusicVolume, value)) {
                                await AudioManager().playButtonClick();
                              }
                              _previousMusicVolume = value;
                              settings.setMusicVolume(value);
                            },
                          ),
                          const SizedBox(height: 30),
                          _buildVolumeSlider(
                            title: localizations.translate('sfx_volume'),
                            value: settings.sfxVolume,
                            color: Colors.green,
                            onChanged: (value) async {
                              if (_shouldPlayClickSound(_previousSfxVolume, value)) {
                                await AudioManager().playButtonClick();
                              }
                              _previousSfxVolume = value;
                              settings.setSfxVolume(value);
                            },
                          ),
                          const SizedBox(height: 30),
                          _buildVolumeSlider(
                            title: localizations.translate('brightness'),
                            value: settings.brightness,
                            color: Colors.orange,
                            onChanged: (value) async {
                              if (_shouldPlayClickSound(_previousBrightness, value)) {
                                await AudioManager().playButtonClick();
                              }
                              _previousBrightness = value;
                              settings.setBrightness(value);
                            },
                          ),
                          const SizedBox(height: 30),
                          _buildLanguageDropdown(settings, localizations),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                  // Back button at bottom left
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: GestureDetector(
                        onTap: () async {
                          await AudioManager().playReturnBack();
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Center(
        child: Text(
          localizations.translate('settings'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
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
      ),
    );
  }

  Widget _buildVolumeSlider({
    required String title,
    required double value,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.3),
            thumbColor: Colors.white,
            overlayColor: color.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: '${(value * 100).round()}%',
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown(SettingsProvider settings, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.translate('language'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: settings.languageCode,
              dropdownColor: Colors.black87,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              isExpanded: true,
              items: SettingsProvider.supportedLanguages.map((code) {
                return DropdownMenuItem<String>(
                  value: code,
                  child: Text(_languageNames[code] ?? code),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null && newValue != settings.languageCode) {
                  settings.setLanguageCode(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}