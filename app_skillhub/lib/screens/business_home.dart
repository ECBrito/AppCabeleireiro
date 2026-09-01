import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart'; // Importante para o 'auth'
import 'auth_screen.dart';

class BusinessHome extends StatelessWidget {
  const BusinessHome({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    // 1. DEFINIR 'AUTH' AQUI EM CIMA PARA ESTAR DISPONÍVEL NO ECRÃ TODO
    final auth = Provider.of<AuthProvider>(context); 
    
    final biz = provider.activeBusiness;
    final color = provider.getThemeColor();

    if (biz == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => provider.unlinkBusiness(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER COM IMAGEM
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Image.network(
                biz.coverImage, 
                height: 350, 
                width: double.infinity, 
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: 0.2),
                colorBlendMode: BlendMode.darken,
                errorBuilder: (c, e, s) => Container(height: 350, color: Colors.grey[900]),
              ),
              Container(
                height: 350,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color, 
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text(
                        biz.type.name.toUpperCase(),
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      biz.name,
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white, 
                        fontSize: 36, 
                        fontWeight: FontWeight.bold,
                        height: 1.0
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(biz.address, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(width: 15),
                        Icon(Icons.star, color: color, size: 14),
                        const SizedBox(width: 4),
                        Text(biz.rating.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // CONTEÚDO
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFF121212)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    biz.welcomeMessage,
                    style: const TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
                  ),
                  const Spacer(),
                  
                  // BOTÃO DE AÇÃO INTELIGENTE
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // AQUI JÁ PODEMOS USAR 'auth' PORQUE FOI DEFINIDO NO TOPO
                        if (auth.isLoggedIn) {
                           if (auth.isOwner) {
                             Navigator.pushNamed(context, '/admin_dashboard');
                           } else {
                             Navigator.pushNamed(context, '/client_home'); 
                           }
                        } else {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => AuthScreen(
                              onSuccess: () {
                                final updatedAuth = Provider.of<AuthProvider>(context, listen: false);
                                if (updatedAuth.isOwner) {
                                   Navigator.pushReplacementNamed(context, '/admin_dashboard');
                                } else {
                                   Navigator.pushReplacementNamed(context, '/client_home');
                                }
                              }
                            ))
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 10,
                        shadowColor: color.withValues(alpha: 0.4),
                      ),
                      icon: Icon(auth.isLoggedIn && auth.isOwner ? Icons.dashboard : Icons.calendar_month),
                      
                      // AQUI ESTAVA O ERRO: Agora o 'auth' é reconhecido
                      label: Text(
                        auth.isLoggedIn && auth.isOwner ? "GERIR A MINHA LOJA" : biz.bookingActionLabel, 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}