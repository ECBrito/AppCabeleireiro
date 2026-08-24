import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../config/theme.dart';
import '../../../providers/app_provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  static const String baseUrl = 'http://10.0.2.2:3000';

  Map<String, bool> _openDays = {
    "Segunda": true,
    "Terça": true,
    "Quarta": true,
    "Quinta": true,
    "Sexta": true,
    "Sábado": true,
    "Domingo": false,
  };

  double _openTime = 9.0;
  double _closeTime = 19.0;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final shopId = int.tryParse(appProvider.activeBusiness?.id.toString() ?? '1') ?? 1;

    try {
      final response = await http.get(Uri.parse('$baseUrl/shops/$shopId/schedule'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['open_days'] != null) {
          final Map<String, dynamic> rawDays = data['open_days'] is String
              ? jsonDecode(data['open_days'])
              : Map<String, dynamic>.from(data['open_days']);

          _openDays = rawDays.map((k, v) => MapEntry(k, v == true));
        }

        if (data['open_time'] != null) {
          _openTime = double.tryParse(data['open_time'].toString()) ?? 9.0;
        }

        if (data['close_time'] != null) {
          _closeTime = double.tryParse(data['close_time'].toString()) ?? 19.0;
        }
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveSchedule() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final shopId = int.tryParse(appProvider.activeBusiness?.id.toString() ?? '1') ?? 1;

    setState(() => _isSaving = true);

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/shops/$shopId/schedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'open_days': _openDays,
          'open_time': _openTime,
          'close_time': _closeTime,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Horários atualizados na base de dados!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Falha ao guardar horários');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final themeColor = provider.getThemeColor();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Horários de Funcionamento'),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: themeColor),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: themeColor))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Dias de Abertura"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: _openDays.keys.map((day) {
                  return SwitchListTile(
                    title: Text(day, style: const TextStyle(color: Colors.white)),
                    value: _openDays[day] ?? false,
                    activeColor: themeColor,
                    onChanged: (val) => setState(() => _openDays[day] = val),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),
            _buildSectionTitle("Horário Geral"),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSlider(
                    "Abertura",
                    _openTime,
                    6,
                    12,
                        (val) => setState(() => _openTime = val),
                    themeColor,
                  ),
                  const Divider(color: Colors.white10),
                  _buildSlider(
                    "Fecho",
                    _closeTime,
                    13,
                    23,
                        (val) => setState(() => _closeTime = val),
                    themeColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _saveSchedule,
        backgroundColor: themeColor,
        label: _isSaving
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
        )
            : const Text(
          "GUARDAR",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        icon: _isSaving ? null : const Icon(Icons.save, color: Colors.black),
      ),
    );
  }

  Widget _buildSlider(
      String label,
      double value,
      double min,
      double max,
      Function(double) onChanged,
      Color color,
      ) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt() * 2,
            activeColor: color,
            label: "${value.toInt()}:00",
            onChanged: onChanged,
          ),
        ),
        Text(
          "${value.toInt()}:00",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}