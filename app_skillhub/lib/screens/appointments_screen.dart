import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../config/theme.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  static const String baseUrl = 'http://10.0.2.2:3000';
  late Future<List<dynamic>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final clientId = auth.userModel?.id;
    _bookingsFuture = _fetchBookings(clientId);
  }

  Future<List<dynamic>> _fetchBookings(int? clientId) async {
    try {
      final url = clientId != null
          ? '$baseUrl/bookings?clientId=$clientId'
          : '$baseUrl/bookings?shopId=1';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  Future<void> _cancelBooking(int id) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/bookings/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': 'cancelled'}),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Marcação cancelada com sucesso."),
            backgroundColor: Colors.orangeAccent,
          ),
        );
        setState(() {
          _loadBookings();
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: const Text("A Minha Agenda"),
          backgroundColor: const Color(0xFF121212),
          centerTitle: false,
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "PRÓXIMOS"),
              Tab(text: "HISTÓRICO"),
            ],
          ),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _bookingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }

            final all = snapshot.data ?? [];
            final now = DateTime.now();

            final upcoming = all.where((item) {
              final status = (item['status'] ?? '').toString().toLowerCase();
              if (status == 'cancelled' || status == 'completed') return false;
              final dateStr = item['booking_date']?.toString().split('T').first ?? '';
              final parsedDate = DateTime.tryParse(dateStr);
              if (parsedDate == null) return true;
              return parsedDate.isAfter(now.subtract(const Duration(days: 1)));
            }).toList();

            final history = all.where((item) {
              final status = (item['status'] ?? '').toString().toLowerCase();
              if (status == 'cancelled' || status == 'completed') return true;
              final dateStr = item['booking_date']?.toString().split('T').first ?? '';
              final parsedDate = DateTime.tryParse(dateStr);
              if (parsedDate == null) return false;
              return parsedDate.isBefore(now.subtract(const Duration(days: 1)));
            }).toList();

            return TabBarView(
              children: [
                _buildList(context, upcoming, true),
                _buildList(context, history, false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<dynamic> list, bool isUpcoming) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.calendar_today : Icons.history,
              size: 60,
              color: Colors.grey[800],
            ),
            const SizedBox(height: 20),
            Text(
              isUpcoming ? "Sem marcações agendadas." : "Sem histórico.",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: AppColors.surface,
      onRefresh: () async {
        setState(() {
          _loadBookings();
        });
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          final price = double.tryParse(item['price']?.toString() ?? '0.0') ?? 0.0;
          final dateRaw = item['booking_date']?.toString().split('T').first ?? '';
          final status = item['status'] ?? 'pending';

          Color statusColor = AppColors.gold;
          if (status == 'confirmed') statusColor = Colors.green;
          if (status == 'cancelled') statusColor = Colors.redAccent;
          if (status == 'completed') statusColor = Colors.blueGrey;

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border(left: BorderSide(color: statusColor, width: 4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['service_name'] ?? 'Serviço',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status.toString().toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        "com ${item['worker_name'] ?? 'Profissional'}",
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 5),
                          Text(
                            "$dateRaw • ${item['booking_time'] ?? ''}",
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Text(
                    "${price.toStringAsFixed(2)}€",
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                if (isUpcoming && status != 'cancelled')
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.white.withOpacity(0.05)),
                      ),
                    ),
                    child: TextButton.icon(
                      onPressed: () => _cancelBooking(item['id']),
                      icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 18),
                      label: const Text(
                        "CANCELAR MARCAÇÃO",
                        style: TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    ),
                  ),

                if (!isUpcoming && status == 'completed')
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.white.withOpacity(0.05)),
                      ),
                    ),
                    child: TextButton.icon(
                      onPressed: () => _showReviewDialog(context),
                      icon: const Icon(Icons.star, color: AppColors.gold, size: 18),
                      label: const Text(
                        "AVALIAR EXPERIÊNCIA",
                        style: TextStyle(color: AppColors.gold, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Avaliar Serviço", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Como foi o teu atendimento?", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                    (index) => const Icon(Icons.star, color: AppColors.gold, size: 30),
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Escreve um comentário...",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.black26,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Obrigado pela avaliação! ⭐")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            child: const Text("ENVIAR", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}