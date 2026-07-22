import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../models/appointment_model.dart';
import '../models/service_model.dart';
import '../models/worker_model.dart';
import '../services/service_db_service.dart';
import '../services/booking_db_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  String? _selectedServiceName;
  double _selectedServicePrice = 0.0;
  Worker? _selectedWorker;
  bool _isSubmitting = false;

  final ServiceDbService _serviceDb = ServiceDbService();
  final BookingDbService _bookingDb = BookingDbService();

  final List<String> _timeSlots = [
    "09:00", "09:30", "10:00", "10:30", "11:00",
    "14:00", "14:30", "15:00", "15:30", "16:00", "17:00", "17:30", "18:00"
  ];

  Future<void> _confirmBooking() async {
    if (_selectedTime == null || _selectedServiceName == null || _selectedWorker == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Por favor escolhe um Profissional, Serviço e Horário.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Nome do utilizador autenticado (ou fallback para o email/Cliente)
      final clientName = authProvider.userModel?.name.isNotEmpty == true
          ? authProvider.userModel!.name
          : (authProvider.currentUser?.email ?? "Cliente");

      final newAppointment = Appointment(
        id: '',
        clientName: clientName,
        serviceName: _selectedServiceName!,
        price: _selectedServicePrice,
        date: _selectedDate,
        time: _selectedTime!,
        shopId: appProvider.currentShop?.id ?? '1',
        workerId: _selectedWorker!.id,
        workerName: _selectedWorker!.name,
        colorHex: appProvider.activeBusiness?.colorHex ?? 0xFFFFD700,
        status: AppointmentStatus.pending,
      );

      // Guardar diretamente no Firestore
      await _bookingDb.createBooking(newAppointment);

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: Text(
            "Agendado com ${_selectedWorker!.name}!\nA tua vaga está reservada.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao agendar: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final biz = provider.activeBusiness;
    final color = provider.getThemeColor();
    final workers = provider.shopWorkers;

    if (biz == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Agendar ${biz.name}'),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: color),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. ESCOLHER PROFISSIONAL ---
            _buildSectionTitle("Com quem queres marcar?", color),
            const SizedBox(height: 15),

            SizedBox(
              height: 120,
              child: workers.isEmpty
                  ? const Center(child: Text("Nenhum profissional disponível.", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: workers.length,
                itemBuilder: (context, index) {
                  final worker = workers[index];
                  final isSelected = _selectedWorker?.id == worker.id;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedWorker = worker),
                    child: Container(
                      margin: const EdgeInsets.only(right: 20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? color : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)] : [],
                            ),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: AppColors.surface,
                              backgroundImage: NetworkImage(worker.photoUrl),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            worker.name.split(' ')[0],
                            style: TextStyle(
                              color: isSelected ? color : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 12, color: Colors.amber),
                              Text(" ${worker.rating}", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(color: Colors.white10, height: 40),

            // --- 2. ESCOLHER SERVIÇO (STREAM DO FIRESTORE) ---
            _buildSectionTitle("Qual o serviço?", color),
            const SizedBox(height: 10),

            StreamBuilder<List<ServiceModel>>(
              stream: _serviceDb.getServicesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: color));
                }

                final services = snapshot.data ?? [];

                if (services.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text("Sem serviços disponíveis de momento.", style: TextStyle(color: Colors.grey)),
                  );
                }

                return Column(
                  children: services.map((service) => RadioListTile<String>(
                    activeColor: color,
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(service.name, style: const TextStyle(color: Colors.white)),
                        Text("${service.price.toStringAsFixed(2)}€", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    subtitle: Text("${service.durationMinutes} min • ${service.description}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    value: service.name,
                    groupValue: _selectedServiceName,
                    onChanged: (value) => setState(() {
                      _selectedServiceName = value;
                      _selectedServicePrice = service.price;
                    }),
                  )).toList(),
                );
              },
            ),

            const SizedBox(height: 30),

            // --- 3. ESCOLHER DATA E HORA ---
            _buildSectionTitle("Quando?", color),
            const SizedBox(height: 15),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
                onDateChanged: (date) => setState(() => _selectedDate = date),
              ),
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _timeSlots.map((time) {
                final isSelected = _selectedTime == time;
                return ChoiceChip(
                  label: Text(time),
                  selected: isSelected,
                  selectedColor: color,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: isSelected ? color : Colors.grey.withOpacity(0.3)),
                  ),
                  onSelected: (val) => setState(() => _selectedTime = time),
                );
              }).toList(),
            ),

            const SizedBox(height: 50),

            // --- 4. TOTAL E BOTÃO ---
            if (_selectedServicePrice > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Estimado", style: TextStyle(color: Colors.white, fontSize: 18)),
                    Text(
                      "${_selectedServicePrice.toStringAsFixed(2)}€",
                      style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 10,
                  shadowColor: color.withOpacity(0.5),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("CONFIRMAR AGENDAMENTO", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 18, color: color, margin: const EdgeInsets.only(right: 10)),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}