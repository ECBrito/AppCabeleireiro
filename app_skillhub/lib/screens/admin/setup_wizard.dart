import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../models/business_model.dart';

class SetupWizardScreen extends StatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  int _selectedColor = 0xFFFFD700;
  bool _isLoading = false;
  
  final List<int> _colors = [0xFFFFD700, 0xFF00BFFF, 0xFFE91E63, 0xFF00FF7F, 0xFF9D4EDD];

  void _finishSetup() async {
    if (_codeController.text.isEmpty || _nameController.text.isEmpty) return;

    setState(() => _isLoading = true);
    final provider = Provider.of<AppProvider>(context, listen: false);

    // 1. Verifica se o código está livre
    final isAvailable = await provider.checkCodeAvailability(_codeController.text);

    if (!isAvailable) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Este código já existe! Escolhe outro."), backgroundColor: Colors.red));
      return;
    }

    // 2. Cria o objeto do novo negócio
    final newShop = Business(
      id: DateTime.now().toString(),
      code: _codeController.text.toLowerCase().replaceAll(' ', '-'),
      name: _nameController.text,
      address: "Configurar morada...",
      rating: 5.0,
      coverImage: "https://images.unsplash.com/photo-1503951914875-452162b7f30a?q=80&w=800",
      colorHex: _selectedColor,
      type: BusinessType.barber, // Default
    );

    // 3. Guarda no Provider e entra na loja
    await provider.createBusiness(newShop);

    if (mounted) {
      // 4. Vai para o Dashboard de Admin da NOVA loja
      Navigator.pushNamedAndRemoveUntil(context, '/admin_dashboard', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.rocket_launch, size: 60, color: AppColors.gold),
              const SizedBox(height: 20),
              const Text("Vamos configurar a tua App", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              // Nome da Loja
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Nome da Barbearia", prefixIcon: Icon(Icons.store, color: AppColors.gold)),
              ),
              const SizedBox(height: 20),

              // Código Único
              TextField(
                controller: _codeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Código Único (ex: joao-cuts)",
                  helperText: "Os clientes vão usar este código para entrar.",
                  prefixIcon: Icon(Icons.tag, color: AppColors.gold),
                ),
              ),
              const SizedBox(height: 30),
              
              const Align(alignment: Alignment.centerLeft, child: Text("Cor da Marca", style: TextStyle(color: Colors.white))),
              const SizedBox(height: 15),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _colors.map((c) => GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: Container(
                    width: 50, height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: _selectedColor == c ? Border.all(color: Colors.white, width: 3) : null,
                    ),
                    child: _selectedColor == c ? const Icon(Icons.check, color: Colors.black) : null,
                  ),
                )).toList(),
              ),

              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _finishSetup,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.black) : const Text("LANÇAR A MINHA APP"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}