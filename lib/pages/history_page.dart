import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- Додано
import '../models/history_model.dart';
import '../models/mood_entry_model.dart'; // <--- Додано
import '../widgets/sidebar.dart';
import '../widgets/add_mood_dialog.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      body: Row(
        children: [
          const SideBar(activePage: 'history'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _CalendarView()),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: _DetailsPanel()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<HistoryModel>();
    final monthDate = model.currentDate;
    final entries = model.entriesForCurrentMonth;

    final daysInMonth = DateUtils.getDaysInMonth(
      monthDate.year,
      monthDate.month,
    );
    final firstDayOfMonth = DateUtils.firstDayOffset(
      monthDate.year,
      monthDate.month,
      MaterialLocalizations.of(context),// Щоб знати з якого дня починається тиждень
      
    );

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Історія настрою 📅',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: model.goToPreviousMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                DateFormat('MMMM yyyy', 'uk_UA').format(monthDate),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: model.goToNextMonth,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд']
                .map(
                  (day) => Text(
                    day,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: daysInMonth + firstDayOfMonth,
            itemBuilder: (context, index) {
              if (index < firstDayOfMonth) {
                return Container();
              }
              final day = index - firstDayOfMonth + 1;
              final date = DateTime(monthDate.year, monthDate.month, day);

              HistoryEntry? entry;
              try {
                entry = entries.firstWhere((e) => e.date.day == day);
              } catch (e) {
                entry = null;
              }

              return InkWell(
                onTap: () => model.selectEntry(entry),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: entry?.color ?? const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: model.selectedEntry?.date == date
                        ? Border.all(color: Colors.red, width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(day.toString()),
                      if (entry != null)
                        Text(entry.emoji, style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SelectedDayCard(), // Тепер цей метод існує
        const SizedBox(height: 24),
        _LegendCard(),
      ],
    );
  }
}

class _SelectedDayCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final entry = context.watch<HistoryModel>().selectedEntry;

    if (entry == null) {
      return const Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: Text('Оберіть день для перегляду деталей')),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Дата
          Text(
            DateFormat('EEEE, d MMMM yyyy р.', 'uk_UA').format(entry.date),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Настрій
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: entry.color.withAlpha(128),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(entry.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Text(
                  entry.moodText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Нотатки
          const Text('Нотатки:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              entry.notes.isEmpty ? "Немає нотаток" : entry.notes,
              style: TextStyle(
                color: entry.notes.isEmpty ? Colors.grey : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // === НОВЕ: ВІДОБРАЖЕННЯ ФОТО ===
          if (entry.imageUrl != null && entry.imageUrl!.isNotEmpty) ...[
            const Text(
              'Фото дня:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                entry.imageUrl!,

        
                width: double.infinity, 
               
                fit: BoxFit.fitWidth,

                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height:
                        200, // Тільки для лоадера залишаємо фіксовану висоту
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            const SizedBox(height: 8),
          ],

          // Кнопки
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    final historyEntry = context
                        .read<HistoryModel>()
                        .selectedEntry;
                    final user = FirebaseAuth.instance.currentUser;
                    if (historyEntry != null && user != null) {
                      final modelToEdit = MoodEntryModel(
                        id: historyEntry.id,
                        userId: user.uid,
                        date: historyEntry.date,
                        emoji: historyEntry.emoji,
                        moodText: historyEntry.moodText,
                        summary: historyEntry.notes,
                        notes: historyEntry.notes,
                        imageUrl: historyEntry
                            .imageUrl, // Передаємо фото в редагування
                      );
                      showAddMoodDialog(context, entryToEdit: modelToEdit);
                    }
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Редагувати'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blueGrey),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Видалити запис?'),
                        content: const Text('Цю дію неможливо відмінити.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Ні'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<HistoryModel>().deleteCurrentEntry();
                              Navigator.of(ctx).pop();
                            },
                            child: const Text(
                              'Так, видалити',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Видалити'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final legend = HistoryModel.moodLegend;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 Легенда настроїв',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ...legend.entries.map((entry) {
            final emoji = entry.key;
            final details = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Container(width: 16, height: 16, color: details['color']),
                  const SizedBox(width: 8),
                  Text("$emoji ${details['text']}"),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
