import 'package:flutter/material.dart';

/// A layout widget that provides a consistent structure for the main screens
/// of the application, including the bottom navigation bar.
class MainLayout extends StatelessWidget {
  /// The body content of the screen.
  final Widget body;
  
  /// The currently selected index in the bottom navigation bar.
  final int currentIndex;
  
  /// Optional callback for when a navigation item is tapped.
  final Function(int)? onNavigationTap;

  const MainLayout({
    super.key,
    required this.body,
    required this.currentIndex,
    this.onNavigationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF101513),
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xFF8E8E8E),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 32),
            activeIcon: Icon(Icons.add_circle, size: 32),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: currentIndex,
        onTap: onNavigationTap ?? _handleNavigation,
      ),
    );
  }

  /// Default navigation handler if no custom handler is provided.
  void _handleNavigation(int index) {
    // This can be expanded to include default navigation logic
    // For now, it's a placeholder for the default behavior
    debugPrint('Navigation to index: $index');
  }
} 