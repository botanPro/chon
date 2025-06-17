import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';
import 'services/navigation_service.dart';
import 'layouts/main_layout.dart';

/// Application-wide design tokens for consistent styling
class AppDesign {
  /// Standard spacing unit used throughout the app (8.0)
  static const double spacing = 8.0;

  /// Standard border radius for UI elements (16.0)
  static const double radius = 16.0;

  /// Default animation duration for transitions (300ms)
  static const animationDuration = Duration(milliseconds: 300);

  /// Primary brand color
  static const Color primaryColor = Color(0xFF00B894);

  /// Background color for screens
  static const Color backgroundColor = Color(0xFF090C0B);

  /// Navigation bar color
  static const Color navBarColor = Color(0xFF13131D);

  // Private constructor to prevent instantiation
  AppDesign._();
}

/// Entry point of the application
void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI appearance
  _configureSystemUI();

  // Add error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  // Initialize the app with AuthService as the root provider
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: const MainApp(),
    ),
  );
}

/// Configures the system UI elements like status bar and navigation bar
void _configureSystemUI() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppDesign.navBarColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
}

/// Root application widget that configures the MaterialApp and theme
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the navigation service instance for app-wide navigation
    final navigationService = NavigationService();

    return MaterialApp(
      title: 'Game App',
      debugShowCheckedModeBanner: false,
      theme: _buildAppTheme(),
      // Use the navigation key from our service for programmatic navigation
      navigatorKey: navigationService.navigatorKey,
      initialRoute: '/',
      onGenerateRoute: _generateRoute,
      builder: (context, child) {
        if (child == null) {
          return const SplashScreen();
        }
        return child;
      },
    );
  }

  /// Builds the app-wide theme configuration
  ThemeData _buildAppTheme() {
    return ThemeData(
      primaryColor: AppDesign.primaryColor,
      scaffoldBackgroundColor: AppDesign.backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppDesign.primaryColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    );
  }

  /// Generates routes based on route name
  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => Consumer<AuthService>(
            builder: (context, authService, _) {
              return authService.isAuthenticated
                  ? const AppNavigator()
                  : const AuthScreen();
            },
          ),
        );
      case '/home':
        return MaterialPageRoute(builder: (_) => const AppNavigator());
      case '/auth':
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

/// A simple splash screen to show while the app is initializing
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'CHON',
              style: TextStyle(
                color: AppDesign.primaryColor,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppDesign.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// A stateful widget that handles the navigation between different screens
/// using the bottom navigation bar.
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  // Get the navigation service instance for managing tab navigation
  final NavigationService _navigationService = NavigationService();

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body:
          _navigationService.getScreenForIndex(_navigationService.currentIndex),
      currentIndex: _navigationService.currentIndex,
      onNavigationTap: _handleNavigation,
    );
  }

  /// Handles navigation between bottom tabs
  void _handleNavigation(int index) {
    setState(() {
      _navigationService.navigateToTabIndex(index);
    });
  }
}
