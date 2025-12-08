import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../models/promotion_model.dart';

class PromotionManageScreen extends StatefulWidget {
  const PromotionManageScreen({super.key});

  @override
  State<PromotionManageScreen> createState() => _PromotionManageScreenState();
}

class _PromotionManageScreenState extends State<PromotionManageScreen> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  int _selectedColor = 0xFF9C27B0; // Roxo default

  final List<int> _colors = [0xFF9C27B0, 0xFF2196F3, 0xFFFF9800, 0xFF4CAF50, 0xFFE91E63];

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder( // StatefulBuilder para atualizar a cor dentro do Dialog
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
                const Align(alignment: Alignment.centerLeft, child: Text("Cor do Cartão", style: TextStyle(color: Colors.grey))),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _colors.map((c) => GestureDetector(
                    onTap: () => setDialogState(() => _selectedColor = c),
                    child: Container(
                      width: 40, height: 40, margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: Color(c), shape: BoxShape.circle,
                        border: _selectedColor == c ? Border.all(color: Colors.white, width: 3) : null,
                      ),
                    ),
                  )).toList(),
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty) {
                    final newPromo = Promotion(
                      id: DateTime.now().toString(),
                      title: _titleController.text,
                      subtitle: _subtitleController.text,
                      // CORREÇÃO: Usar 'color' em vez de 'colorHex' para coincidir com o modelo
                      color: _selectedColor,
                    );
                    Provider.of<AppProvider>(context, listen: false).addPromotion(newPromo);
                    _titleController.clear(); _subtitleController.clear();
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                child: const Text("PUBLICAR", style: TextStyle(color: Colors.black)),
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
    final promos = provider.promotions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Campanhas Ativas'),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: themeColor),
      ),
      body: promos.isEmpty 
          ? const Center(child: Text("Sem campanhas ativas.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: promos.length,
              itemBuilder: (context, index) {
                final p = promos[index];
                // CORREÇÃO: Usar 'p.color' aqui também
                final color = Color(p.color);
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color.withOpacity(0.8), color.withOpacity(0.4)]),
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
                            child: const Text("ATIVO", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 10),
                          Text(p.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(p.subtitle, style: const TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white),
                        onPressed: () => provider.removePromotion(p.id),
                      )
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        backgroundColor: themeColor,
        icon: const Icon(Icons.campaign, color: Colors.black),
        label: const Text("NOVA CAMPANHA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}