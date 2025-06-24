import 'package:flutter/material.dart';
import '../widgets/game_card.dart';
import '../models/game.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../screens/payment_method_screen.dart';
import '../screens/reflex_master_screen.dart';
import '../screens/puzzle_slide_screen.dart';
import '../screens/memory_matrix_screen.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
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
  late AnimationController _backgroundAnimationController;

  // Previous values to detect changes
  int _prevDays = 30;
  int _prevHours = 30;
  int _prevMinutes = 30;
  int _prevSeconds = 30;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _initControllers();

    // Start the timer after controllers are initialized
    _startTimer();

    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
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
    _backgroundAnimationController.dispose();
    _scrollController.dispose();

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
    final games = [
      Game(
        title: 'TRIVIA CHALLENGE',
        description: 'Test your knowledge with timed questions',
        icon: Icons.quiz_rounded,
        prize: 'Cash Prize',
        prizeValue: 500,
        rating: 4.5,
      ),
      Game(
        title: 'MEMORY MATRIX',
        description: 'Remember and recreate patterns',
        icon: Icons.memory_rounded,
        prize: 'Cash Prize',
        prizeValue: 350,
        rating: 4.4,
      ),
      Game(
        title: 'REFLEX MASTER',
        description: 'Tap targets as fast as you can',
        icon: Icons.touch_app_rounded,
        prize: 'Cash Prize',
        prizeValue: 300,
        rating: 4.2,
      ),
      Game(
        title: 'PUZZLE SLIDE',
        description: 'Arrange tiles in the correct order',
        icon: Icons.grid_view_rounded,
        prize: 'Cash Prize',
        prizeValue: 250,
        rating: 4.0,
      ),
      Game(
        title: 'MEMORY MATCH',
        description: 'Find matching pairs of cards',
        icon: Icons.grid_on_rounded,
        prize: 'Cash Prize',
        prizeValue: 400,
        rating: 4.3,
      ),
      Game(
        title: 'WORD PUZZLE',
        description: 'Form words from jumbled letters',
        icon: Icons.text_fields_rounded,
        prize: 'Cash Prize',
        prizeValue: 350,
        rating: 4.1,
      ),
      Game(
        title: 'NUMBER CRUSH',
        description: 'Match numbers to solve puzzles',
        icon: Icons.calculate_rounded,
        prize: 'Cash Prize',
        prizeValue: 450,
        rating: 4.4,
      ),
      Game(
        title: 'PATTERN RUSH',
        description: 'Remember and repeat patterns',
        icon: Icons.pattern,
        prize: 'Cash Prize',
        prizeValue: 300,
        rating: 3.9,
      ),
    ];

    return Stack(
      children: [
        // Animated background
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return CustomPaint(
                painter: HomeBackgroundPainter(
                  animationValue: _backgroundAnimationController.value,
                ),
              );
            },
          ),
        ),

        // Main content
        SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User profile and balance
                      _buildUserProfile(),

                      const SizedBox(height: 24),

                      // Countdown timer
                      _buildCountdownTimer(),

                      const SizedBox(height: 24),

                      // Section title
                      const Text(
                        'Popular Games',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Game cards
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return GameCard(game: games[index]);
                    },
                    childCount: games.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppDesign.primaryColor,
                    AppDesign.accentColor,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppDesign.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF1A2322),
                child: const Text(
                  'BH',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'Bashdar ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Hakim',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppDesign.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppDesign.primaryColor,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Level 5',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        // Wallet button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: AppDesign.primaryColor,
                size: 16,
              ),
              const SizedBox(width: 6),
              const Text(
                '\$1,250',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownTimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppDesign.elevatedSurfaceColor,
            AppDesign.surfaceColor,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppDesign.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.timer_outlined,
                  color: AppDesign.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Daily Tournament Starts In',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeUnit('DAYS', _days, _daysController),
              _buildTimeSeparator(),
              _buildTimeUnit('HOURS', _hours, _hoursController),
              _buildTimeSeparator(),
              _buildTimeUnit('MINS', _minutes, _minutesController),
              _buildTimeSeparator(),
              _buildTimeUnit('SECS', _seconds, _secondsController),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesign.primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: AppDesign.primaryColor.withOpacity(0.4),
              ),
              child: const Text(
                'REGISTER NOW',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(
      String label, int value, AnimationController? controller) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: controller ?? const AlwaysStoppedAnimation(0),
              builder: (context, child) {
                final animationValue = controller?.value ?? 0;

                return Transform.scale(
                  scale: 1.0 + (animationValue * 0.2),
                  child: Opacity(
                    opacity:
                        1.0 - (animationValue * 0.5) + (animationValue * 0.5),
                    child: Text(
                      value.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 20.0;

    // Draw diagonal lines
    for (double i = -size.width; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HomeBackgroundPainter extends CustomPainter {
  final double animationValue;

  HomeBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Create a rect for the entire canvas
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Create gradient background
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppDesign.backgroundColor,
        const Color(0xFF0D1211),
        const Color(0xFF0A0E0D),
      ],
    );

    // Draw the gradient
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Draw subtle patterns
    final patternPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    // Draw horizontal lines with wave effect
    const spacing = 60.0;
    for (double i = 0; i < size.height; i += spacing) {
      final path = Path();
      path.moveTo(0, i);

      for (double x = 0; x < size.width; x += 20) {
        final y = i +
            8 *
                math.sin((x / size.width * 4 * math.pi) +
                    (animationValue * 2 * math.pi));
        path.lineTo(x, y);
      }

      canvas.drawPath(path, patternPaint);
    }

    // Draw some subtle glowing circles
    for (int i = 0; i < 3; i++) {
      final x = size.width *
          (0.2 + 0.6 * math.sin(animationValue * math.pi * 0.2 + i * 0.7));
      final y = size.height *
          (0.3 + 0.4 * math.cos(animationValue * math.pi * 0.1 + i * 0.5));
      final radius =
          100.0 + 50.0 * math.sin(animationValue * math.pi * 0.3 + i);

      final circlePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            AppDesign.primaryColor.withOpacity(0.05),
            AppDesign.primaryColor.withOpacity(0.01),
            AppDesign.primaryColor.withOpacity(0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius));

      canvas.drawCircle(
        Offset(x, y),
        radius,
        circlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HomeBackgroundPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
