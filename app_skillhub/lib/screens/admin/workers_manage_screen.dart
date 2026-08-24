import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../config/theme.dart';
import '../../providers/app_provider.dart';

class WorkersManageScreen extends StatefulWidget {
  const WorkersManageScreen({super.key});

  @override
  State<WorkersManageScreen> createState() => _WorkersManageScreenState();
}

class _WorkersManageScreenState extends State<WorkersManageScreen> {
  static const String baseUrl = 'http://10.0.2.2:3000';
  late Future<List<dynamic>> _workersFuture;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  void _loadWorkers() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final shopId = int.tryParse(appProvider.activeBusiness?.id.toString() ?? '1') ?? 1;
    setState(() {
      _workersFuture = _fetchWorkers(shopId);
    });
  }

  Future<List<dynamic>> _fetchWorkers(int shopId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/workers?shopId=$shopId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  Future<void> _addWorker({
    required int shopId,
    required String name,
    required String role,
    required String bio,
  }) async {
    try {
      final randomImgId = 10 + (DateTime.now().second % 80);
      final response = await http.post(
        Uri.parse('$baseUrl/workers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'shop_id': shopId,
          'name': name,
          'role': role.isNotEmpty ? role : 'Profissional',
          'bio': bio,
          'photo_url': 'https://randomuser.me/api/portraits/men/$randomImgId.jpg',
          'rating': 5.0,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _loadWorkers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao adicionar profissional: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _deleteWorker(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/workers/$id'));
      if (response.statusCode == 200) {
        _loadWorkers();
      }
    } catch (_) {}
  }

  void _showAddWorkerDialog(Color themeColor, int shopId) {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final bioController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Adicionar Profissional", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Nome",
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: roleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Cargo (ex: Barbeiro, Colorista)",
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bioController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Bio / Especialidade",
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: themeColor),
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                await _addWorker(
                  shopId: shopId,
                  name: name,
                  role: roleController.text.trim(),
                  bio: bioController.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text("GUARDAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final themeColor = appProvider.getThemeColor();
    final int shopId = int.tryParse(appProvider.activeBusiness?.id.toString() ?? '1') ?? 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Equipa de Profissionais"),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: themeColor),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _workersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: themeColor));
          }

          final workers = snapshot.data ?? [];

          if (workers.isEmpty) {
            return const Center(
              child: Text("Nenhum profissional registado na equipa.", style: TextStyle(color: Colors.grey)),
            );
          }

          return RefreshIndicator(
            color: themeColor,
            onRefresh: () async => _loadWorkers(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: workers.length,
              itemBuilder: (context, index) {
                final worker = workers[index];
                final id = worker['id'];
                final name = worker['name'] ?? 'Profissional';
                final role = worker['role'] ?? 'Colaborador';
                final photoUrl = worker['photo_url'] ?? 'https://randomuser.me/api/portraits/men/32.jpg';
                final rating = worker['rating'] ?? 5.0;

                return Card(
                  color: AppColors.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(photoUrl),
                    ),
                    title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      "$role • ⭐ $rating",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _deleteWorker(id),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeColor,
        onPressed: () => _showAddWorkerDialog(themeColor, shopId),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}