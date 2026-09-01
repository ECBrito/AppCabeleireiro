import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  static const String baseUrl = 'http://10.0.2.2:3000';
  DateTime _selectedDate = DateTime.now();

  String get _formattedDate =>
      "${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

  Future<List<dynamic>> _fetchMyAgenda(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/workers/agenda/$userId?date=$_formattedDate'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  Future<void> _updateStatus(int appointmentId, String newStatus) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/bookings/$appointmentId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        setState(() {});
        if (mounted) {
          String msg = "Estado atualizado!";
          if (newStatus == 'completed') msg = "Serviço concluído (+1 carimbo atribuído ao cliente)! ✂️";
          if (newStatus == 'cancelled') msg = "Marcação cancelada.";
          if (newStatus == 'confirmed') msg = "Marcação confirmada!";

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: newStatus == 'cancelled' ? Colors.redAccent : Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao atualizar: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  // --- MODAL DE DETALHES DO CLIENTE ---
  void _showClientDetails(Map<String, dynamic> appt) {
    final clientName = appt['client_name'] ?? 'Cliente';
    final clientPhone = (appt['client_phone'] ?? '').toString().replaceAll(' ', '');
    final serviceName = appt['service_name'] ?? 'Serviço';
    final price = double.tryParse(appt['price']?.toString() ?? '0.0') ?? 0.0;
    final time = appt['booking_time'] ?? '';
    final status = (appt['status'] ?? 'pending').toString().toUpperCase();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Detalhes da Marcação",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(status, style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(color: Colors.white10, height: 25),

            // INFO DO CLIENTE
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.gold,
                child: Icon(Icons.person, color: Colors.black),
              ),
              title: Text(clientName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text(
                clientPhone.isNotEmpty ? clientPhone : "Sem contacto telefónico registado",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),

            // SERVIÇO & HORÁRIO
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(serviceName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Horário: $time", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  Text(
                    "${price.toStringAsFixed(2)}€",
                    style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // BOTÕES DE CONTACTO DIRETO
            if (clientPhone.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.symmetric(vertical: 12)),
                      onPressed: () async {
                        final uri = Uri.parse('tel:$clientPhone');
                        if (await canLaunchUrl(uri)) await launchUrl(uri);
                      },
                      icon: const Icon(Icons.call, color: Colors.white, size: 18),
                      label: const Text("Ligar", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
                      onPressed: () async {
                        final clean = clientPhone.startsWith('+') ? clientPhone : '+351$clientPhone';
                        final uri = Uri.parse('https://wa.me/$clean?text=Olá%20$clientName,%20falamos%20da%20barbearia%20sobre%20a%20tua%20marcação%20das%20$time.');
                        if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      icon: const Icon(Icons.chat, color: Colors.white, size: 18),
                      label: const Text("WhatsApp", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // --- CONFIRMAÇÃO DE CANCELAMENTO ---
  Future<void> _confirmCancelDialog(int apptId, String clientName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Cancelar Marcação?", style: TextStyle(color: Colors.white)),
        content: Text(
          "Tens a certeza que pretendes cancelar o agendamento de $clientName?",
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("VOLTAR", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("CANCELAR MARCAÇÃO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _updateStatus(apptId, 'cancelled');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userId = auth.userModel?.id ?? 0;
    final userName = auth.userModel?.name ?? 'Profissional';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Olá, $userName", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Painel do Profissional", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/client_home'),
            icon: const Icon(Icons.person, color: AppColors.gold, size: 18),
            label: const Text("Modo Cliente", style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sair',
            onPressed: () {
              auth.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // SELETOR DE DATAS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 14,
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index - 2));
                  final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 55,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.gold : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? null : Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('E', 'pt_PT').format(date).toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // LISTA DE MARCAÇÕES DO DIA
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              key: ValueKey(_formattedDate),
              future: _fetchMyAgenda(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                }

                final tasks = snapshot.data ?? [];

                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available, size: 60, color: Colors.grey[800]),
                        const SizedBox(height: 15),
                        const Text("Sem marcações para este dia.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: () async => setState(() {}),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final appt = tasks[index];
                      final id = appt['id'];
                      final clientName = appt['client_name'] ?? 'Cliente';
                      final serviceName = appt['service_name'] ?? 'Serviço';
                      final time = appt['booking_time'] ?? '';
                      final status = (appt['status'] ?? 'pending').toString().toLowerCase();

                      Color statusColor = AppColors.gold;
                      String statusLabel = "PENDENTE";

                      if (status == 'confirmed') {
                        statusColor = Colors.green;
                        statusLabel = "CONFIRMADO";
                      } else if (status == 'completed') {
                        statusColor = Colors.blue;
                        statusLabel = "CONCLUÍDO";
                      } else if (status == 'cancelled') {
                        statusColor = Colors.redAccent;
                        statusLabel = "CANCELADO";
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border(left: BorderSide(color: statusColor, width: 4)),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showClientDetails(appt),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            clientName,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              statusLabel,
                                              style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "$serviceName • $time",
                                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),

                                // BOTÃO DE AÇÕES RÁPIDAS
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                                  color: AppColors.surface,
                                  onSelected: (action) {
                                    if (action == 'info') {
                                      _showClientDetails(appt);
                                    } else if (action == 'cancel') {
                                      _confirmCancelDialog(id, clientName);
                                    } else {
                                      _updateStatus(id, action);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'info',
                                      child: Row(
                                        children: [
                                          Icon(Icons.info_outline, color: Colors.white70, size: 18),
                                          SizedBox(width: 8),
                                          Text("Ver Info / Contactar", style: TextStyle(color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                    if (status != 'confirmed' && status != 'completed')
                                      const PopupMenuItem(
                                        value: 'confirmed',
                                        child: Row(
                                          children: [
                                            Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                                            SizedBox(width: 8),
                                            Text("Confirmar", style: TextStyle(color: Colors.green)),
                                          ],
                                        ),
                                      ),
                                    if (status != 'completed')
                                      const PopupMenuItem(
                                        value: 'completed',
                                        child: Row(
                                          children: [
                                            Icon(Icons.content_cut, color: Colors.blueAccent, size: 18),
                                            SizedBox(width: 8),
                                            Text("Concluir Serviço", style: TextStyle(color: Colors.blueAccent)),
                                          ],
                                        ),
                                      ),
                                    if (status != 'cancelled')
                                      const PopupMenuItem(
                                        value: 'cancel',
                                        child: Row(
                                          children: [
                                            Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 18),
                                            SizedBox(width: 8),
                                            Text("Cancelar Marcação", style: TextStyle(color: Colors.redAccent)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1, end: 0);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}