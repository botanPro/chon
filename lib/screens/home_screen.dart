import 'package:flutter/material.dart';
import '../widgets/game_card.dart';
import '../widgets/language_switcher.dart';
import '../l10n/app_localizations.dart';
import '../models/game.dart';
import '../services/auth_service.dart';
import '../screens/payment_method_screen.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/trivia_socket_service.dart';
import '../screens/trivia_game_screen.dart';
import '../utils/apiConnection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _days = 30;
  int _hours = 30;
  int _minutes = 30;
  int _seconds = 30;
  Timer? _timer;

  // Animation controllers for each time unit - make them nullable
  AnimationController? _daysController;
  AnimationController? _hoursController;
  AnimationController? _minutesController;
  AnimationController? _secondsController;

  // Previous values to detect changes
  int _prevDays = 30;
  int _prevHours = 30;
  int _prevMinutes = 30;
  int _prevSeconds = 30;

  List<dynamic>? _competitions;
  Map<int, bool> _gameTimerFinished = {};

  @override
  void initState() {
    super.initState();
    print('HomeScreen initState');
    _initControllers();
    _startTimer();
    _competitions = [];

    // Only connect and listen once
    final socketService = TriviaSocketService();
    socketService.connect(socketUrl);
    socketService.onCompetitionData((data) {
      if (!mounted) return;
      print('Received competition data: \\${data.toString()}');
      final competitions = data['competitions'];
      if (competitions == null) {
        print('No "competitions" key in data!');
        return;
      }
      setState(() {
        _competitions = competitions;
      });
    });

    print('Emitting getCompetitionData for all');
    socketService.getCompetitionData('all');
  }

  void _initControllers() {
    _daysController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _hoursController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _minutesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _secondsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    // Cancel timer first
    _timer?.cancel();

    // Then dispose controllers
    _daysController?.dispose();
    _hoursController?.dispose();
    _minutesController?.dispose();
    _secondsController?.dispose();

    // Clean up socket listeners
    TriviaSocketService().disconnect();

    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return; // Check if widget is still mounted

      setState(() {
        // Store previous values
        _prevDays = _days;
        _prevHours = _hours;
        _prevMinutes = _minutes;
        _prevSeconds = _seconds;

        if (_seconds > 0) {
          _seconds--;
        } else {
          _seconds = 59;
          if (_minutes > 0) {
            _minutes--;
          } else {
            _minutes = 59;
            if (_hours > 0) {
              _hours--;
            } else {
              _hours = 23;
              if (_days > 0) {
                _days--;
              } else {
                timer.cancel();
              }
            }
          }
        }

        // Trigger animations for changed values
        if (_prevSeconds != _seconds && _secondsController != null) {
          _secondsController!.reset();
          _secondsController!.forward();
        }

        if (_prevMinutes != _minutes && _minutesController != null) {
          _minutesController!.reset();
          _minutesController!.forward();
        }

        if (_prevHours != _hours && _hoursController != null) {
          _hoursController!.reset();
          _hoursController!.forward();
        }

        if (_prevDays != _days && _daysController != null) {
          _daysController!.reset();
          _daysController!.forward();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final games = (_competitions ?? [])
        .map((comp) => Game(
              competitionId: comp['id'] ?? '',
              title: comp['name'] ?? 'Unknown',
              description: '',
              icon: Icons.gamepad,
              prize: '',
              prizeValue: comp['entry_fee'] is num
                  ? comp['entry_fee'].toDouble()
                  : double.tryParse(comp['entry_fee'].toString()) ?? 0.0,
              rating: 0.0,
              startTime: comp['startTime'] ?? comp['start_time'],
            ))
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF090C0B),
        image: DecorationImage(
          image: AssetImage('assets/images/bg-gradient.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User profile section
                    Consumer<AuthService>(
                      builder: (context, authService, child) {
                        final nickname = authService.nickname ?? 'User';
                        final level = authService.level;

                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFF2A2A3A),
                              child: Text(
                                nickname.isNotEmpty
                                    ? nickname.substring(0, 1).toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nickname,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                          0x4025332F), // #25332F with 25% opacity
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Color(
                                              0xFF96C3BC), // #96C3BC color for star icon
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .level(level),
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.75),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const CompactLanguageSwitcher(),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Countdown section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101513),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Countdown',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          LayoutBuilder(builder: (context, constraints) {
                            // Calculate the width available for each time box
                            final boxWidth = (constraints.maxWidth - 24) /
                                4; // 24 is for spacing between boxes
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildTimeBox(
                                    context,
                                    _days,
                                    AppLocalizations.of(context)!.days,
                                    _daysController,
                                    boxWidth),
                                _buildTimeBox(
                                    context,
                                    _hours,
                                    AppLocalizations.of(context)!.hours,
                                    _hoursController,
                                    boxWidth),
                                _buildTimeBox(
                                    context,
                                    _minutes,
                                    AppLocalizations.of(context)!.minutes,
                                    _minutesController,
                                    boxWidth),
                                _buildTimeBox(
                                    context,
                                    _seconds,
                                    AppLocalizations.of(context)!.seconds,
                                    _secondsController,
                                    boxWidth),
                              ],
                            );
                          }),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.gameWillStart,
                            style: const TextStyle(
                              color: Color(0xFF737373),
                              fontSize: 12, // Reduced font size
                            ),
                            maxLines: 2, // Allow wrapping
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.notifications_outlined,
                                  size: 16), // Reduced icon size
                              label: const Text('Notify Me',
                                  style: TextStyle(
                                      fontSize: 14)), // Reduced font size
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFF262B29),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                      color: Color(0xFF2A2A3A)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Game cards
                    if (games.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        alignment: Alignment.center,
                        child: Text(
                          'No data found',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.55,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: games.length,
                        itemBuilder: (context, index) {
                          final game = games[index];
                          bool isTimerFinished =
                              _gameTimerFinished[index] ?? false;
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF101513),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                  child: AspectRatio(
                                    aspectRatio: 1.5,
                                    child: Container(
                                      color: index == 0
                                          ? const Color(0xFF00B894)
                                          : const Color(0xFF6AB04C),
                                      child: Center(
                                        child: Text(
                                          game.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        12, 12, 12, 6),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Entry Fee: \$${game.prizeValue.toInt()}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          game.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (game.startTime != null &&
                                            game.startTime!.isNotEmpty)
                                          GameCountdownTimer(
                                              startTime: game.startTime!,
                                              onFinished: (finished) {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                  if (mounted) {
                                                    setState(() {
                                                      _gameTimerFinished[
                                                          index] = finished;
                                                    });
                                                  }
                                                });
                                              }),
                                        const Spacer(),
                                        if (!isTimerFinished)
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                final authService =
                                                    Provider.of<AuthService>(
                                                        context,
                                                        listen: false);
                                                final playerId =
                                                    authService.userId ??
                                                        'player_demo';
                                                final playerName =
                                                    authService.nickname ??
                                                        'User';
                                                _showCountdownAndStartGame(
                                                    context,
                                                    game,
                                                    playerId,
                                                    playerName);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: Colors.black,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                minimumSize:
                                                    const Size.fromHeight(40),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    'Play Now',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Icon(
                                                    Icons.arrow_forward,
                                                    size: 12,
                                                    color: Colors.grey.shade800,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 24),

                    // News section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101513),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'News for you',
                            style: TextStyle(
                              color: Color(0xFF8E8E8E),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Since yesterday your ',
                                  style: TextStyle(
                                    color: Color(0xFF8E8E8E),
                                    fontSize: 16, // Reduced font size
                                  ),
                                ),
                                TextSpan(
                                  text: 'sales ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16, // Reduced font size
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: 'have increased!',
                                  style: TextStyle(
                                    color: Color(0xFF8E8E8E),
                                    fontSize: 16, // Reduced font size
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBox(BuildContext context, int value, String label,
      AnimationController? controller, double boxWidth) {
    final fontSize = boxWidth * 0.5; // Responsive font size based on box width

    if (controller == null) {
      // Fallback if controller is not initialized
      return Container(
        width: boxWidth,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF242F2C),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      color: const Color(0xFF96C3BC),
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFFEFEFEF),
                fontSize: boxWidth * 0.15, // Responsive font size for label
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return Container(
      width: boxWidth,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF242F2C),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                // Create a fade-in animation
                final opacity = controller.value < 0.5
                    ? 1.0 - controller.value * 2 // Fade out in first half
                    : (controller.value - 0.5) * 2; // Fade in in second half

                return Opacity(
                  opacity: opacity,
                  child: child,
                );
              },
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      color: const Color(0xFF96C3BC),
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFFEFEFEF),
              fontSize: boxWidth * 0.15, // Responsive font size for label
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showCountdownAndStartGame(
      BuildContext context, Game game, String playerId, String playerName) {
    if (game.startTime == null) {
      // Fallback: start immediately if no startTime
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TriviaGameScreen(
            competitionId: game.competitionId,
            playerId: playerId,
            playerName: playerName,
          ),
        ),
      );
      return;
    }
    final startTime = DateTime.parse(game.startTime!).toUtc();
    final now = DateTime.now().toUtc();
    int seconds = startTime.difference(now).inSeconds;
    if (seconds < 0) seconds = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CountdownDialog(
          seconds: seconds,
          onCountdownComplete: () {
            Navigator.of(context).pop(); // Close the dialog
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TriviaGameScreen(
                  competitionId: game.competitionId,
                  playerId: playerId,
                  playerName: playerName,
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatStartTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }
}

class CountdownDialog extends StatefulWidget {
  final int seconds;
  final VoidCallback onCountdownComplete;

  const CountdownDialog(
      {Key? key, required this.seconds, required this.onCountdownComplete})
      : super(key: key);

  @override
  State<CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<CountdownDialog> {
  late int _seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _seconds = widget.seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        timer.cancel();
        widget.onCountdownComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = Duration(seconds: _seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game starts in',
              style: TextStyle(
                color: Color(0xFF96c3bc),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 60,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameCountdownTimer extends StatefulWidget {
  final String startTime;
  final ValueChanged<bool>? onFinished;
  const GameCountdownTimer({Key? key, required this.startTime, this.onFinished})
      : super(key: key);
  @override
  _GameCountdownTimerState createState() => _GameCountdownTimerState();
}

class _GameCountdownTimerState extends State<GameCountdownTimer> {
  late Duration _remaining;
  late Timer _timer;
  bool _started = false;
  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final start = DateTime.tryParse(widget.startTime)?.toLocal();
    if (start == null) {
      if (!_started) widget.onFinished?.call(true);
      setState(() {
        _started = true;
      });
      return;
    }
    final now = DateTime.now();
    final diff = start.difference(now);
    if (diff.isNegative) {
      if (!_started) widget.onFinished?.call(true);
      setState(() {
        _started = true;
      });
    } else {
      if (_started) widget.onFinished?.call(false);
      setState(() {
        _remaining = diff;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_started) {
      return const Text('Game Finished',
          style: TextStyle(
              color: Color(0xFF96C3BC),
              fontSize: 11,
              fontWeight: FontWeight.w400));
    }
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTimeBox(twoDigits(days)),
            const Text(':',
                style: TextStyle(
                    color: Color(0xFF96C3BC),
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            _buildTimeBox(twoDigits(hours)),
            const Text(':',
                style: TextStyle(
                    color: Color(0xFF96C3BC),
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            _buildTimeBox(twoDigits(minutes)),
            const Text(':',
                style: TextStyle(
                    color: Color(0xFF96C3BC),
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            _buildTimeBox(twoDigits(seconds)),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _CountdownLabel('Days'),
            SizedBox(width: 10),
            _CountdownLabel('Hours'),
            SizedBox(width: 10),
            _CountdownLabel('Minutes'),
            SizedBox(width: 10),
            _CountdownLabel('Seconds'),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF242F2C),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Color(0xFF96C3BC),
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CountdownLabel extends StatelessWidget {
  final String label;
  const _CountdownLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF96C3BC),
        fontSize: 9,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
