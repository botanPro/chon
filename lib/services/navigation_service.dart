import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
// Import other screens as needed

/// A service that handles navigation between screens in the application.
/// This provides a centralized place to manage navigation logic.
class NavigationService {
  /// Singleton instance
  static final NavigationService _instance = NavigationService._internal();

  /// Factory constructor to return the singleton instance
  factory NavigationService() => _instance;

  /// Private constructor for singleton pattern
  NavigationService._internal();

  /// Global navigation key to use for navigation without context
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Current selected index in the bottom navigation bar
  int _currentIndex = 0;

  /// Getter for current index
  int get currentIndex => _currentIndex;

  /// Reset navigation state (used when logging out)
  void resetNavigation() {
    _currentIndex = 0;
  }

  /// Navigate to a named route
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  /// Replace the current route with a named route
  Future<dynamic> navigateToReplacement(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Navigate to a screen based on the bottom navigation bar index
  void navigateToTabIndex(int index) {
    _currentIndex = index;

    // Use navigatorKey to navigate without context if needed
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Navigate to the appropriate screen based on index
    switch (index) {
      case 0:
        // Already on home screen, no need to navigate
        break;
      case 1:
        // History screen
        break;
      case 2:
        // Create screen
        break;
      case 3:
        // Profile screen
        // navigateTo('/profile');
        break;
    }
  }

  /// Get the appropriate screen widget based on the current tab index
  Widget getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        // return const HistoryScreen();
        return const Placeholder(child: Center(child: Text('History Screen')));
      case 2:
        // return const CreateScreen();
        return const Placeholder(child: Center(child: Text('Create Screen')));
      case 3:
        // return const ProfileScreen();
        return const Placeholder(child: Center(child: Text('Profile Screen')));
      default:
        return const HomeScreen();
    }
  }
}
