import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/settings_provider.dart';
import '../../l10n/app_localizations.dart';
import '/core/services/audio_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  final Map<String, String> _languageNames = {
    'it': 'Italiano',
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'pt': 'Português',
  };

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
    _animationController.dispose();
    super.dispose();
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
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _buildHeader(localizations),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(30),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildVolumeSlider(
                                title: localizations.translate('music_volume'),
                                value: settings.musicVolume,
                                icon: Icons.music_note,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1E88E5), Color(0xFF64B5F6)],
                                ),
                                onChanged: (value) async {
                                  settings.setMusicVolume(value);
                                },
                                onChangeEnd: (value) async {
                                  await AudioManager().playButtonClick();
                                },
                              ),
                              const SizedBox(height: 35),
                              _buildVolumeSlider(
                                title: localizations.translate('sfx_volume'),
                                value: settings.sfxVolume,
                                icon: Icons.volume_up,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF43A047), Color(0xFF81C784)],
                                ),
                                onChanged: (value) async {
                                  settings.setSfxVolume(value);
                                },
                                onChangeEnd: (value) async {
                                  await AudioManager().playButtonClick();
                                },
                              ),
                              const SizedBox(height: 35),
                              _buildVolumeSlider(
                                title: localizations.translate('brightness'),
                                value: settings.brightness,
                                icon: Icons.brightness_6,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFB8C00), Color(0xFFFFB74D)],
                                ),
                                onChanged: (value) async {
                                  settings.setBrightness(value);
                                },
                                onChangeEnd: (value) async {
                                  await AudioManager().playButtonClick();
                                },
                              ),
                              const SizedBox(height: 35),
                              _buildLanguageDropdown(settings, localizations),
                              const SizedBox(height: 35),
                              _buildPanoramicControlToggle(settings, localizations),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Back button
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: _buildBackButton(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.3),
                Colors.purple.withOpacity(0.3),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            localizations.translate('settings').toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
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
    );
  }

  Widget _buildVolumeSlider({
    required String title,
    required double value,
    required IconData icon,
    required Gradient gradient,
    required ValueChanged<double> onChanged,
    required ValueChanged<double>? onChangeEnd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Text(
                '${(value * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              trackHeight: 8.0,
              trackShape: GradientRectangularSliderTrackShape(gradient: gradient),
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 14,
                elevation: 5,
              ),
              overlayColor: Colors.white.withOpacity(0.1),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 0),
              valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Slider(
              value: value,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown(SettingsProvider settings, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.language,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  localizations.translate('language'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: settings.languageCode,
              dropdownColor: Colors.black.withOpacity(0.95),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: Colors.white,
                size: 30,
              ),
              isExpanded: true,
              borderRadius: BorderRadius.circular(15),
              items: SettingsProvider.supportedLanguages.map((code) {
                return DropdownMenuItem<String>(
                  value: code,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(_languageNames[code] ?? code),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) async {
                if (newValue != null && newValue != settings.languageCode) {
                  await AudioManager().playButtonClick();
                  settings.setLanguageCode(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPanoramicControlToggle(SettingsProvider settings, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00ACC1), Color(0xFF4DD0E1)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.touch_app,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  localizations.translate('panoramic_control'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (settings.useDragControl) {
                      await AudioManager().playButtonClick();
                      settings.setUseDragControl(false);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !settings.useDragControl
                          ? Colors.cyan.withOpacity(0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: !settings.useDragControl
                            ? Colors.cyan
                            : Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.screen_rotation,
                            color: !settings.useDragControl
                                ? Colors.white
                                : Colors.white60,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                localizations.translate('accelerometer'),
                                style: TextStyle(
                                  color: !settings.useDragControl
                                      ? Colors.white
                                      : Colors.white60,
                                  fontSize: 16,
                                  fontWeight: !settings.useDragControl
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (!settings.useDragControl) {
                      await AudioManager().playButtonClick();
                      settings.setUseDragControl(true);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: settings.useDragControl
                          ? Colors.cyan.withOpacity(0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: settings.useDragControl
                            ? Colors.cyan
                            : Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.swipe,
                            color: settings.useDragControl
                                ? Colors.white
                                : Colors.white60,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                localizations.translate('drag'),
                                style: TextStyle(
                                  color: settings.useDragControl
                                      ? Colors.white
                                      : Colors.white60,
                                  fontSize: 16,
                                  fontWeight: settings.useDragControl
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () async {
        // Ottieni il Navigator prima dell'await
        final navigator = Navigator.of(context);

        // Ora puoi fare l'operazione asincrona
        await AudioManager().playReturnBack();

        // Doppio controllo di sicurezza: usa il navigator salvato E verifica mounted
        if (context.mounted) {
          navigator.pop();
        }
      },
      child: Container(
        width: 60,
        height: 60,
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
          size: 28,
        ),
      ),
    );
  }
}

// Custom TrackShape per gradient - versione semplificata
class GradientRectangularSliderTrackShape extends RectangularSliderTrackShape {
  final Gradient gradient;

  const GradientRectangularSliderTrackShape({required this.gradient});

  @override
  void paint(
      PaintingContext context,
      Offset offset, {
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required TextDirection textDirection,
        required Offset thumbCenter,
        Offset? secondaryOffset,
        bool isDiscrete = false,
        bool isEnabled = false,
      }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final activeTrackRadius = Radius.circular(trackRect.height / 2);
    final inactiveTrackRadius = Radius.circular(trackRect.height / 2);

    final Paint activePaint = Paint()
      ..shader = gradient.createShader(trackRect);

    final Paint inactivePaint = Paint()
      ..color = Colors.white.withOpacity(0.2);

    final activeTrackRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );

    final inactiveTrackRect = Rect.fromLTRB(
      thumbCenter.dx,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
    );

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(activeTrackRect, activeTrackRadius),
      activePaint,
    );

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(inactiveTrackRect, inactiveTrackRadius),
      inactivePaint,
    );
  }
}