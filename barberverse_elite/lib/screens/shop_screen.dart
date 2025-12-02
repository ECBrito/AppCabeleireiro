import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart'; // Import essencial para as fontes
import '../providers/app_provider.dart';
import '../models/service_model.dart';
import '../config/theme.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Obtém os dados e a cor da loja selecionada do Provider
    final provider = Provider.of<AppProvider>(context);
    final shop = provider.currentShop;
    final themeColor = provider.getThemeColor();

    // Se por acaso não houver loja selecionada (erro), mostra loading
    if (shop == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Cabeçalho que estica com a imagem (SliverAppBar)
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true, // Mantém a barra no topo ao fazer scroll
            backgroundColor: AppColors.background,
            iconTheme: IconThemeData(color: themeColor), // Seta de voltar na cor da loja
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                shop.name,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [const Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagem de fundo da loja
                  Image.network(
                    shop.image,
                    fit: BoxFit.cover,
                    errorBuilder: (c,e,s) => Container(color: Colors.grey[900]),
                  ),
                  // Gradiente escuro para o texto se ler bem
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Conteúdo da Loja
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating / Avaliação
                  Row(
                    children: [
                      Icon(Icons.star, color: themeColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "${shop.rating} • Excelente",
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Título da Lista
                  Text("Serviços", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // Lista de Serviços (Preços)
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final service = mockServices[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeColor.withOpacity(0.3)), // Borda na cor da loja
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                        service.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                    subtitle: Text(
                        "${service.durationMinutes} min",
                        style: TextStyle(color: Colors.grey[400])
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${service.price.toStringAsFixed(2)}€",
                        style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    onTap: () {
                      // Feedback visual ao clicar num serviço
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Selecionaste: ${service.name}"),
                          backgroundColor: themeColor,
                          duration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                  ),
                ).animate().fadeIn(delay: (100 * index).ms).slideX();
              },
              childCount: mockServices.length,
            ),
          ),

          // Espaço extra no fundo para o botão não tapar o último item
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // Botão Flutuante para Marcar (Leva ao ecrã de Booking)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegar para o agendamento
          Navigator.pushNamed(context, '/booking');
        },
        backgroundColor: themeColor,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.calendar_month),
        label: const Text("MARCAR AGORA", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}