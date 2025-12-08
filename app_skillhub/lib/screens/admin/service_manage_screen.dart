import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../models/service_model.dart';

class ServiceManageScreen extends StatefulWidget {
  const ServiceManageScreen({super.key});

  @override
  State<ServiceManageScreen> createState() => _ServiceManageScreenState();
}

class _ServiceManageScreenState extends State<ServiceManageScreen> {
  // Controladores para o formulário
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

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
              decoration: const InputDecoration(
                labelText: "Nome (ex: Corte Navalha)",
                prefixIcon: Icon(Icons.cut, color: AppColors.gold),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              style: const TextStyle(color: Colors.white),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Preço (€)",
                prefixIcon: Icon(Icons.euro, color: AppColors.gold),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _durationController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Duração (minutos)",
                prefixIcon: Icon(Icons.timer, color: AppColors.gold),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearControllers();
              Navigator.pop(ctx);
            },
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
                final newService = Service(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text,
                  price: double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0,
                  durationMinutes: int.tryParse(_durationController.text) ?? 30,
                );
                
                // Adiciona ao Provider
                Provider.of<AppProvider>(context, listen: false).addService(newService);
                
                _clearControllers();
                Navigator.pop(ctx);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Serviço adicionado com sucesso!")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.black,
            ),
            child: const Text("ADICIONAR", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _clearControllers() {
    _nameController.clear();
    _priceController.clear();
    _durationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final services = provider.services;
    final themeColor = provider.getThemeColor();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gerir Serviços'),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: themeColor),
      ),
      body: services.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt, size: 60, color: Colors.grey[800]),
                  const SizedBox(height: 15),
                  const Text("Sem serviços. Adiciona um!", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
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
                    side: BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.content_cut, color: themeColor),
                    ),
                    title: Text(
                      service.name, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                    subtitle: Text(
                      "${service.durationMinutes} min", 
                      style: TextStyle(color: themeColor.withOpacity(0.7)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${service.price.toStringAsFixed(2)}€", 
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            provider.removeService(service.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Serviço removido.")),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddServiceDialog(context),
        backgroundColor: themeColor,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("NOVO SERVIÇO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}