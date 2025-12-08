import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/app_provider.dart';
import '../../../models/customer_model.dart';

class CustomerManageScreen extends StatefulWidget {
  const CustomerManageScreen({super.key});

  @override
  State<CustomerManageScreen> createState() => _CustomerManageScreenState();
}

class _CustomerManageScreenState extends State<CustomerManageScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = "";

  void _showAddCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Novo Cliente", style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInput(_nameController, "Nome", Icons.person),
              const SizedBox(height: 10),
              _buildInput(_phoneController, "Telemóvel", Icons.phone, type: TextInputType.phone),
              const SizedBox(height: 10),
              _buildInput(_emailController, "Email (Opcional)", Icons.email, type: TextInputType.emailAddress),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearControllers();
              Navigator.pop(ctx);
            },
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                final newCustomer = Customer(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text,
                  phone: _phoneController.text,
                  email: _emailController.text,
                  totalVisits: 0,
                );
                
                Provider.of<AppProvider>(context, listen: false).addCustomer(newCustomer);
                _clearControllers();
                Navigator.pop(ctx);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cliente adicionado com sucesso!")),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            child: const Text("GUARDAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.gold),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }

  void _clearControllers() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final themeColor = provider.getThemeColor();
    
    // Filtrar clientes pela pesquisa
    final allCustomers = provider.customers;
    final filteredCustomers = allCustomers.where((c) {
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             c.phone.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meus Clientes'),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: themeColor),
      ),
      body: Column(
        children: [
          // Barra de Pesquisa
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Pesquisar por nome ou telefone...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          
          // Lista
          Expanded(
            child: filteredCustomers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off, size: 60, color: Colors.grey[800]),
                        const SizedBox(height: 15),
                        const Text("Nenhum cliente encontrado.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = filteredCustomers[index];
                      return Card(
                        color: AppColors.surface,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: themeColor.withOpacity(0.2),
                            child: Text(
                              customer.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(customer.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            "${customer.phone} • ${customer.totalVisits} visitas", 
                            style: const TextStyle(color: Colors.grey, fontSize: 12)
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => provider.removeCustomer(customer.id),
                          ),
                          onTap: () {
                            // Futuro: Abrir detalhes do cliente / histórico
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerDialog(context),
        backgroundColor: themeColor,
        child: const Icon(Icons.person_add, color: Colors.black),
      ),
    );
  }
}