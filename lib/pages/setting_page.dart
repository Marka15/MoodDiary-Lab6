import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sentry_flutter/sentry_flutter.dart'; // <-- 1. ДОДАЙТЕ ЦЕЙ ІМПОРТ
import '../models/setting_model.dart';
import '../widgets/sidebar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   
    final settingsData = UserSettingsModel(
      userName: 'Користувач MoodDiary',
      userEmail: 'user@example.com',
      registrationDate: DateTime(2025, 1, 15),
      recordsForExport: 14,
      appVersion: '1.0.0',
      copyrightNotice: '© 2025 MoodDiary. Всі права захищені.',
    );

    final formattedDate = DateFormat('dd MMMM yyyy', 'uk_UA').format(settingsData.registrationDate);

    return Scaffold(
      body: Row(
        children: [
        
          const SideBar(activePage: 'settings'),

          Expanded(
            child: Container(
              color: const Color(0xFFF5F9F5),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  
                    const Row(
                      children: [
                        Text('Налаштування', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        SizedBox(width: 12),
                        Icon(Icons.settings, size: 28, color: Colors.black54),
                      ],
                    ),
                    const SizedBox(height: 32),

                
                    _SettingsCard(
                      icon: Icons.person_outline,
                      title: 'Профіль користувача',
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: const Color(0xFF5FB35F),
                                child: Text(settingsData.avatarLetter, style: const TextStyle(fontSize: 24, color: Colors.white)),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildInfoField(label: 'ІМ\'Я', value: settingsData.userName),
                                    const SizedBox(height: 16),
                                    _buildInfoField(label: 'ЕЛЕКТРОННА ПОШТА', value: settingsData.userEmail),
                                    const SizedBox(height: 16),
                                    _buildInfoField(label: 'ДАТА РЕЄСТРАЦІЇ', value: formattedDate),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Редагувати профіль'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4E5D4), foregroundColor: const Color(0xFF3E8B3E), elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Картка "Експорт даних"
                    _SettingsCard(
                      icon: Icons.download_outlined,
                      title: 'Експорт даних',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Завантажте копію всіх ваших записів настрою у зручному форматі'),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildExportButton(icon: Icons.description, label: 'Експорт у JSON'),
                              _buildExportButton(icon: Icons.table_chart, label: 'Експорт у CSV'),
                              _buildExportButton(icon: Icons.text_snippet, label: 'Експорт у TXT'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.black54, size: 18),
                              const SizedBox(width: 8),
                              Text('Всього записів для експорту: ${settingsData.recordsForExport}'),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),


                    // Картка для тестування
                    _SettingsCard(
                      icon: Icons.bug_report_outlined,
                      title: 'Тестування звітів про помилки',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Використовуйте ці кнопки, щоб надіслати тестові помилки в Sentry.'),
                          const SizedBox(height: 20),
                        
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                
                                throw StateError('Це тестова НЕКРИТИЧНА помилка з налаштувань!');
                              } catch (exception, stackTrace) {
                               
                                await Sentry.captureException(
                                  exception,
                                  stackTrace: stackTrace,
                                );
                            
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Некритичну помилку відправлено в Sentry!'),
                                      backgroundColor: Colors.blue,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.warning_amber),
                            label: const Text('Згенерувати некритичну помилку'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Кнопка для критичної помилки (крешу)
                          ElevatedButton.icon(
                            onPressed: () {
                
                              throw Exception('Це тестова КРИТИЧНА помилка (креш) з налаштувань!');
                            },
                            icon: const Icon(Icons.error_outline),
                            label: const Text('Згенерувати критичну помилку (креш)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                 

                    // Картка "Небезпечна зона" 
                    _DangerZoneCard(),
                    const SizedBox(height: 24),

                    // Картка "Про програму"
                    _SettingsCard(
                      icon: Icons.info_outline,
                      title: 'Про програму',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('MoodDiary - ваш персональний щоденник емоційного стану', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text('Версія: ${settingsData.appVersion}'),
                          const SizedBox(height: 4),
                          Text(settingsData.copyrightNotice),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildInfoField({required String label, required String value}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      Container(
        width: double.infinity, padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
        child: Text(value),
      ),
    ]);
  }

  Widget _buildExportButton({required IconData icon, required String label}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: OutlinedButton.icon(
          onPressed: () {}, icon: Icon(icon, color: const Color(0xFF3E8B3E)),
          label: Text(label, style: const TextStyle(color: Colors.black87)),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ),
    );
  }
}

// Віджети _SettingsCard та _DangerZoneCard 
class _SettingsCard extends StatelessWidget {
  final IconData icon; final String title; final Widget child;
  const _SettingsCard({Key? key, required this.icon, required this.title, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: Colors.black54), const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
        const Divider(height: 32),
        child,
      ]),
    );
  }
}

class _DangerZoneCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.shade300)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700), const SizedBox(width: 12),
          Text('Небезпечна зона', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
        ]),
        const SizedBox(height: 16),
        const Text('Вийти з облікового запису', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Ви будете виведені з системи. Всі дані залишаться збереженими.'),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {}, icon: const Icon(Icons.logout), label: const Text('Вийти з облікового запису'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        )
      ]),
    );
  }
}