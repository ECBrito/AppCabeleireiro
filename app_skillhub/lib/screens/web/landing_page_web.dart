import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart'; // <--- Importante para AppColors

class LandingPageWeb extends StatelessWidget {
  const LandingPageWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNavBar(context),
            _buildHeroSection(context, isDesktop),
            _buildPricingSection(context, isDesktop),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("SkillHub", style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          Row(
            children: [
              TextButton(onPressed: () {}, child: const Text("Funcionalidades", style: TextStyle(color: Colors.white))),
              const SizedBox(width: 20),
              TextButton(onPressed: () {}, child: const Text("Preços", style: TextStyle(color: Colors.white))),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold, // Corrigido
                  foregroundColor: Colors.black
                ),
                child: const Text("ENTRAR"),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: isDesktop ? 100 : 20),
      child: Column(
        children: [
          Text(
            "A App que se transforma\nno teu negócio.",
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: isDesktop ? 64 : 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Barbeiros, Tatuadores, Spas. Crie a sua aplicação em minutos.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold, // Corrigido
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text("COMEÇAR GRÁTIS"),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: const Color(0xFF0A0A0A),
      child: Column(
        children: [
          Text("Planos Simples", style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 50),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildPriceCard("Starter", "0€", ["1 Profissional", "Até 50 Clientes"], false),
              _buildPriceCard("Pro", "29€", ["5 Profissionais", "Clientes Ilimitados"], true),
              _buildPriceCard("Enterprise", "99€", ["Múltiplas Lojas", "API Dedicada"], false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(String title, String price, List<String> features, bool isHighlighted) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.white : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: isHighlighted ? null : Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: isHighlighted ? Colors.black : Colors.grey, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(price, style: TextStyle(color: isHighlighted ? Colors.black : Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
          const Text("/mês", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isHighlighted ? Colors.black : Colors.white10,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text("Escolher"),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: const BoxDecoration( // CORREÇÃO CRÍTICA AQUI
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: const Center(child: Text("© 2025 SkillHub Technologies.", style: TextStyle(color: Colors.grey))),
    );
  }
}