import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onSuccess; // O que fazer depois de entrar?

  const AuthScreen({super.key, required this.onSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _loading = false;

  void _submit() async {
    setState(() => _loading = true);
    
    // Chama o login
    await Provider.of<AuthProvider>(context, listen: false)
        .login(_emailController.text, _passController.text);
    
    if (mounted) {
      setState(() => _loading = false);
      Navigator.pop(context); // Fecha o ecrã de login
      widget.onSuccess(); // Executa a ação (ex: ir para o Admin ou Booking)
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pega a cor da loja atual para o tema do login ficar igual à loja
    final provider = Provider.of<AppProvider>(context);
    final themeColor = provider.getThemeColor();
    final shopName = provider.activeBusiness?.name ?? "Loja";

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.account_circle, size: 60, color: themeColor),
            const SizedBox(height: 20),
            Text(
              "Bem-vindo à\n$shopName", 
              style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)
            ),
            const SizedBox(height: 10),
            const Text("Faça login para continuar.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),

            // Inputs
            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: const TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.email, color: themeColor),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: const TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.lock, color: themeColor),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),
            
            // Botão Entrar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading 
                  ? const CircularProgressIndicator(color: Colors.black) 
                  : const Text("ENTRAR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            
            const SizedBox(height: 20),
            const Center(child: Text("Dica: 'admin' para dono, 'cliente' para cliente.", style: TextStyle(color: Colors.grey, fontSize: 12))),
          ],
        ),
      ),
    );
  }
}