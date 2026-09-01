import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/theme.dart';
import '../models/business_model.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../services/shop_service.dart';
import 'profile_screen.dart';
import 'favorites_screen.dart';
import 'notifications_screen.dart';
import 'loyalty_screen.dart';
import 'appointments_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentBottomIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final app = Provider.of<AppProvider>(context, listen: false);
      if (auth.userModel?.id != null) {
        app.loadFavorites(auth.userModel!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const _ClientHomeFeed(),
      const AppointmentsScreen(),
      const LoyaltyScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: IndexedStack(
        index: _currentBottomIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: AppColors.gold.withValues(alpha: 0.2),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                (states) => states.contains(WidgetState.selected)
                ? const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12)
                : const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                (states) => states.contains(WidgetState.selected)
                ? const IconThemeData(color: AppColors.gold)
                : const IconThemeData(color: Colors.grey),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentBottomIndex,
          onDestinationSelected: (idx) => setState(() => _currentBottomIndex = idx),
          backgroundColor: const Color(0xFF1A1A1A),
          elevation: 10,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Descobrir',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Marcações',
            ),
            NavigationDestination(
              icon: Icon(Icons.card_giftcard_outlined),
              selectedIcon: Icon(Icons.card_giftcard),
              label: 'Fidelidade',
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientHomeFeed extends StatefulWidget {
  const _ClientHomeFeed();

  @override
  State<_ClientHomeFeed> createState() => _ClientHomeFeedState();
}

class _ClientHomeFeedState extends State<_ClientHomeFeed> {
  static const String baseUrl = 'http://10.0.2.2:3000';

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _visualCategories = [
    {"name": "Todos", "icon": Icons.grid_view},
    {"name": "Cabelo", "icon": Icons.content_cut},
    {"name": "Barba", "icon": Icons.face},
    {"name": "Estética", "icon": Icons.spa},
  ];

  late Future<List<dynamic>> _promosFuture;
  late Future<List<dynamic>> _topWorkersFuture;

  @override
  void initState() {
    super.initState();
    _loadDynamicData();
  }

  void _loadDynamicData() {
    _promosFuture = _fetchActivePromotions();
    _topWorkersFuture = _fetchTopWorkers();
  }

  Future<List<dynamic>> _fetchActivePromotions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/promotions/active'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  Future<List<dynamic>> _fetchTopWorkers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/workers/top'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isStaff = auth.isOwner || auth.isWorker;

    final userPhoto = auth.userModel?.name.isNotEmpty == true
        ? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(auth.userModel!.name)}&background=D4AF37&color=000'
        : 'https://randomuser.me/api/portraits/men/32.jpg';

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
          if (isStaff)
            IconButton(
              icon: const Icon(Icons.work, color: AppColors.gold),
              tooltip: 'Painel Profissional',
              onPressed: () {
                if (auth.isOwner) {
                  Navigator.pushNamed(context, '/admin_dashboard');
                } else {
                  Navigator.pushNamed(context, '/worker_dashboard');
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            tooltip: 'Favoritos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            tooltip: 'Notificações',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(userPhoto),
                backgroundColor: const Color(0xFF1E1E1E),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: () async {
          setState(() {
            _loadDynamicData();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                    hintText: "Procurar barbearia, localização...",
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
                                color: isSelected ? AppColors.gold : const Color(0xFF1E1E1E),
                                shape: BoxShape.circle,
                                border: isSelected ? null : Border.all(color: Colors.white10),
                                boxShadow: isSelected
                                    ? [
                                  BoxShadow(
                                    color: AppColors.gold.withValues(alpha: 0.4),
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
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              // 1. CAMPANHAS / PROMOÇÕES REAIS (PostgreSQL)
              FutureBuilder<List<dynamic>>(
                future: _promosFuture,
                builder: (context, snapshot) {
                  final promos = snapshot.data ?? [];
                  if (promos.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Campanhas Ativas",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: promos.length,
                          itemBuilder: (context, index) {
                            final p = promos[index];
                            final colorHex = int.tryParse(p['color_hex']?.toString() ?? '') ?? 0xFF9C27B0;
                            final color = Color(colorHex);

                            return Container(
                              width: 250,
                              margin: const EdgeInsets.only(right: 15),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [color.withValues(alpha: 0.85), color.withValues(alpha: 0.4)],
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
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      p['shop_name'] ?? "DESTAQUE",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    p['title'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    p['subtitle'] ?? '',
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                  );
                },
              ),

              // 2. PROFISSIONAIS REAIS DA EQUIPA (PostgreSQL)
              FutureBuilder<List<dynamic>>(
                future: _topWorkersFuture,
                builder: (context, snapshot) {
                  final workers = snapshot.data ?? [];
                  if (workers.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Profissionais em Destaque",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: workers.length,
                          itemBuilder: (context, index) {
                            final worker = workers[index];
                            final name = worker['name'] ?? 'Barbeiro';
                            final photoUrl = worker['photo_url'] ??
                                'https://randomuser.me/api/portraits/men/32.jpg';
                            final rating = double.tryParse(worker['rating']?.toString() ?? '5.0') ?? 5.0;

                            return Container(
                              margin: const EdgeInsets.only(right: 18),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.gold, width: 2),
                                    ),
                                    child: CircleAvatar(
                                      radius: 28,
                                      backgroundImage: NetworkImage(photoUrl),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    name.toString().split(' ')[0],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 10),
                                      Text(
                                        " $rating",
                                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ).animate().scale(delay: (40 * index).ms);
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                  );
                },
              ),

              // 3. LISTA DE LOJAS DO POSTGRESQL
              FutureBuilder<List<Map<String, dynamic>>>(
                future: ShopService.getShops(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: CircularProgressIndicator(color: AppColors.gold),
                      ),
                    );
                  }

                  final List<Map<String, dynamic>> shopsData = snapshot.data ?? [];

                  final shops = shopsData
                      .map((data) {
                    final colorHex = int.tryParse(data['color_hex']?.toString() ?? '') ?? 0xFFFFD700;
                    return Business(
                      id: data['id'].toString(),
                      name: data['name'] ?? 'Barbearia',
                      type: BusinessType.values.first,
                      code: data['code'] ?? 'SKILL',
                      colorHex: colorHex,
                      address: data['address'] ?? 'Beja',
                      rating: double.tryParse(data['rating']?.toString() ?? '5.0') ?? 5.0,
                      coverImage: data['cover_image'] ??
                          'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=800&q=80',
                    );
                  })
                      .where((shop) => shop.name.toLowerCase().contains(_searchQuery.toLowerCase()))
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
                              "Espaços Recomendados",
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                            ),
                            Text("${shops.length} locais", style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
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
      ),
    );
  }

  Widget _buildShopCard(BuildContext context, Business shop) {
    return Consumer2<AppProvider, AuthProvider>(
      builder: (context, provider, auth, child) {
        final isFavorite = provider.isFavorite(shop.id);
        final userId = auth.userModel?.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Color(shop.colorHex).withValues(alpha: 0.3),
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
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        shop.coverImage,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(height: 150, color: Colors.grey[900]),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () async {
                          if (userId != null) {
                            await provider.toggleFavoriteHttp(userId, shop.id);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Inicia sessão para guardar favoritos."),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
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
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                          const Icon(Icons.star, color: AppColors.gold, size: 16),
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