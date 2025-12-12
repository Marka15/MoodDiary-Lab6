import 'package:flutter/material.dart';

// Цей клас описує один варіант настрою: його емодзі, назву та колір фону.
class MoodOption {
  final String emoji;
  final String label;
  final Color color;

  const MoodOption({
    required this.emoji,
    required this.label,
    required this.color,
  });
}