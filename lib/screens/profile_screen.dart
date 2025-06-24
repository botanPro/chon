import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/achievement_card.dart';
import 'dart:math' as math;

/// ProfileScreen displays the user's profile information including their
/// balance, level, and account management options.
///
/// This screen uses a custom circular progress indicator to display the user's
/// balance with a teal accent color scheme on a dark background.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _backgroundAnimationController;

  // Sample achievements data
  final List<Achievement> _achievements = [
    const Achievement(
      title: 'First Victory',
      description: 'Win your first game',
      icon: Icons.emoji_events_rounded,
      unlocked: true,
    ),
    const Achievement(
      title: 'Trivia Master',
      description: 'Answer 50 trivia questions correctly',
      icon: Icons.quiz_rounded,
      unlocked: true,
    ),
    const Achievement(
      title: 'Speed Demon',
      description: 'Complete a Reflex Master game with a score over 1000',
      icon: Icons.speed_rounded,
      unlocked: false,
      progress: 0.7,
    ),
    const Achievement(
      title: 'Memory King',
      description: 'Reach level 10 in Memory Matrix',
      icon: Icons.memory_rounded,
      unlocked: false,
      progress: 0.4,
    ),
    const Achievement(
      title: 'Puzzle Solver',
      description: 'Complete 5 puzzles in under 2 minutes each',
      icon: Icons.grid_view_rounded,
      unlocked: false,
      progress: 0.2,
    ),
    const Achievement(
      title: 'Tournament Champion',
      description: 'Win a daily tournament',
      icon: Icons.workspace_premium_rounded,
      unlocked: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.backgroundColor,
      body: Stack(
        children: [
          // Animated background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundAnimationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ProfileBackgroundPainter(
                    animationValue: _backgroundAnimationController.value,
                  ),
                );
              },
            ),
          ),

          // Main content
          SafeArea(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: _buildProfileHeader(),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        indicatorColor: AppDesign.primaryColor,
                        indicatorWeight: 3,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white.withOpacity(0.5),
                        tabs: const [
                          Tab(text: 'ACHIEVEMENTS'),
                          Tab(text: 'STATS'),
                          Tab(text: 'HISTORY'),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  // Achievements tab
                  AchievementsList(achievements: _achievements),

                  // Stats tab
                  _buildStatsTab(),

                  // History tab
                  _buildHistoryTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar and user info
          Row(
            children: [
              // Avatar with level indicator
              Stack(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
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
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF1A2322),
                      child: const Text(
                        'BH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Level indicator
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppDesign.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: const Text(
                        'LVL 5',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 24),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bashdar Hakim',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Member since June 2023',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
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
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
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
                                Icons.emoji_events_rounded,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '12',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Progress to next level
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress to Level 6',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '75%',
                    style: TextStyle(
                      color: AppDesign.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 0.75,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppDesign.primaryColor),
                borderRadius: BorderRadius.circular(4),
                minHeight: 8,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overall stats card
        _buildStatsCard(
          title: 'Overall Stats',
          stats: [
            {'label': 'Games Played', 'value': '42'},
            {'label': 'Win Rate', 'value': '68%'},
            {'label': 'Total Score', 'value': '12,450'},
          ],
        ),

        const SizedBox(height: 16),

        // Game-specific stats
        _buildStatsCard(
          title: 'Trivia Challenge',
          stats: [
            {'label': 'Games Played', 'value': '15'},
            {'label': 'Correct Answers', 'value': '132'},
            {'label': 'Best Score', 'value': '950'},
          ],
          icon: Icons.quiz_rounded,
          color: const Color(0xFF96C3BC),
        ),

        const SizedBox(height: 16),

        _buildStatsCard(
          title: 'Memory Matrix',
          stats: [
            {'label': 'Games Played', 'value': '8'},
            {'label': 'Highest Level', 'value': '7'},
            {'label': 'Best Score', 'value': '840'},
          ],
          icon: Icons.memory_rounded,
          color: const Color(0xFF8E94F2),
        ),

        const SizedBox(height: 16),

        _buildStatsCard(
          title: 'Reflex Master',
          stats: [
            {'label': 'Games Played', 'value': '12'},
            {'label': 'Targets Hit', 'value': '324'},
            {'label': 'Best Score', 'value': '720'},
          ],
          icon: Icons.touch_app_rounded,
          color: const Color(0xFFFF9A76),
        ),
      ],
    );
  }

  Widget _buildStatsCard({
    required String title,
    required List<Map<String, String>> stats,
    IconData? icon,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppDesign.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color?.withOpacity(0.3) ?? Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card title
          Row(
            children: [
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color?.withOpacity(0.1) ??
                        Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color ?? Colors.white,
                    size: 20,
                  ),
                ),
              if (icon != null) const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stat['value']!,
                      style: TextStyle(
                        color: color ?? Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat['label']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    // Sample game history data
    final gameHistory = [
      {
        'game': 'Trivia Challenge',
        'date': 'Today',
        'score': 850,
        'result': 'Win',
        'icon': Icons.quiz_rounded,
        'color': const Color(0xFF96C3BC),
      },
      {
        'game': 'Memory Matrix',
        'date': 'Yesterday',
        'score': 720,
        'result': 'Win',
        'icon': Icons.memory_rounded,
        'color': const Color(0xFF8E94F2),
      },
      {
        'game': 'Reflex Master',
        'date': 'Yesterday',
        'score': 540,
        'result': 'Loss',
        'icon': Icons.touch_app_rounded,
        'color': const Color(0xFFFF9A76),
      },
      {
        'game': 'Puzzle Slide',
        'date': '2 days ago',
        'score': 680,
        'result': 'Win',
        'icon': Icons.grid_view_rounded,
        'color': const Color(0xFF8E94F2),
      },
      {
        'game': 'Trivia Challenge',
        'date': '3 days ago',
        'score': 620,
        'result': 'Loss',
        'icon': Icons.quiz_rounded,
        'color': const Color(0xFF96C3BC),
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: gameHistory.length,
      itemBuilder: (context, index) {
        final game = gameHistory[index];
        final isWin = game['result'] == 'Win';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppDesign.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isWin
                  ? (game['color'] as Color).withOpacity(0.3)
                  : Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Game icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (game['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    game['icon'] as IconData,
                    color: game['color'] as Color,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Game details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game['game'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        game['date'] as String,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Score and result
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${game['score']} pts',
                      style: TextStyle(
                        color: isWin ? game['color'] as Color : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isWin
                            ? (game['color'] as Color).withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        game['result'] as String,
                        style: TextStyle(
                          color: isWin ? game['color'] as Color : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppDesign.backgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class ProfileBackgroundPainter extends CustomPainter {
  final double animationValue;

  ProfileBackgroundPainter({required this.animationValue});

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
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1;

    // Draw horizontal lines with wave effect
    const spacing = 80.0;
    for (double i = 0; i < size.height; i += spacing) {
      final path = Path();
      path.moveTo(0, i);

      for (double x = 0; x < size.width; x += 20) {
        final y = i +
            5 *
                math.sin((x / size.width * 4 * math.pi) +
                    (animationValue * 2 * math.pi));
        path.lineTo(x, y);
      }

      canvas.drawPath(path, patternPaint);
    }

    // Draw some subtle glowing circles
    for (int i = 0; i < 3; i++) {
      final x = size.width *
          (0.2 + 0.6 * math.sin(animationValue * math.pi * 0.1 + i * 0.7));
      final y = size.height *
          (0.3 + 0.4 * math.cos(animationValue * math.pi * 0.05 + i * 0.5));
      final radius =
          120.0 + 30.0 * math.sin(animationValue * math.pi * 0.2 + i);

      final circlePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            AppDesign.primaryColor.withOpacity(0.03),
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
  bool shouldRepaint(covariant ProfileBackgroundPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
