import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../models/appointment_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  DateTime _selectedDate = DateTime.now();
  bool _isShopOpen = true; // Estado local da loja (pode ser movido para o Provider)

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final appointments = provider.appointments;
    final totalRevenue = provider.totalRevenue;
    final themeColor = provider.getThemeColor();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Painel de Gestão', style: TextStyle(fontSize: 20)),
            Text(
              DateFormat('EEEE, d MMMM', 'pt_PT').format(DateTime.now()),
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
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
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Estado da Loja (Aberto/Fechado)
            _buildShopStatusToggle(themeColor),
            const SizedBox(height: 20),

            // 2. Cartão de Faturação Principal
            _buildRevenueCard(totalRevenue, themeColor),
            const SizedBox(height: 25),

            // 3. Grelha de Ações Rápidas (Expandida)
            Text("Ações Rápidas", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 15),
            _buildQuickActionsGrid(context, themeColor),
            const SizedBox(height: 30),

            // 4. Agenda com Seletor de Data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Agenda", style: Theme.of(context).textTheme.titleLarge),
                Icon(Icons.calendar_month, color: themeColor),
              ],
            ),
            const SizedBox(height: 15),
            _buildDateSelector(themeColor),
            const SizedBox(height: 15),

            // Lista de Marcações
            appointments.isEmpty
                ? _buildEmptyState()
                : _buildAppointmentList(appointments, themeColor),

            const SizedBox(height: 80), // Espaço para o FAB
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Futuro: Abrir modal para bloquear horário ou marcar pausa
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Adicionar bloqueio de horário")));
        },
        backgroundColor: themeColor,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("NOVO AGENDAMENTO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Widget para abrir/fechar a loja
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
                      spreadRadius: 2,
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
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Switch(
            value: _isShopOpen,
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
            inactiveTrackColor: Colors.red.withOpacity(0.2),
            onChanged: (val) => setState(() => _isShopOpen = val),
          ),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildQuickActionsGrid(BuildContext context, Color color) {
    // Lista de ações disponíveis
    final actions = [
      {'title': 'Serviços', 'icon': Icons.content_cut, 'route': '/services_manage'},
      {'title': 'Clientes', 'icon': Icons.people, 'route': null}, // Placeholder
      {'title': 'Promoções', 'icon': Icons.local_offer, 'route': null}, // Placeholder
      {'title': 'Relatórios', 'icon': Icons.bar_chart, 'route': null}, // Placeholder
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 colunas
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.6, // Retângulos horizontais
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
                SnackBar(content: Text("Funcionalidade ${action['title']} em breve!"), backgroundColor: color),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action['icon'] as IconData, color: color, size: 32),
                const SizedBox(height: 10),
                Text(
                  action['title'] as String,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ).animate().scale(delay: (50 * index).ms);
      },
    );
  }

  // Seletor de data horizontal
  Widget _buildDateSelector(Color color) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // Próximas 2 semanas
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? color : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: isSelected ? null : Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', 'pt_PT').format(date).toUpperCase(), // Dia da semana (Seg, Ter)
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: 20,
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

  // (Widgets anteriores mantidos e integrados)
  Widget _buildRevenueCard(double revenue, Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeColor, themeColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: themeColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Faturação Total", style: GoogleFonts.lato(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
              const Icon(Icons.trending_up, color: Colors.black54),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "${revenue.toStringAsFixed(2)}€",
            style: GoogleFonts.playfairDisplay(color: Colors.black, fontSize: 42, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildEmptyState() {
    return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Sem marcações para este dia.", style: TextStyle(color: Colors.grey))));
  }

  Widget _buildAppointmentList(List<Appointment> appointments, Color color) {
    // Filtrar por dia (Simulação visual, já que a lista real é simples)
    final dailyAppointments = appointments.reversed.toList();

    return Column(
      children: dailyAppointments.map((appt) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4)), // Indicador lateral colorido
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(appt.clientName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text("${appt.serviceName} • ${DateFormat('HH:mm').format(appt.date)}", style: TextStyle(color: Colors.grey[400])),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text("${appt.price.toStringAsFixed(2)}€", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
        ),
      )).toList(),
    );
  }
}