import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../config/theme.dart';
import '../../providers/app_provider.dart';

class ServiceManageScreen extends StatefulWidget {
  const ServiceManageScreen({super.key});

  @override
  State<ServiceManageScreen> createState() => _ServiceManageScreenState();
}

class _ServiceManageScreenState extends State<ServiceManageScreen> {
  static const String baseUrl = 'http://10.0.2.2:3000';
  late Future<List<dynamic>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  void _loadServices() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final shopId = int.tryParse(appProvider.activeBusiness?.id ?? '1') ?? 1;
    setState(() {
      _servicesFuture = _fetchServices(shopId);
    });
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

  Future<void> _saveService({
    int? id,
    required String name,
    required double price,
    required int duration,
    required String desc,
    required int shopId,
  }) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({
        'shop_id': shopId,
        'name': name,
        'price': price,
        'duration_minutes': duration,
        'description': desc,
      });

      if (id == null) {
        await http.post(Uri.parse('$baseUrl/services'), headers: headers, body: body);
      } else {
        await http.put(Uri.parse('$baseUrl/services/$id'), headers: headers, body: body);
      }
      _loadServices();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao gravar serviço: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _deleteService(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/services/$id'));
      if (response.statusCode == 200) {
        _loadServices();
      }
    } catch (_) {}
  }

  void _showServiceForm(int shopId, [Map<String, dynamic>? existingService]) {
    final nameController = TextEditingController(text: existingService?['name'] ?? '');
    final priceController = TextEditingController(text: existingService?['price']?.toString() ?? '');
    final durationController = TextEditingController(
      text: existingService?['duration_minutes']?.toString() ?? '30',
    );
    final descController = TextEditingController(text: existingService?['description'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existingService == null ? "Adicionar Novo Serviço" : "Editar Serviço",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Nome do Serviço",
                    filled: true,
                    fillColor: Colors.black26,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Preço (€)",
                          filled: true,
                          fillColor: Colors.black26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Duração (min)",
                          filled: true,
                          fillColor: Colors.black26,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Descrição (opcional)",
                    filled: true,
                    fillColor: Colors.black26,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final price = double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0.0;
                      final duration = int.tryParse(durationController.text) ?? 30;
                      final desc = descController.text.trim();

                      if (name.isEmpty) return;

                      await _saveService(
                        id: existingService?['id'],
                        name: name,
                        price: price,
                        duration: duration,
                        desc: desc,
                        shopId: shopId,
                      );

                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      existingService == null ? "GUARDAR" : "ATUALIZAR",
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final themeColor = appProvider.getThemeColor();
    final shopId = int.tryParse(appProvider.activeBusiness?.id ?? '1') ?? 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Gestão de Serviços"),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: themeColor),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _servicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: themeColor));
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Erro ao carregar serviços.", style: TextStyle(color: Colors.redAccent)),
            );
          }

          final services = snapshot.data ?? [];

          if (services.isEmpty) {
            return const Center(
              child: Text("Sem serviços registados.", style: TextStyle(color: Colors.grey)),
            );
          }

          return RefreshIndicator(
            color: themeColor,
            onRefresh: () async => _loadServices(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                final price = double.tryParse(service['price']?.toString() ?? '0.0') ?? 0.0;
                final duration = service['duration_minutes'] ?? 30;
                final desc = service['description'] ?? '';

                return Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      service['name'] ?? '',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "$duration min • $desc",
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${price.toStringAsFixed(2)}€",
                          style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          onPressed: () => _showServiceForm(shopId, service),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteService(service['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServiceForm(shopId),
        backgroundColor: themeColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}