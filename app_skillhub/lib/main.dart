import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'config/theme.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';

// Ecrãs
import 'screens/login_screen.dart';
import 'screens/client_home_screen.dart'; // Contém a Home do Cliente com Abas
import 'screens/shop_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/loyalty_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/shop_edit_screen.dart';
import 'screens/admin/service_manage_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await initializeDateFormatting();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const SkillHubApp(),
    ),
  );
}

class SkillHubApp extends StatelessWidget {
  const SkillHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // MUDANÇA: Começa sempre pelo Login (ou verifica token no futuro)
      home: const LoginScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),

        // Rota do Cliente (Abre a Shell com a Lista de Lojas)
        '/client_home': (context) => const ClientHomeScreen(),

        '/shop_details': (context) => const ShopScreen(),
        '/booking': (context) => const BookingScreen(),
        '/loyalty': (context) => const LoyaltyScreen(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/shop_edit': (context) => const ShopEditScreen(),
        '/services_manage': (context) => const ServiceManageScreen(),
      },
    );
  }
}