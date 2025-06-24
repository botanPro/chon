import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../main.dart';

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
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              backgroundColor: AppDesign.navBarColor,
              selectedItemColor: AppDesign.primaryColor,
              unselectedItemColor: Colors.white.withOpacity(0.5),
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
                _buildNavItem(
                    Icons.home_outlined, Icons.home_rounded, 'Home', 0),
                _buildNavItem(
                    Icons.explore_outlined, Icons.explore, 'Explore', 1),
                _buildLogoNavItem(),
                _buildNavItem(Icons.notifications_outlined,
                    Icons.notifications_rounded, 'Alerts', 3),
                _buildNavItem(Icons.person_outline_rounded,
                    Icons.person_rounded, 'Profile', 4),
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
        padding: const EdgeInsets.only(bottom: 4, top: 8),
        child: Icon(
          index == currentIndex ? activeIcon : icon,
          size: index == currentIndex ? 28 : 26,
          color: index == currentIndex
              ? AppDesign.primaryColor
              : Colors.white.withOpacity(0.5),
        ),
      ),
      label: label,
    );
  }

  BottomNavigationBarItem _buildLogoNavItem() {
    return BottomNavigationBarItem(
      icon: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(bottom: 4, top: 2),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppDesign.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            // Button background
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppDesign.primaryColor,
                    AppDesign.accentColor,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
            // Logo
            ClipOval(
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: LogoSpinAnimation(
                    child: Image.asset(
                      'assets/images/chon.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text(
                          'CHON',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Color(0x4D000000),
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
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

/// A widget that adds a periodic spinning animation to its child
class LogoSpinAnimation extends StatefulWidget {
  final Widget child;

  const LogoSpinAnimation({
    super.key,
    required this.child,
  });

  @override
  State<LogoSpinAnimation> createState() => _LogoSpinAnimationState();
}

class _LogoSpinAnimationState extends State<LogoSpinAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Create animation controller with a longer duration for a smoother spin
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create a curved animation
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    // Add listener to restart the animation
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Wait a bit before starting the next spin
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted) {
            _controller.reset();
            _controller.forward();
          }
        });
      }
    });

    // Start the animation after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * math.pi,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
