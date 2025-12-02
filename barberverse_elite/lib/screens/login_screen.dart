import 'package:flutter/material.dart';
import '../config/theme.dart'; // Importa o nosso tema

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
    await Future.delayed(const Duration(seconds: 2));

    final email = _emailController.text.trim();

    // Lógica de Login Simulada (será substituída por Firebase depois)
    if (email.contains('admin') || email.contains('barber')) {
      // Se for barbeiro/admin, vai para o Dashboard
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      }
    } else {
      // Se for cliente, vai para a Home (Lista de Lojas)
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/client_home');
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usa o tema definido no main.dart
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ícone ou Logo (podes substituir por uma imagem depois)
              const Icon(Icons.content_cut, size: 80, color: AppColors.gold),
              const SizedBox(height: 20),

              // Título
              Text(
                'BarberVerse Elite',
                textAlign: TextAlign.center,
                style: textTheme.displayLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'Agende o seu estilo.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 50),

              // Campo de Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Campo de Password
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 40),

              // Botão de Entrar
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                )
                    : const Text('ENTRAR'),
              ),
              const SizedBox(height: 20),

              // Link para criar conta (apenas visual por enquanto)
              TextButton(
                onPressed: () {},
                child: Text(
                  'Ainda não tem conta? Registe-se',
                  style: TextStyle(color: AppColors.gold.withOpacity(0.8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}