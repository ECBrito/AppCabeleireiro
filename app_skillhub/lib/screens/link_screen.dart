import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../models/business_model.dart';

class LinkScreen extends StatefulWidget {
  const LinkScreen({super.key});
  @override
  State<LinkScreen> createState() => _LinkScreenState();
}

class _LinkScreenState extends State<LinkScreen> {
  final _controller = TextEditingController();
  bool _loading = false;

  void _entrar(String code) async {
    if (code.isEmpty) return;
    setState(() => _loading = true);
    
    // Tenta vincular à loja no Provider
    // Se funcionar, o AppProvider avisa o main.dart e o ecrã muda sozinho!
    final success = await Provider.of<AppProvider>(context, listen: false).linkBusiness(code);
    
    if (mounted) {
      setState(() => _loading = false);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Código inválido! Tente: barber"), backgroundColor: Colors.red)
        );
      }
      // NOTA: Não fazemos Navigator.push aqui. O Consumer no main.dart faz isso.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("SkillHub.", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)).animate().fadeIn(),
            const SizedBox(height: 10),
            const Text("Insira o código do estabelecimento", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "ex: barber",
                filled: true, fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: _loading
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(
                        icon: const Icon(Icons.arrow_forward, color: Colors.white),
                        onPressed: () => _entrar(_controller.text),
                      ),
              ),
              onSubmitted: _entrar,
            ),
            const SizedBox(height: 20),
            // Atalhos rápidos para testar
            Wrap(
              spacing: 10,
              children: mockBusinesses.map((b) => ActionChip(
                label: Text(b.code),
                backgroundColor: const Color(0xFF1E1E1E),
                labelStyle: const TextStyle(color: Colors.white),
                onPressed: () => _entrar(b.code),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}