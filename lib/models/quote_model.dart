class QuoteModel {
  final String content;
  final String author;

  QuoteModel({required this.content, required this.author});

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      content: json['content'] ?? 'Не вдалося завантажити цитату',
      author: json['author'] ?? 'Невідомий',
    );
  }
}