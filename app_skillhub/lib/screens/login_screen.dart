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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      await auth.login(
        _emailController.text.trim(),
        _passController.text,
      );

      if (!mounted) return;

      if (auth.isLoggedIn) {
        if (auth.isOwner) {
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/client_home');
        }
      }
    } catch (error) {
      if (!mounted) return;

      String errorMessage = "Email ou palavra-passe incorretos.";
      final errStr = error.toString().toLowerCase();

      // Mapeamento detalhado de erros do Firebase Auth
      if (errStr.contains('configuration_not_found')) {
        errorMessage = "Autenticação por Email não ativada no Firebase Console!";
      } else if (errStr.contains('user-not-found') || errStr.contains('invalid-credential')) {
        errorMessage = "Email ou palavra-passe incorretos.";
      } else if (errStr.contains('wrong-password')) {
        errorMessage = "Palavra-passe incorreta.";
      } else if (errStr.contains('invalid-email')) {
        errorMessage = "O formato do email é inválido.";
      } else if (errStr.contains('network-request-failed')) {
        errorMessage = "Sem ligação à internet.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.2),
                        blurRadius: 30,
                      )
                    ],
                  ),
                  child: const Icon(Icons.content_cut, size: 50, color: AppColors.gold),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                const SizedBox(height: 30),

                Text(
                  "Bem-vindo de volta.",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn().slideY(begin: 0.3, end: 0),

                const SizedBox(height: 10),
                const Text(
                  "Gere o teu negócio ou marca o teu estilo.",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 50),

                // INPUT EMAIL
                _buildEmailField(),
                const SizedBox(height: 20),

                // INPUT PASSWORD
                _buildPasswordField(),

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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 10,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Text(
                      "ENTRAR NA CONTA",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // LINK PARA REGISTO
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/register'),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(text: "Não tens conta? "),
                        TextSpan(
                          text: "Cria a tua conta aqui.",
                          style: TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Por favor insere o teu email.";
        }
        if (!value.contains('@') || !value.contains('.')) {
          return "Insere um email válido.";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Email",
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.gold),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passController,
      obscureText: _isObscure,
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Por favor insere a tua palavra-passe.";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.gold),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () => setState(() => _isObscure = !_isObscure),
        ),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
      ),
    );
  }
}