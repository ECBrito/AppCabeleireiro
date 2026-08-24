import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../models/business_model.dart';
import '../providers/app_provider.dart';
import '../services/shop_service.dart';
import 'profile_screen.dart';
import 'favorites_screen.dart';
import 'notifications_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _visualCategories = [
    {"name": "Todos", "icon": Icons.grid_view},
    {"name": "Cabelo", "icon": Icons.content_cut},
    {"name": "Barba", "icon": Icons.face},
    {"name": "Spa", "icon": Icons.spa},
    {"name": "Tattoo", "icon": Icons.brush},
  ];

  final List<Map<String, dynamic>> _topBarbers = [
    {
      'name': 'Carlos',
      'rating': 5.0,
      'image': 'https://randomuser.me/api/portraits/men/32.jpg',
    },
    {
      'name': 'Sofia',
      'rating': 4.9,
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
    },
    {
      'name': 'André',
      'rating': 4.8,
      'image': 'https://randomuser.me/api/portraits/men/85.jpg',
    },
    {
      'name': 'Ana',
      'rating': 4.9,
      'image': 'https://randomuser.me/api/portraits/women/60.jpg',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.hub, color: AppColors.gold),
            const SizedBox(width: 8),
            Text(
              'SkillHub',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            tooltip: 'Favoritos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                tooltip: 'Notificações',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    'https://randomuser.me/api/portraits/men/32.jpg',
                  ),
                  backgroundColor: Color(0xFF1E1E1E),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BARRA DE PESQUISA
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Procurar barbearia, spa...",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  fillColor: const Color(0xFF1E1E1E),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = "");
                          },
                        )
                      : null,
                ),
              ),
            ),

            // CATEGORIAS VISUAIS
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _visualCategories.length,
                itemBuilder: (context, index) {
                  final cat = _visualCategories[index];
                  final isSelected = _selectedCategoryIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategoryIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 20),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.gold
                                  : const Color(0xFF1E1E1E),
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? null
                                  : Border.all(color: Colors.white10),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.gold.withOpacity(0.4),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Icon(
                              cat['icon'] as IconData,
                              color: isSelected ? Colors.black : Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            cat['name'] as String,
                            style: TextStyle(
                              color: isSelected ? AppColors.gold : Colors.grey,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // BANNER PROMOÇÃO
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildPromoCard(
                    const Color(0xFF9C27B0),
                    "Semana do Estudante",
                    "20% OFF",
                  ),
                  _buildPromoCard(
                    const Color(0xFF2196F3),
                    "Indique um Amigo",
                    "Ganhe 50 pts",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // TOP PROFISSIONAIS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Top Profissionais",
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const Text(
                    "Ver todos",
                    style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _topBarbers.length,
                itemBuilder: (context, index) {
                  final barber = _topBarbers[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.gold, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(barber['image']),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          barber['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 10,
                            ),
                            Text(
                              " ${barber['rating']}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().scale(delay: (50 * index).ms);
                },
              ),
            ),

            const SizedBox(height: 20),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: ShopService.getShops(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: AppColors.gold),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        "Erro ao carregar lojas:\n${snapshot.error}",
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final List<Map<String, dynamic>> shopsData =
                    snapshot.data ?? [];

                // Converte os dados da BD para o modelo Business
                final shops = shopsData
                    .map((data) {
                      return Business(
                        id: data['id'].toString(),
                        name: data['name'] ?? 'Barbearia',
                        type: BusinessType.values.first,
                        code: 'SKILL',
                        colorHex: 0xFFFFD700,
                        address: data['address'] ?? 'Beja',
                        rating:
                            double.tryParse(
                              data['rating']?.toString() ?? '5.0',
                            ) ??
                            5.0,
                        coverImage:
                            data['cover_image'] ??
                            'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=800&q=80',
                      );
                    })
                    .where((shop) {
                      return shop.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );
                    })
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Recomendados (Postgres)",
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.white),
                          ),
                          Text(
                            "${shops.length} locais",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    shops.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: Text(
                                "Sem barbearias registadas.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: shops.length,
                            itemBuilder: (context, index) {
                              return _buildShopCard(context, shops[index]);
                            },
                          ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCard(Color color, String title, String subtitle) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "PROMO",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(BuildContext context, Business shop) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final isFavorite = provider.isFavorite(shop.id);
        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Color(shop.colorHex).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              provider.selectShop(shop);
              Navigator.pushNamed(context, '/shop_details');
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        shop.coverImage,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            Container(height: 150, color: Colors.grey[900]),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => provider.toggleFavorite(shop.id),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop.name,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Color(shop.colorHex),
                                  fontSize: 18,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            shop.address,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.gold,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            shop.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
