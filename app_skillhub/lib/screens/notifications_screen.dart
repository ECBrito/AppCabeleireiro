import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../config/theme.dart';
import '../providers/auth_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const String baseUrl = 'http://10.0.2.2:3000';
  late Future<List<dynamic>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userModel?.id;
    setState(() {
      _notificationsFuture = _fetchNotifications(userId);
    });
  }

  Future<List<dynamic>> _fetchNotifications(int? userId) async {
    if (userId == null) return [];
    try {
      final response = await http.get(Uri.parse('$baseUrl/notifications/$userId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  Future<void> _markAllAsRead(int? userId) async {
    if (userId == null) return;
    try {
      final response = await http.patch(Uri.parse('$baseUrl/notifications/$userId/read-all'));
      if (response.statusCode == 200) {
        _loadNotifications();
      }
    } catch (_) {}
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return "Recentemente";
    final date = DateTime.tryParse(dateStr);
    if (date == null) return "Recentemente";

    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return "Há ${diff.inMinutes} min";
    if (diff.inHours < 24) return "Há ${diff.inHours} horas";
    return "Há ${diff.inDays} dias";
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userId = auth.userModel?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Notificações"),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.gold),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: AppColors.gold),
            tooltip: "Marcar todas como lidas",
            onPressed: () => _markAllAsRead(userId),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Text("Sem notificações no momento.", style: TextStyle(color: Colors.grey)),
            );
          }

          return RefreshIndicator(
            color: AppColors.gold,
            onRefresh: () async => _loadNotifications(),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white10),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final isRead = notif['is_read'] == true;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: isRead ? Colors.white10 : AppColors.gold.withOpacity(0.2),
                    child: Icon(
                      isRead ? Icons.notifications_none : Icons.notifications_active,
                      color: isRead ? Colors.grey : AppColors.gold,
                    ),
                  ),
                  title: Text(
                    notif['title'] ?? 'Notificação',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(notif['body'] ?? '', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 5),
                      Text(
                        _formatTime(notif['created_at']),
                        style: TextStyle(color: AppColors.gold.withOpacity(0.7), fontSize: 10),
                      ),
                    ],
                  ),
                  trailing: isRead
                      ? null
                      : Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                ).animate().fadeIn(delay: (100 * index).ms).slideX();
              },
            ),
          );
        },
      ),
    );
  }
}