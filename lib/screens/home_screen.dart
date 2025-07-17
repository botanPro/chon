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
import '../utils/responsive_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic>? _competitions;
  Map<int, bool> _gameTimerFinished = {};
  Map<int, bool> _userRegistered = {}; // Track registration status per game

  @override
  void initState() {
    super.initState();
    print('HomeScreen initState');
    _competitions = [];

    // Fetch competitions using REST API
    _fetchCompetitions();
  }

  @override
  void dispose() {
    // Clean up socket listeners
    TriviaSocketService().disconnect();

    super.dispose();
  }

  Future<void> _fetchCompetitions() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.token ?? '';

      final response = await http.get(
        Uri.parse('$apiUrl/api/competitions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);
      print('Competitions API response: $data');
      List competitions = [];
      if (data['data'] is List) {
        competitions = data['data'];
      } else {
        print('Unexpected competitions structure: \\${data['data']}');
      }
      setState(() {
        _competitions = competitions;
      });
      print('Loaded \\${competitions.length} competitions');
    } catch (e) {
      print('Error fetching competitions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not load competitions. Please try again.'),
          backgroundColor: Colors.blueGrey,
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> fetchCompetitionDetails(
      String competitionId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/api/competitions/$competitionId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['data'] != null) {
          return data['data'];
        } else {
          print('Failed to load competition details: ${data['message']}');
          return null;
        }
      } else {
        print('Failed to load competition details: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching competition details: $e');
      return null;
    }
  }

  Future<bool> joinCompetition(String competitionId, String token) async {
    try {
      print('Joining competition: $competitionId');

      final response = await http.post(
        Uri.parse('$apiUrl/api/competitions/$competitionId/join'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print(
          'Join competition response: \\${response.statusCode} \\${response.body}');
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        print('Successfully joined competition');
        return true;
      } else if (response.statusCode == 400 &&
          data['message']
                  ?.toString()
                  .toLowerCase()
                  .contains('already registered') ==
              true) {
        print('Player already registered for this competition');
        return true; // Consider this a success since player can proceed
      } else {
        print('Failed to join competition: \\${data['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Could not join competition. Please try again.'),
            backgroundColor: Colors.blueGrey,
          ),
        );
        return false;
      }
    } catch (e) {
      print('Error joining competition: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not join competition. Please try again.'),
          backgroundColor: Colors.blueGrey,
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final games = (_competitions ?? [])
        .map((comp) => Game(
              competitionId: comp['id']?.toString() ?? '',
              title: comp['name'] ?? 'Unknown',
              description: comp['description'] ?? '',
              icon: Icons.gamepad,
              prize: '',
              prizeValue: comp['entry_fee'] is num
                  ? comp['entry_fee'].toDouble()
                  : double.tryParse(comp['entry_fee']?.toString() ?? '') ?? 0.0,
              rating: 0.0,
              startTime: comp['start_time'],
              // Add additional competition data
              status: comp['status'] ?? 'unknown',
              currentPlayers: comp['current_players'] ?? 0,
              maxPlayers: comp['max_players'] ?? 0,
              isRegistered: comp['is_registered'] ?? false,
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

                    // Ad Banner Placeholder
                    Container(
                      height: 110,
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF2D3748).withOpacity(0.8),
                            const Color(0xFF1A202C).withOpacity(0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.ads_click,
                            color: Colors.white.withOpacity(0.6),
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppLocalizations.of(context)!.advertisementSpace,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppLocalizations.of(context)!.yourAdsWillAppearHere,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveUtils.getGridCount(context),
                          childAspectRatio:
                              ResponsiveUtils.getCardAspectRatio(context),
                          crossAxisSpacing:
                              ResponsiveUtils.getResponsiveSpacing(context,
                                  mobile: 12, tablet: 16, desktop: 20),
                          mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              mobile: 12,
                              tablet: 16,
                              desktop: 20),
                        ),
                        itemCount: games.length,
                        itemBuilder: (context, index) {
                          final game = games[index];
                          bool isTimerFinished =
                              _gameTimerFinished[index] ?? false;
                          bool isUserRegistered =
                              _userRegistered[index] ?? false;
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
                                        // Remove Entry Fee display
                                        // Text(
                                        //   'Entry Fee: \$${game.prizeValue.toInt()}',
                                        //   style: const TextStyle(
                                        //     color: Colors.white,
                                        //     fontSize: 18,
                                        //     fontWeight: FontWeight.bold,
                                        //   ),
                                        // ),
                                        const SizedBox(height: 2),
                                        Text(
                                          game.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Competition status and player count
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                    game.status),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                game.status.toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${game.currentPlayers}/${game.maxPlayers}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (game.isRegistered) ...[
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.green.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.green,
                                                width: 1,
                                              ),
                                            ),
                                            child: const Text(
                                              '✓ REGISTERED',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
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
                                        // Show different button states based on registration and timer
                                        if (!isTimerFinished &&
                                            !game.isRegistered)
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () async {
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
                                                final token =
                                                    authService.token ?? '';
                                                final details =
                                                    await fetchCompetitionDetails(
                                                        game.competitionId,
                                                        token);
                                                if (details != null) {
                                                  // Check open_time before allowing registration
                                                  final openTimeStr =
                                                      details['open_time'] ??
                                                          '';
                                                  if (openTimeStr.isNotEmpty) {
                                                    final openTime =
                                                        DateTime.parse(
                                                                openTimeStr)
                                                            .toUtc();
                                                    final now =
                                                        DateTime.now().toUtc();
                                                    if (now
                                                        .isBefore(openTime)) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Registration is not open yet.'),
                                                          backgroundColor:
                                                              Colors.blueGrey,
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                  }
                                                  _showCountdownAndStartGame(
                                                    context,
                                                    game,
                                                    playerId,
                                                    playerName,
                                                    details,
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Could not load competition details. Please try again.'),
                                                    ),
                                                  );
                                                }
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
                                        // Show Registered state with countdown
                                        if (!isTimerFinished &&
                                            game.isRegistered)
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.green.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.green
                                                    .withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                      size: 16,
                                                    ),
                                                    SizedBox(width: 6),
                                                    Text(
                                                      'Registered',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                const Text(
                                                  'Game starts soon...',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        // Show "Tap to Play" button after countdown for registered users
                                        if (isTimerFinished &&
                                            game.isRegistered)
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () async {
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
                                                final token =
                                                    authService.token ?? '';
                                                final details =
                                                    await fetchCompetitionDetails(
                                                        game.competitionId,
                                                        token);
                                                if (details != null) {
                                                  // Navigate directly to game since user is already registered
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          TriviaGameScreen(
                                                        competitionId:
                                                            game.competitionId,
                                                        playerId: playerId,
                                                        playerName: playerName,
                                                        competitionDetails:
                                                            details,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Could not load competition details. Please try again.'),
                                                    ),
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF96C3BC),
                                                foregroundColor: Colors.white,
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
                                                    'Tap to Play',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Icon(
                                                    Icons.play_arrow,
                                                    size: 16,
                                                    color: Colors.white,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCountdownAndStartGame(
      BuildContext context,
      Game game,
      String playerId,
      String playerName,
      Map<String, dynamic> competitionDetails) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token ?? '';

    // First, join the competition
    final joined = await joinCompetition(game.competitionId, token);
    if (!joined) {
      print('Failed to join competition, cannot proceed to game');
      return;
    }

    // Check if competition has started by checking the start time
    final startTime = game.startTime;
    print('[DEBUG] Home screen - checking competition start time: $startTime');

    if (startTime != null) {
      try {
        final startDateTime = DateTime.parse(startTime);
        final now = DateTime.now();
        final timeUntilStart = startDateTime.difference(now).inSeconds;

        print('[DEBUG] Home screen - start datetime: $startDateTime');
        print('[DEBUG] Home screen - current time: $now');
        print(
            '[DEBUG] Home screen - time until start: $timeUntilStart seconds');

        if (timeUntilStart > 0) {
          // Competition hasn't started yet - show countdown dialog
          print(
              '[DEBUG] Home screen - competition has not started yet. Showing countdown dialog for $timeUntilStart seconds');
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => CountdownDialog(
              seconds: timeUntilStart,
              onCountdownComplete: () {
                print(
                    '[DEBUG] Home screen - countdown completed, navigating to game');
                Navigator.of(context).pop(); // Close countdown dialog
                // Now navigate to the game since competition has started
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TriviaGameScreen(
                      competitionId: game.competitionId,
                      playerId: playerId,
                      playerName: playerName,
                      competitionDetails: competitionDetails,
                    ),
                  ),
                );
              },
            ),
          );
          return;
        } else {
          print(
              '[DEBUG] Home screen - competition has already started or is starting now');
        }
      } catch (e) {
        print('Error parsing competition start time: $e');
        // If there's an error parsing the time, proceed to game as fallback
      }
    } else {
      print(
          '[DEBUG] Home screen - no start time specified for competition - proceeding immediately');
    }

    // Competition has started or no start time specified - proceed to game
    print('[DEBUG] Home screen - navigating directly to game');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TriviaGameScreen(
          competitionId: game.competitionId,
          playerId: playerId,
          playerName: playerName,
          competitionDetails: competitionDetails,
        ),
      ),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
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
