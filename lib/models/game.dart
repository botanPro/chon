import 'package:flutter/material.dart';

/// Represents a game in the application.
///
/// This model contains all the information needed to display a game in the UI,
/// including its title, description, icon, and prize information.
class Game {
  /// The competition ID for this game (if applicable)
  final String competitionId;

  /// The title or name of the game
  final String title;

  /// A brief description of the game
  final String description;

  /// The icon representing the game in the UI
  final IconData icon;

  /// The prize description (e.g., "Cash Prize", "Gift Card")
  final String prize;

  /// The monetary value of the prize in dollars
  final double prizeValue;

  /// The user rating of the game (0.0 to 5.0)
  final double rating;

  /// The UTC start time of the competition (nullable)
  final String? startTime;

  /// Creates a new Game instance.
  ///
  /// [title] and [description] provide text information about the game.
  /// [icon] is used for visual representation in the UI.
  /// [prize] describes the type of prize.
  /// [prizeValue] is the monetary value of the prize.
  /// [rating] is optional and defaults to 0.0.
  const Game({
    required this.competitionId,
    required this.title,
    required this.description,
    required this.icon,
    required this.prize,
    required this.prizeValue,
    this.rating = 0.0,
    this.startTime,
  });

  /// Creates a copy of this Game with the given fields replaced with new values.
  Game copyWith({
    String? competitionId,
    String? title,
    String? description,
    IconData? icon,
    String? prize,
    double? prizeValue,
    double? rating,
    String? startTime,
  }) {
    return Game(
      competitionId: competitionId ?? this.competitionId,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      prize: prize ?? this.prize,
      prizeValue: prizeValue ?? this.prizeValue,
      rating: rating ?? this.rating,
      startTime: startTime ?? this.startTime,
    );
  }

  @override
  String toString() {
    return 'Game{competitionId: $competitionId, title: $title, prize: $prize, prizeValue: \$$prizeValue, rating: $rating, startTime: $startTime}';
  }
}
