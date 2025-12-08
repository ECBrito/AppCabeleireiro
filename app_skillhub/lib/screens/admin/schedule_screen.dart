import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/app_provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // Simulação de horário semanal
  final Map<String, bool> _openDays = {
    "Segunda": true, "Terça": true, "Quarta": true, 
    "Quinta": true, "Sexta": true, "Sábado": true, "Domingo": false
  };
  
  double _openTime = 9.0;
  double _closeTime = 19.0;

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
      body: SingleChildScrollView(
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
                    value: _openDays[day]!,
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
                  _buildSlider("Abertura", _openTime, 6, 12, (val) => setState(() => _openTime = val), themeColor),
                  const Divider(color: Colors.white10),
                  _buildSlider("Fecho", _closeTime, 13, 23, (val) => setState(() => _closeTime = val), themeColor),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Horários atualizados!")));
        },
        backgroundColor: themeColor,
        label: const Text("GUARDAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.save, color: Colors.black),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, Function(double) onChanged, Color color) {
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
        Text("${value.toInt()}:00", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
  }
}