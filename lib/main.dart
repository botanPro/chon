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

// Design tokens
const kSpacing = 8.0;
const kRadius = 16.0;
const kAnimationDuration = Duration(milliseconds: 300);

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF13131D),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the navigation service instance
    final navigationService = NavigationService();
    
    return MaterialApp(
      title: 'Game App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF00B894),
        scaffoldBackgroundColor: const Color(0xFF090C0B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00B894),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      // Use the navigation key from our service
      navigatorKey: navigationService.navigatorKey,
      // Define routes
      initialRoute: '/',
      onGenerateRoute: (settings) {
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
      },
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
  // Get the navigation service instance
  final NavigationService _navigationService = NavigationService();
  
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: _navigationService.getScreenForIndex(_navigationService.currentIndex),
      currentIndex: _navigationService.currentIndex,
      onNavigationTap: _handleNavigation,
    );
  }
  
  void _handleNavigation(int index) {
    setState(() {
      _navigationService.navigateToTabIndex(index);
    });
  }
}
