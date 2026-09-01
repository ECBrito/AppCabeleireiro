import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../config/theme.dart';
import '../../providers/app_provider.dart';

class PromotionManageScreen extends StatefulWidget {
  const PromotionManageScreen({super.key});

  @override
  State<PromotionManageScreen> createState() => _PromotionManageScreenState();
}

class _PromotionManageScreenState extends State<PromotionManageScreen> {
  static const String baseUrl = 'http://10.0.2.2:3000';

  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  int _selectedColor = 0xFF9C27B0;

  final List<int> _colors = [0xFF9C27B0, 0xFF2196F3, 0xFFFF9800, 0xFF4CAF50, 0xFFE91E63];
  late Future<List<dynamic>> _promotionsFuture;

  @override
  void initState() {
    super.initState();
    _loadPromotions();
  }

  void _loadPromotions() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final shopId = int.tryParse(appProvider.activeBusiness?.id ?? '1') ?? 1;
    setState(() {
      _promotionsFuture = _fetchPromotions(shopId);
    });
  }

  Future<List<dynamic>> _fetchPromotions(int shopId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/promotions?shopId=$shopId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  Future<void> _addPromotion(int shopId) async {
    if (_titleController.text.trim().isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/promotions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'shop_id': shopId,
          'title': _titleController.text.trim(),
          'subtitle': _subtitleController.text.trim(),
          'color_hex': _selectedColor,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _titleController.clear();
        _subtitleController.clear();
        _loadPromotions();
      }
    } catch (_) {}
  }

  Future<void> _deletePromotion(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/promotions/$id'));
      if (response.statusCode == 200) {
        _loadPromotions();
      }
    } catch (_) {}
  }

  void _showAddDialog(BuildContext context, int shopId) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text("Nova Campanha", style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInput(_titleController, "Título (ex: Black Friday)"),
                const SizedBox(height: 10),
                _buildInput(_subtitleController, "Desconto (ex: 50% OFF)"),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Cor do Cartão", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _colors.map((c) => GestureDetector(
                    onTap: () => setDialogState(() => _selectedColor = c),
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: _selectedColor == c ? Border.all(color: Colors.white, width: 3) : null,
                      ),
                    ),
                  )).toList(),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _addPromotion(shopId);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                child: const Text("PUBLICAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final themeColor = provider.getThemeColor();
    final shopId = int.tryParse(provider.activeBusiness?.id ?? '1') ?? 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Campanhas Ativas'),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: themeColor),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _promotionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: themeColor));
          }

          final promos = snapshot.data ?? [];

          if (promos.isEmpty) {
            return const Center(
              child: Text("Sem campanhas ativas de momento.", style: TextStyle(color: Colors.grey)),
            );
          }

          return RefreshIndicator(
            color: themeColor,
            onRefresh: () async => _loadPromotions(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: promos.length,
              itemBuilder: (context, index) {
                final p = promos[index];
                final color = Color(int.tryParse(p['color_hex']?.toString() ?? '') ?? 0xFF9C27B0);

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.4)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                            child: const Text(
                              "ATIVO",
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            p['title'] ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            p['subtitle'] ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white),
                        onPressed: () => _deletePromotion(p['id']),
                      )
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, shopId),
        backgroundColor: themeColor,
        icon: const Icon(Icons.campaign, color: Colors.black),
        label: const Text("NOVA CAMPANHA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}