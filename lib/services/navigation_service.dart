import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/transaction_history_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/notifications_screen.dart';
// Import other screens as needed

/// A service that handles navigation between screens in the application.
/// This provides a centralized place to manage navigation logic and state.
///
/// Uses the singleton pattern to ensure only one instance exists throughout the app.
class NavigationService {
  /// Singleton instance
  static final NavigationService _instance = NavigationService._internal();

  /// Factory constructor to return the singleton instance
  factory NavigationService() => _instance;

  /// Private constructor for singleton pattern
  NavigationService._internal();

  /// Global navigation key to use for navigation without context
  /// This allows navigation from anywhere in the app without needing a BuildContext
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Current selected index in the bottom navigation bar
  int _currentIndex = 0;

  /// Getter for current index
  int get currentIndex => _currentIndex;

  /// Navigation tab indices
  /// Using named constants for better code readability and maintenance
  static const int homeTab = 0;
  static const int historyTab = 1;
  static const int centerTab = 2;
  // static const int notificationsTab = 3; // Commented out notifications tab
  static const int profileTab =
      3; // Updated from 4 to 3 since notifications was removed

  /// Reset navigation state (used when logging out)
  /// This ensures the app returns to the home tab when a user logs out
  void resetNavigation() {
    _currentIndex = homeTab;
  }

  /// Navigate to a named route
  ///
  /// [routeName] The name of the route to navigate to
  /// [arguments] Optional arguments to pass to the route
  ///
  /// Returns a Future that completes when the navigation is done
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  /// Replace the current route with a named route
  ///
  /// [routeName] The name of the route to navigate to
  /// [arguments] Optional arguments to pass to the route
  ///
  /// Returns a Future that completes when the navigation is done
  Future<dynamic> navigateToReplacement(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Navigate back to the previous screen
  ///
  /// [result] Optional result to pass back to the previous screen
  ///
  /// Returns true if navigation was successful, false otherwise
  bool goBack<T extends Object?>([T? result]) {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop(result);
      return true;
    }
    return false;
  }

  /// Navigate to a screen based on the bottom navigation bar index
  ///
  /// [index] The index of the tab to navigate to
  void navigateToTabIndex(int index) {
    // Update the current index
    _currentIndex = index;

    // Use navigatorKey to navigate without context if needed
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Additional navigation logic can be added here if needed
    // For example, clearing the navigation stack when switching tabs
    switch (index) {
      case homeTab:
        // Already on home screen, no need to navigate
        break;
      case historyTab:
        // History screen logic if needed
        break;
      case centerTab:
        // Center logo - special handling if needed
        break;
      case profileTab:
        // Profile screen logic if needed
        break;
    }
  }

  /// Get the appropriate screen widget based on the current tab index
  ///
  /// [index] The index of the tab to get the screen for
  ///
  /// Returns the Widget for the specified tab index
  Widget getScreenForIndex(int index) {
    switch (index) {
      case homeTab:
        return const HomeScreen();
      case historyTab:
        return const TransactionHistoryScreen();
      case centerTab:
        // Center logo - return to home
        return const HomeScreen();
      case profileTab:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }
}
