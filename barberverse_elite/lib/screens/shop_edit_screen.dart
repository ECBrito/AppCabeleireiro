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

  // Cor selecionada atualmente
  int _selectedColor = 0xFFFFD700;

  // Paleta de cores disponíveis para o tema
  final List<int> _availableColors = [
    0xFFFFD700, // Dourado (Barber King)
    0xFF00BFFF, // Azul Neon (Urban Cuts)
    0xFFCF6679, // Vermelho (Retro)
    0xFF00FF7F, // Verde Cyber
    0xFF9D4EDD, // Roxo Real
  ];

  @override
  void initState() {
    super.initState();
    // 1. Carregar os dados atuais da loja para editar
    final provider = Provider.of<AppProvider>(context, listen: false);
    final currentShop = provider.currentShop;

    _nameController = TextEditingController(text: currentShop?.name ?? "Nova Barbearia");
    _addressController = TextEditingController(text: currentShop?.address ?? "Rua Principal");
    _imageController = TextEditingController(text: currentShop?.image ?? "");

    if (currentShop != null) {
      _selectedColor = currentShop.colorHex;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final currentShop = provider.currentShop;

      // 2. Criar o objeto loja atualizado
      final updatedShop = BarberShop(
        id: currentShop?.id ?? '1', // Mantém o ID
        name: _nameController.text,
        address: _addressController.text,
        rating: currentShop?.rating ?? 5.0,
        image: _imageController.text.isNotEmpty
            ? _imageController.text
            : 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?q=80&w=800',
        colorHex: _selectedColor, // A nova cor escolhida
      );

      // 3. Atualizar no Provider (Muda a cor da app imediatamente!)
      provider.updateShop(updatedShop);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loja atualizada com sucesso!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Loja'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Informações", style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 15),

              _buildTextField("Nome do Estabelecimento", _nameController, Icons.store),
              const SizedBox(height: 20),
              _buildTextField("Morada", _addressController, Icons.location_on),
              const SizedBox(height: 20),
              _buildTextField("URL da Imagem", _imageController, Icons.image),

              const SizedBox(height: 40),
              const Text("Tema da Aplicação", style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 15),

              // Seletor de Cores Horizontal
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableColors.length,
                  itemBuilder: (context, index) {
                    final colorInt = _availableColors[index];
                    final isSelected = _selectedColor == colorInt;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = colorInt),
                      child: Container(
                        margin: const EdgeInsets.only(right: 15),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(colorInt),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Color(colorInt).withOpacity(0.6),
                              blurRadius: 8,
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

              const SizedBox(height: 50),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(_selectedColor), // Botão na cor escolhida
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("GUARDAR ALTERAÇÕES"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
    );
  }
}