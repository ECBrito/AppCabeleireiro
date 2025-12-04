import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class BusinessHome extends StatelessWidget {
  const BusinessHome({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final biz = provider.activeBusiness!;
    final color = provider.getThemeColor();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        title: Text(biz.name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.black),
            onPressed: () => provider.unlink(), // Sai da loja
          )
        ],
      ),
      body: Column(
        children: [
          Image.network(biz.coverImage, height: 200, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(biz.icon, size: 60, color: color),
                const SizedBox(height: 20),
                Text("Bem-vindo à ${biz.name}!", style: const TextStyle(fontSize: 24, color: Colors.white)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.black),
                  child: const Text("MARCAR HORÁRIO"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}