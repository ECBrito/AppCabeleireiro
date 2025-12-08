import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    setState(() => _isLoading = true);
    
    // Chama o Provider para fazer login
    await Provider.of<AuthProvider>(context, listen: false)
        .login(_emailController.text, _passController.text);
    
    if (mounted) {
      setState(() => _isLoading = false);
      final auth = Provider.of<AuthProvider>(context, listen: false);

      // Redirecionamento Inteligente
      if (auth.isLoggedIn) {
        if (auth.isOwner) {
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        } else {
          // Se for cliente, vai para a lista de lojas (MainShell/LinkScreen)
          Navigator.pushReplacementNamed(context, '/client_home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login falhou. Tenta 'admin' ou 'cliente'"), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                  boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.2), blurRadius: 30)],
                ),
                child: const Icon(Icons.content_cut, size: 50, color: AppColors.gold),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              
              const SizedBox(height: 30),
              
              Text(
                "Bem-vindo de volta.",
                style: GoogleFonts.playfairDisplay(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
              ).animate().fadeIn().slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 10),
              const Text("Gere o teu negócio ou marca o teu estilo.", style: TextStyle(color: Colors.grey)),
              
              const SizedBox(height: 50),

              // INPUTS
              _buildTextField("Email", Icons.email_outlined, _emailController),
              const SizedBox(height: 20),
              _buildTextField("Password", Icons.lock_outlined, _passController, isObscure: true),
              
              const SizedBox(height: 40),

              // BOTÃO ENTRAR
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 10,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.black) 
                    : const Text("ENTRAR NA CONTA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 30),
              
              // LINK PARA REGISTO (Vai para o ecrã de venda)
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/register'),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(text: "Não tens conta? "),
                      TextSpan(text: "Cria o teu negócio aqui.", style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isObscure = false}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: AppColors.gold),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gold)),
      ),
    );
  }
}