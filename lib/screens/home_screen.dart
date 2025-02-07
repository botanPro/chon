import 'package:flutter/material.dart';
import '../widgets/game_card.dart';
import '../models/game.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      Game(
        title: 'Memory Match',
        description: '🚗 Match & Win a Tesla Model 3!',
        icon: Icons.grid_view,
        prize: 'Tesla Model 3',
        prizeValue: 40000,
      ),
      Game(
        title: 'Number Guess',
        description: '💻 Guess right for a MacBook Pro!',
        icon: Icons.numbers,
        prize: 'MacBook Pro',
        prizeValue: 2500,
      ),
      Game(
        title: 'Word Scramble',
        description: '📱 Solve & Win iPhone 15 Pro!',
        icon: Icons.text_rotation_none,
        prize: 'iPhone 15 Pro',
        prizeValue: 1000,
      ),
      Game(
        title: 'Trivia Challenge',
        description: '🎮 Answer & Win a PS5!',
        icon: Icons.quiz,
        prize: 'PlayStation 5',
        prizeValue: 500,
      ),
      Game(
        title: 'Color Chain',
        description: '🎨 Chain colors for an iPad Pro!',
        icon: Icons.palette,
        prize: 'iPad Pro',
        prizeValue: 1200,
      ),
      Game(
        title: 'Word Tower',
        description: '🎧 Build words for AirPods Max!',
        icon: Icons.text_fields,
        prize: 'AirPods Max',
        prizeValue: 550,
      ),
      Game(
        title: 'Pattern Rush',
        description: '⌚️ Match patterns for Apple Watch!',
        icon: Icons.grid_4x4,
        prize: 'Apple Watch',
        prizeValue: 400,
      ),
      Game(
        title: 'Sound Symphony',
        description: '🔊 Create music for Sonos Arc!',
        icon: Icons.music_note,
        prize: 'Sonos Arc',
        prizeValue: 900,
      ),
      Game(
        title: 'Gravity Puzzle',
        description: '🎮 Solve & Win Nintendo Switch!',
        icon: Icons.change_circle,
        prize: 'Nintendo Switch',
        prizeValue: 300,
      ),
      Game(
        title: 'Time Painter',
        description: '📱 Paint time for Galaxy Tab S9!',
        icon: Icons.brush,
        prize: 'Galaxy Tab S9',
        prizeValue: 800,
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.background,
                      Theme.of(context)
                          .colorScheme
                          .background
                          .withOpacity(0.95),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.emoji_events,
                            color: Theme.of(context).colorScheme.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Prize Games',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.monetization_on,
                                color: Colors.white.withOpacity(0.9),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Consumer<AuthService>(
                                builder: (context, auth, _) => Text(
                                  '\$${auth.balance.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () =>
                                Navigator.pushNamed(context, '/profile'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.person_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '🎮 Play & Win Big!',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Win amazing prizes worth up to \$40,000',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.grey,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.card_giftcard,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatistic(
                                context,
                                '10',
                                'Games',
                                Icons.sports_esports,
                              ),
                              _buildStatistic(
                                context,
                                '\$48K+',
                                'Prizes',
                                Icons.emoji_events,
                              ),
                              _buildStatistic(
                                context,
                                '\$1',
                                'Per Play',
                                Icons.monetization_on,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => GameCard(game: games[index]),
                  childCount: games.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistic(
      BuildContext context, String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
