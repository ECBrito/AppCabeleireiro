import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
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

  Future<void> _toggleBlock(Map<String, dynamic> customer, int shopId) async {
    final id = customer['id'];
    final isBlocked = customer['is_blocked'] == true;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          isBlocked ? "Desbloquear Cliente?" : "Bloquear Cliente?",
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          isBlocked
              ? "O cliente voltará a poder marcar serviços na barbearia."
              : "O cliente ficará impedido de criar novas marcações.",
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isBlocked ? Colors.green : Colors.redAccent,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              isBlocked ? "DESBLOQUEAR" : "BLOQUEAR",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/customers/$id/toggle-block'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'shopId': shopId,
          'phone': customer['phone'],
          'userId': customer['user_id'],
        }),
      );

      if (response.statusCode == 200) {
        _loadCustomers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isBlocked ? "Cliente desbloqueado." : "Cliente bloqueado com sucesso."),
              backgroundColor: isBlocked ? Colors.green : Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  // --- AÇÕES DE CONTACTO (CHAMADA / WHATSAPP) ---
  void _showContactOptions(Map<String, dynamic> customer) {
    final phone = (customer['phone'] ?? '').toString().replaceAll(' ', '').replaceAll('-', '');
    final name = customer['name'] ?? 'Cliente';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Contactar $name", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(phone.isEmpty ? "Sem número associado" : phone, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.call, color: Colors.white)),
              title: const Text("Fazer Chamada Telefónica", style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(ctx);
                final uri = Uri.parse('tel:$phone');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
            ),
            const SizedBox(height: 5),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.chat, color: Colors.white)),
              title: const Text("Enviar Mensagem WhatsApp", style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(ctx);
                final cleanPhone = phone.startsWith('+') ? phone : '+351$phone';
                final uri = Uri.parse('https://wa.me/$cleanPhone?text=Olá%20$name,%20falamos%20da%20barbearia.');
                if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- MODAL DE HISTÓRICO DE MARCAÇÕES ---
  Future<void> _showHistoryModal(Map<String, dynamic> customer, int shopId) async {
    final phone = customer['phone'] ?? '';
    final userId = customer['user_id'];
    final name = customer['name'] ?? 'Cliente';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Histórico de $name", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(color: Colors.white10),
              Expanded(
                child: FutureBuilder<http.Response>(
                  future: http.get(Uri.parse('$baseUrl/customers/history?shopId=$shopId&phone=$phone&userId=${userId ?? ''}')),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                    }
                    if (!snapshot.hasData || snapshot.data!.statusCode != 200) {
                      return const Center(child: Text("Sem registo de histórico.", style: TextStyle(color: Colors.grey)));
                    }

                    final List history = jsonDecode(snapshot.data!.body);
                    if (history.isEmpty) {
                      return const Center(child: Text("Nenhuma marcação encontrada.", style: TextStyle(color: Colors.grey)));
                    }

                    return ListView.separated(
                      controller: scrollController,
                      itemCount: history.length,
                      separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                      itemBuilder: (context, idx) {
                        final h = history[idx];
                        final status = (h['status'] ?? 'pending').toString().toUpperCase();
                        Color statusColor = Colors.grey;
                        if (status == 'COMPLETED') statusColor = Colors.blue;
                        if (status == 'CONFIRMED') statusColor = Colors.green;
                        if (status == 'CANCELLED') statusColor = Colors.redAccent;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text("${h['service_name'] ?? 'Serviço'} - ${h['price'] ?? 0}€", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text("Profissional: ${h['worker_name'] ?? 'Barbeiro'} • ${h['booking_date'] ?? ''} às ${h['booking_time'] ?? ''}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                            child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context, int shopId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Nova Ficha de Cliente", style: TextStyle(color: Colors.white)),
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
              final name = _nameController.text.trim();
              final phone = _phoneController.text.trim();
              if (name.isNotEmpty && phone.isNotEmpty) {
                await http.post(
                  Uri.parse('$baseUrl/customers'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'shop_id': shopId,
                    'name': name,
                    'phone': phone,
                    'email': _emailController.text.trim(),
                  }),
                );
                _clearControllers();
                _loadCustomers();
                if (ctx.mounted) Navigator.pop(ctx);
              }
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
        title: const Text('Gestão de Clientes'),
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
                hintText: "Pesquisar por nome ou telemóvel...",
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
                  return const Center(
                    child: Text("Nenhum cliente encontrado.", style: TextStyle(color: Colors.grey)),
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
                      final isBlocked = customer['is_blocked'] == true;

                      return Card(
                        color: AppColors.surface,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isBlocked ? Colors.redAccent.withOpacity(0.5) : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isBlocked ? Colors.redAccent.withOpacity(0.2) : themeColor.withOpacity(0.2),
                              child: Icon(
                                isBlocked ? Icons.block : Icons.person,
                                color: isBlocked ? Colors.redAccent : themeColor,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      color: isBlocked ? Colors.grey : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      decoration: isBlocked ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                                if (isBlocked)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                    child: const Text("BLOQUEADO", style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text("$phone • $visits visitas concluídas", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // BOTÃO CONTACTO (Ligar / WhatsApp)
                                IconButton(
                                  icon: const Icon(Icons.phone_outlined, color: Colors.greenAccent),
                                  tooltip: "Contactar",
                                  onPressed: () => _showContactOptions(customer),
                                ),

                                // MENU DE OPÇÕES (Histórico / Bloquear)
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                                  color: AppColors.surface,
                                  onSelected: (val) {
                                    if (val == 'history') {
                                      _showHistoryModal(customer, shopId);
                                    } else if (val == 'block') {
                                      _toggleBlock(customer, shopId);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'history',
                                      child: Row(
                                        children: [
                                          Icon(Icons.history, color: Colors.blueAccent, size: 18),
                                          SizedBox(width: 8),
                                          Text("Ver Histórico", style: TextStyle(color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'block',
                                      child: Row(
                                        children: [
                                          Icon(
                                            isBlocked ? Icons.lock_open : Icons.block,
                                            color: isBlocked ? Colors.green : Colors.redAccent,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            isBlocked ? "Desbloquear" : "Bloquear Cliente",
                                            style: TextStyle(color: isBlocked ? Colors.green : Colors.redAccent),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () => _showHistoryModal(customer, shopId),
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