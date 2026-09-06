import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
  Map<String, dynamic>? _selectedWorker;
  Map<String, dynamic>? _selectedService;

  List<dynamic> _workers = [];
  List<dynamic> _services = [];
  List<String> _occupiedSlots = [];
  bool _isLoadingSlots = false;

  final List<String> _allTimeSlots = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '14:00', '14:30', '15:00', '15:30', '16:00', '16:30',
    '17:00', '17:30', '18:00', '18:30', '19:00'
  ];

  String get _formattedDate =>
      "${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final app = Provider.of<AppProvider>(context, listen: false);
    final shopId = int.tryParse(app.activeBusiness?.id ?? '1') ?? 1;

    try {
      final workersRes = await http.get(Uri.parse('$baseUrl/workers?shopId=$shopId'));
      final servicesRes = await http.get(Uri.parse('$baseUrl/services?shopId=$shopId'));

      if (workersRes.statusCode == 200 && servicesRes.statusCode == 200) {
        setState(() {
          _workers = jsonDecode(workersRes.body);
          _services = jsonDecode(servicesRes.body);
          if (_workers.isNotEmpty) {
            _selectedWorker = _workers.first;
          }
          if (_services.isNotEmpty) {
            _selectedService = _services.first;
          }
        });
        _fetchOccupiedSlots();
      }
    } catch (_) {}
  }

  Future<void> _fetchOccupiedSlots() async {
    final app = Provider.of<AppProvider>(context, listen: false);
    final shopId = int.tryParse(app.activeBusiness?.id ?? '1') ?? 1;
    final workerId = _selectedWorker?['id'];

    setState(() => _isLoadingSlots = true);

    try {
      String url = '$baseUrl/bookings/occupied-slots?shopId=$shopId&date=$_formattedDate';
      if (workerId != null) {
        url += '&workerId=$workerId';
      }

      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          _occupiedSlots = data.map((e) => e.toString()).toList();
          // Se a hora que o cliente tinha selecionada já estiver ocupada, desseleciona-a
          if (_selectedTime != null && _occupiedSlots.contains(_selectedTime)) {
            _selectedTime = null;
          }
        });
      }
    } catch (_) {
    } finally {
      setState(() => _isLoadingSlots = false);
    }
  }

  Future<void> _confirmBooking() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final app = Provider.of<AppProvider>(context, listen: false);

    if (_selectedWorker == null || _selectedService == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Seleciona o profissional, o serviço e um horário disponível."),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    final body = {
      'client_id': auth.userModel?.id,
      'client_name': auth.userModel?.name ?? 'Cliente',
      'client_phone': auth.userModel?.phone ?? '',
      'shop_id': int.tryParse(app.activeBusiness?.id ?? '1') ?? 1,
      'worker_id': _selectedWorker!['id'],
      'worker_name': _selectedWorker!['name'],
      'service_name': _selectedService!['name'],
      'price': double.tryParse(_selectedService!['price'].toString()) ?? 0.0,
      'booking_date': _formattedDate,
      'booking_time': _selectedTime,
      'status': 'pending',
    };

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (res.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Marcação realizada com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (res.statusCode == 409) {
        final err = jsonDecode(res.body);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err['message'] ?? "Horário indisponível."),
            backgroundColor: Colors.redAccent,
          ),
        );
        _fetchOccupiedSlots();
      } else {
        throw Exception();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao concluir marcação."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context);
    final themeColor = app.getThemeColor();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Marcar Atendimento"),
        backgroundColor: const Color(0xFF121212),
        iconTheme: IconThemeData(color: themeColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ESCOLHER DATA
            const Text(
              "1. Seleciona o Dia",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 14,
                itemBuilder: (context, idx) {
                  final date = DateTime.now().add(Duration(days: idx));
                  final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedDate = date);
                      _fetchOccupiedSlots();
                    },
                    child: Container(
                      width: 55,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? themeColor : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? Colors.transparent : Colors.white12),
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
                          const SizedBox(height: 4),
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

            const SizedBox(height: 25),

            // 2. ESCOLHER PROFISSIONAL
            const Text(
              "2. Profissional",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _workers.length,
                itemBuilder: (context, idx) {
                  final worker = _workers[idx];
                  final isSelected = _selectedWorker?['id'] == worker['id'];

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedWorker = worker);
                      _fetchOccupiedSlots();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? themeColor : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundImage: NetworkImage(
                                worker['photo_url'] ?? 'https://randomuser.me/api/portraits/men/32.jpg',
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (worker['name'] ?? '').toString().split(' ').first,
                            style: TextStyle(
                              color: isSelected ? themeColor : Colors.white70,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // 3. ESCOLHER SERVIÇO
            const Text(
              "3. Serviço",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            ..._services.map((svc) {
              final isSelected = _selectedService?['id'] == svc['id'];
              final price = double.tryParse(svc['price'].toString()) ?? 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? themeColor : Colors.white12),
                ),
                child: ListTile(
                  dense: true,
                  onTap: () => setState(() => _selectedService = svc),
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? themeColor : Colors.grey,
                  ),
                  title: Text(svc['name'] ?? '', style: const TextStyle(color: Colors.white)),
                  trailing: Text(
                    "${price.toStringAsFixed(2)}€",
                    style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),

            const SizedBox(height: 25),

            // 4. HORÁRIOS (COM ESTILO DESATIVADO / DISABLED)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "4. Horário",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (_isLoadingSlots)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _allTimeSlots.map((time) {
                final isOccupied = _occupiedSlots.contains(time);
                final isSelected = _selectedTime == time;

                return InkWell(
                  onTap: isOccupied
                      ? null // Totalmente desativado ao toque
                      : () {
                    setState(() {
                      _selectedTime = isSelected ? null : time;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isOccupied
                          ? Colors.white.withValues(alpha: 0.04) // Fundo opaco / desativado
                          : (isSelected ? themeColor : const Color(0xFF1E1E1E)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isOccupied
                            ? Colors.transparent
                            : (isSelected ? themeColor : Colors.white12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isOccupied) ...[
                          Icon(Icons.lock_outline, size: 12, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          time,
                          style: TextStyle(
                            color: isOccupied
                                ? Colors.grey[700] // Texto escurecido
                                : (isSelected ? Colors.black : Colors.white),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            decoration: isOccupied ? TextDecoration.lineThrough : null, // Efeito riscado
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 40),

            // BOTÃO CONFIRMAR
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _selectedTime == null ? null : _confirmBooking,
                child: const Text(
                  "CONFIRMAR MARCAÇÃO",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}