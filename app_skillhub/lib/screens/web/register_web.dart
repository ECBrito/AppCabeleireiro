import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';

class RegisterWeb extends StatefulWidget {
  const RegisterWeb({super.key});

  @override
  State<RegisterWeb> createState() => _RegisterWebState();
}

class _RegisterWebState extends State<RegisterWeb> {
  bool _isLoading = false;

  void _register() async {
    setState(() => _isLoading = true);
    
    // 1. Simula tempo de processamento (API + Pagamento Stripe)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      // 2. Vai para o Wizard de Configuração da Loja
      Navigator.pushReplacementNamed(context, '/setup_wizard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // LADO ESQUERDO (Marketing)
          Expanded(
            flex: 4,
            child: Container(
              color: const Color(0xFF121212),
              padding: const EdgeInsets.all(60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("SkillHub.", style: GoogleFonts.playfairDisplay(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Text("Estás a 2 minutos\nda tua App.", style: GoogleFonts.playfairDisplay(fontSize: 50, color: AppColors.gold, height: 1.1)),
                  const SizedBox(height: 20),
                  const Text("Junta-te a +500 profissionais que automatizaram o seu negócio.", style: TextStyle(color: Colors.grey, fontSize: 18)),
                  const Spacer(),
                  // Testemunho
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      children: [
                        CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("⭐️⭐️⭐️⭐️⭐️"),
                            Text("Mudou a minha barbearia.", style: TextStyle(color: Colors.white)),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // LADO DIREITO (Formulário)
          Expanded(
            flex: 6,
            child: Center(
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Criar Conta Profissional", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Text("Teste gratuito de 14 dias. Cancela quando quiseres.", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 40),

                    _buildInput("Nome Completo", Icons.person),
                    const SizedBox(height: 20),
                    _buildInput("Email", Icons.email),
                    const SizedBox(height: 20),
                    _buildInput("Password", Icons.lock, isPass: true),
                    
                    const SizedBox(height: 40),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.black,
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text("CRIAR CONTA", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, IconData icon, {bool isPass = false}) {
    return TextField(
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true, fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}