import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../config/theme.dart';
import '../providers/auth_provider.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => LoyaltyScreenState();
}

class LoyaltyScreenState extends State<LoyaltyScreen> {
  static const String baseUrl = 'http://10.0.2.2:3000';
  Future<List<dynamic>>? _loyaltyFuture;

  @override
  void initState() {
    super.initState();
    loadLoyalty();
  }

  void loadLoyalty() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userModel?.id;
    setState(() {
      _loyaltyFuture = _fetchLoyaltyCards(userId);
    });
  }

  Future<List<dynamic>> _fetchLoyaltyCards(int? userId) async {
    if (userId == null) return [];
    try {
      final response = await http.get(Uri.parse('$baseUrl/loyalty/$userId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Cartão de Fidelidade"),
        backgroundColor: const Color(0xFF121212),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.gold),
            tooltip: 'Atualizar',
            onPressed: loadLoyalty,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _loyaltyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }

          final cards = snapshot.data ?? [];

          if (cards.isEmpty) {
            return RefreshIndicator(
              color: AppColors.gold,
              onRefresh: () async => loadLoyalty(),
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.card_giftcard, size: 60, color: Colors.grey[800]),
                        const SizedBox(height: 20),
                        const Text(
                          "Ainda não tens carimbos acumulados.\nConclui um corte para começar!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.gold,
            onRefresh: () async => loadLoyalty(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                final stamps = card['stamps'] ?? 0;
                final maxStamps = card['max_stamps'] ?? 10;
                final reward = card['reward_text'] ?? '1 Corte Grátis no 10º carimbo';
                final shopName = card['shop_name'] ?? 'Barbearia';
                final colorHex = int.tryParse(card['color_hex']?.toString() ?? '') ?? 0xFFFFD700;
                final cardColor = Color(colorHex);

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardColor.withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: cardColor.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            shopName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: cardColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "$stamps / $maxStamps",
                              style: TextStyle(color: cardColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text("Recompensa: $reward", style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                      const SizedBox(height: 20),

                      // GRELHA DE CARIMBOS
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(maxStamps, (i) {
                          final isEarned = i < stamps;
                          return Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isEarned ? cardColor : Colors.black26,
                              border: Border.all(
                                color: isEarned ? cardColor : Colors.white24,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              isEarned ? Icons.content_cut : Icons.lock_outline,
                              color: isEarned ? Colors.black : Colors.grey[600],
                              size: 20,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1, end: 0);
              },
            ),
          );
        },
      ),
    );
  }
}