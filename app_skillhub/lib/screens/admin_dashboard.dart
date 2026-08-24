import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  static const String baseUrl = 'http://10.0.2.2:3000';

  DateTime _selectedDate = DateTime.now();
  bool _isShopOpen = true;

  String get _formattedSelectedDate {
    return "${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
  }

  Future<List<dynamic>> _fetchBookings(int shopId, String date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookings?shopId=$shopId&date=$date'),
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
        setState(() {}); // Recarrega os dados da data selecionada
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Marcação atualizada para: $newStatus"),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
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

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final themeColor = appProvider.getThemeColor();
    final shopName = appProvider.activeBusiness?.name ?? "SkillHub Admin";
    final shopId = int.tryParse(appProvider.activeBusiness?.id ?? '1') ?? 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shopName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(
              DateFormat('EEEE, d MMMM', 'pt_PT').format(DateTime.now()).toUpperCase(),
              style: TextStyle(fontSize: 12, color: Colors.grey[400], letterSpacing: 1),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: themeColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configurar Loja',
            onPressed: () => Navigator.pushNamed(context, '/shop_edit'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        key: ValueKey(_formattedSelectedDate),
        future: _fetchBookings(shopId, _formattedSelectedDate),
        builder: (context, snapshot) {
          final dayAppointments = snapshot.data ?? [];

          final dayRevenue = dayAppointments
              .where((appt) => appt['status'] != 'cancelled')
              .fold(0.0, (sum, appt) {
            final price = double.tryParse(appt['price']?.toString() ?? '0.0') ?? 0.0;
            return sum + price;
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShopStatusToggle(themeColor),
                const SizedBox(height: 20),

                _buildRevenueCard(dayRevenue, themeColor),
                const SizedBox(height: 25),

                Text("Gestão Rápida", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                const SizedBox(height: 15),
                _buildQuickActionsGrid(context, themeColor),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Agenda", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                    Icon(Icons.calendar_month, color: themeColor),
                  ],
                ),
                const SizedBox(height: 15),
                _buildDateSelector(themeColor),
                const SizedBox(height: 15),

                if (snapshot.connectionState == ConnectionState.waiting)
                  Center(child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: CircularProgressIndicator(color: themeColor),
                  ))
                else if (dayAppointments.isEmpty)
                  _buildEmptyState()
                else
                  _buildAppointmentList(dayAppointments, themeColor),

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/booking'),
        backgroundColor: themeColor,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("NOVA MARCAÇÃO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildShopStatusToggle(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isShopOpen ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _isShopOpen ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isShopOpen ? Colors.green : Colors.red).withOpacity(0.6),
                      blurRadius: 8,
                    )
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _isShopOpen ? "LOJA ABERTA" : "LOJA FECHADA",
                style: TextStyle(
                  color: _isShopOpen ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Switch(
            value: _isShopOpen,
            activeColor: Colors.green,
            onChanged: (val) => setState(() => _isShopOpen = val),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildRevenueCard(double revenue, Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeColor.withOpacity(0.9), themeColor.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Faturação Estimada do Dia",
                style: GoogleFonts.lato(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              Text(
                "${revenue.toStringAsFixed(2)}€",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.black,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.trending_up, color: Colors.black, size: 28),
          )
        ],
      ),
    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack);
  }

  Widget _buildQuickActionsGrid(BuildContext context, Color color) {
    final actions = [
      {'title': 'Serviços', 'icon': Icons.content_cut, 'route': '/services_manage'},
      {'title': 'Equipa', 'icon': Icons.people, 'route': '/workers_manage'},
      {'title': 'Clientes', 'icon': Icons.people_outline, 'route': '/customers_manage'},
      {'title': 'Promoções', 'icon': Icons.local_offer, 'route': '/promotions_manage'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 2.5,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          onTap: () {
            if (action['route'] != null) {
              Navigator.pushNamed(context, action['route'] as String);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text("Em breve!"), backgroundColor: color),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action['icon'] as IconData, color: color, size: 20),
                const SizedBox(width: 10),
                Text(
                  action['title'] as String,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSelector(Color color) {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 55,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected ? color : AppColors.surface,
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
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Text("Sem marcações para esta data.", style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildAppointmentList(List<dynamic> appointments, Color color) {
    return Column(
      children: appointments.map((appt) {
        final id = appt['id'];
        final clientName = appt['client_name'] ?? 'Cliente';
        final serviceName = appt['service_name'] ?? 'Serviço';
        final time = appt['booking_time'] ?? '';
        final workerName = appt['worker_name'] ?? 'Profissional';
        final status = (appt['status'] ?? 'pending').toString().toLowerCase();
        final price = double.tryParse(appt['price']?.toString() ?? '0.0') ?? 0.0;

        Color statusColor = AppColors.gold;
        String statusLabel = 'PENDENTE';
        if (status == 'confirmed') {
          statusColor = Colors.green;
          statusLabel = 'CONFIRMADO';
        } else if (status == 'completed') {
          statusColor = Colors.blue;
          statusLabel = 'CONCLUÍDO';
        } else if (status == 'cancelled') {
          statusColor = Colors.redAccent;
          statusLabel = 'CANCELADO';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: statusColor, width: 4)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(clientName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$serviceName • $time ($workerName)", style: TextStyle(color: Colors.grey[400])),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${price.toStringAsFixed(2)}€",
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  color: AppColors.surface,
                  onSelected: (newStatus) => _updateStatus(id, newStatus),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'confirmed',
                      child: Text("Confirmar", style: TextStyle(color: Colors.green)),
                    ),
                    PopupMenuItem(
                      value: 'completed',
                      child: Text("Concluir", style: TextStyle(color: Colors.blue)),
                    ),
                    PopupMenuItem(
                      value: 'cancelled',
                      child: Text("Cancelar", style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0);
      }).toList(),
    );
  }
}