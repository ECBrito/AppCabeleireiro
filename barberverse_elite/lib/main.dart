import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Gestão de estado
import 'package:hive_flutter/hive_flutter.dart'; // Base de dados local

// Configuração e Tema
import 'config/theme.dart';
import 'providers/app_provider.dart';

// Ecrãs (Screens)
import 'screens/login_screen.dart';
import 'screens/client_home_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/loyalty_screen.dart'; // <--- CAMINHO CORRIGIDO (screens/...)
import 'screens/admin_dashboard.dart';
import 'screens/shop_edit_screen.dart';

void main() async {
  // 1. Inicialização obrigatória para Plugins
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa o Hive (Base de Dados)
  await Hive.initFlutter();

  // 3. Arranca a App envolvida no Provider
  runApp(
    MultiProvider(
      providers: [
        // O AppProvider fica disponível para toda a app (para o efeito Camaleão)
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const BarberVerseApp(),
    ),
  );
}

class BarberVerseApp extends StatelessWidget {
  const BarberVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BarberVerse Elite',
      debugShowCheckedModeBanner: false, // Remove a etiqueta "Debug"

      // Aplica o tema Midnight Gold que definimos
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Define o Login como o primeiro ecrã
      home: const LoginScreen(),

      // Mapa de Rotas (Navegação)
      routes: {
        '/login': (context) => const LoginScreen(),

        // Rotas do Cliente
        '/client_home': (context) => const ClientHomeScreen(),
        '/shop_details': (context) => const ShopScreen(),
        '/booking': (context) => const BookingScreen(),
        '/loyalty': (context) => const LoyaltyScreen(), // Nova rota da carteira

        // Rotas do Admin
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/shop_edit': (context) => const ShopEditScreen(),
      },
    );
  }
}