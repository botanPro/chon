import 'package:flutter/material.dart';

class Game {
  final String title;
  final String description;
  final IconData icon;
  final String prize;
  final double prizeValue;
  final double rating;

  const Game({
    required this.title,
    required this.description,
    required this.icon,
    required this.prize,
    required this.prizeValue,
    this.rating = 0.0,
  });
}
