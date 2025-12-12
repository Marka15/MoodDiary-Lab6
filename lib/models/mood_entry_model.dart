import 'package:cloud_firestore/cloud_firestore.dart';

class MoodEntryModel {
  final String? id; 
  final String userId;
  final DateTime date;
  final String emoji;
  final String moodText;
  final String summary;
  final String notes;
 final String? imageUrl;

  MoodEntryModel({
    this.id,
    required this.userId,
    required this.date,
    required this.emoji,
    required this.moodText,
    required this.summary,
    required this.notes,
      this.imageUrl,
  });

  //  Для отримання даних
  factory MoodEntryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MoodEntryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      emoji: data['emoji'] ?? '😐',
      moodText: data['moodText'] ?? '',
      summary: data['summary'] ?? '',
      notes: data['notes'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }

  // Для відправки
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date), // Конвертуємо назад
      'emoji': emoji,
      'moodText': moodText,
      'summary': summary,
      'notes': notes,
      'imageUrl': imageUrl,
    };
  }
}