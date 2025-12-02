import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../models/appointment_model.dart';
import '../models/worker_model.dart'; // Import do modelo de trabalhador

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

  // NOVO: Variável para guardar o profissional selecionado
  Worker? _selectedWorker;

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
    // Validação reforçada: Agora exige Worker também
    if (_selectedTime != null && _selectedServiceName != null && _selectedWorker != null) {
      final provider = Provider.of<AppProvider>(context, listen: false);

      final newAppointment = Appointment(
        id: DateTime.now().toString(),
        clientName: "Cliente Atual",
        serviceName: _selectedServiceName!,
        price: _selectedServicePrice,
        date: _selectedDate,
        time: _selectedTime!,
        shopId: provider.currentShop?.id ?? '1',
        // NOVOS CAMPOS: Guardamos quem vai fazer o serviço
        workerId: _selectedWorker!.id,
        workerName: _selectedWorker!.name,
      );

      provider.addAppointment(newAppointment);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Icon(Icons.check_circle, color: AppColors.gold, size: 50),
          content: Text(
            "Marcação Confirmada com ${_selectedWorker!.name}!\nO teu lugar está reservado.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text("OK", style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor escolhe um Profissional, Serviço e Horário.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final themeColor = provider.getThemeColor();

    // Obtém a lista de trabalhadores desta loja específica
    final workers = provider.shopWorkers;

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
            // 1. SECÇÃO DE PROFISSIONAIS (NOVO)
            _buildSectionTitle("Escolha um Profissional"),
            const SizedBox(height: 15),

            SizedBox(
              height: 110, // Altura para Avatar + Nome
              child: workers.isEmpty
                  ? const Center(child: Text("Sem profissionais disponíveis.", style: TextStyle(color: Colors.grey)))
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
                            padding: const EdgeInsets.all(3), // Espaço para a borda
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? themeColor : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.surface,
                              backgroundImage: NetworkImage(worker.photoUrl),
                              onBackgroundImageError: (_, __) {}, // Ignora erros de imagem
                              child: worker.photoUrl.isEmpty
                                  ? const Icon(Icons.person, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            worker.name.split(' ')[0], // Mostra só o primeiro nome
                            style: TextStyle(
                              color: isSelected ? themeColor : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "⭐ ${worker.rating}",
                            style: TextStyle(color: Colors.grey[600], fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(color: Colors.white10, height: 40),

            // 2. SECÇÃO DE SERVIÇOS
            _buildSectionTitle("Seleciona o Serviço"),
            const SizedBox(height: 10),

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

            const SizedBox(height: 20),

            // 3. SECÇÃO DE DATA E HORA
            _buildSectionTitle("Selecionar Data e Hora"),
            const SizedBox(height: 15),

            // Calendário
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

            const SizedBox(height: 20),
            const Text("Manhã", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            _buildTimeGrid(_timeSlots.sublist(0, 5), themeColor),

            const SizedBox(height: 15),
            const Text("Tarde", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            _buildTimeGrid(_timeSlots.sublist(5), themeColor),

            const SizedBox(height: 40),

            // RESUMO DO PREÇO
            if (_selectedServicePrice > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Preço Total", style: TextStyle(color: Colors.white, fontSize: 18)),
                    Text("${_selectedServicePrice.toStringAsFixed(2)}€", style: TextStyle(color: themeColor, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

            // BOTÃO CONFIRMAR
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

  Widget _buildTimeGrid(List<String> times, Color themeColor) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: times.map((time) {
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}