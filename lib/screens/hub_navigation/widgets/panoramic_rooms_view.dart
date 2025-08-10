import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../core/services/settings_provider.dart';

class PanoramicRoomsView extends StatefulWidget {
  final String imagePath;
  final double imageWidth;
  final double imageHeight;
  final double viewportHeightRatio;
  final Widget? overlayContent;
  final Color? primaryColor;

  const PanoramicRoomsView({
    super.key,
    required this.imagePath,
    required this.imageWidth,
    required this.imageHeight,
    this.viewportHeightRatio = 0.65,
    this.overlayContent,
    this.primaryColor,
  });

  @override
  State<PanoramicRoomsView> createState() => _PanoramicRoomsViewState();
}

class _PanoramicRoomsViewState extends State<PanoramicRoomsView>
    with SingleTickerProviderStateMixin {
  // Controller per l'animazione a 60fps
  late AnimationController _animationController;

  // Sottoscrizione al sensore
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  // Variabili di posizione
  double _currentOffsetX = 0.0;
  double _targetOffsetX = 0.0;

  // Variabili per drag
  double _dragStartX = 0.0;
  double _dragStartOffset = 0.0;

  // Calibrazione
  double? _initialXValue;

  // Parametri di controllo
  static const double maxTiltValue = 3.0; // Sensibilità
  static const double deadZone = 0.3;     // Zona morta centrale
  static const double smoothingFactor = 0.1; // Fattore di smussatura (0.0 a 1.0)

  // Limiti calcolati
  double _maxOffsetX = 0.0;
  bool _isLayoutCalculated = false;

  // Modalità di controllo
  bool _useDragControl = false;

  @override
  void initState() {
    super.initState();

    // Il controller aggiorna la logica a ogni frame
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // La durata non è importante qui
    )..addListener(_updateAnimationLoop);

    _animationController.repeat(); // Avvia il loop di animazione

    // Leggi la preferenza iniziale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      _useDragControl = settings.useDragControl;
      if (!_useDragControl) {
        _initializeAccelerometer();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ascolta i cambiamenti nelle impostazioni
    final settings = Provider.of<SettingsProvider>(context);
    if (_useDragControl != settings.useDragControl) {
      _useDragControl = settings.useDragControl;
      if (_useDragControl) {
        // Passa a drag control
        _accelerometerSubscription?.cancel();
        _accelerometerSubscription = null;
        _initialXValue = null;
      } else {
        // Passa ad accelerometro
        _initializeAccelerometer();
      }
    }
  }

  // Il sensore imposta solo la destinazione
  void _initializeAccelerometer() {
    _accelerometerSubscription?.cancel();

    _accelerometerSubscription = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 32),
    ).listen((AccelerometerEvent event) {
      if (!mounted || !_isLayoutCalculated || _useDragControl) return;

      if (_initialXValue == null) {
        _initialXValue = event.x;
        return;
      }

      double relativeX = event.x - _initialXValue!;

      if (relativeX.abs() < deadZone) {
        relativeX = 0.0;
      } else {
        relativeX = relativeX - (relativeX.sign * deadZone);
      }

      relativeX = relativeX.clamp(-maxTiltValue, maxTiltValue);
      double normalizedTilt = relativeX / maxTiltValue;
      _targetOffsetX = -normalizedTilt * _maxOffsetX;
    });
  }

  // A ogni frame, la posizione attuale si avvicina a quella di destinazione
  void _updateAnimationLoop() {
    if (!mounted) return;

    setState(() {
      if (_useDragControl) {
        // In modalità drag, la posizione corrente è già la target
        _currentOffsetX = _targetOffsetX;
      } else {
        // In modalità accelerometro, interpola verso la target
        _currentOffsetX += (_targetOffsetX - _currentOffsetX) * smoothingFactor;
      }
    });
  }

  // Gestione del drag
  void _onPanStart(DragStartDetails details) {
    if (!_useDragControl) return;
    _dragStartX = details.localPosition.dx;
    _dragStartOffset = _currentOffsetX;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_useDragControl || !_isLayoutCalculated) return;

    final dragDelta = details.localPosition.dx - _dragStartX;
    _targetOffsetX = (_dragStartOffset + dragDelta).clamp(-_maxOffsetX, _maxOffsetX);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (!_isLayoutCalculated) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final imageDisplayHeight = screenHeight * widget.viewportHeightRatio;
        final imageDisplayWidth = (imageDisplayHeight / widget.imageHeight) * widget.imageWidth;

        _maxOffsetX = (imageDisplayWidth - screenWidth) / 2;
        if (_maxOffsetX < 0) _maxOffsetX = 0;
        _isLayoutCalculated = true;
      }

      // Il resto della UI rimane invariato, ma aggiungiamo GestureDetector per drag
      return Stack(
        children: [
          // Vista panoramica con supporto drag
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            child: Center(
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight * widget.viewportHeightRatio,
                child: ClipRect(
                  child: Transform.translate(
                    offset: Offset(_currentOffsetX, 0),
                    child: OverflowBox(
                      maxWidth: double.infinity,
                      child: Image.asset(
                        widget.imagePath,
                        width: (constraints.maxHeight * widget.viewportHeightRatio / widget.imageHeight) * widget.imageWidth,
                        height: constraints.maxHeight * widget.viewportHeightRatio,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Overlay content
          if (widget.overlayContent != null) widget.overlayContent!,

          // Barra di posizione
          if (_maxOffsetX > 0)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: SafeArea(
                child: Center(
                  child: Container(
                    width: 200,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.translate(
                          offset: Offset((_currentOffsetX / _maxOffsetX * 98).clamp(-98, 98), 0),
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: widget.primaryColor ?? Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (widget.primaryColor ?? Colors.white).withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Istruzioni dinamiche basate sulla modalità
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: SafeArea(
              child: AnimatedOpacity(
                opacity: _currentOffsetX.abs() < 10 ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 300),
                child: Consumer<SettingsProvider>(
                  builder: (context, settings, child) {
                    return Text(
                      settings.useDragControl
                          ? 'Trascina per esplorare la stanza'
                          : 'Inclina il dispositivo per esplorare la stanza',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}