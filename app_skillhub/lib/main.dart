import 'package:flutter/foundation.dart' show kIsWeb; // Importante
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'config/theme.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';

// Ecrãs Mobile
import 'screens/link_screen.dart';
import 'screens/client_home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/Appointments_Screen.dart';
import 'screens/loyalty_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/shop_edit_screen.dart';
import 'screens/admin/service_manage_screen.dart';
import 'screens/web/register_web.dart';
import 'screens/admin/setup_wizard.dart';
import 'screens/admin/customer_manage_screen.dart';
import 'screens/admin/promotion_manage_screen.dart'; 
import 'screens/admin/reports_screen.dart';
import 'screens/admin/schedule_screen.dart';
import 'screens/admin/expenses_screen.dart';
import 'screens/booking_screen.dart';

// Ecrã Web
import 'screens/web/landing_page_web.dart';

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
      
      // AQUI ESTÁ A MAGIA:
      // Se estiver no Browser (Chrome) -> Mostra a Landing Page
      // Se estiver no Telemóvel -> Mostra o LinkScreen (código)
      home: kIsWeb 
          ? const LandingPageWeb() 
          : const LinkScreenWrapper(),
      
      routes: {
        '/login': (context) => const LoginScreen(),
        '/landing': (context) => const LandingPageWeb(),
        '/client_home': (context) => const ClientHomeScreen(),
        '/shop_details': (context) => const ShopScreen(),
        '/booking': (context) => const BookingScreen(),
        '/loyalty': (context) => const LoyaltyScreen(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/shop_edit': (context) => const ShopEditScreen(),
        '/services_manage': (context) => const ServiceManageScreen(),
        '/register': (context) => const RegisterWeb(),
        '/setup_wizard': (context) => const SetupWizardScreen(),
        '/customers_manage': (context) => const CustomerManageScreen(),
        '/promotions_manage': (context) => const PromotionManageScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/schedule': (context) => const ScheduleScreen(),
        '/expenses': (context) => const ExpensesScreen(),
      },
    );
  }
}

// Wrapper para decidir se mostra Link ou Loja no telemóvel
class LinkScreenWrapper extends StatelessWidget {
  const LinkScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLinked) {
          return const ClientHomeScreen();
        } else {
          return const LinkScreen();
        }
      },
    );
  }
}