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
import '../screens/payment_method_screen.dart';
import '../utils/responsive_utils.dart';

class GameCard extends StatelessWidget {
  final Game game;

  const GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    final padding = ResponsiveUtils.getResponsivePadding(context,
        mobile: 12, tablet: 16, desktop: 20);
    final buttonHeight = ResponsiveUtils.getResponsiveButtonHeight(context);
    final spacing = ResponsiveUtils.getResponsiveSpacing(context,
        mobile: 8, tablet: 10, desktop: 12);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context,
        mobile: 12, tablet: 14, desktop: 16);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101513),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game image
          ClipRRect(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(borderRadius)),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: Container(
                color: game.title == 'IMPOSSIBLE CLIMB'
                    ? const Color(0xFF00B894)
                    : const Color(0xFF6AB04C),
                child: Center(
                  child: ResponsiveText(
                    game.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    mobileFontSize: 14,
                    tabletFontSize: 16,
                    desktopFontSize: 18,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),

          // Game details
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: spacing * 0.75, vertical: spacing * 0.25),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A3A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.white,
                            size: iconSize,
                          ),
                          SizedBox(width: spacing * 0.5),
                          ResponsiveText(
                            game.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            mobileFontSize: 12,
                            tabletFontSize: 13,
                            desktopFontSize: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: spacing),

                // Price
                ResponsiveText(
                  '\$ ${game.prizeValue.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  mobileFontSize: 20,
                  tabletFontSize: 24,
                  desktopFontSize: 28,
                ),

                SizedBox(height: spacing * 0.5),

                // Game name
                ResponsiveText(
                  'Game Name',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  mobileFontSize: 16,
                  tabletFontSize: 18,
                  desktopFontSize: 20,
                ),

                SizedBox(height: spacing * 0.5),

                // Description
                ResponsiveText(
                  game.description,
                  style: const TextStyle(
                    color: Color(0xFF8E8E8E),
                  ),
                  mobileFontSize: 12,
                  tabletFontSize: 14,
                  desktopFontSize: 16,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: spacing * 1.5),

                // Play button
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(game.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          content: Text(
                              game.description ?? 'No description available.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentMethodScreen(
                                      amount: game.prizeValue,
                                      gameName: game.title,
                                      competitionId: game.competitionId,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Play Now'),
                                  SizedBox(width: spacing * 0.5),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: iconSize,
                                    color: Colors.grey.shade800,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: spacing),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ResponsiveText(
                          'Game Details',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                          mobileFontSize: 14,
                          tabletFontSize: 16,
                          desktopFontSize: 18,
                        ),
                        SizedBox(width: spacing * 0.5),
                        Icon(
                          Icons.info_outline,
                          size: iconSize,
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
