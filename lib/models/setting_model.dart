// Цей файл описує структуру даних для сторінки налаштувань.
// Він не містить жодного коду, пов'язаного з інтерфейсом користувача.

class UserSettingsModel {
  final String userName;
  final String userEmail;
  final DateTime registrationDate;
  final int recordsForExport;
  final String appVersion;
  final String copyrightNotice;

  UserSettingsModel({
    required this.userName,
    required this.userEmail,
    required this.registrationDate,
    required this.recordsForExport,
    required this.appVersion,
    required this.copyrightNotice,
  });

  // Допоміжний метод для отримання першої літери імені для аватара
  String get avatarLetter => userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : '?';
}