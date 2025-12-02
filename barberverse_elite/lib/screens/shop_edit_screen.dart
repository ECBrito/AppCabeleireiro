import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../models/shop_model.dart';

class ShopEditScreen extends StatefulWidget {
  const ShopEditScreen({super.key});

  @override
  State<ShopEditScreen> createState() => _ShopEditScreenState();
}

class _ShopEditScreenState extends State<ShopEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _imageController;
  int _selectedColor = 0xFFFFD700; // Dourado por defeito

  // Cores disponíveis para o tema "Camaleão"
  final List<int> _availableColors = [
    0xFFFFD700, // Dourado
    0xFF00BFFF, // Azul Neon
    0xFFCF6679, // Vermelho
    0xFF00FF7F, // Verde Primavera
    0xFF9D4EDD, // Roxo
  ];

  @override
  void initState() {
    super.initState();
    // Carregar dados atuais (Simulado: usaria o currentShop do provider)
    // Como exemplo, iniciamos com valores dummy
    _nameController = TextEditingController(text: "A Minha Barbearia");
    _addressController = TextEditingController(text: "Rua Exemplo, 123");
    _imageController = TextEditingController(text: "https://...");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _saveShop() {
    if (_formKey.currentState!.validate()) {
      // Aqui atualizaríamos o Provider
      // final newShop = BarberShop(..., colorHex: _selectedColor);
      // Provider.of<AppProvider>(context, listen: false).updateShop(newShop);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alterações guardadas com sucesso!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração da Loja'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Informações Básicas", style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 15),

              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nome do Estabelecimento',
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (value) => value!.isEmpty ? 'O nome é obrigatório' : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _addressController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Morada Completa',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _imageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'URL da Imagem de Capa',
                  prefixIcon: Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 30),

              const Text("Tema da App (Camaleão)", style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 15),

              // Seletor de Cores
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableColors.length,
                  itemBuilder: (context, index) {
                    final color = Color(_availableColors[index]);
                    final isSelected = _selectedColor == _availableColors[index];

                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = _availableColors[index]),
                      child: Container(
                        margin: const EdgeInsets.only(right: 15),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.black)
                            : null,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveShop,
                  child: const Text("GUARDAR ALTERAÇÕES"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}