import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  static const String baseUrl = 'http://10.0.2.2:3000';
  late Future<List<dynamic>> _loyaltyFuture;

  @override
  void initState() {
    super.initState();
    _loadLoyalty();
  }

  void _loadLoyalty() {
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
    final appProvider = Provider.of<AppProvider>(context);
    final themeColor = appProvider.getThemeColor();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Cartão de Fidelidade"),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: themeColor),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _loyaltyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: themeColor));
          }

          final cards = snapshot.data ?? [];

          if (cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard, size: 60, color: Colors.grey[800]),
                  const SizedBox(height: 20),
                  const Text("Ainda não tens carimbos acumulados.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: themeColor,
            onRefresh: () async => _loadLoyalty(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                final stamps = card['stamps'] ?? 0;
                final maxStamps = card['max_stamps'] ?? 10;
                final reward = card['reward_text'] ?? 'Recompensa especial';
                final shopName = card['shop_name'] ?? 'Barbearia';
                final cardColor = Color(int.tryParse(card['color_hex']?.toString() ?? '') ?? 0xFFFFD700);

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardColor.withOpacity(0.4)),
                    boxShadow: [
                      BoxShadow(color: cardColor.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
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
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: cardColor.withOpacity(0.2),
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
                            width: 50,
                            height: 50,
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
                              size: 22,
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