import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../config/theme.dart';
import '../models/business_model.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  static const String baseUrl = 'http://10.0.2.2:3000';
  late Future<List<dynamic>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userModel?.id;
    setState(() {
      _favoritesFuture = _fetchFavorites(userId);
    });
  }

  Future<List<dynamic>> _fetchFavorites(int? userId) async {
    if (userId == null) return [];
    try {
      final response = await http.get(Uri.parse('$baseUrl/favorites/$userId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  Future<void> _removeFavorite(int? userId, int shopId) async {
    if (userId == null) return;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/favorites/toggle'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'shopId': shopId}),
      );

      if (response.statusCode == 200) {
        _loadFavorites();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final provider = Provider.of<AppProvider>(context);
    final userId = auth.userModel?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Os Meus Favoritos"),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }

          final favShops = snapshot.data ?? [];

          if (favShops.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 60, color: Colors.grey[800]),
                  const SizedBox(height: 20),
                  const Text("Ainda não tens barbearias favoritas.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.gold,
            onRefresh: () async => _loadFavorites(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favShops.length,
              itemBuilder: (context, index) {
                final shop = favShops[index];
                final colorHex = int.tryParse(shop['color_hex']?.toString() ?? '') ?? 0xFFFFD700;
                final themeColor = Color(colorHex);

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: themeColor.withOpacity(0.3)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        shop['cover_image'] ?? 'https://images.unsplash.com/photo-1503951914875-452162b7f30a?q=80&w=400',
                      ),
                      radius: 25,
                    ),
                    title: Text(
                      shop['name'] ?? '',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      shop['address'] ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.redAccent),
                      onPressed: () => _removeFavorite(userId, shop['id']),
                    ),
                    onTap: () {
                      final businessObj = Business(
                        id: shop['id'].toString(),
                        name: shop['name'] ?? '',
                        type: BusinessType.values.first,
                        code: shop['code'] ?? 'SHOP',
                        colorHex: colorHex,
                        address: shop['address'] ?? '',
                        rating: double.tryParse(shop['rating']?.toString() ?? '5.0') ?? 5.0,
                        coverImage: shop['cover_image'] ?? '',
                      );
                      provider.selectShop(businessObj);
                      Navigator.pushNamed(context, '/shop_details');
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}