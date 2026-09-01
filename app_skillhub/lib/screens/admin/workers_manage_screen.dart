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
    required int? userId,
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
          'user_id': userId,
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
    final searchController = TextEditingController();
    final roleController = TextEditingController();
    final bioController = TextEditingController();

    Map<String, dynamic>? selectedUser;
    List<dynamic> searchResults = [];
    bool isSearching = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> searchUsers(String query) async {
            if (query.trim().length < 2) {
              setDialogState(() {
                searchResults = [];
                isSearching = false;
              });
              return;
            }

            setDialogState(() => isSearching = true);
            try {
              final response = await http.get(
                Uri.parse('$baseUrl/users/search?query=${Uri.encodeComponent(query)}&shopId=$shopId'),
              );
              if (response.statusCode == 200) {
                setDialogState(() {
                  searchResults = jsonDecode(response.body);
                  isSearching = false;
                });
              }
            } catch (_) {
              setDialogState(() => isSearching = false);
            }
          }

          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text("Adicionar Membro à Equipa", style: TextStyle(color: Colors.white)),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Procura a conta registada do profissional:",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 10),

                    // CAMPO DE PESQUISA DE UTILIZADOR
                    TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Nome ou Email da conta",
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: isSearching
                            ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                        )
                            : (selectedUser != null
                            ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            setDialogState(() {
                              selectedUser = null;
                              searchController.clear();
                              searchResults = [];
                            });
                          },
                        )
                            : null),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      onChanged: (val) {
                        if (selectedUser == null) {
                          searchUsers(val);
                        }
                      },
                    ),

                    // LISTA DE RESULTADOS DE PESQUISA
                    if (selectedUser == null && searchResults.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        constraints: const BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: searchResults.length,
                          separatorBuilder: (_, _) => const Divider(color: Colors.white10, height: 1),
                          itemBuilder: (context, index) {
                            final user = searchResults[index];
                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: themeColor.withValues(alpha: 0.2),
                                child: Text(
                                  (user['name'] ?? 'U')[0].toUpperCase(),
                                  style: TextStyle(color: themeColor, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                user['name'] ?? '',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                user['email'] ?? '',
                                style: const TextStyle(color: Colors.grey, fontSize: 11),
                              ),
                              onTap: () {
                                setDialogState(() {
                                  selectedUser = user;
                                  searchController.text = user['name'] ?? '';
                                  searchResults = [];
                                });
                              },
                            );
                          },
                        ),
                      ),

                    // CONTA SELECIONADA (CONFIRMAÇÃO VISUAL)
                    if (selectedUser != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Conta: ${selectedUser!['name']} (${selectedUser!['email']})",
                                style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 15),

                    // CARGO
                    TextField(
                      controller: roleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Cargo (ex: Barbeiro Principal, Esteticista)",
                        labelStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.black26,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // BIO / ESPECIALIDADE
                    TextField(
                      controller: bioController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Especialidade / Bio",
                        labelStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.black26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                onPressed: selectedUser == null
                    ? null
                    : () async {
                  await _addWorker(
                    shopId: shopId,
                    userId: selectedUser!['id'],
                    name: selectedUser!['name'],
                    role: roleController.text.trim(),
                    bio: bioController.text.trim(),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text(
                  "ADICIONAR",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
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
                final bio = worker['bio'] ?? '';
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
                      bio.isNotEmpty ? "$role • $bio" : "$role • ⭐ $rating",
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
        child: const Icon(Icons.person_add, color: Colors.black),
      ),
    );
  }
}