import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../models/service_model.dart';
import '../config/theme.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final shop = provider.currentShop;
    final themeColor = provider.getThemeColor();

    if (shop == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final List<String> galleryImages = [
      'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?q=80&w=400',
      'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?q=80&w=400',
      'https://images.unsplash.com/photo-1593702295094-aea8c59b2e3b?q=80&w=400',
      'https://images.unsplash.com/photo-1503951914875-452162b7f30a?q=80&w=400',
    ];

    // Mock da equipa para esta loja
    final List<Map<String, String>> teamMembers = [
      {'name': 'Carlos', 'role': 'Master Barber', 'image': 'https://randomuser.me/api/portraits/men/32.jpg'},
      {'name': 'Sofia', 'role': 'Colorista', 'image': 'https://randomuser.me/api/portraits/women/44.jpg'},
      {'name': 'André', 'role': 'Barbeiro', 'image': 'https://randomuser.me/api/portraits/men/85.jpg'},
    ];

    // Reviews fictícios
    final List<Map<String, dynamic>> reviews = [
      {"user": "Mário S.", "rating": 5.0, "text": "O melhor corte que já fiz! O ambiente é top."},
      {"user": "Tiago L.", "rating": 4.5, "text": "Muito profissionais, mas tive de esperar 5 min."},
      {"user": "Vasco R.", "rating": 5.0, "text": "Recomendo o Combo King. Saí de lá novo."},
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // CABEÇALHO
          SliverAppBar(
            expandedHeight: 250.0,
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
                  shadows: [const Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(shop.image, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.grey[900])),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.95)],
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
                  // Info e Contactos
                  Row(
                    children: [
                      Icon(Icons.star, color: themeColor, size: 20),
                      const SizedBox(width: 8),
                      Text("${shop.rating} (124 Reviews)", style: const TextStyle(color: Colors.white, fontSize: 16)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: const Text("Aberto Agora", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Botões de Ação Rápida
                  Row(
                    children: [
                      Expanded(child: _buildActionButton(Icons.call, "Ligar", themeColor)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildActionButton(Icons.map, "Mapa", themeColor)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildActionButton(Icons.share, "Partilhar", themeColor)),
                    ],
                  ),

                  // NOVO: Sobre Nós
                  const SizedBox(height: 30),
                  Text("Sobre Nós", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text(
                    "A ${shop.name} oferece uma experiência de barbearia clássica com um toque moderno. Especialistas em cortes de precisão, barbas de luxo e tratamentos de spa para homens exigentes.",
                    style: TextStyle(color: Colors.grey[400], height: 1.5, fontSize: 14),
                  ),

                  // NOVO: Horário
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Icon(Icons.access_time, color: themeColor, size: 20),
                          const SizedBox(width: 10),
                          const Text("Seg - Sáb", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ]),
                        const Text("09:00 - 20:00", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),

                  // NOVO: A Nossa Equipa
                  const SizedBox(height: 30),
                  Text("A Nossa Equipa", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: teamMembers.length,
                      itemBuilder: (context, index) {
                        final member = teamMembers[index];
                        return Container(
                          margin: const EdgeInsets.only(right: 20),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: themeColor)),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(member['image']!),
                                ),
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
                  Text("Serviços", style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ),

          // LISTA DE SERVIÇOS
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final service = mockServices[index];
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
                    trailing: Text("${service.price.toStringAsFixed(2)}€", style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 16)),
                    onTap: () {},
                  ),
                ).animate().fadeIn(delay: (50 * index).ms).slideX();
              },
              childCount: mockServices.length,
            ),
          ),

          // SECÇÃO DE REVIEWS (NOVO)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text("O que dizem os clientes", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 15),
                  ...reviews.map((r) => Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(r['user'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Row(children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < r['rating'] ? AppColors.gold : Colors.grey))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(r['text'], style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/booking'),
        backgroundColor: themeColor,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.calendar_month),
        label: const Text("MARCAR AGORA", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}