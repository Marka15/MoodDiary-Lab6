import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- 1. ДОДАНО: для доступу до даних користувача
import 'package:mood_diary/pages/login_page.dart'; // <-- 2. ДОДАНО: для переходу на сторінку входу
import 'package:mood_diary/pages/statistics_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/history_page.dart';
import '../pages/setting_page.dart';
import 'help_dialog.dart';
import 'add_mood_dialog.dart';

class SideBar extends StatelessWidget {
  final String activePage;

  const SideBar({Key? key, required this.activePage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  
    final currentUser = FirebaseAuth.instance.currentUser;

 
    final String userName = currentUser?.displayName ?? currentUser?.email ?? 'Користувач';
    final String? userPhotoUrl = currentUser?.photoURL;
 

    return Container(
      width: 260,
      color: const Color(0xFFD4E5D4),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.eco, color: Color(0xFF3E8B3E), size: 20),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 3.0),
                child: Text(
                  'MoodDiary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E8B3E),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.help_outline, color: Colors.black54),
                onPressed: () {
                  showHelpDialog(context);
                },
                tooltip: 'Допомога',
              ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.settings,
                  color: activePage == 'settings'
                      ? const Color(0xFF5FB35F)
                      : const Color(0xFF3E8B3E),
                ),
                onPressed: () {
                  if (activePage != 'settings') {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const SettingsPage(),
                        transitionDuration: const Duration(milliseconds: 300),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      ),
                    );
                  }
                },
                tooltip: 'Налаштування',
              ),
            ],
          ),
          const SizedBox(height: 48),

          _NavItem(
            icon: Icons.home,
            text: 'Панель приладів',
            isActive: activePage == 'dashboard',
            onTap: () {
              if (activePage != 'dashboard') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const DashboardPage(),
                    transitionDuration: const Duration(milliseconds: 300),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          _NavItem(
            icon: Icons.history,
            text: 'Історія',
            isActive: activePage == 'history',
            onTap: () {
              if (activePage != 'history') {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
              }
            },
          ),
          const SizedBox(height: 16),
          _NavItem(
            icon: Icons.bar_chart,
            text: 'Статистика',
            isActive: activePage == 'statistics',
            onTap: () {
              if (activePage != 'statistics') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => StatisticsPage(),
                    transitionDuration: const Duration(milliseconds: 300),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              }
            },
          ),
          const Spacer(),

          Row(
            children: [
              // Якщо є фото - показуємо його, якщо ні - першу літеру імені
              if (userPhotoUrl != null)
                CircleAvatar(
                  backgroundImage: NetworkImage(userPhotoUrl),
                  backgroundColor: const Color(0xFF5FB35F),
                )
              else
                CircleAvatar(
                  backgroundColor: const Color(0xFF5FB35F),
                  child: Text(userName.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white)),
                ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Text(
                  userName,
                  style: const TextStyle(color: Color(0xFF3E8B3E)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () { showAddMoodDialog(context);},
              icon: const Icon(Icons.add),
              label: const Text('Додати запис'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5FB35F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),

         
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () async {
                // Виходимо з акаунта
                await FirebaseAuth.instance.signOut();
                // Перенаправляємо на сторінку входу і очищуємо історію навігації
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Вийти'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3E8B3E),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
         
        ],
      ),
    );
  }
}


class _NavItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.text, required this.onTap, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF5FB35F) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.white : const Color(0xFF3E8B3E)),
            const SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.w500, color: isActive ? Colors.white : const Color(0xFF3E8B3E)),
            ),
          ],
        ),
      ),
    );
  }
}