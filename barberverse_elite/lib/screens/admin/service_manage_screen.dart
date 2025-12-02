import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../models/service_model.dart';

class ServiceManageScreen extends StatefulWidget {
  const ServiceManageScreen({super.key});

  @override
  State<ServiceManageScreen> createState() => _ServiceManageScreenState();
}

class _ServiceManageScreenState extends State<ServiceManageScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  void _showAddServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Novo Serviço", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Nome (ex: Corte Navalha)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Preço (€)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _durationController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Duração (minutos)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
                final newService = Service(
                  id: DateTime.now().toString(),
                  name: _nameController.text,
                  price: double.tryParse(_priceController.text) ?? 0.0,
                  durationMinutes: int.tryParse(_durationController.text) ?? 30,
                );
                Provider.of<AppProvider>(context, listen: false).addService(newService);
                _nameController.clear();
                _priceController.clear();
                _durationController.clear();
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            child: const Text("ADICIONAR", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final services = provider.services;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerir Serviços'),
        backgroundColor: AppColors.background,
      ),
      body: services.isEmpty
          ? const Center(child: Text("Sem serviços. Adiciona um!", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Card(
            color: AppColors.surface,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            child: ListTile(
              title: Text(service.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text("${service.durationMinutes} min", style: TextStyle(color: AppColors.gold.withOpacity(0.8))),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${service.price.toStringAsFixed(2)}€", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => provider.removeService(service.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddServiceDialog(context),
        backgroundColor: AppColors.gold,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("NOVO SERVIÇO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}