import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../config/theme.dart';
import '../../../providers/app_provider.dart';

class CustomerManageScreen extends StatefulWidget {
  const CustomerManageScreen({super.key});

  @override
  State<CustomerManageScreen> createState() => _CustomerManageScreenState();
}

class _CustomerManageScreenState extends State<CustomerManageScreen> {
  static const String baseUrl = 'http://10.0.2.2:3000';

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _searchController = TextEditingController();

  String _searchQuery = "";
  late Future<List<dynamic>> _customersFuture;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  void _loadCustomers() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final shopId = int.tryParse(appProvider.activeBusiness?.id ?? '1') ?? 1;
    setState(() {
      _customersFuture = _fetchCustomers(shopId);
    });
  }

  Future<List<dynamic>> _fetchCustomers(int shopId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/customers?shopId=$shopId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  Future<void> _addCustomer(int shopId) async {
    if (_nameController.text.trim().isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'shop_id': shopId,
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _clearControllers();
        _loadCustomers();
      }
    } catch (_) {}
  }

  Future<void> _deleteCustomer(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/customers/$id'));
      if (response.statusCode == 200) {
        _loadCustomers();
      }
    } catch (_) {}
  }

  void _showAddCustomerDialog(BuildContext context, int shopId) {
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
            onPressed: () async {
              await _addCustomer(shopId);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            child: const Text("GUARDAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType type = TextInputType.text,
      }) {
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
    final shopId = int.tryParse(provider.activeBusiness?.id ?? '1') ?? 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meus Clientes'),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: themeColor),
      ),
      body: Column(
        children: [
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
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _customersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: themeColor));
                }

                final allCustomers = snapshot.data ?? [];
                final filteredCustomers = allCustomers.where((c) {
                  final name = (c['name'] ?? '').toString().toLowerCase();
                  final phone = (c['phone'] ?? '').toString();
                  return name.contains(_searchQuery.toLowerCase()) || phone.contains(_searchQuery);
                }).toList();

                if (filteredCustomers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off, size: 60, color: Colors.grey[800]),
                        const SizedBox(height: 15),
                        const Text("Nenhum cliente encontrado.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: themeColor,
                  onRefresh: () async => _loadCustomers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = filteredCustomers[index];
                      final name = customer['name'] ?? 'Cliente';
                      final phone = customer['phone'] ?? '';
                      final visits = customer['total_visits'] ?? 0;
                      final id = customer['id'];

                      return Card(
                        color: AppColors.surface,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: themeColor.withOpacity(0.2),
                            child: Text(
                              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'C',
                              style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            "$phone • $visits visitas",
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _deleteCustomer(id),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerDialog(context, shopId),
        backgroundColor: themeColor,
        child: const Icon(Icons.person_add, color: Colors.black),
      ),
    );
  }
}