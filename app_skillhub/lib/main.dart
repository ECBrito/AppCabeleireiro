import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'config/theme.dart';
import 'firebase_options.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';

// Ecrãs Principais e Autenticação
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/client_home_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/loyalty_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/worker_dashboard_screen.dart';
import 'screens/profile_screen.dart';

// Ecrãs de Gestão / Admin
import 'screens/admin_dashboard.dart';
import 'screens/shop_edit_screen.dart';
import 'screens/admin/service_manage_screen.dart';
import 'screens/admin/workers_manage_screen.dart';
import 'screens/admin/customer_manage_screen.dart';
import 'screens/admin/promotion_manage_screen.dart';
import 'screens/admin/schedule_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await initializeDateFormatting('pt_PT', null);
// 1. Obrigatório antes de qualquer plugin assíncrono
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializar o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
            );
          }

          if (auth.isLoggedIn) {
            if (auth.isOwner) {
              return const AdminDashboard();
            } else {
              return const ClientHomeScreen();
            }
          }

          return const LoginScreen();
        },
      ),

      routes: {
        // Autenticação e Cliente
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/client_home': (context) => const ClientHomeScreen(),
        '/shop_details': (context) => const ShopScreen(),
        '/booking': (context) => const BookingScreen(),
        '/loyalty': (context) => const LoyaltyScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/appointments': (context) => const AppointmentsScreen(),
        '/worker_dashboard': (context) => const WorkerDashboardScreen(),

        // Administração e Gestão
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/shop_edit': (context) => const ShopEditScreen(),
        '/services_manage': (context) => const ServiceManageScreen(),
        '/workers_manage': (context) => const WorkersManageScreen(),
        '/customers_manage': (context) => const CustomerManageScreen(),
        '/promotions_manage': (context) => const PromotionManageScreen(),
        '/schedule_manage': (context) => const ScheduleScreen(),
      },
    );
  }
}