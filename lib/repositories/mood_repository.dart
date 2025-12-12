//import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; 
import '../models/mood_entry_model.dart';
import 'package:image_picker/image_picker.dart'; 
import 'dart:typed_data';

class MoodRepository {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('mood_entries');
// завантаження даних 
  Stream<List<MoodEntryModel>> getEntriesStream(String userId) {
    return _collection
        .where('userId', isEqualTo: userId) 
        .orderBy('date', descending: true)  
        .snapshots()                        
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MoodEntryModel.fromFirestore(doc))
          .toList();
    });
  }

  // Метод для додавання запису
  Future<void> addEntry(MoodEntryModel entry) async {
    try {
      await _collection.add(entry.toFirestore());
    } catch (e) {
      throw Exception('Не вдалося додати запис: $e');
    }
  }
// Оновлення запису
 Future<void> updateEntry(MoodEntryModel entry) async {
    if (entry.id == null) return;
    try {
  
      await _collection.doc(entry.id).update(entry.toFirestore());
    } catch (e) {
      throw Exception('Помилка оновлення: $e');
    }
  }
// Видалення
    Future<void> deleteEntry(String entryId) async {
    try {
      await _collection.doc(entryId).delete();
    } catch (e) {
      throw Exception('Не вдалося видалити запис: $e');
    }

  }

// Завантаження зображення
 Future<String?> uploadImage(XFile imageFile, String userId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child(userId)
          .child(fileName);

      Uint8List fileBytes = await imageFile.readAsBytes();

  
      await ref.putData(fileBytes, SettableMetadata(contentType: 'image/jpeg'));

      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

}