import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_entry_model.dart';
import '../repositories/mood_repository.dart';
import '../models/quote_model.dart';
import '../repositories/quote_repository.dart';

class DashboardModel extends ChangeNotifier {
  final MoodRepository _repository = MoodRepository();
  final QuoteRepository _quoteRepository = QuoteRepository();

  bool _isLoading = false;
  String? _errorMessage;
  List<MoodEntryModel> _recentEntries = [];
    QuoteModel? _dailyQuote;

  // Геттери станt
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MoodEntryModel> get recentEntries {
    _recentEntries.sort((a, b) => b.date.compareTo(a.date));

  return _recentEntries.take(3).toList();
  }
   QuoteModel? get dailyQuote => _dailyQuote;


  int get entriesThisMonth {
    final now = DateTime.now();
    return _recentEntries.where((e) => 
      e.date.month == now.month && e.date.year == now.year
    ).length;
  }

  String get averageMoodEmoji {
    if (_recentEntries.isEmpty) return '😐';
    return _recentEntries.first.emoji; 
  }

  // 3. Повертаємо текст останнього запису
  String get averageMoodText {
     if (_recentEntries.isEmpty) return 'Немає даних';
     return _recentEntries.first.moodText;
  }
  
  // =======================================================

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _recentEntries = [];
        _errorMessage = "Необхідно увійти в систему";
      } else {
        // Отримуємо потік даних і беремо перше значення (як Future)
        final stream = _repository.getEntriesStream(user.uid);
        _recentEntries = await stream.first; 

         _dailyQuote = await _quoteRepository.getRandomQuote();
      }

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNewMood() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final newEntry = MoodEntryModel(
        userId: user.uid,
        date: DateTime.now(),
        emoji: '😎',
        moodText: 'Круто',
        summary: 'Я увійшов в систему!',
        notes: 'Це запис реального юзера.',
      );
      
      await _repository.addEntry(newEntry);
      // Оновлюємо дані після запису
      await fetchDashboardData(); 
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}