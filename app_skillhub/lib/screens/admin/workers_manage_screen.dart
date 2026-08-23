import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../models/worker_model.dart';
import '../../services/worker_db_service.dart';

class WorkersManageScreen extends StatefulWidget {
  const WorkersManageScreen({super.key});

  @override
  State<WorkersManageScreen> createState() => _WorkersManageScreenState();
}

class _WorkersManageScreenState extends State<WorkersManageScreen> {
  final WorkerDbService _workerDb = WorkerDbService();

  void _showAddWorkerDialog(Color themeColor, int shopId) {
    final nameController = TextEditingController();
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
              controller: bioController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Especialidade / Bio (ex: Especialista em Barba)",
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
              if (nameController.text.trim().isNotEmpty) {
                final newWorker = Worker(
                  id: 0,
                  name: nameController.text.trim(),
                  photoUrl: 'https://randomuser.me/api/portraits/men/${(10 + DateTime.now().second % 80)}.jpg',
                  rating: 5.0,
                  shopId: shopId,
                  bio: bioController.text.trim(),
                );
                await _workerDb.addWorker(newWorker);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  setState(() {});
                }
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
      body: StreamBuilder<List<Worker>>(
        stream: _workerDb.getWorkersStream(shopId: shopId),
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

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              return Card(
                color: AppColors.surface,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(worker.photoUrl),
                  ),
                  title: Text(worker.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    worker.bio.isNotEmpty ? worker.bio : "⭐ ${worker.rating}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () async {
                      await _workerDb.deleteWorker(worker.id);
                      setState(() {});
                    },
                  ),
                ),
              );
            },
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