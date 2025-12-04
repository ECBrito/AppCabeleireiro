import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'config/theme.dart';
import 'providers/app_provider.dart';

// Importa os ecrãs (Garante que estes ficheiros existem!)
import 'screens/link_screen.dart';
import 'screens/main_shell.dart';
import 'screens/login_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/loyalty_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/shop_edit_screen.dart';
import 'screens/admin/service_manage_screen.dart';
import 'screens/web/landing_page_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await initializeDateFormatting();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppProvider())],
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
      
      // Lógica Web vs Mobile
      home: kIsWeb 
          ? const LandingPageWeb() 
          : const AppEntryPoint(),
      
      routes: {
        '/login': (context) => const LoginScreen(),
        '/landing': (context) => const LandingPageWeb(),
        // REMOVIDO O 'CONST' PARA EVITAR ERROS SE OS ECRÃS NÃO FOREM CONSTANTES
        '/client_home': (context) => const MainShell(), 
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

class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLinked) {
          return const MainShell();
        } else {
          return const LinkScreen();
        }
      },
    );
  }
}