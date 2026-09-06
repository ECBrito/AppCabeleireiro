import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../config/theme.dart';
import '../providers/app_provider.dart';

class ShopPortfolioScreen extends StatefulWidget {
  const ShopPortfolioScreen({super.key});

  @override
  State<ShopPortfolioScreen> createState() => _ShopPortfolioScreenState();
}

class _ShopPortfolioScreenState extends State<ShopPortfolioScreen> {
  static const String baseUrl = 'http://10.0.2.2:3000';
  late Future<List<dynamic>> _portfolioFuture;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  void _loadPortfolio() {
    final app = Provider.of<AppProvider>(context, listen: false);
    final shopId = int.tryParse(app.activeBusiness?.id ?? '1') ?? 1;
    setState(() {
      _portfolioFuture = _fetchPortfolio(shopId);
    });
  }

  Future<List<dynamic>> _fetchPortfolio(int shopId) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/shops/$shopId/portfolio'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}
    return [];
  }

  Future<void> _addImage(String url) async {
    final app = Provider.of<AppProvider>(context, listen: false);
    final shopId = int.tryParse(app.activeBusiness?.id ?? '1') ?? 1;

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/shops/$shopId/portfolio'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image_url': url}),
      );

      if (res.statusCode == 201) {
        _loadPortfolio();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Foto adicionada com sucesso!"), backgroundColor: Colors.green),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _deleteImage(int imageId) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/shops/portfolio/$imageId'));
      if (res.statusCode == 200) {
        _loadPortfolio();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Foto removida."), backgroundColor: Colors.orangeAccent),
          );
        }
      }
    } catch (_) {}
  }

  void _showAddImageDialog(Color themeColor) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Adicionar Foto ao Portfólio", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "URL da Imagem",
            labelStyle: TextStyle(color: Colors.grey),
            hintText: "https://...",
            hintStyle: TextStyle(color: Colors.white24),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: themeColor, foregroundColor: Colors.black),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                _addImage(text);
                Navigator.pop(ctx);
              }
            },
            child: const Text("ADICIONAR", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context);
    final themeColor = app.getThemeColor();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Portfólio da Barbearia"),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: themeColor),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _portfolioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: themeColor));
          }

          final images = snapshot.data ?? [];

          if (images.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined, size: 60, color: Colors.grey[800]),
                  const SizedBox(height: 15),
                  const Text("Ainda não adicionaste fotos ao portfólio.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.9,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final item = images[index];
              final imageId = item['id'];
              final imageUrl = item['image_url'];

              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey[900],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => _deleteImage(imageId),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: themeColor,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text("ADICIONAR FOTO", style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showAddImageDialog(themeColor),
      ),
    );
  }
}