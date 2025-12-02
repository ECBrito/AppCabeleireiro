import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/shop_model.dart';
import '../providers/app_provider.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "Todos";

  // Categorias Fictícias
  final List<String> _categories = ["Todos", "Barba", "Cabelo", "Spa", "Vip"];

  // Mock Data: Top Barbeiros (Novidade)
  final List<Map<String, dynamic>> _topBarbers = [
    {'name': 'Carlos', 'rating': 5.0, 'image': 'https://randomuser.me/api/portraits/men/32.jpg'},
    {'name': 'Sofia', 'rating': 4.9, 'image': 'https://randomuser.me/api/portraits/women/44.jpg'},
    {'name': 'André', 'rating': 4.8, 'image': 'https://randomuser.me/api/portraits/men/85.jpg'},
    {'name': 'Ana', 'rating': 4.9, 'image': 'https://randomuser.me/api/portraits/women/60.jpg'},
    {'name': 'Miguel', 'rating': 4.7, 'image': 'https://randomuser.me/api/portraits/men/22.jpg'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lógica de Filtro Local
    final filteredShops = mockShops.where((shop) {
      final matchesName = shop.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == "Todos" || true;
      return matchesName && matchesCategory;
    }).toList();

    return Scaffold(
      // AppBar limpa com ações
      appBar: AppBar(
        title: const Text('BarberVerse'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.gold),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sem notificações novas")));
            },
          ),
          IconButton(
            icon: const Icon(Icons.wallet, color: AppColors.gold),
            onPressed: () => Navigator.pushNamed(context, '/loyalty'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. BARRA DE PESQUISA
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Procurar barbearia...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = "");
                    },
                  )
                      : null,
                  fillColor: AppColors.surface,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // 2. BANNER DE PROMOÇÃO (Carrossel)
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildPromoCard(Colors.purple, "Semana do Estudante", "20% OFF"),
                  _buildPromoCard(Colors.blue, "Indique um Amigo", "Ganhe 50 pts"),
                  _buildPromoCard(Colors.orange, "Combo Pai & Filho", "Oferta Especial"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 3. FILTROS (Chips)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.gold : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected ? null : Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // --- NOVA SECÇÃO: TOP PROFISSIONAIS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text("Top Profissionais", style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 100,
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
                          padding: const EdgeInsets.all(3),
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
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.gold, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              barber['rating'].toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                  ).animate().scale(delay: (100 * index).ms);
                },
              ),
            ),
            // ---------------------------------------

            const SizedBox(height: 10),

            // 4. TÍTULO DA LISTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Perto de Si", style: Theme.of(context).textTheme.titleLarge),
                  Text("${filteredShops.length} resultados", style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 5. LISTA DE LOJAS
            ListView.builder(
              shrinkWrap: true, // Importante dentro de SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(), // O scroll é feito pelo pai
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredShops.length,
              itemBuilder: (context, index) {
                final shop = filteredShops[index];
                return _buildShopCard(context, shop)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: (50 * index).ms)
                    .slideY(begin: 0.1, end: 0);
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
      width: 280,
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
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
            child: const Text("PROMO", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildShopCard(BuildContext context, BarberShop shop) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final isFavorite = provider.isFavorite(shop.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Color(shop.colorHex).withOpacity(0.3), width: 1),
          ),
          elevation: 4,
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
                        shop.image,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(height: 150, color: Colors.grey[900], child: const Icon(Icons.store, color: Colors.white24)),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => provider.toggleFavorite(shop.id),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                          child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.white, size: 20),
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
                          Text(shop.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Color(shop.colorHex), fontSize: 18)),
                          const SizedBox(height: 4),
                          Text(shop.address, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.gold, size: 16),
                          const SizedBox(width: 4),
                          Text(shop.rating.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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