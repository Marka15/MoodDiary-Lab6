import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/statistics_model.dart';
import '../widgets/sidebar.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      body: Row(
        children: [
          const SideBar(activePage: 'statistics'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  const Row(
                    children: [
                      Text(
                        'Статистика',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Text('📊', style: TextStyle(fontSize: 28)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Кнопки вибору періоду
                  _PeriodSelector(),
                  const SizedBox(height: 32),
                  
                  // Верхні картки (Найчастіший настрій + Найдовша серія)
                  Row(
                    children: [
                      Expanded(child: _MostFrequentMoodCard()),
                      const SizedBox(width: 24),
                      Expanded(child: _LongestStreakCard()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Графік динаміки настрою
                  _MoodTrendChart(),
                  const SizedBox(height: 24),
                  
                  // Розподіл настроїв (кругова діаграма)
                  _MoodDistributionChart(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Віджет вибору періоду
class _PeriodSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<StatisticsModel>();
    
    return Row(
      children: [
        _PeriodButton(
          text: 'Останні 7 днів',
          isSelected: model.selectedPeriod == 'last7',
          onTap: () => model.setPeriod('last7'),
        ),
        const SizedBox(width: 12),
        _PeriodButton(
          text: 'Останні 30 днів',
          isSelected: model.selectedPeriod == 'last30',
          onTap: () => model.setPeriod('last30'),
        ),
        const SizedBox(width: 12),
        _PeriodButton(
          text: 'Весь час',
          isSelected: model.selectedPeriod == 'all',
          onTap: () => model.setPeriod('all'),
        ),
      ],
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5FB35F) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF5FB35F) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Картка найчастішого настрою
class _MostFrequentMoodCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<StatisticsModel>();
    final mood = model.mostFrequentMood;
    
    return Container(
      padding: const EdgeInsets.all(24),
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
            'Найчастіший настрій',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.star, color: Color(0xFF4CAF50), size: 32),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(mood['emoji'], style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        mood['text'],
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Картка найдовшої серії
class _LongestStreakCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<StatisticsModel>();
    
    return Container(
      padding: const EdgeInsets.all(24),
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
            'Найдовша серія',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.local_fire_department, color: Color(0xFF4CAF50), size: 32),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model.longestStreak} днів',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Графік динаміки настрою
class _MoodTrendChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<StatisticsModel>();
    final data = model.moodTrendData;
    
    return Container(
      padding: const EdgeInsets.all(24),
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
          const Row(
            children: [
              Text(
                'Динаміка настрою',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Text('📈', style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: _LineChart(data: data),
          ),
        ],
      ),
    );
  }
}

// Власний віджет лінійного графіка
class _LineChart extends StatelessWidget {
  final List<MoodDataPoint> data;

  const _LineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('Немає даних'));

    final maxValue = 6.0;
    final minValue = 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final stepX = width / (data.length - 1);

        return CustomPaint(
          size: Size(width, height),
          painter: _LineChartPainter(
            data: data,
            maxValue: maxValue,
            minValue: minValue,
            stepX: stepX,
          ),
        );
      },
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<MoodDataPoint> data;
  final double maxValue;
  final double minValue;
  final double stepX;

  _LineChartPainter({
    required this.data,
    required this.maxValue,
    required this.minValue,
    required this.stepX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedValue = (data[i].value - minValue) / (maxValue - minValue);
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Малюємо точки
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = const Color(0xFF4CAF50),
      );
    }

    canvas.drawPath(path, paint);

    // Малюємо сітку та підписи
    _drawGrid(canvas, size);
    _drawLabels(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    // Горизонтальні лінії
    for (int i = 0; i <= 6; i++) {
      final y = size.height - (i / 6 * size.height);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawLabels(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Підписи осі Y
    for (int i = 0; i <= 6; i++) {
      textPainter.text = TextSpan(
        text: i.toString(),
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      );
      textPainter.layout();
      final y = size.height - (i / 6 * size.height) - textPainter.height / 2;
      textPainter.paint(canvas, Offset(-25, y));
    }

    // Підписи осі X (кожен 2-й день)
    for (int i = 0; i < data.length; i += 2) {
      textPainter.text = TextSpan(
        text: data[i].day,
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      );
      textPainter.layout();
      final x = i * stepX - textPainter.width / 2;
      textPainter.paint(canvas, Offset(x, size.height + 10));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Розподіл настроїв (кругова діаграма)
class _MoodDistributionChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<StatisticsModel>();
    final distribution = model.moodDistribution;
    
    return Container(
      padding: const EdgeInsets.all(24),
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
          const Row(
            children: [
              Text(
                'Розподіл настроїв',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Text('😊', style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Кругова діаграма
              SizedBox(
                width: 250,
                height: 250,
                child: CustomPaint(
                  painter: _PieChartPainter(distribution: distribution),
                ),
              ),
              const SizedBox(width: 32),
              // Легенда
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: distribution.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: item.color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(item.emoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.mood,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            '${item.percentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Малювання кругової діаграми
class _PieChartPainter extends CustomPainter {
  final List<MoodDistribution> distribution;

  _PieChartPainter({required this.distribution});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final innerRadius = radius * 0.5; // Для donut chart

    double startAngle = -math.pi / 2;

    for (var item in distribution) {
      final sweepAngle = (item.percentage / 100) * 2 * math.pi;
      
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      // Малюємо сегмент
      final path = Path();
      path.moveTo(center.dx, center.dy);
      path.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
      );
      path.lineTo(center.dx, center.dy);
      canvas.drawPath(path, paint);

      startAngle += sweepAngle;
    }

    // Малюємо білий круг всередині для donut chart
    canvas.drawCircle(
      center,
      innerRadius,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}