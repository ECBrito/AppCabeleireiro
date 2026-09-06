import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../models/business_model.dart';
import 'shop_portfolio_screen.dart';

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
  late TextEditingController _phoneController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _coverImageController;
  late TextEditingController _openTimeController;
  late TextEditingController _closeTimeController;

  int _selectedColorHex = 0xFFFFD700;
  bool _isLoading = false;
  bool _isFetchingInitial = true;

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
    _phoneController = TextEditingController();
    _latController = TextEditingController();
    _lngController = TextEditingController();
    _coverImageController = TextEditingController(text: currentShop?.coverImage ?? '');
    _openTimeController = TextEditingController(text: '09:00');
    _closeTimeController = TextEditingController(text: '19:00');
    _selectedColorHex = currentShop?.colorHex ?? 0xFFFFD700;

    _loadFullShopDetails();
  }

  Future<void> _loadFullShopDetails() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final shopId = int.tryParse(provider.activeBusiness?.id ?? '1') ?? 1;

    try {
      final res = await http.get(Uri.parse('$baseUrl/shops/$shopId'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _phoneController.text = data['phone'] ?? '';
          _latController.text = data['latitude']?.toString() ?? '';
          _lngController.text = data['longitude']?.toString() ?? '';
        });
      }

      final schedRes = await http.get(Uri.parse('$baseUrl/shops/$shopId/schedule'));
      if (schedRes.statusCode == 200) {
        final schedData = jsonDecode(schedRes.body);
        setState(() {
          _openTimeController.text = schedData['open_time'] ?? '09:00';
          _closeTimeController.text = schedData['close_time'] ?? '19:00';
        });
      }
    } catch (_) {
    } finally {
      setState(() => _isFetchingInitial = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _coverImageController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
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
          'phone': _phoneController.text.trim(),
          'latitude': double.tryParse(_latController.text.trim()),
          'longitude': double.tryParse(_lngController.text.trim()),
          'cover_image': _coverImageController.text.trim(),
          'color_hex': _selectedColorHex,
        }),
      );

      await http.put(
        Uri.parse('$baseUrl/shops/$shopId/schedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'open_days': ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"],
          'open_time': _openTimeController.text.trim(),
          'close_time': _closeTimeController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final updatedData = jsonDecode(response.body);

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
            content: Text("Loja e horários atualizados com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Erro ao atualizar os dados');
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
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            tooltip: "Gerir Portfólio",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShopPortfolioScreen()),
              );
            },
          ),
        ],
      ),
      body: _isFetchingInitial
          ? Center(child: CircularProgressIndicator(color: themeColor))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ACESSO RÁPIDO AO PORTFÓLIO
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.collections, color: themeColor),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Galeria e Portfólio",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Adiciona ou remove fotos de trabalhos realizados",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ShopPortfolioScreen()),
                        );
                      },
                      child: const Text("GERIR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              _buildSectionTitle("Informações Gerais"),
              const SizedBox(height: 15),

              // NOME DA LOJA
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                validator: (val) => val == null || val.trim().isEmpty ? 'Insere o nome da loja' : null,
                decoration: _buildInputDecoration("Nome da Barbearia / Salão", Icons.store),
              ),
              const SizedBox(height: 15),

              // MORADA
              TextFormField(
                controller: _addressController,
                style: const TextStyle(color: Colors.white),
                validator: (val) => val == null || val.trim().isEmpty ? 'Insere a morada' : null,
                decoration: _buildInputDecoration("Morada Completa", Icons.location_on),
              ),
              const SizedBox(height: 15),

              // TELEFONE
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration("Telefone de Contacto (ex: +351960000000)", Icons.phone),
              ),
              const SizedBox(height: 15),

              // COORDENADAS GPS
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration("Latitude", Icons.map_outlined),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration("Longitude", Icons.map_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // URL DA IMAGEM DE CAPA
              TextFormField(
                controller: _coverImageController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration("URL da Imagem de Capa", Icons.image),
              ),

              const SizedBox(height: 30),
              _buildSectionTitle("Horário de Funcionamento"),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _openTimeController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration("Hora de Abertura", Icons.access_time),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _closeTimeController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration("Hora de Fecho", Icons.access_time_filled),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              _buildSectionTitle("Cor da Identidade Visual"),
              const SizedBox(height: 15),

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
                            ? [BoxShadow(color: Color(colorVal).withValues(alpha: 0.6), blurRadius: 10)]
                            : [],
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.black, size: 20) : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}