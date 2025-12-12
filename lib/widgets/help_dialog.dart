import 'package:flutter/material.dart';

// Ця функція залишається без змін.
void showHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (BuildContext context) {
      return const HelpDialog();
    },
  );
}


class HelpDialog extends StatelessWidget {
  const HelpDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 8,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      child: SizedBox(
        width: 550,
        height: 600,
        child: Stack(
          children: [
            // Основний контент, що прокручується
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Scrollbar(
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок
                      const Row(
                        children: [
                          Icon(Icons.menu_book_outlined, color: Color(0xFF3E8B3E), size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Довідник користувача',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Секція "Про програму"
                      const _SectionHeader(title: 'Про програму MoodDiary'),
                      const SizedBox(height: 8),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                          children: [
                            TextSpan(
                                text: 'MoodDiary',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                                text:
                                    ' — це ваш персональний цифровий щоденник для відстеження емоційного стану. '
                                    'Регулярно фіксуючи свій настрій, ви можете краще зрозуміти свої емоційні патерни, визначити '
                                    'фактори, що впливають на ваш стан, та працювати над покращенням свого ментального здоров\'я.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Секція "Гарячі клавіші"
                      const _SectionHeader(
                        icon: Icons.keyboard_alt_outlined,
                        title: 'Гарячі клавіші',
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Для швидкої та ефективної роботи використовуйте наступні клавіші:',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),

                      // Таблиця гарячих клавіш
                      _HotkeysTable(),
                    ],
                  ),
                ),
              ),
            ),

            // Кнопка закриття поверх усього
            Positioned(
              top: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 20, color: Colors.black54),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Допоміжний віджет для заголовків секцій
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  const _SectionHeader({Key? key, required this.title, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.black54, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Віджет для всієї таблиці гарячих клавіш
class _HotkeysTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          _HotkeysTableHeader(),
          Divider(height: 1, color: Color(0xFFE0E0E0)),
          // --- Зміни тут ---
          _HotkeyTableRow(
              keyLabel: 'A',
              action: 'Відкрити вікно\nдодавання нового запису',
              contextText: 'Завжди'),
          Divider(height: 1, color: Color(0xFFE0E0E0)),
          _HotkeyTableRow(
              keyLabel: 'D',
              action: 'Перейти на\n"Панель приладів"',
              contextText: 'Завжди'),
          Divider(height: 1, color: Color(0xFFE0E0E0)),
          _HotkeyTableRow(
              keyLabel: 'H',
              action: 'Перейти на\nсторінку "Історія"',
              contextText: 'Завжди'),
          Divider(height: 1, color: Color(0xFFE0E0E0)),
          _HotkeyTableRow(
              keyLabel: 'S',
              action: 'Перейти на\nсторінку "Статистика"',
              contextText: 'Завжди'),
        ],
      ),
    );
  }
}

// Віджет для заголовка таблиці
class _HotkeysTableHeader extends StatelessWidget {
  const _HotkeysTableHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, color: Colors.black54);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('Клавіша(і)', style: headerStyle)),
          Expanded(flex: 5, child: Text('Дія', style: headerStyle)),
          Expanded(flex: 3, child: Text('Контекст', style: headerStyle)),
        ],
      ),
    );
  }
}

// Віджет для одного рядка таблиці
class _HotkeyTableRow extends StatelessWidget {
  final String keyLabel;
  final String action;
  // --- ВИПРАВЛЕНО ТУТ ---
  final String contextText; 

  const _HotkeyTableRow({
    Key? key,
    required this.keyLabel,
    required this.action,
    // --- І ТУТ ---
    required this.contextText, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rowStyle = TextStyle(color: Colors.grey.shade800, height: 1.4);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                keyLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'monospace'),
              ),
            ),
          ),
          Expanded(flex: 5, child: Text(action, style: rowStyle)),
          // --- І ТУТ ---
          Expanded(flex: 3, child: Text(contextText, style: rowStyle)), // Використовуємо перейменоване поле
        ],
      ),
    );
  }
}