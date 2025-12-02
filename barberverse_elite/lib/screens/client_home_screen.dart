import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart'; // Importante para ligar ao Provider
import '../config/theme.dart';
import '../models/shop_model.dart';
import '../providers/app_provider.dart'; // Importante para mudar a loja selecionada
import 'loyalty_screen.dart'; // Importa o ecrã de fidelidade para o botão da carteira

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha a sua Barbearia'),
        actions: [
          // Botão da Carteira/Fidelidade (NOVO)
          IconButton(
            icon: const Icon(Icons.wallet, color: AppColors.gold),
            tooltip: 'Minha Carteira',
            onPressed: () {
              Navigator.pushNamed(context, '/loyalty');
              // Ou se preferires navegação direta sem rota definida:
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const LoyaltyScreen()));
            },
          ),
          // Botão de Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: mockShops.length,
        itemBuilder: (context, index) {
          final shop = mockShops[index];
          // Animação de entrada em cascata para cada cartão
          return _buildShopCard(context, shop)
              .animate()
              .fadeIn(duration: 600.ms, delay: (100 * index).ms)
              .slideX(begin: 0.2, end: 0);
        },
      ),
    );
  }

  Widget _buildShopCard(BuildContext context, BarberShop shop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // A borda do cartão já usa a cor da marca da loja para dar uma dica
        side: BorderSide(color: Color(shop.colorHex).withOpacity(0.3), width: 1),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {
          // LÓGICA CRÍTICA DO CAMALEÃO:
          // 1. Define esta loja como a "Loja Atual" no Provider
          // Isto vai disparar a mudança de cor em toda a app instantaneamente
          Provider.of<AppProvider>(context, listen: false).selectShop(shop);

          // 2. Navega para o ecrã de detalhes da loja
          Navigator.pushNamed(context, '/shop_details');
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem da Loja (Hero Image)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                shop.image,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                // Placeholder caso a imagem da net falhe
                errorBuilder: (c, e, s) => Container(
                  height: 150,
                  color: Colors.grey[900],
                  child: const Center(
                    child: Icon(Icons.store, size: 50, color: Colors.white24),
                  ),
                ),
              ),
            ),

            // Informações da Loja
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
                          color: Color(shop.colorHex), // Nome na cor da loja
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shop.address,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),

                  // Badge de Avaliação
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.gold, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          shop.rating.toString(),
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}