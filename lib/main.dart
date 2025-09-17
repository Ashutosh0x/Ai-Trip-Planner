import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'screens/splash_screen.dart';
import 'dart:io' show Platform;
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/trips_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/trip_planning_screen.dart';
import 'screens/saved_trips_screen.dart';
import 'screens/ai_picks_screen.dart';
import 'screens/search_screen.dart';
import 'screens/trip_preferences_screen.dart';
import 'screens/budget_preferences_screen.dart';
import 'screens/start_riding_screen.dart';
import 'screens/confirm_pay_screen.dart';
import 'screens/secure_confirm_pay_screen.dart';
import 'screens/saved_payment_methods_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/billing_history_screen.dart';
import 'screens/payment_methods_screen.dart';
import 'screens/new_event_screen.dart';
import 'services/firebase_service.dart';
import 'services/theme_service.dart';
import 'services/payments_service.dart';
import 'services/secure_payment_service.dart';
import 'services/notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Firebase
  await FirebaseService.initialize();

  // Initialize Notifications (FCM + local)
  await NotificationsService.instance.initialize();

  // Stripe will be initialised lazily inside payment screens to avoid startup crashes

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('de'),
        Locale('hi'),
        Locale('ar'),
        Locale('pt'),
        Locale('ru'),
        Locale('ja'),
        Locale('zh'),
        Locale('it'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: ChangeNotifierProvider(
        create: (context) => ThemeService()..loadTheme(),
        child: const AITripPlannerApp(),
      ),
    ),
  );
}

class AITripPlannerApp extends StatelessWidget {
  const AITripPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        const String backendBaseUrl = String.fromEnvironment(
          'BACKEND_BASE_URL',
          defaultValue: '',
        );
        final PaymentsService paymentsService = PaymentsService(
          backendBaseUrl: backendBaseUrl,
        );

        return MaterialApp(
          title: 'AI Trip Planner',
          debugShowCheckedModeBanner: false,
          navigatorKey: NotificationsService.instance.navigatorKey,
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4ECDC4),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.dosisTextTheme(),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4ECDC4),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.dosisTextTheme(ThemeData.dark().textTheme),
          ),
          themeMode: themeService.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/home': (context) => const HomeScreen(),
            '/explore': (context) => const ExploreScreen(),
            '/trips': (context) => const TripsScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/edit-profile': (context) => const EditProfileScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/trip-planning': (context) => const TripPlanningScreen(),
            '/saved-trips': (context) => const SavedTripsScreen(),
            '/ai-picks': (context) => const AIPicksScreen(),
            '/trip-preferences': (context) => const TripPreferencesScreen(),
            '/budget-preferences': (context) => const BudgetPreferencesScreen(),
            '/start-riding': (context) => const StartRidingScreen(),
            '/confirm-pay': (context) => const SecureConfirmPayScreen(),
            '/saved-payment-methods': (context) => const SavedPaymentMethodsScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/billing-history': (context) =>
                BillingHistoryScreen(paymentsService: paymentsService),
            '/payment-methods': (context) =>
                PaymentMethodsScreen(paymentsService: paymentsService),
            '/new-event': (context) => const NewEventScreen(),
            '/search': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as String;
              return SearchScreen(query: args);
            },
          },
        );
      },
    );
  }
}
