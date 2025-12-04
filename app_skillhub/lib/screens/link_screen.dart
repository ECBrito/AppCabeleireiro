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
    setState(() => _loading = true);
    final success = await Provider.of<AppProvider>(context, listen: false).linkBusiness(code);
    setState(() => _loading = false);
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Loja não encontrada! Tente: barber, ink, ou spa")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("SkillHub", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            const Text("A tua app universal.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 50),
            
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Código da Loja",
                hintText: "ex: barber",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: () => _entrar(_controller.text),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            const Text("Experimenta estes códigos:", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: mockBusinesses.map((b) => ActionChip(
                label: Text(b.code),
                avatar: Icon(b.icon, size: 16, color: Color(b.colorHex)),
                backgroundColor: const Color(0xFF1E1E1E),
                labelStyle: const TextStyle(color: Colors.white),
                onPressed: () => _entrar(b.code),
              )).toList(),
            ),
            if (_loading) const Padding(padding: EdgeInsets.only(top:20), child: CircularProgressIndicator())
          ],
        ).animate().fadeIn().slideY(begin: 0.1, end: 0),
      ),
    );
  }
}