import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/business_model.dart'; // Importa o modelo Business
import '../providers/app_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Acede ao provider para filtrar as lojas favoritas
    final provider = Provider.of<AppProvider>(context);

    // Filtra a lista de mockBusinesses baseada nos IDs favoritos
    final favShops = mockBusinesses.where((shop) => provider.isFavorite(shop.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Meus Favoritos"),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: favShops.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 60, color: Colors.grey[800]),
            const SizedBox(height: 20),
            const Text("Ainda não tens favoritos.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: favShops.length,
        itemBuilder: (context, index) {
          final shop = favShops[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Color(shop.colorHex).withOpacity(0.3)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(shop.coverImage),
                radius: 25,
              ),
              title: Text(shop.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(shop.address, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () => provider.toggleFavorite(shop.id), // Remove dos favoritos
              ),
              onTap: () {
                provider.selectShop(shop);
                Navigator.pushNamed(context, '/shop_details');
              },
            ),
          );
        },
      ),
    );
  }
}