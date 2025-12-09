import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/appointment_model.dart';
import '../config/theme.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final allAppointments = provider.appointments;
    
    // Separar Futuro e Passado
    final now = DateTime.now();
    final upcoming = allAppointments.where((a) => a.date.isAfter(now.subtract(const Duration(hours: 1)))).toList();
    final history = allAppointments.where((a) => a.date.isBefore(now.subtract(const Duration(hours: 1)))).toList();

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
        body: TabBarView(
          children: [
            _buildList(context, upcoming, true),
            _buildList(context, history, false),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Appointment> list, bool isUpcoming) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isUpcoming ? Icons.calendar_today : Icons.history, size: 60, color: Colors.grey[800]),
            const SizedBox(height: 20),
            Text(isUpcoming ? "Sem marcações agendadas." : "Sem histórico.", style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final appt = list[index];
        final cardColor = Color(appt.colorHex);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: cardColor, width: 4)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0,4))],
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(appt.serviceName, style: TextStyle(color: cardColor, fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text(appt.serviceName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 5),
                    Text("com ${appt.workerName}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 5),
                        Text("${DateFormat('dd/MM').format(appt.date)} • ${appt.time}", style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  ],
                ),
                trailing: Text("${appt.price}€", style: TextStyle(color: cardColor, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              
              // BOTÃO DE AVALIAR (Apenas no Histórico)
              if (!isUpcoming)
                 Container(
                   width: double.infinity,
                   decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
                   child: TextButton.icon(
                     onPressed: () => _showReviewDialog(context, appt),
                     icon: const Icon(Icons.star, color: AppColors.gold, size: 18),
                     label: const Text("AVALIAR EXPERIÊNCIA", style: TextStyle(color: AppColors.gold)),
                   ),
                 )
            ],
          ),
        ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  void _showReviewDialog(BuildContext context, Appointment appt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Avaliar Serviço", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Como foi o teu corte?", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => const Icon(Icons.star, color: AppColors.gold, size: 30)),
            ),
            const SizedBox(height: 20),
            const TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Escreve um comentário...",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true, fillColor: Colors.black26,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Obrigado pela avaliação! ⭐")));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            child: const Text("ENVIAR", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}