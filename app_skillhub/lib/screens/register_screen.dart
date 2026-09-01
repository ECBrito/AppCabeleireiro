import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'client'; // 'client' ou 'owner'
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        role: _selectedRole,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Conta criada com sucesso!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // O Consumer no main.dart deteta a sessão e encaminha para o ecrã correto automaticamente.
    } catch (e) {
      if (!mounted) return;

      String errorMessage = "Erro ao criar conta.";
      if (e is Exception) {
        final cleanMsg = e.toString().replaceAll('Exception:', '').trim();
        if (cleanMsg.isNotEmpty) {
          errorMessage = cleanMsg;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Criar Conta',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Junta-te à comunidade SkillHub',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  const SizedBox(height: 30),

                  // SELETOR DE ROLE
                  Row(
                    children: [
                      Expanded(
                        child: _buildRoleCard(
                          title: 'Cliente',
                          icon: Icons.person_outline,
                          roleValue: 'client',
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildRoleCard(
                          title: 'Dono de Loja',
                          icon: Icons.storefront_outlined,
                          roleValue: 'owner',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // NOME COMPLETO
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nome Completo',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.person, color: AppColors.gold),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Insere o teu nome' : null,
                  ),
                  const SizedBox(height: 15),

                  // EMAIL
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.email, color: AppColors.gold),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Insere o e-mail';
                      if (!val.contains('@') || !val.contains('.')) return 'E-mail inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // PASSWORD
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Palavra-passe',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.lock, color: AppColors.gold),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (val) =>
                    val == null || val.length < 6 ? 'Mínimo 6 caracteres' : null,
                  ),
                  const SizedBox(height: 30),

                  // BOTÃO DE REGISTO
                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'CRIAR CONTA',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // LINK PARA LOGIN
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Já tens conta? ', style: TextStyle(color: Colors.grey[400])),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Iniciar Sessão',
                          style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required IconData icon,
    required String roleValue,
  }) {
    final isSelected = _selectedRole == roleValue;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = roleValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.gold : Colors.white10,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.gold : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.gold : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}