import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';

class LandingPageWeb extends StatefulWidget {
  const LandingPageWeb({super.key});

  @override
  State<LandingPageWeb> createState() => _LandingPageWebState();
}

class _LandingPageWebState extends State<LandingPageWeb> {
  // Controladores para o Scroll Suave
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  // Função para fazer scroll até à secção
  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      
      // NAVBAR FIXA
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 80),
        child: _GlassNavBar(
          isDesktop: isDesktop,
          onFeaturesTap: () => _scrollTo(_featuresKey),
          onPricingTap: () => _scrollTo(_pricingKey),
          onContactTap: () => _scrollTo(_contactKey),
        ),
      ),
      
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // 1. HERO (Capa)
            _buildHeroSection(context, isDesktop),
            
            // 2. SOCIAL PROOF (Logos)
            _buildTrustedBy(),

            // 3. FUNCIONALIDADES
            Container(key: _featuresKey), // Âncora
            _buildFeaturesSection(context, isDesktop),

            // 4. SHOWCASE (O Telemóvel)
            _buildShowcaseSection(context, isDesktop),

            // 5. PREÇOS
            Container(key: _pricingKey), // Âncora
            _buildPricingSection(context, isDesktop),

            // 6. CONTACTO & FOOTER
            Container(key: _contactKey), // Âncora
            _buildContactAndFooter(context, isDesktop),
          ],
        ),
      ),
    );
  }

  // --- SECÇÕES ---

  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    return Container(
      constraints: BoxConstraints(minHeight: isDesktop ? 900 : 700),
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 100 : 20, 
        150, // Padding top para compensar a Navbar
        isDesktop ? 100 : 20, 
        50
      ),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage("https://images.unsplash.com/photo-1634547985446-5c5675c93c4e?q=80&w=2000"),
          fit: BoxFit.cover,
          opacity: 0.2,
        ),
      ),
      child: Flex(
        direction: isDesktop ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: isDesktop ? 5 : 0,
            child: Column(
              crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                _AnimatedBadge(text: "🚀 A Revolução do Agendamento"),
                const SizedBox(height: 20),
                Text(
                  "A Tua Barbearia.\nA Tua App.\nSem Código.",
                  textAlign: isDesktop ? TextAlign.start : TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: isDesktop ? 72 : 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 30),
                Text(
                  "A plataforma All-in-One para barbeiros, tatuadores e spas. Fideliza clientes e gere o teu negócio num só lugar.",
                  textAlign: isDesktop ? TextAlign.start : TextAlign.center,
                  style: GoogleFonts.lato(fontSize: 18, color: Colors.grey[400], height: 1.5),
                ).animate().fadeIn(delay: 200.ms),
                
                const SizedBox(height: 50),
                
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    _GlowButton(
                      text: "COMEÇAR AGORA", 
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      isPrimary: true
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms).scale(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustedBy() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      color: Colors.black,
      child: Column(
        children: [
          Text("MAIS DE 500 NEGÓCIOS USAM SKILLHUB", style: TextStyle(color: Colors.grey[700], letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.content_cut, color: Colors.grey[800], size: 40),
              const SizedBox(width: 40),
              Icon(Icons.brush, color: Colors.grey[800], size: 40),
              const SizedBox(width: 40),
              Icon(Icons.spa, color: Colors.grey[800], size: 40),
              const SizedBox(width: 40),
              Icon(Icons.fitness_center, color: Colors.grey[800], size: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      color: const Color(0xFF0F0F0F),
      child: Column(
        children: [
          const Text("PORQUÊ NÓS?", style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 10),
          Text("Tudo o que precisa para escalar.", style: GoogleFonts.playfairDisplay(fontSize: 40, color: Colors.white)),
          const SizedBox(height: 60),
          
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _FeatureCard(icon: Icons.palette, title: "Design Camaleão", desc: "A app adapta-se à cor da sua marca automaticamente.", width: isDesktop ? 350 : double.infinity),
              _FeatureCard(icon: Icons.calendar_month, title: "Gestão Inteligente", desc: "Agenda sincronizada em tempo real com o seu staff.", width: isDesktop ? 350 : double.infinity),
              _FeatureCard(icon: Icons.loyalty, title: "Fidelização", desc: "Cartões digitais que mantêm os clientes a voltar.", width: isDesktop ? 350 : double.infinity),
              _FeatureCard(icon: Icons.analytics, title: "Analytics", desc: "Saiba exatamente quanto faturou hoje.", width: isDesktop ? 350 : double.infinity),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShowcaseSection(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      color: Colors.black,
      child: Column(
        children: [
          Text("App do Cliente & Admin", style: GoogleFonts.playfairDisplay(fontSize: 32, color: Colors.white)),
          const SizedBox(height: 40),
          // Aqui poderias pôr imagens dos ecrãs lado a lado
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MockupScreen(color: AppColors.gold, icon: Icons.content_cut),
              if (isDesktop) const SizedBox(width: 40),
              if (isDesktop) _MockupScreen(color: Colors.blue, icon: Icons.spa),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F0F0F), Color(0xFF1E1E1E)],
        ),
      ),
      child: Column(
        children: [
          Text("Planos Transparentes", style: GoogleFonts.playfairDisplay(fontSize: 40, color: Colors.white)),
          const SizedBox(height: 50),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: const [
              _PricingCard(title: "Starter", price: "0€", features: ["1 Profissional", "App Básica"], isPopular: false),
              _PricingCard(title: "Pro", price: "29€", features: ["5 Profissionais", "Personalização Total", "Sem anúncios"], isPopular: true),
              _PricingCard(title: "Enterprise", price: "99€", features: ["Lojas Ilimitadas", "API Dedicada", "Suporte 24/7"], isPopular: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactAndFooter(BuildContext context, bool isDesktop) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // CONTACT FORM
          Container(
            padding: const EdgeInsets.all(40),
            margin: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 800),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Text("Dúvidas? Fale Connosco.", style: GoogleFonts.playfairDisplay(fontSize: 28, color: Colors.white)),
                const SizedBox(height: 30),
                const TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(hintText: "O seu email", filled: true, fillColor: Colors.black),
                ),
                const SizedBox(height: 15),
                const TextField(
                  maxLines: 3,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(hintText: "A sua mensagem", filled: true, fillColor: Colors.black),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mensagem enviada!")));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, padding: const EdgeInsets.all(20)),
                    child: const Text("ENVIAR MENSAGEM"),
                  ),
                ),
              ],
            ),
          ),

          // FOOTER
          Container(
            padding: const EdgeInsets.all(50),
            decoration: BoxDecoration(
              border: const Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Column(
              children: [
                const Icon(Icons.content_cut, color: AppColors.gold, size: 40),
                const SizedBox(height: 20),
                Text("SkillHub", style: GoogleFonts.playfairDisplay(fontSize: 24, color: Colors.white)),
                const SizedBox(height: 10),
                const Text("Feito com ❤️ em Portugal.", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(onPressed: (){}, child: const Text("Termos", style: TextStyle(color: Colors.grey))),
                    const SizedBox(width: 20),
                    TextButton(onPressed: (){}, child: const Text("Privacidade", style: TextStyle(color: Colors.grey))),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- COMPONENTES VISUAIS ---

class _GlassNavBar extends StatelessWidget {
  final bool isDesktop;
  final VoidCallback onFeaturesTap;
  final VoidCallback onPricingTap;
  final VoidCallback onContactTap;

  const _GlassNavBar({
    required this.isDesktop,
    required this.onFeaturesTap,
    required this.onPricingTap,
    required this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.content_cut, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text("SkillHub", style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          if (isDesktop)
            Row(
              children: [
                TextButton(onPressed: onFeaturesTap, child: const Text("Funcionalidades", style: TextStyle(color: Colors.white))),
                TextButton(onPressed: onPricingTap, child: const Text("Preços", style: TextStyle(color: Colors.white))),
                TextButton(onPressed: onContactTap, child: const Text("Contacto", style: TextStyle(color: Colors.white))),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: const StadiumBorder()),
                  child: const Text("Entrar"),
                )
              ],
            ),
        ],
      ),
    );
  }
}

class _GlowButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _GlowButton({required this.text, required this.onPressed, required this.isPrimary});

  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
          decoration: BoxDecoration(
            color: widget.isPrimary ? AppColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.isPrimary ? AppColors.gold : Colors.white24),
            boxShadow: _isHovered && widget.isPrimary
                ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.6), blurRadius: 20, spreadRadius: 2)]
                : [],
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              color: widget.isPrimary ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ).animate(target: _isHovered ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05)),
      ),
    );
  }
}

