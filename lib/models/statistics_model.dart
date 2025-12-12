import 'package:flutter/material.dart';

class StatisticsModel extends ChangeNotifier {
  // Період для аналізу
  String _selectedPeriod = 'last7'; // 'last7', 'last30', 'all'
  
  String get selectedPeriod => _selectedPeriod;

  void setPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  // Найчастіший настрій
  Map<String, dynamic> get mostFrequentMood => {
    'emoji': '😊',
    'text': 'Відмінно',
    'color': const Color(0xFF4CAF50),
  };

  // Найдовша серія
  int get longestStreak => 14;

  // Дані для графіка динаміки настрою (останні 30 днів)
  List<MoodDataPoint> get moodTrendData {
    // Генеруємо тестові дані
    return [
      MoodDataPoint(day: '2 лют', value: 5),
      MoodDataPoint(day: '3 лют', value: 4),
      MoodDataPoint(day: '4 лют', value: 3),
      MoodDataPoint(day: '5 лют', value: 2),
      MoodDataPoint(day: '6 лют', value: 4),
      MoodDataPoint(day: '7 лют', value: 5),
      MoodDataPoint(day: '10 лют', value: 5),
      MoodDataPoint(day: '12 лют', value: 4),
      MoodDataPoint(day: '14 лют', value: 4),
      MoodDataPoint(day: '15 лют', value: 5),
      MoodDataPoint(day: '18 лют', value: 3),
      MoodDataPoint(day: '20 лют', value: 4),
      MoodDataPoint(day: '22 лют', value: 1),
      MoodDataPoint(day: '25 лют', value: 5),
    ];
  }

  // Розподіл настроїв (для кругової діаграми)
  List<MoodDistribution> get moodDistribution {
    return [
      MoodDistribution(
        mood: 'Відмінно',
        emoji: '😍',
        count: 12,
        color: const Color(0xFF4CAF50),
        percentage: 40,
      ),
      MoodDistribution(
        mood: 'Добре',
        emoji: '😊',
        count: 8,
        color: const Color(0xFF8BC34A),
        percentage: 27,
      ),
      MoodDistribution(
        mood: 'Нормально',
        emoji: '😐',
        count: 5,
        color: const Color(0xFFFFEB3B),
        percentage: 17,
      ),
      MoodDistribution(
        mood: 'Погано',
        emoji: '😔',
        count: 3,
        color: const Color(0xFFFF9800),
        percentage: 10,
      ),
      MoodDistribution(
        mood: 'Жахливо',
        emoji: '😭',
        count: 1,
        color: const Color(0xFFFF5722),
        percentage: 3,
      ),
      MoodDistribution(
        mood: 'Закоханий',
        emoji: '🥰',
        count: 1,
        color: const Color(0xFFE91E63),
        percentage: 3,
      ),
    ];
  }

  // Загальна кількість записів за обраний період
  int get totalEntries {
    switch (_selectedPeriod) {
      case 'last7':
        return 7;
      case 'last30':
        return 30;
      default:
        return 45;
    }
  }
}

// Клас для даних графіка
class MoodDataPoint {
  final String day;
  final int value; // від 1 до 5

  MoodDataPoint({required this.day, required this.value});
}

// Клас для розподілу настроїв
class MoodDistribution {
  final String mood;
  final String emoji;
  final int count;
  final Color color;
  final double percentage;

  MoodDistribution({
    required this.mood,
    required this.emoji,
    required this.count,
    required this.color,
    required this.percentage,
  });
}