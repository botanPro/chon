import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game.dart';
import '../screens/memory_game_screen.dart';
import '../screens/number_game_screen.dart';
import '../screens/word_game_screen.dart';
import '../screens/trivia_game_screen.dart';
import '../screens/color_chain_screen.dart';
import '../screens/word_tower_screen.dart';
import '../screens/pattern_rush_screen.dart';
import '../screens/sound_symphony_screen.dart';
import '../screens/gravity_puzzle_screen.dart';
import '../screens/time_painter_screen.dart';

class GameCard extends StatelessWidget {
  final Game game;

  const GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101513),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: Container(
                color: game.title == 'IMPOSSIBLE CLIMB' ? const Color(0xFF00B894) : const Color(0xFF6AB04C),
                child: Center(
                  child: Text(
                    game.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Game details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A3A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            game.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Price
                Text(
                  '\$ ${game.prizeValue.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Game name
                const Text(
                  'Game Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Description
                Text(
                  game.description,
                  style: const TextStyle(
                    color: Color(0xFF8E8E8E),
                    fontSize: 12,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Play button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Play Now'),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Colors.grey.shade800,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
