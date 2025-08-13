// lib/screens/hub_navigation/game_rooms/videogames_room.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/controllers/quiz_controller.dart';
import '../../../core/models/medium_type.dart';
import '../../../core/models/questions.dart';
import '../../../core/services/audio_manager.dart';
import '../../../core/game_widgets/history_panel.dart';
import '../../../core/game_widgets/medium_settings_panel.dart';
import '../../../core/game_widgets/quiz_overlay.dart';
import '../../../core/game_widgets/result_overlay.dart';
import '../widgets/panoramic_rooms_view.dart';

class VideogamesRoom extends StatelessWidget {
  const VideogamesRoom({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuizController()..initialize('test_user_id'),
      child: const _VideogamesRoomView(),
    );
  }
}

class _VideogamesRoomView extends StatefulWidget {
  const _VideogamesRoomView();

  @override
  State<_VideogamesRoomView> createState() => _VideogamesRoomViewState();
}

class _VideogamesRoomViewState extends State<_VideogamesRoomView> {
  bool _showGameButtons = false;
  bool _showHistoryPanel = false;
  bool _showSettingsPanel = false;
  bool _showResultOverlay = false;

  @override
  void initState() {
    super.initState();
    // Carica le impostazioni del medium all'avvio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizController>().loadMediumSettings(MediumType.videogames);
    });
  }

  void _startGame(BuildContext context, QuestionType questionType, GameMode gameMode) async {
    final quizController = context.read<QuizController>();

    // Nascondi i pulsanti prima di iniziare
    setState(() {
      _showGameButtons = false;
    });

    // Avvia il quiz con la modalità selezionata
    final success = await quizController.startQuiz(
      medium: MediumType.videogames,
      questionType: questionType,
      gameMode: gameMode,
    );

    if (!success) {
      // Mostra errore se il quiz non si avvia
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(quizController.errorMessage ?? 'Errore nel caricamento del quiz'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _closeQuizOverlay(BuildContext context) {
    final quizController = context.read<QuizController>();
    quizController.endSession();
    setState(() {
      _showGameButtons = false;
      _showResultOverlay = false;
    });
  }

  void _handleQuizComplete(BuildContext context) {
    setState(() {
      _showResultOverlay = true;
    });
  }

  void _handleReplay(BuildContext context) {
    final quizController = context.read<QuizController>();
    setState(() {
      _showResultOverlay = false;
    });
    quizController.replayQuiz();
  }

  void _handleContinue(BuildContext context) {
    setState(() {
      _showResultOverlay = false;
    });
    // Qui potresti navigare a un'altra schermata o mostrare altre opzioni
  }

  void _handleExit(BuildContext context) {
    final quizController = context.read<QuizController>();
    quizController.endSession();
    setState(() {
      _showResultOverlay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediumColor = const Color(0xFF63FF47);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<QuizController>(
        builder: (context, controller, child) {
          // Controlla se il quiz è completato
          if (controller.currentSession != null &&
              controller.currentSession!.isComplete &&
              !_showResultOverlay) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleQuizComplete(context);
            });
          }

          return Stack(
            children: [
              // 1. Vista Panoramica con hotspot
              PanoramicRoomsView(
                imagePath: 'assets/images/backgrounds/rooms/videogames_room.png',
                imageWidth: 2560.0,
                imageHeight: 1440.0,
                primaryColor: mediumColor,
                overlayContent: _buildHotspots(screenWidth, screenHeight),
              ),

              // 2. UI della stanza (back button e titolo)
              _buildRoomUI(context, mediumColor),

              // 3. Pannelli overlay condizionali
              if (_showGameButtons && controller.currentSession == null && !_showResultOverlay)
                _buildGameModeSelector(context, mediumColor),

              if (_showHistoryPanel)
                _buildHistoryOverlay(context, mediumColor),

              if (_showSettingsPanel)
                _buildSettingsOverlay(context, mediumColor),

              // 4. Quiz Overlay
              if (controller.currentSession != null && !controller.currentSession!.isComplete)
                GestureDetector(
                  onTap: () {
                    // Tap fuori chiude il quiz
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Uscire dal quiz?'),
                        content: const Text('Perderai i progressi di questa partita.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Continua'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _closeQuizOverlay(context);
                            },
                            child: const Text('Esci'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: QuizOverlay(controller: controller),
                  ),
                ),

              // 5. Result Overlay
              if (_showResultOverlay && controller.currentSession != null)
                ResultOverlay(
                  session: controller.currentSession!,
                  onContinue: () => _handleContinue(context),
                  onReplay: () => _handleReplay(context),
                  onExit: () => _handleExit(context),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHotspots(double screenWidth, double screenHeight) {
    return Stack(
      children: [
        // Hotspot sinistro (20% larghezza) - Storico
        Positioned(
          left: 0,
          top: screenHeight * 0.3,
          width: screenWidth * 0.2,
          height: screenHeight * 0.4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showHistoryPanel = true;
                _showSettingsPanel = false;
                _showGameButtons = false;
              });
              AudioManager().playButtonClick();
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // Hotspot centrale (50% larghezza) - Pulsanti gioco
        Positioned(
          left: screenWidth * 0.25,
          top: screenHeight * 0.3,
          width: screenWidth * 0.5,
          height: screenHeight * 0.4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showGameButtons = !_showGameButtons;
                _showHistoryPanel = false;
                _showSettingsPanel = false;
              });
              AudioManager().playButtonClick();
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // Hotspot destro (80% larghezza) - Impostazioni
        Positioned(
          right: 0,
          top: screenHeight * 0.3,
          width: screenWidth * 0.2,
          height: screenHeight * 0.4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showSettingsPanel = true;
                _showHistoryPanel = false;
                _showGameButtons = false;
              });
              AudioManager().playButtonClick();
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomUI(BuildContext context, Color mediumColor) {
    return SafeArea(
      child: Stack(
        children: [
          // Back button
          Positioned(
            top: 16,
            left: 16,
            child: ElevatedButton(
              onPressed: () {
                AudioManager().playReturnBack();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
                backgroundColor: Colors.black.withOpacity(0.5),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),

          // Titolo stanza
          Positioned(
            top: 20,
            right: 20,
            child: Text(
              'Videogames Room',
              style: TextStyle(
                color: mediumColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(blurRadius: 10.0, color: mediumColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameModeSelector(BuildContext context, Color mediumColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showGameButtons = false;
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Previene chiusura quando clicchi sulla card
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: mediumColor.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: mediumColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Seleziona Modalità',
                        style: TextStyle(
                          color: mediumColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () {
                          setState(() {
                            _showGameButtons = false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // VERO/FALSO - Classic Mode
                  _buildModeButton(
                    context,
                    'Vero / Falso - Classic',
                    '15 domande (5+5+5), 20 sec per domanda',
                    QuestionType.truefalse,
                    GameMode.classic,
                    mediumColor,
                    Icons.check_circle_outline,
                  ),
                  const SizedBox(height: 12),

                  // SCELTA MULTIPLA - Classic Mode
                  _buildModeButton(
                    context,
                    'Scelta Multipla - Classic',
                    '15 domande (5+5+5), 60 sec per domanda',
                    QuestionType.multiple,
                    GameMode.classic,
                    mediumColor,
                    Icons.grid_view_rounded,
                  ),

                  // Divider per future modalità
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),

                  // Placeholder per future modalità
                  Text(
                    'Altre modalità in arrivo...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
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

  Widget _buildModeButton(
      BuildContext context,
      String title,
      String subtitle,
      QuestionType type,
      GameMode mode,
      Color color,
      IconData icon,
      ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _startGame(context, type, mode),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withOpacity(0.5)),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withOpacity(0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryOverlay(BuildContext context, Color mediumColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showHistoryPanel = false;
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Previene chiusura quando clicchi sul pannello
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: context.read<QuizController>().getGameHistory(MediumType.videogames),
              builder: (context, snapshot) {
                return HistoryPanel(
                  medium: MediumType.videogames,
                  gameHistory: snapshot.data ?? [],
                  onClose: () {
                    setState(() {
                      _showHistoryPanel = false;
                    });
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsOverlay(BuildContext context, Color mediumColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showSettingsPanel = false;
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Previene chiusura quando clicchi sul pannello
            child: MediumSettingsPanel(
              medium: MediumType.videogames,
              currentSettings: context.read<QuizController>().mediumSettings,
              onSettingsChanged: (settings) {
                context.read<QuizController>().updateMediumSettings(settings);
              },
              onClose: () {
                setState(() {
                  _showSettingsPanel = false;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}