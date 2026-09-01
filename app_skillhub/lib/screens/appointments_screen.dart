import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../config/theme.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => AppointmentsScreenState();
}

class AppointmentsScreenState extends State<AppointmentsScreen> {
  static const String baseUrl = 'http://10.0.2.2:3000';
  Future<List<dynamic>>? _bookingsFuture;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  void loadBookings() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final clientId = auth.userModel?.id;
    setState(() {
      _bookingsFuture = _fetchBookings(clientId);
    });
  }

  Future<List<dynamic>> _fetchBookings(int? clientId) async {
    if (clientId == null) return [];
    try {
      final url = '$baseUrl/bookings?clientId=$clientId';
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
        loadBookings();
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
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.gold),
              tooltip: 'Atualizar',
              onPressed: loadBookings,
            ),
          ],
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
              return const Center(child: CircularProgressIndicator(color: AppColors.gold));
            }

            final all = snapshot.data ?? [];
            final now = DateTime.now();
            final todayStr =
                "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

            // Próximos: Apenas confirmados ou pendentes e de hoje em diante
            final upcoming = all.where((item) {
              final status = (item['status'] ?? '').toString().toLowerCase();
              if (status == 'cancelled' || status == 'completed') return false;
              final dateStr = (item['booking_date'] ?? '').toString().split('T').first;
              if (dateStr.isEmpty) return true;
              return dateStr.compareTo(todayStr) >= 0;
            }).toList();

            // Histórico: Concluídos, Cancelados ou anteriores a hoje
            final history = all.where((item) {
              final status = (item['status'] ?? '').toString().toLowerCase();
              if (status == 'cancelled' || status == 'completed') return true;
              final dateStr = (item['booking_date'] ?? '').toString().split('T').first;
              if (dateStr.isEmpty) return false;
              return dateStr.compareTo(todayStr) < 0;
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
      return RefreshIndicator(
        color: AppColors.gold,
        onRefresh: () async => loadBookings(),
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Column(
                children: [
                  Icon(
                    isUpcoming ? Icons.calendar_today : Icons.history,
                    size: 60,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isUpcoming ? "Sem marcações ativas." : "Sem histórico de serviços.",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: AppColors.surface,
      onRefresh: () async => loadBookings(),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          final price = double.tryParse(item['price']?.toString() ?? '0.0') ?? 0.0;
          final dateRaw = (item['booking_date'] ?? '').toString().split('T').first;
          final status = (item['status'] ?? 'pending').toString().toLowerCase();

          Color statusColor = AppColors.gold;
          String statusLabel = "PENDENTE";
          if (status == 'confirmed') {
            statusColor = Colors.green;
            statusLabel = "CONFIRMADO";
          } else if (status == 'completed') {
            statusColor = Colors.blueAccent;
            statusLabel = "CONCLUÍDO";
          } else if (status == 'cancelled') {
            statusColor = Colors.redAccent;
            statusLabel = "CANCELADO";
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border(left: BorderSide(color: statusColor, width: 4)),
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
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusLabel,
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
                        "Profissional: ${item['worker_name'] ?? 'Barbeiro'}",
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
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.white10)),
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
              ],
            ),
          ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }
}