import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Пакет для форматування дат
import '../models/dashboard_model.dart';
import '../widgets/sidebar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Завантажуємо дані при вході
    Future.microtask(
      () => Provider.of<DashboardModel>(
        context,
        listen: false,
      ).fetchDashboardData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<DashboardModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      body: Row(
        children: [
          const SideBar(activePage: 'dashboard'),
          Expanded(child: _buildBody(model)),
        ],
      ),
    );
  }

  Widget _buildBody(DashboardModel model) {
    // 1. Спінер
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Помилка
    if (model.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Сталася помилка: ${model.errorMessage}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => model.fetchDashboardData(),
              child: const Text('Спробувати ще раз'),
            ),
          ],
        ),
      );
    }

    // 3. Контент
    return _MainContent();
  }
}

class _MainContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Вітаємо знову! 👋',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _DashboardCard(
                child: _QuoteCard(), 
                flex: 4, 
                color: const Color(0xFFFFF9C4), 
              ),
              // Картка введення настрою
              _DashboardCard(child: _MoodInputCard(), flex: 2),
              // Картка останніх записів
              _DashboardCard(child: _RecentEntriesCard(), flex: 2),
              // Статистика
              _DashboardCard(
                child: _AverageMoodCard(),
                color: const Color(0xFFE0F0FF),
                flex: 1,
              ),
              _DashboardCard(
                child: _MonthlyEntriesCard(),
                color: const Color(0xFFFFF0E0),
                flex: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Базовий віджет для карток
class _DashboardCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final int flex;

  const _DashboardCard({required this.child, this.color, this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
      
        final cardWidth = (constraints.maxWidth / 2.2) * flex;

        return Container(
          width: cardWidth,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: color ?? Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

// === КАРТКИ ===

class _MoodInputCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Як ви себе почуваєте сьогодні?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['😍', '😊', '😐', '😔', '😭']
              .map(
                (emoji) => InkWell(
                  // Додав ефект натискання (поки без дії)
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Функція додавання буде реалізована пізніше',
                        ),
                      ),
                    );
                  },
                  child: Text(emoji, style: const TextStyle(fontSize: 36)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _RecentEntriesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<DashboardModel>(context);
    final entries = model.recentEntries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.list_alt, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              'Останні записи',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (entries.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "Записів поки немає. Додайте перший!",
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ...entries.map((entry) {
            final dateString = DateFormat(
              'd MMMM, HH:mm',
              'uk_UA',
            ).format(entry.date);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Text(entry.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 16),
                  Expanded(
                    // Додав Expanded, щоб текст не вилазив за межі
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateString,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          entry.summary,
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow
                              .ellipsis, // Три крапки, якщо текст довгий
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<DashboardModel>(context);
    final quote = model.dailyQuote;

    if (quote == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.amber),
            SizedBox(width: 8),
            Text(
              'Цитата дня',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '"${quote.content}"',
          style: const TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "- ${quote.author}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class _AverageMoodCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<DashboardModel>(context);
    return Column(
      children: [
        const Row(
          children: [
            Icon(Icons.sentiment_satisfied, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text(
              'Середній настрій',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(model.averageMoodEmoji, style: const TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        Text(model.averageMoodText, style: const TextStyle(fontSize: 18)),
      ],
    );
  }
}

class _MonthlyEntriesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<DashboardModel>(context);
    return Column(
      children: [
        const Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.orangeAccent),
            SizedBox(width: 8),
            Text(
              'Записів цього місяця',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          model.entriesThisMonth.toString(),
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E8B3E),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Продовжуйте в тому ж дусі!',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
