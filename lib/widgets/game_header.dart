import 'package:flutter/material.dart';

class GameHeader extends StatelessWidget {
  final int score;
  final int? timeLeft;
  final int? moves;
  final int? level;
  final VoidCallback onExit;

  const GameHeader({
    super.key,
    required this.score,
    this.timeLeft,
    this.moves,
    this.level,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: onExit,
              icon: const Icon(Icons.arrow_back),
              style: IconButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.surface.withOpacity(0.1),
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat(
                    context,
                    'Score',
                    score.toString(),
                    Icons.stars,
                  ),
                  if (timeLeft != null)
                    _buildStat(
                      context,
                      'Time',
                      '${timeLeft}s',
                      Icons.timer,
                    ),
                  if (moves != null)
                    _buildStat(
                      context,
                      'Moves',
                      moves.toString(),
                      Icons.swipe,
                    ),
                  if (level != null)
                    _buildStat(
                      context,
                      'Level',
                      level.toString(),
                      Icons.trending_up,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
      BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
