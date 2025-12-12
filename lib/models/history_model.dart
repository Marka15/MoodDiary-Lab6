import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/mood_repository.dart';
//import '../models/mood_entry_model.dart'; 

class HistoryEntry {
  final String id;
  final DateTime date;
  final String emoji;
  final String moodText;
  final String notes;
  final Color color;
  final String? imageUrl; 

  HistoryEntry({
    required this.id,
    required this.date,
    required this.emoji,
    required this.moodText,
    required this.notes,
    required this.color,
    this.imageUrl, 
  });
}

class HistoryModel extends ChangeNotifier {
  final MoodRepository _repository = MoodRepository();
  
  DateTime _currentDate = DateTime.now(); 
  HistoryEntry? _selectedEntry;
  List<HistoryEntry> _allEntries = [];
  bool _isLoading = false;

  // Геттери
  DateTime get currentDate => _currentDate;
  HistoryEntry? get selectedEntry => _selectedEntry;
  bool get isLoading => _isLoading;
  List<HistoryEntry> get entriesForCurrentMonth => _allEntries.where((e) => 
      e.date.month == _currentDate.month && e.date.year == _currentDate.year
    ).toList();
  
  static final Map<String, Map<String, dynamic>> moodLegend = {
    '🤩': {'text': 'Відмінно', 'color': const Color(0xFF90C890)},
    '😊': {'text': 'Добре', 'color': const Color(0xFFB7DEB7)},
    '😐': {'text': 'Нормально', 'color': const Color(0xFFFFF2A7)},
    '😟': {'text': 'Погано', 'color': const Color(0xFFFFD19A)},
    '😭': {'text': 'Жахливо', 'color': const Color(0xFFFFA994)},
    '🥰': {'text': 'Закоханий', 'color': const Color(0xFFF7B4D4)},
  };

  Color _getColorForMood(String emoji) {
    if (moodLegend.containsKey(emoji)) {
      return moodLegend[emoji]!['color'];
    }
    return const Color(0xFFE0E0E0);
  }

  HistoryModel() {
    _initData();
  }

  void _initData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _isLoading = true;
      notifyListeners();

      _repository.getEntriesStream(user.uid).listen((moodModels) {
        _allEntries = moodModels.map((model) {
          return HistoryEntry(
            id: model.id ?? '',
            date: model.date,
            emoji: model.emoji,
            moodText: model.moodText,
            notes: model.notes,
            imageUrl: model.imageUrl, 
            color: _getColorForMood(model.emoji),
          );
        }).toList();

        _isLoading = false;
        
        if (_selectedEntry != null) {
          try {
            final updatedEntry = _allEntries.firstWhere((e) => e.id == _selectedEntry!.id);
            _selectedEntry = updatedEntry;
          } catch (e) {
            _selectedEntry = null;
          }
        }
        notifyListeners();
      });
    }
  }

  //   Методи oToNextMonth, deleteCurrentEntry
  void goToNextMonth() {
    _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    _selectedEntry = null;
    notifyListeners();
  }

  void goToPreviousMonth() {
    _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    _selectedEntry = null;
    notifyListeners();
  }

  void selectEntry(HistoryEntry? entry) {
    _selectedEntry = entry;
    notifyListeners();
  }

  Future<void> deleteCurrentEntry() async {
    if (_selectedEntry == null) return;
    try {
      await _repository.deleteEntry(_selectedEntry!.id);
      _selectedEntry = null;
    } catch (e) {
      print("Error deleting: $e");
    }
  }
}