class _AnimatedBadge extends StatelessWidget {
  final String text;
  const _AnimatedBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
    ).animate().shimmer(duration: 2.seconds, delay: 1.seconds);
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final double width;

  const _FeatureCard({required this.icon, required this.title, required this.desc, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.gold, size: 28),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(desc, style: const TextStyle(color: Colors.grey, height: 1.5)),
        ],
      ),
    );
  }
}

class _PricingCard extends StatefulWidget {
  final String title;
  final String price;
  final List<String> features;
  final bool isPopular;

  const _PricingCard({required this.title, required this.price, required this.features, required this.isPopular});

  @override
  State<_PricingCard> createState() => _PricingCardState();
}

class _PricingCardState extends State<_PricingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 320,
        padding: const EdgeInsets.all(40),
        transform: _isHovered ? Matrix4.translationValues(0, -10, 0) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: widget.isPopular ? Colors.white : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _isHovered ? AppColors.gold : Colors.transparent, width: 2),
          boxShadow: _isHovered 
              ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.2), blurRadius: 30, spreadRadius: 5)] 
              : [],
        ),
        child: Column(
          children: [
            if (widget.isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                child: const Text("MAIS VENDIDO", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            Text(widget.title, style: TextStyle(color: widget.isPopular ? Colors.black : Colors.grey, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text(widget.price, style: TextStyle(color: widget.isPopular ? Colors.black : Colors.white, fontSize: 56, fontWeight: FontWeight.bold)),
            Text("/mês", style: TextStyle(color: widget.isPopular ? Colors.black54 : Colors.grey)),
            const SizedBox(height: 30),
            ...widget.features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: widget.isPopular ? Colors.green : AppColors.gold, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(f, style: TextStyle(color: widget.isPopular ? Colors.black87 : Colors.white70))),
                ],
              ),
            )),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isPopular ? Colors.black : Colors.white10,
                  foregroundColor: Colors.white,
                ),
                child: const Text("ESCOLHER"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChameleonPhoneMockup extends StatefulWidget {
  const _ChameleonPhoneMockup();
  @override
  State<_ChameleonPhoneMockup> createState() => _ChameleonPhoneMockupState();
}

class _ChameleonPhoneMockupState extends State<_ChameleonPhoneMockup> {
  int _index = 0;
  final List<Color> _colors = [AppColors.gold, const Color(0xFF00BFFF), const Color(0xFFE91E63)];
  final List<IconData> _icons = [Icons.content_cut, Icons.spa, Icons.brush];
  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) setState(() => _index = (_index + 1) % _colors.length);
    });
  }
  @override
  Widget build(BuildContext context) {
    final color = _colors[_index];
    final icon = _icons[_index];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      width: 300, height: 600,
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFF333333), width: 8),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 50, spreadRadius: 10)],
      ),
      child: Center(child: Icon(icon, size: 80, color: color)),
    );
  }
}

class _MockupScreen extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _MockupScreen({required this.color, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, height: 400,
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Center(child: Icon(icon, size: 50, color: color)),
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground();
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.black);
  }
}