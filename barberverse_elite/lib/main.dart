import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; // <--- IMPORT NOVO (CRÍTICO)

import 'config/theme.dart';
import 'providers/app_provider.dart';

// Ecrãs
import 'screens/login_screen.dart';
import 'screens/client_home_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/loyalty_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/shop_edit_screen.dart';
import 'screens/admin/service_manage_screen.dart';
import 'screens/worker_dashboard.dart'; // Import novo

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializa a Base de Dados
  await Hive.initFlutter();

  // 2. Inicializa a Formatação de Datas (CORREÇÃO DO ERRO)
  await initializeDateFormatting();

  runApp(
    MultiProvider(
      providers: [
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
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      home: const LoginScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/client_home': (context) => const ClientHomeScreen(),
        '/shop_details': (context) => const ShopScreen(),
        '/booking': (context) => const BookingScreen(),
        '/loyalty': (context) => const LoyaltyScreen(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/shop_edit': (context) => const ShopEditScreen(),
        '/services_manage': (context) => const ServiceManageScreen(),
        '/worker_dashboard': (context) => const WorkerDashboard(),
      },
    );
  }
}