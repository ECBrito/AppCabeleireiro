import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  static const String baseUrl = 'http://10.0.2.2:3000';

  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  String? _selectedServiceName;
  double _selectedServicePrice = 0.0;
  Map<String, dynamic>? _selectedWorker;
  bool _isSubmitting = false;

  final List<String> _timeSlots = [
    "09:00", "09:30", "10:00", "10:30", "11:00",
    "14:00", "14:30", "15:00", "15:30", "16:00", "17:00", "17:30", "18:00"
  ];

  Future<List<dynamic>> _fetchWorkers(int shopId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/workers?shopId=$shopId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  Future<List<dynamic>> _fetchServices(int shopId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/services?shopId=$shopId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  Future<void> _confirmBooking(int shopId) async {
    if (_selectedTime == null || _selectedServiceName == null || _selectedWorker == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor escolhe um Profissional, Serviço e Horário.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final clientName = authProvider.userModel?.name.isNotEmpty == true
          ? authProvider.userModel!.name
          : (authProvider.currentUser?.email ?? "Cliente");

      final formattedDate = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'client_id': authProvider.userModel?.id,
          'client_name': clientName,
          'shop_id': shopId,
          'worker_id': _selectedWorker!['id'],
          'worker_name': _selectedWorker!['name'],
          'service_name': _selectedServiceName,
          'price': _selectedServicePrice,
          'booking_date': formattedDate,
          'booking_time': _selectedTime,
          'status': 'pending',
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erro ao criar agendamento');
      }

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: Text(
            "Agendado com ${_selectedWorker!['name']}!\nA tua vaga está reservada.",
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
          behavior: SnackBarBehavior.floating,
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

    if (biz == null) return const SizedBox();
    final shopId = int.tryParse(biz.id) ?? 1;

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
            _buildSectionTitle("Com quem queres marcar?", color),
            const SizedBox(height: 15),

            FutureBuilder<List<dynamic>>(
              future: _fetchWorkers(shopId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: color));
                }

                final workers = snapshot.data ?? [];

                if (workers.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "Nenhum profissional disponível de momento.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: workers.length,
                    itemBuilder: (context, index) {
                      final worker = workers[index];
                      final isSelected = _selectedWorker?['id'] == worker['id'];
                      final rating = double.tryParse(worker['rating']?.toString() ?? '5.0') ?? 5.0;

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
                                  boxShadow: isSelected
                                      ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)]
                                      : [],
                                ),
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundColor: AppColors.surface,
                                  backgroundImage: NetworkImage(
                                    worker['photo_url'] ?? 'https://randomuser.me/api/portraits/men/32.jpg',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                (worker['name'] ?? 'Profissional').toString().split(' ')[0],
                                style: TextStyle(
                                  color: isSelected ? color : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 12, color: Colors.amber),
                                  Text(" $rating", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const Divider(color: Colors.white10, height: 40),

            _buildSectionTitle("Qual o serviço?", color),
            const SizedBox(height: 10),

            FutureBuilder<List<dynamic>>(
              future: _fetchServices(shopId),
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
                  children: services.map((service) {
                    final name = service['name'] ?? '';
                    final price = double.tryParse(service['price']?.toString() ?? '0.0') ?? 0.0;
                    final duration = service['duration_minutes'] ?? 30;
                    final description = service['description'] ?? '';

                    return RadioListTile<String>(
                      activeColor: color,
                      contentPadding: EdgeInsets.zero,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(name, style: const TextStyle(color: Colors.white)),
                          Text("${price.toStringAsFixed(2)}€", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      subtitle: Text("$duration min • $description", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      value: name,
                      groupValue: _selectedServiceName,
                      onChanged: (value) => setState(() {
                        _selectedServiceName = value;
                        _selectedServicePrice = price;
                      }),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 30),

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
                    fontWeight: FontWeight.bold,
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
                onPressed: _isSubmitting ? null : () => _confirmBooking(shopId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 10,
                  shadowColor: color.withOpacity(0.5),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                )
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