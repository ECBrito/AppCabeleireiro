import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/appointment_model.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final allAppointments = provider.appointments;
    
    // Separar Futuro e Passado
    final now = DateTime.now();
    final upcoming = allAppointments.where((a) => a.date.isAfter(now.subtract(const Duration(days: 1))) && a.status != AppointmentStatus.cancelled).toList();
    final history = allAppointments.where((a) => a.date.isBefore(now.subtract(const Duration(days: 1))) || a.status == AppointmentStatus.completed || a.status == AppointmentStatus.cancelled).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: const Text("A Minha Agenda"),
          backgroundColor: const Color(0xFF121212),
          centerTitle: false,
          bottom: const TabBar(
            indicatorColor: Color(0xFFFFD700),
            labelColor: Color(0xFFFFD700),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "PRÓXIMOS"),
              Tab(text: "HISTÓRICO"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(upcoming, true),
            _buildList(history, false),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Appointment> list, bool isUpcoming) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isUpcoming ? Icons.calendar_today : Icons.history, size: 60, color: Colors.grey[800]),
            const SizedBox(height: 20),
            Text(
              isUpcoming ? "Sem marcações agendadas." : "Sem histórico.",
              style: const TextStyle(color: Colors.grey),
            ),
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
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0,4))
            ],
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(appt.serviceName, style: TextStyle(color: cardColor, fontWeight: FontWeight.bold, fontSize: 14)),
                    // ETIQUETA DE STATUS
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: appt.statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: appt.statusColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        appt.statusText.toUpperCase(),
                        style: TextStyle(color: appt.statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
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
                        Icon(Icons.calendar_month, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 5),
                        Text(
                          "${DateFormat('dd/MM').format(appt.date)} às ${appt.time}",
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Text(
                  "${appt.price}€",
                  style: TextStyle(color: cardColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              // Botão Cancelar (Só se for futuro e não cancelado)
              if (isUpcoming && appt.status == AppointmentStatus.pending)
                 Container(
                   width: double.infinity,
                   decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white10))),
                   child: TextButton(
                     onPressed: () {
                       // Aqui chamarias provider.cancelAppointment(appt.id)
                     },
                     child: const Text("CANCELAR", style: TextStyle(color: Colors.red)),
                   ),
                 )
            ],
          ),
        ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }
}