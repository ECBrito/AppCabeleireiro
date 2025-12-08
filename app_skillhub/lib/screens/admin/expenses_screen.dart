import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/app_provider.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final List<Map<String, dynamic>> _expenses = [
    {"title": "Renda do Espaço", "amount": 800.0, "date": "01 Out"},
    {"title": "Produtos de Barba", "amount": 150.50, "date": "05 Out"},
    {"title": "Eletricidade", "amount": 120.0, "date": "10 Out"},
  ];

  void _addExpense() {
    // Aqui abririas um Dialog para adicionar despesa
    setState(() {
      _expenses.add({"title": "Nova Despesa", "amount": 50.0, "date": "Hoje"});
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<AppProvider>(context).getThemeColor();
    
    double totalExpenses = _expenses.fold(0, (sum, item) => sum + item['amount']);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Despesas'),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: themeColor),
      ),
      body: Column(
        children: [
          // Resumo
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Gasto (Mês)", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                Text("-${totalExpenses.toStringAsFixed(2)}€", style: const TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          // Lista
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final exp = _expenses[index];
                return Card(
                  color: AppColors.surface,
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.receipt_long, color: Colors.red),
                    ),
                    title: Text(exp['title'], style: const TextStyle(color: Colors.white)),
                    subtitle: Text(exp['date'], style: const TextStyle(color: Colors.grey)),
                    trailing: Text("-${exp['amount']}€", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}