import 'package:flutter/material.dart';

class Game {
  final String title;
  final String description;
  final IconData icon;
  final String prize;
  final double prizeValue;

  const Game({
    required this.title,
    required this.description,
    required this.icon,
    required this.prize,
    required this.prizeValue,
  });
}
