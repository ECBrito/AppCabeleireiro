import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String baseUrl = 'http://10.0.2.2:3000';

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    _nameController = TextEditingController(text: auth.userModel?.name ?? "");
    _emailController = TextEditingController(text: auth.userModel?.email ?? "");
    _phoneController = TextEditingController(text: auth.userModel?.phone ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userModel?.id;

    if (userId == null) return;

    setState(() => _isSaving = true);

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['user'] != null) {
          auth.setUserFromMap(data['user']);
        }

        if (mounted) {
          setState(() => _isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Perfil atualizado com sucesso!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        throw Exception("Erro ao guardar dados.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao atualizar perfil: $e"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);

    final currentShop = appProvider.activeBusiness;
    final themeColor = appProvider.getThemeColor();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('O Meu Perfil'),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: themeColor),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : Icon(_isEditing ? Icons.check : Icons.edit, color: themeColor),
            onPressed: _isSaving
                ? null
                : () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: themeColor, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
                  ),
                ),
                if (_isEditing)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: themeColor, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                  ),
              ],
            ),

            const SizedBox(height: 40),

            _buildProfileField("Nome Completo", _nameController, Icons.person, themeColor, isEditable: _isEditing),
            const SizedBox(height: 20),
            _buildProfileField("Email", _emailController, Icons.email, themeColor, isEditable: false),
            const SizedBox(height: 20),
            _buildProfileField("Telemóvel", _phoneController, Icons.phone, themeColor, isEditable: _isEditing),

            const SizedBox(height: 40),

            if (currentShop != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: themeColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(currentShop.icon, color: themeColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Conectado a ${currentShop.name}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => appProvider.unlinkBusiness(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red.withOpacity(0.5)),
                        ),
                        icon: const Icon(Icons.link_off),
                        label: const Text("DESVINCULAR DESTA LOJA"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],

            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.grey),
                label: const Text("Terminar Sessão na Conta", style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(
      String label,
      TextEditingController controller,
      IconData icon,
      Color color, {
        required bool isEditable,
      }) {
    return TextField(
      controller: controller,
      enabled: isEditable,
      style: TextStyle(color: isEditable ? Colors.white : Colors.grey),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isEditable ? color : Colors.grey),
        prefixIcon: Icon(icon, color: isEditable ? color : Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.white10),
        ),
      ),
    );
  }
}