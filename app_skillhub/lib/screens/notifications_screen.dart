import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dados Mock
    final notifications = [
      {"title": "Marcação Confirmada", "body": "O teu corte na Barber King foi confirmado para amanhã às 15:00.", "time": "Há 10 min", "read": false},
      {"title": "Promoção Relâmpago ⚡", "body": "20% de desconto em todos os serviços de Spa na Zen Garden.", "time": "Há 2 horas", "read": true},
      {"title": "Bem-vindo!", "body": "Obrigado por te juntares ao SkillHub. Começa a explorar!", "time": "Há 1 dia", "read": true},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Notificações"),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(color: Colors.white10),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          final isRead = notif['read'] as bool;

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: isRead ? Colors.white10 : AppColors.gold.withOpacity(0.2),
              child: Icon(
                  isRead ? Icons.notifications_none : Icons.notifications_active,
                  color: isRead ? Colors.grey : AppColors.gold
              ),
            ),
            title: Text(
              notif['title'] as String,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(notif['body'] as String, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 5),
                Text(notif['time'] as String, style: TextStyle(color: AppColors.gold.withOpacity(0.7), fontSize: 10)),
              ],
            ),
            trailing: isRead ? null : Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle)),
          ).animate().fadeIn(delay: (100 * index).ms).slideX();
        },
      ),
    );
  }
}