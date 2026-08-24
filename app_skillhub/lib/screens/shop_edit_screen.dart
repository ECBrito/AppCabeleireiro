import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../models/business_model.dart';

class ShopEditScreen extends StatefulWidget {
  const ShopEditScreen({super.key});

  @override
  State<ShopEditScreen> createState() => _ShopEditScreenState();
}

class _ShopEditScreenState extends State<ShopEditScreen> {
  static const String baseUrl = 'http://10.0.2.2:3000';

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _coverImageController;

  int _selectedColorHex = 0xFFFFD700;
  bool _isLoading = false;

  final List<int> _availableColors = [
    0xFFFFD700, // Gold
    0xFF00E676, // Green
    0xFF2979FF, // Blue
    0xFFFF1744, // Red
    0xFFFF9100, // Orange
    0xFFE040FB, // Purple
  ];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    final currentShop = provider.activeBusiness;

    _nameController = TextEditingController(text: currentShop?.name ?? '');
    _addressController = TextEditingController(text: currentShop?.address ?? '');
    _coverImageController = TextEditingController(text: currentShop?.coverImage ?? '');
    _selectedColorHex = currentShop?.colorHex ?? 0xFFFFD700;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _coverImageController.dispose();
    super.dispose();
  }

  Future<void> _saveShopData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = Provider.of<AppProvider>(context, listen: false);
    final shopId = int.tryParse(provider.activeBusiness?.id ?? '1') ?? 1;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/shops/$shopId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'address': _addressController.text.trim(),
          'cover_image': _coverImageController.text.trim(),
          'color_hex': _selectedColorHex,
        }),
      );

      if (response.statusCode == 200) {
        final updatedData = jsonDecode(response.body);

        // Atualiza o estado global no AppProvider
        final updatedShop = Business(
          id: updatedData['id'].toString(),
          name: updatedData['name'] ?? '',
          type: provider.activeBusiness?.type ?? BusinessType.values.first,
          code: updatedData['code'] ?? 'SHOP',
          colorHex: int.tryParse(updatedData['color_hex']?.toString() ?? '') ?? _selectedColorHex,
          address: updatedData['address'] ?? '',
          rating: double.tryParse(updatedData['rating']?.toString() ?? '5.0') ?? 5.0,
          coverImage: updatedData['cover_image'] ?? '',
        );
        provider.selectShop(updatedShop);

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Loja atualizada com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Erro ao atualizar os dados no servidor');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Color(_selectedColorHex);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Configurar Espaço"),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: themeColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Informações Gerais"),
              const SizedBox(height: 15),

              // NOME DA LOJA
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                validator: (val) => val == null || val.trim().isEmpty ? 'Insere o nome da loja' : null,
                decoration: InputDecoration(
                  labelText: "Nome da Barbearia / Salão",
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 15),

              // MORADA
              TextFormField(
                controller: _addressController,
                style: const TextStyle(color: Colors.white),
                validator: (val) => val == null || val.trim().isEmpty ? 'Insere a morada' : null,
                decoration: InputDecoration(
                  labelText: "Morada / Localização",
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 15),

              // URL DA IMAGEM DE CAPA
              TextFormField(
                controller: _coverImageController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "URL da Imagem de Capa",
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 30),
              _buildSectionTitle("Cor do Tema da Loja"),
              const SizedBox(height: 15),

              // PALETA DE CORES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _availableColors.map((colorVal) {
                  final isSelected = _selectedColorHex == colorVal;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorHex = colorVal),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Color(colorVal),
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                        boxShadow: isSelected
                            ? [BoxShadow(color: Color(colorVal).withOpacity(0.6), blurRadius: 10)]
                            : [],
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.black, size: 20) : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 50),

              // BOTÃO GUARDAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveShopData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                  )
                      : const Text("GUARDAR ALTERAÇÕES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}