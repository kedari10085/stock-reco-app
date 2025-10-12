import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/notifications_screen.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'services/stock_price_service.dart';
import 'services/returns_service.dart';
import 'services/revenue_cat_service.dart';
import 'services/push_notification_service.dart';
import 'services/biometric_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Performance optimization: Reduce debug checks in release mode
  if (kDebugMode) {
    debugPrint('🚀 Starting StockReco Pro in debug mode...');
  }
  
  try {
    // Initialize only critical services synchronously
    await Firebase.initializeApp();
    await Hive.initFlutter();
    // Load environment variables safely (avoid crashing on bad encoding)
    try {
    } catch (e) {
      debugPrint('⚠️ .env failed to load: $e');
    }
    
    // Start app immediately for better performance
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeService()),
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => ReturnsService()),
          ChangeNotifierProvider(create: (_) => RevenueCatService()),
          ChangeNotifierProvider(create: (_) => BiometricService()),
        ],
        child: const StockRecoApp(),
      ),
    );
    
    // Initialize non-critical services asynchronously
    _initializeBackgroundServices();
  } catch (e) {
    // Minimal error handling for performance
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Initialization Error'),
                const SizedBox(height: 8),
                Text('$e', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _initializeBackgroundServices() async {
  try {
    debugPrint('Initializing background services...');
    
    // Initialize notification service
    await NotificationService.initialize();
    
    // Initialize StockPriceService singleton
    await StockPriceService().initialize();
    
    // Initialize RevenueCat
    final revenueCatService = RevenueCatService();
    await revenueCatService.initialize();
    
    // Initialize biometric service
    await BiometricService().initialize();
    
    debugPrint('Background services initialized');
  } catch (e) {
    debugPrint('Background services error: $e');
  }
}

class StockRecoApp extends StatelessWidget {
  const StockRecoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final authService = Provider.of<AuthService>(context);

    return MaterialApp(
      title: 'StockReco Pro',
      debugShowCheckedModeBanner: false,
      
      // Localization
      locale: const Locale('en', 'US'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('hi', 'IN'), // Hindi (for future)
      ],
      
      // Theme
      theme: themeService.lightTheme,
      darkTheme: themeService.darkTheme,
      themeMode: themeService.themeMode,
      
      // Navigation
      navigatorKey: PushNotificationService.navigatorKey,
      home: authService.isAuthenticated ? const HomeScreen() : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/subscription': (context) => const SubscriptionScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
    );
  }
}
