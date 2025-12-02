import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../models/appointment_model.dart'; // Import do modelo

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  // Guardamos o objeto inteiro do serviço ou apenas nome/preço
  String? _selectedServiceName;
  double _selectedServicePrice = 0.0;

  final List<String> _timeSlots = [
    "09:00", "09:30", "10:00", "10:30", "11:00",
    "14:00", "14:30", "15:00", "15:30", "16:00", "17:30"
  ];

  final Map<String, double> _services = {
    "Corte Clássico": 15.00,
    "Barba Mestre": 10.00,
    "Combo King": 22.00,
    "Design Sobrancelha": 5.00
  };

  void _confirmBooking() {
    if (_selectedTime != null && _selectedServiceName != null) {
      final provider = Provider.of<AppProvider>(context, listen: false);

      // 1. Cria a marcação real
      final newAppointment = Appointment(
        id: DateTime.now().toString(),
        clientName: "Cliente Atual", // Em produção, viria do Login
        serviceName: _selectedServiceName!,
        price: _selectedServicePrice,
        date: _selectedDate,
        time: _selectedTime!,
        shopId: provider.currentShop?.id ?? '1',
      );

      // 2. Salva no Provider (Cérebro)
      provider.addAppointment(newAppointment);

      // 3. Mostra sucesso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Icon(Icons.check_circle, color: AppColors.gold, size: 50),
          content: const Text(
            "Marcação Confirmada!\nO barbeiro já recebeu o teu pedido.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Fecha dialog
                Navigator.pop(context); // Volta à loja
              },
              child: const Text("OK", style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleciona um serviço e um horário.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<AppProvider>(context).getThemeColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Visita'),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: themeColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Seleciona o Dia"),
            const SizedBox(height: 15),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: themeColor.withOpacity(0.3)),
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                onDateChanged: (date) => setState(() => _selectedDate = date),
              ),
            ),

            const SizedBox(height: 30),
            _buildSectionTitle("Seleciona o Serviço"),
            const SizedBox(height: 15),

            ..._services.entries.map((entry) => RadioListTile<String>(
              activeColor: themeColor,
              contentPadding: EdgeInsets.zero,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(color: Colors.white)),
                  Text("${entry.value.toStringAsFixed(2)}€", style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
                ],
              ),
              value: entry.key,
              groupValue: _selectedServiceName,
              onChanged: (value) => setState(() {
                _selectedServiceName = value;
                _selectedServicePrice = entry.value;
              }),
            )),

            const SizedBox(height: 30),
            _buildSectionTitle("Horário Disponível"),
            const SizedBox(height: 15),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _timeSlots.map((time) {
                final isSelected = _selectedTime == time;
                return ChoiceChip(
                  label: Text(
                    time,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: themeColor,
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? themeColor : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  onSelected: (selected) => setState(() => _selectedTime = selected ? time : null),
                );
              }).toList(),
            ),

            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text("CONFIRMAR AGENDAMENTO"),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}