import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <--- Importante
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Para formatar a data/hora
import '../config/theme.dart';
import '../providers/app_provider.dart'; // <--- Para ler os dados

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. "Ouvir" o Provider. Sempre que houver uma nova marcação, este ecrã atualiza-se.
    final provider = Provider.of<AppProvider>(context);
    final appointments = provider.appointments;
    final totalRevenue = provider.totalRevenue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Gestão'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/shop_edit'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cartão de Faturação (Agora com valor REAL)
            _buildRevenueCard(totalRevenue),
            const SizedBox(height: 20),

            // Estatísticas Rápidas (Dinâmicas)
            Row(
              children: [
                Expanded(child: _buildStatCard("Marcações", "${appointments.length}", Icons.calendar_today)),
                const SizedBox(width: 15),
                Expanded(child: _buildStatCard("Avaliação", "4.9", Icons.star)),
              ],
            ),
            const SizedBox(height: 30),

            // Lista de Marcações (Agenda Real)
            Text("Agenda", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 15),

            // Mostra a lista real ou uma mensagem se estiver vazia
            appointments.isEmpty
                ? _buildEmptyState()
                : _buildAppointmentList(appointments),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Futuro: Adicionar bloqueio de horário
        backgroundColor: AppColors.gold,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildRevenueCard(double revenue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gold, AppColors.goldDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Faturação Total",
            style: GoogleFonts.lato(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          // Valor Dinâmico formatado
          Text(
            "${revenue.toStringAsFixed(2)}€",
            style: GoogleFonts.playfairDisplay(
              color: Colors.black,
              fontSize: 42,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack);
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.gold, size: 28),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.calendar_month_outlined, size: 60, color: Colors.grey[800]),
            const SizedBox(height: 10),
            const Text("Sem marcações ainda.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList(List<dynamic> appointments) {
    // Ordenar por data (mais recente primeiro)
    final sortedList = List.from(appointments);
    // Aqui podíamos ordenar: sortedList.sort(...)

    return Column(
      children: sortedList.map((appt) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gold.withOpacity(0.5)),
              ),
              child: Text(
                // Formata a hora ou usa a string direta
                appt.time,
                style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(appt.clientName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(
                "${appt.serviceName} • ${DateFormat('dd/MM').format(appt.date)}",
                style: const TextStyle(color: Colors.grey)
            ),
            trailing: Text(
              "${appt.price.toStringAsFixed(2)}€",
              style: const TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
      }).toList(),
    );
  }
}