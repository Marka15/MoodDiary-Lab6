import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote_model.dart';

class QuoteRepository {

  final String _baseUrl = 'https://dummyjson.com/quotes/random';

  Future<QuoteModel> getRandomQuote() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        return QuoteModel(
          content: data['quote'] ?? 'Цитата не знайдена',
          author: data['author'] ?? 'Невідомий',
        );
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      print("Error fetching quote: $e"); 
      
      return QuoteModel(
        content: "Кожен день - це новий початок. Продовжуй рухатися вперед!",
        author: "MoodDiary (Офлайн)",
      );
    }
  }
}