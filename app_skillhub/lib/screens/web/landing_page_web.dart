import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../config/theme.dart';

class LandingPageWeb extends StatefulWidget {
  const LandingPageWeb({super.key});

  @override
  State<LandingPageWeb> createState() => _LandingPageWebState();
}

class _LandingPageWebState extends State<LandingPageWeb> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    // Efeito Parallax simples: ouvir o scroll
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      // NAVBAR FLUTUANTE (GLASSMORPHISM)
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 80),
        child: _GlassNavBar(isDesktop: isDesktop),
      ),
      body: Stack(
        children: [
          // BACKGROUND ANIMADO (Aurora)
          Positioned.fill(
            child: const _AnimatedBackground(),
          ),

          // CONTEÚDO COM SCROLL
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildHeroSection(context, isDesktop),
                _buildStatsTicker(isDesktop),
                _buildFeaturesSection(context, isDesktop),
                _buildShowcaseSection(context, isDesktop),
                _buildPricingSection(context, isDesktop),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SECÇÃO 1: HERO (O Impacto) ---
  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    return Container(
      constraints: BoxConstraints(minHeight: isDesktop ? 900 : 700),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 20, vertical: 120),
      child: Flex(
        direction: isDesktop ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // TEXTO
          Expanded(
            flex: isDesktop ? 5 : 0,
            child: Column(
              crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                _AnimatedBadge(text: "NOVO: Versão Enterprise Disponível"),
                const SizedBox(height: 20),
                Text(
                  "A App que se\ntransforma no\nteu negócio.",
                  textAlign: isDesktop ? TextAlign.start : TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: isDesktop ? 72 : 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                    shadows: [
                      Shadow(color: AppColors.gold.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 0))
                    ]
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 30),
                Text(
                  "Barbeiros. Tatuadores. Spas.\nCrie a sua aplicação móvel premium em minutos, sem código.",
                  textAlign: isDesktop ? TextAlign.start : TextAlign.center,
                  style: GoogleFonts.lato(fontSize: 18, color: Colors.grey[400], height: 1.5),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 50),
                
                // BOTÕES DE AÇÃO
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
                    _GlowButton(
                      text: "VER DEMO", 
                      onPressed: () {},
                      isPrimary: false
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms).scale(),
              ],
            ),
          ),
          
          if (isDesktop) const SizedBox(width: 50),

          // TELEMÓVEL 3D (MOCKUP ANIMADO)
          Expanded(
            flex: isDesktop ? 4 : 0,
            child: const _ChameleonPhoneMockup()
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -20, duration: 3.seconds, curve: Curves.easeInOut), // Efeito de levitação
          ),
        ],
      ),
    );
  }

  // --- SECÇÃO 2: NÚMEROS (Social Proof) ---
  Widget _buildStatsTicker(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: Colors.white.withOpacity(0.1))),
        color: Colors.black.withOpacity(0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("10k+", "Downloads"),
          _buildStatItem("500+", "Negócios"),
          _buildStatItem("4.9", "Avaliação Média"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.gold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5)),
      ],
    ).animate().fadeIn();
  }

  // --- SECÇÃO 3: FEATURES (Bento Grid) ---
  Widget _buildFeaturesSection(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      child: Column(
        children: [
          Text("Poder Ilimitado", style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, letterSpacing: 2)),
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

  // --- SECÇÃO 4: SHOWCASE (Imagens grandes) ---
  Widget _buildShowcaseSection(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100),
      width: double.infinity,
      child: Column(
        children: [
          // Imagem grande com efeito de vidro
          Container(
            width: isDesktop ? 1000 : double.infinity,
            height: 500,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1503951914875-452162b7f30a?q=80&w=1200'),
                fit: BoxFit.cover,
              ),
              boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.2), blurRadius: 50, spreadRadius: -10)],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(40),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("BarberVerse para Profissionais", style: GoogleFonts.playfairDisplay(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Faça a gestão da sua equipa num único painel intuitivo.", style: TextStyle(color: Colors.white70, fontSize: 18)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SECÇÃO 5: PREÇOS ---
  Widget _buildPricingSection(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, AppColors.surface],
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
            children: [
              _PricingCard(title: "Starter", price: "0€", features: const ["1 Profissional", "App Básica"], isPopular: false),
              _PricingCard(title: "Pro", price: "29€", features: const ["5 Profissionais", "Personalização Total", "Sem anúncios"], isPopular: true),
              _PricingCard(title: "Enterprise", price: "99€", features: const ["Lojas Ilimitadas", "API Dedicada", "Suporte 24/7"], isPopular: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(50),
      color: Colors.black,
      child: Column(
        children: [
          const Icon(Icons.content_cut, color: AppColors.gold, size: 40),
          const SizedBox(height: 20),
          Text("SkillHub", style: GoogleFonts.playfairDisplay(fontSize: 24, color: Colors.white)),
          const SizedBox(height: 10),
          const Text("Feito com ❤️ em Portugal.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Termos", style: TextStyle(color: Colors.grey)),
              SizedBox(width: 20),
              Text("Privacidade", style: TextStyle(color: Colors.grey)),
              SizedBox(width: 20),
              Text("Contacto", style: TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}

// --- WIDGETS AUXILIARES (COMPONENTES) ---

class _GlassNavBar extends StatelessWidget {
  final bool isDesktop;
  const _GlassNavBar({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7), // Efeito Vidro
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
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
                _NavButton("Funcionalidades"),
                _NavButton("Preços"),
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

class _NavButton extends StatelessWidget {
  final String text;
  const _NavButton(this.text);
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}

// Botão com Brilho
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
                ? [BoxShadow(color: AppColors.gold.withOpacity(0.6), blurRadius: 20, spreadRadius: 2)]
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
        color: AppColors.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
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
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
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
        decoration: BoxDecoration(
          color: widget.isPopular ? Colors.white : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _isHovered ? AppColors.gold : Colors.transparent, width: 2),
          transform: _isHovered ? Matrix4.translationValues(0, -10, 0) : Matrix4.identity(),
          boxShadow: _isHovered 
              ? [BoxShadow(color: AppColors.gold.withOpacity(0.2), blurRadius: 30, spreadRadius: 5)] 
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
                  Text(f, style: TextStyle(color: widget.isPopular ? Colors.black87 : Colors.white70)),
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

// --- TELEMÓVEL 3D QUE MUDA DE COR (O CAMALEÃO) ---
class _ChameleonPhoneMockup extends StatefulWidget {
  const _ChameleonPhoneMockup();

  @override
  State<_ChameleonPhoneMockup> createState() => _ChameleonPhoneMockupState();
}

class _ChameleonPhoneMockupState extends State<_ChameleonPhoneMockup> {
  int _index = 0;
  final List<Color> _colors = [AppColors.gold, const Color(0xFF00BFFF), const Color(0xFFE91E63)];
  final List<String> _names = ["Barber King", "Zen Spa", "Ink Master"];
  final List<IconData> _icons = [Icons.content_cut, Icons.spa, Icons.brush];

  @override
  void initState() {
    super.initState();
    // Ciclo automático a cada 3 segundos
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() => _index = (_index + 1) % _colors.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = _colors[_index];
    final name = _names[_index];
    final icon = _icons[_index];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      width: 300,
      height: 600,
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFF333333), width: 8),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 50, spreadRadius: 10),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          children: [
            // StatusBar Fake
            Container(height: 30, color: Colors.black, child: const Row(mainAxisAlignment: MainAxisAlignment.end, children: [Icon(Icons.battery_full, color: Colors.white, size: 14), SizedBox(width: 15)])),
            
            // App Header
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              padding: const EdgeInsets.all(20),
              color: color.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(width: 10),
                  Text(name, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            // Conteúdo Simulado da App
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Cartão Fidelidade
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(child: Icon(Icons.qr_code, size: 50, color: Colors.black26)),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildMockBtn(color),
                        const SizedBox(width: 10),
                        _buildMockBtn(Colors.white10),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMockBtn(Color color) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        height: 60,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// --- BACKGROUND COM GRADIENTE ANIMADO ---
class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();
  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0A0A0A),
                Color.lerp(const Color(0xFF0A0A0A), const Color(0xFF1A1A1A), _controller.value)!,
              ],
            ),
          ),
        );
      },
    );
  }
}