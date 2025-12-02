import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dados fictícios de progresso
    const int currentPoints = 750;
    const int maxPoints = 1000;
    const double progress = currentPoints / maxPoints;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Carteira VIP'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // CARTÃO DOURADO (O "Wow" factor)
            Container(
              height: 220,
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gold, AppColors.goldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.diamond, color: Colors.black, size: 30),
                      Text(
                        "NÍVEL PLATINUM",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$currentPoints",
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.black,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        "PONTOS ACUMULADOS",
                        style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // Barra de Progresso dentro do cartão
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Faltam ${maxPoints - currentPoints} para prémio",
                        style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).shimmer(delay: 1000.ms, duration: 1500.ms),

            const SizedBox(height: 40),

            Align(
              alignment: Alignment.centerLeft,
              child: Text("Histórico de Cortes", style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 15),

            // Lista de Histórico
            _buildHistoryItem("Corte Clássico", "Barber King", "Ontem", "+150 pts"),
            _buildHistoryItem("Barba Mestre", "Urban Cuts", "15 Out", "+100 pts"),
            _buildHistoryItem("Combo King", "Barber King", "01 Out", "+300 pts"),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String service, String shop, String date, String points) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold.withOpacity(0.5)),
          ),
          child: const Icon(Icons.content_cut, color: AppColors.gold, size: 20),
        ),
        title: Text(service, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text("$shop • $date", style: TextStyle(color: Colors.grey[500])),
        trailing: Text(
          points,
          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    ).animate().fadeIn().slideX();
  }
}