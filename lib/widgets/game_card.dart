import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/game.dart';
import '../main.dart';
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
import '../screens/payment_method_screen.dart';
import '../screens/reflex_master_screen.dart';
import '../screens/puzzle_slide_screen.dart';
import '../screens/memory_matrix_screen.dart';

class GameCard extends StatelessWidget {
  final Game game;

  const GameCard({super.key, required this.game});

  // Get game-specific gradient colors
  List<Color> _getGameColors() {
    switch (game.title) {
      case 'TRIVIA CHALLENGE':
        return [const Color(0xFF96C3BC), const Color(0xFF7B9F9A)];
      case 'MEMORY MATCH':
        return [const Color(0xFF8E94F2), const Color(0xFF6A75E0)];
      case 'MEMORY MATRIX':
        return [const Color(0xFF8E94F2), const Color(0xFF6A75E0)];
      case 'WORD PUZZLE':
        return [const Color(0xFFF5B700), const Color(0xFFDA9E00)];
      case 'NUMBER CRUSH':
        return [const Color(0xFFFF5F5D), const Color(0xFFE04A48)];
      case 'PATTERN RUSH':
        return [const Color(0xFF00CFE3), const Color(0xFF00A3B4)];
      case 'REFLEX MASTER':
        return [const Color(0xFFFF9A76), const Color(0xFFE07E5F)];
      case 'PUZZLE SLIDE':
        return [const Color(0xFF8E94F2), const Color(0xFF6A75E0)];
      default:
        return [AppDesign.primaryColor, AppDesign.accentColor];
    }
  }

  // Get the appropriate screen for the game
  Widget _getGameScreen() {
    switch (game.title) {
      case 'TRIVIA CHALLENGE':
        return const TriviaGameScreen();
      case 'MEMORY MATCH':
        return const MemoryGameScreen();
      case 'WORD PUZZLE':
        return const WordGameScreen();
      case 'NUMBER CRUSH':
        return const NumberGameScreen();
      case 'PATTERN RUSH':
        return const PatternRushScreen();
      case 'COLOR CHAIN':
        return const ColorChainScreen();
      case 'WORD TOWER':
        return const WordTowerScreen();
      case 'SOUND SYMPHONY':
        return const SoundSymphonyScreen();
      case 'GRAVITY PUZZLE':
        return const GravityPuzzleScreen();
      case 'TIME PAINTER':
        return const TimePainterScreen();
      case 'REFLEX MASTER':
        return const ReflexMasterScreen();
      case 'PUZZLE SLIDE':
        return const PuzzleSlideScreen();
      case 'MEMORY MATRIX':
        return const MemoryMatrixScreen();
      default:
        return const TriviaGameScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getGameColors();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppDesign.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game image/header
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
            child: Stack(
              children: [
                // Pattern overlay
                Opacity(
                  opacity: 0.1,
                  child: CustomPaint(
                    size: const Size(double.infinity, 140),
                    painter: PatternPainter(),
                  ),
                ),

                // Game title and icon
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Game icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          game.icon,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Game title and subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              game.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              game.description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Game details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Prize and rating row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Prize amount
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors[0].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.attach_money_rounded,
                            color: colors[0],
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${game.prizeValue.toInt()}',
                          style: TextStyle(
                            color: AppDesign.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    // Rating
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            game.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Play button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to game screen directly
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => _getGameScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors[0],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 4,
                      shadowColor: colors[0].withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Play Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.play_arrow_rounded,
                          size: 20,
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

// Pattern painter for game card headers
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

    // Draw circles
    for (int i = 0; i < 5; i++) {
      final radius = 20.0 + i * 20.0;
      canvas.drawCircle(
        Offset(size.width - 40, 40),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
