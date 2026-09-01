import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

// Ecrãs
import 'client_home_screen.dart'; // O "Shopping" (Lista)
import 'shop_screen.dart';        // A "Loja" (Individual)
import 'appointments_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final themeColor = provider.getThemeColor();

    // LÓGICA DE DECISÃO (AQUI ESTÁ O SEGREDO):
    // Se o cliente já se vinculou a uma loja, a "Home" é a Loja.
    // Se não, a "Home" é a Lista de Lojas (Shopping).
    Widget homeWidget;
    if (provider.isLinked) {
      homeWidget = const ShopScreen(isHomeMode: true); // Modo "Home da App"
    } else {
      homeWidget = const ClientHomeScreen(); // Modo "Procurar Loja"
    }

    // Lista de Ecrãs para a navegação
    final List<Widget> screens = [
      homeWidget,                 // Index 0: Dinâmico (Loja ou Lista)
      const AppointmentsScreen(), // Index 1: Agenda
      const ProfileScreen(),      // Index 2: Perfil
    ];

    return Scaffold(
      body: screens[_currentIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF121212),
          selectedItemColor: themeColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              // O ícone também muda para dar feedback
              icon: Icon(provider.isLinked ? Icons.store : Icons.hub_outlined),
              activeIcon: Icon(provider.isLinked ? Icons.store : Icons.hub),
              label: 'Início',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Agenda',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}