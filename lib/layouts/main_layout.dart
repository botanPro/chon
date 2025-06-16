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
      extendBody: true, // Make the body extend behind the navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              backgroundColor: const Color(0xFF101513),
              selectedItemColor: const Color(0xFF00B894),
              unselectedItemColor: const Color(0xFF8E8E8E),
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
              ),
              elevation: 0,
              items: [
                _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
                _buildNavItem(
                    Icons.history_outlined, Icons.history, 'History', 1),
                _buildLogoNavItem(),
                _buildNavItem(Icons.notifications_outlined, Icons.notifications,
                    'Notifications', 3),
                _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 4),
              ],
              currentIndex: currentIndex,
              onTap: onNavigationTap ?? _handleNavigation,
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, IconData activeIcon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(
          index == currentIndex ? activeIcon : icon,
          size: index == currentIndex ? 28 : 26,
          color: index == currentIndex
              ? const Color(0xFF00B894)
              : const Color(0xFF8E8E8E),
        ),
      ),
      label: label,
    );
  }

  BottomNavigationBarItem _buildLogoNavItem() {
    return BottomNavigationBarItem(
      icon: Container(
        height: 60,
        width: 60,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF101513),
          border: Border.all(
            color: const Color(0xFF00B894),
            width: 2,
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Color(0xFF00B894), Color(0xFF008066)],
              center: Alignment(0.0, 0.0),
              focal: Alignment(0.0, 0.0),
              radius: 0.8,
            ),
          ),
          child: Center(
            child: Text(
              'chon',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    blurRadius: 4.0,
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      label: '',
    );
  }

  /// Default navigation handler if no custom handler is provided.
  void _handleNavigation(int index) {
    // This can be expanded to include default navigation logic
    // For now, it's a placeholder for the default behavior
    debugPrint('Navigation to index: $index');
  }
}
