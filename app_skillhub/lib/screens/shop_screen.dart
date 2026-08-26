import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../config/theme.dart';
import '../models/business_model.dart';

class ShopScreen extends StatelessWidget {
  final bool isHomeMode;

  const ShopScreen({super.key, this.isHomeMode = false});

  static const String baseUrl = 'http://10.0.2.2:3000';

  Future<List<dynamic>> _fetchWorkers(int shopId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/workers?shopId=$shopId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  Future<List<dynamic>> _fetchServices(int shopId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/services?shopId=$shopId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final Business? shop = provider.activeBusiness;

    if (shop == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    final themeColor = Color(shop.colorHex);
    final shopId = int.tryParse(shop.id) ?? 1;
    final isFav = provider.isFavorite(shop.id);
    final userId = authProvider.userModel?.id;

    final List<String> galleryImages = [
      'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?q=80&w=400',
      'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?q=80&w=400',
      'https://images.unsplash.com/photo-1593702295094-aea8c59b2e3b?q=80&w=400',
      'https://images.unsplash.com/photo-1503951914875-452162b7f30a?q=80&w=400',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 1. CABEÇALHO COM BOTÃO DE FAVORITO
          SliverAppBar(
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.background,
            iconTheme: IconThemeData(color: themeColor),
            automaticallyImplyLeading: !isHomeMode,
            actions: [
              // BOTÃO FAVORITO (CORAÇÃO)
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : Colors.white,
                ),
                tooltip: isFav ? "Remover dos Favoritos" : "Adicionar aos Favoritos",
                onPressed: () async {
                  if (userId != null) {
                    final newState = await provider.toggleFavoriteHttp(userId, shop.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            newState
                                ? "Adicionado aos favoritos!"
                                : "Removido dos favoritos.",
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: newState ? Colors.green : Colors.grey[800],
                        ),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Inicia sessão para guardar favoritos."),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                },
              ),

              if (!isHomeMode)
                TextButton.icon(
                  onPressed: () async {
                    await provider.linkBusiness(shop.code);
                    if (context.mounted) {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  },
                  icon: const Icon(Icons.push_pin, color: Colors.white, size: 18),
                  label: const Text(
                    "USAR ESTA APP",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  style: TextButton.styleFrom(backgroundColor: themeColor.withOpacity(0.2)),
                ),
              const SizedBox(width: 10),
            ],
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
                    errorBuilder: (c, e, s) => Container(color: Colors.grey[900]),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.background.withOpacity(0.95)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. DETALHES E EQUIPA DINÂMICA
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: themeColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "${shop.rating} Avaliações",
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Aberto",
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

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

                  Text("Sobre", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(
                    "Espaço profissional dedicado aos melhores serviços de barbearia e estética em ${shop.address}.",
                    style: TextStyle(color: Colors.grey[400], height: 1.5),
                  ),

                  const SizedBox(height: 30),

                  Text("Equipa", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                  const SizedBox(height: 15),
                  FutureBuilder<List<dynamic>>(
                    future: _fetchWorkers(shopId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                      }
                      final workers = snapshot.data ?? [];
                      if (workers.isEmpty) {
                        return const Text("Sem profissionais associados.", style: TextStyle(color: Colors.grey));
                      }
                      return SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: workers.length,
                          itemBuilder: (context, index) {
                            final worker = workers[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 20),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundImage: NetworkImage(
                                      worker['photo_url'] ?? 'https://randomuser.me/api/portraits/men/32.jpg',
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    worker['name'] ?? 'Barbeiro',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  Text(
                                    worker['role'] ?? 'Profissional',
                                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

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
                          image: DecorationImage(
                            image: NetworkImage(galleryImages[index]),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(color: Colors.white10),
                        ),
                      ).animate().fadeIn(delay: (100 * index).ms).scale(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text("Serviços", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),

          // 3. LISTA DE SERVIÇOS (PostgreSQL)
          SliverToBoxAdapter(
            child: FutureBuilder<List<dynamic>>(
              future: _fetchServices(shopId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
                  );
                }

                final services = snapshot.data ?? [];
                if (services.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Text("Sem serviços registados nesta loja.", style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final item = services[index];
                    final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: themeColor.withOpacity(0.2)),
                      ),
                      child: ListTile(
                        title: Text(
                          item['name'] ?? '',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${item['duration_minutes'] ?? 30} min",
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        trailing: Text(
                          "${price.toStringAsFixed(2)}€",
                          style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/booking'),
        backgroundColor: themeColor,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.calendar_month),
        label: Text(
          shop.bookingActionLabel,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
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