import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _nameController.text = user?.name ?? "Cliente";
    _emailController.text = user?.email ?? "email@exemplo.com";
    _phoneController.text = user?.phoneNumber ?? "912345678";
  }

  void _saveProfile() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.updateProfile(name: _nameController.text, phone: _phoneController.text);
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Perfil atualizado com sucesso!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);

    // Dados da loja atual (para mostrar de onde estamos a sair)
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
            icon: Icon(_isEditing ? Icons.check : Icons.edit, color: themeColor),
            onPressed: () {
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
            // FOTO DE PERFIL
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

            _buildProfileField("Nome Completo", _nameController, Icons.person, themeColor),
            const SizedBox(height: 20),
            _buildProfileField("Email", _emailController, Icons.email, themeColor),
            const SizedBox(height: 20),
            _buildProfileField("Telemóvel", _phoneController, Icons.phone, themeColor),

            const SizedBox(height: 40),

            // --- ÁREA DE VINCULAÇÃO (NOVO) ---
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
                        onPressed: () {
                          // AÇÃO DE DESVINCULAR
                          appProvider.unlinkBusiness();
                          // Nota: O main.dart deteta isto e muda para o ecrã de LinkScreen automaticamente
                        },
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

            // BOTÃO TERMINAR SESSÃO (Conta SkillHub)
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  auth.logout();
                  Navigator.pushReplacementNamed(context, '/login');
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

  Widget _buildProfileField(String label, TextEditingController controller, IconData icon, Color color) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      style: TextStyle(color: _isEditing ? Colors.white : Colors.grey),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _isEditing ? color : Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}