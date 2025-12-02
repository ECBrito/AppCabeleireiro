import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);

    // Simulação de atraso de rede
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

    final email = _emailController.text.trim();

    if (mounted) {
      if (email.contains('admin')) {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else if (email.contains('worker')) {
        Navigator.pushReplacementNamed(context, '/worker_dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/client_home');
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, AppColors.background],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // LOGO ANIMADO
                const Icon(Icons.content_cut, size: 80, color: AppColors.gold)
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .then()
                    .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.5)),

                const SizedBox(height: 20),

                Text(
                  'BarberVerse Elite',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                    letterSpacing: 1.5,
                  ),
                ).animate().fadeIn().slideY(begin: 0.3, end: 0),

                const SizedBox(height: 10),
                Text(
                  'O teu estilo, a tua escolha.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(color: Colors.grey, fontSize: 16),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 50),

                // CAMPOS DE INPUT
                _buildTextField("Email", _emailController, Icons.email_outlined),
                const SizedBox(height: 20),
                _buildTextField("Password", _passwordController, Icons.lock_outlined, isPassword: true),

                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Esqueceste-te da password?", style: TextStyle(color: Colors.grey)),
                  ),
                ),

                const SizedBox(height: 30),

                // BOTÃO ENTRAR
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    shadowColor: AppColors.gold.withOpacity(0.5),
                    elevation: 10,
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black))
                      : const Text('ENTRAR'),
                ).animate().scale(delay: 400.ms),

                const SizedBox(height: 40),

                // LOGIN SOCIAL
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text("OU ENTRAR COM", style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(Icons.g_mobiledata, "Google"), // Google Icon simulado
                    _buildSocialButton(Icons.apple, "Apple"),
                    _buildSocialButton(Icons.facebook, "Facebook"),
                  ],
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 30),

                Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.grey),
                      children: [
                        const TextSpan(text: "Novo por aqui? "),
                        TextSpan(
                          text: "Cria uma conta",
                          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                          // recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX();
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}