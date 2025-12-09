import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Para animações bonitas
import '../providers/app_provider.dart';
import '../config/theme.dart';
import '../models/business_model.dart'; // Import para Business

class ShopScreen extends StatelessWidget {
  // Parâmetro para saber se estamos no modo Home ou Preview
  final bool isHomeMode;

  const ShopScreen({super.key, this.isHomeMode = false});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // CORREÇÃO CRÍTICA: Usamos sempre o 'activeBusiness' porque ele contém
    // o objeto 'Business' completo com todos os campos (colorHex, code, etc).
    // O 'currentShop' era um getter de compatibilidade que retornava um tipo diferente.
    // Se estiver em HomeMode, usamos o activeBusiness (já vinculado).
    // Se estiver em Preview, usamos o shop selecionado temporariamente (provider.selectedShop).
    // NOTA: O provider deve ter um getter para o shop temporário se quisermos preview sem vincular.
    // Para simplificar, assumimos que selectShop define o activeBusiness temporariamente ou usamos um campo separado.
    // Vamos usar activeBusiness assumindo que o clique na lista o definiu.
    final Business? shop = provider.activeBusiness;

    // Fallback de segurança
    if (shop == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final themeColor = Color(shop.colorHex);
    final services = provider.services;

    // --- DADOS VISUAIS (MOCK) ---
    // Estes dados estariam no BusinessModel num cenário real
    final List<String> galleryImages = [
      'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?q=80&w=400',
      'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?q=80&w=400',
      'https://images.unsplash.com/photo-1593702295094-aea8c59b2e3b?q=80&w=400',
      'https://images.unsplash.com/photo-1503951914875-452162b7f30a?q=80&w=400',
    ];

    final List<Map<String, String>> teamMembers = [
      {'name': 'Carlos', 'role': 'Master', 'image': 'https://randomuser.me/api/portraits/men/32.jpg'},
      {'name': 'Sofia', 'role': 'Colorista', 'image': 'https://randomuser.me/api/portraits/women/44.jpg'},
      {'name': 'André', 'role': 'Barber', 'image': 'https://randomuser.me/api/portraits/men/85.jpg'},
    ];

    final List<Map<String, dynamic>> reviews = [
      {"user": "Mário S.", "rating": 5.0, "text": "Melhor corte da cidade! Ambiente top."},
      {"user": "Tiago L.", "rating": 4.0, "text": "Bom serviço, mas esperei 10 min."},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 1. CABEÇALHO (Imagem Grande + Botão Vincular)
          SliverAppBar(
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.background,
            iconTheme: IconThemeData(color: themeColor),
            // Se for HomeMode, removemos o botão de voltar padrão porque estamos na raiz
            automaticallyImplyLeading: !isHomeMode,

            actions: [
              // BOTÃO DE VINCULAR (Só aparece se NÃO estivermos já vinculados e a loja for paga)
              if (!isHomeMode) // && shop.isPremium (Opcional: só permitir vincular a premium)
                TextButton.icon(
                  onPressed: () async {
                    // AÇÃO DE VINCULAR
                    await provider.linkBusiness(shop.code);
                    // Volta à raiz (que agora será esta loja)
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.push_pin, color: Colors.white),
                  label: const Text("USAR ESTA APP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(backgroundColor: themeColor.withOpacity(0.2)),
                ),

              const SizedBox(width: 10),
            ],

            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                shop.name,
                style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, shadows: [const Shadow(color: Colors.black, blurRadius: 15)]),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(shop.coverImage, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.grey[900])),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppColors.background.withOpacity(0.95)]))),
                ],
              ),
            ),
          ),

          // 2. CONTEÚDO RICO
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

                  const SizedBox(height: 30),

                  // Sobre Nós
                  Text("Sobre", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(
                    "Especialistas em cortes clássicos e modernos. O teu estilo é a nossa prioridade. Ambiente relaxado e profissional.",
                    style: TextStyle(color: Colors.grey[400], height: 1.5),
                  ),

                  const SizedBox(height: 30),

                  // Equipa
                  Text("Equipa", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
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
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Galeria (Portfólio)
                  Text("Portfólio", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
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

                  // Título Serviços
                  Text("Serviços", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),

          // LISTA DE SERVIÇOS
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final service = services[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: themeColor.withOpacity(0.2))),
                  child: ListTile(
                    title: Text(service.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text("${service.durationMinutes} min", style: TextStyle(color: Colors.grey[400])),
                    trailing: Text("${service.price.toStringAsFixed(2)}€", style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                );
              },
              childCount: services.length,
            ),
          ),

          // REVIEWS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Text("Opiniões", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
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
                        const SizedBox(height: 5),
                        Text(r['text'], style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 100),
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
        label: Text(shop.bookingActionLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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