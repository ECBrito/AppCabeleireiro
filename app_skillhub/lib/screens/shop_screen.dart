import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../config/theme.dart';
import '../models/business_model.dart'; // <--- IMPORT NOVO (Essencial)

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ligar ao Cérebro para saber qual é a loja
    final provider = Provider.of<AppProvider>(context);
    
    // CORREÇÃO: Usamos 'activeBusiness' (que tem coverImage) em vez de 'currentShop'
    final shop = provider.activeBusiness; 
    
    final themeColor = provider.getThemeColor();
    final services = provider.services; // Lista de serviços do Provider

    // Se não houver loja selecionada (erro), mostra loading
    if (shop == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // Dados Visuais (Mock) para encher o ecrã
    final List<String> galleryImages = [
      'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?q=80&w=400',
      'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?q=80&w=400',
      'https://images.unsplash.com/photo-1593702295094-aea8c59b2e3b?q=80&w=400',
    ];

    final List<Map<String, String>> teamMembers = [
      {'name': 'Carlos', 'role': 'Master', 'image': 'https://randomuser.me/api/portraits/men/32.jpg'},
      {'name': 'Sofia', 'role': 'Colorista', 'image': 'https://randomuser.me/api/portraits/women/44.jpg'},
      {'name': 'André', 'role': 'Barber', 'image': 'https://randomuser.me/api/portraits/men/85.jpg'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // CABEÇALHO EXPANSÍVEL
          SliverAppBar(
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.background,
            iconTheme: IconThemeData(color: themeColor),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                shop.name,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [const Shadow(color: Colors.black, blurRadius: 15)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    shop.coverImage,
                    fit: BoxFit.cover,
                    errorBuilder: (c,e,s) => Container(color: Colors.grey[900]),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.background.withOpacity(0.9)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CONTEÚDO
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Rápida
                  Row(
                    children: [
                      Icon(Icons.star, color: themeColor, size: 20),
                      const SizedBox(width: 8),
                      Text("${shop.rating} (120+ Reviews)", style: const TextStyle(color: Colors.white, fontSize: 16)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: const Text("Aberto", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Botões de Ação
                  Row(
                    children: [
                      Expanded(child: _buildActionButton(Icons.call, "Ligar", themeColor)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildActionButton(Icons.map, "Mapa", themeColor)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildActionButton(Icons.share, "Partilhar", themeColor)),
                    ],
                  ),

                  const SizedBox(height: 30),
                  
                  // Equipa
                  Text("A Nossa Equipa", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: teamMembers.length,
                      itemBuilder: (context, index) {
                        final member = teamMembers[index];
                        return Container(
                          margin: const EdgeInsets.only(right: 20),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(member['image']!),
                              ),
                              const SizedBox(height: 5),
                              Text(member['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              Text(member['role']!, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                            ],
                          ),
                        ).animate().scale(delay: (100 * index).ms);
                      },
                    ),
                  ),

                  const SizedBox(height: 30),
                  
                  // Galeria
                  Text("Portfólio", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: galleryImages.length,
                      itemBuilder: (context, index) => Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(image: NetworkImage(galleryImages[index]), fit: BoxFit.cover),
                            border: Border.all(color: Colors.white10),
                          ),
                        ).animate().fadeIn(delay: (100 * index).ms).scale(),
                    ),
                  ),

                  const SizedBox(height: 30),
                  
                  // Serviços
                  Text("Serviços", style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ),

          // LISTA DE SERVIÇOS (Vertical)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final service = services[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeColor.withOpacity(0.2)),
                  ),
                  child: ListTile(
                    title: Text(service.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text("${service.durationMinutes} min", style: TextStyle(color: Colors.grey[400])),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text("${service.price.toStringAsFixed(2)}€", style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    onTap: () {
                      // Feedback visual
                    },
                  ),
                ).animate().fadeIn(delay: (50 * index).ms).slideX();
              },
              childCount: services.length,
            ),
          ),

          // Espaço extra para o botão flutuante não tapar o último item
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      
      // BOTÃO DE MARCAR (FLUTUANTE)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/booking'),
        backgroundColor: themeColor,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.calendar_month),
        label: const Text("MARCAR AGORA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}