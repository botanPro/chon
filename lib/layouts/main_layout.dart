import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/responsive_utils.dart';

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
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context,
        mobile: 20, tablet: 24, desktop: 28);
    final selectedFontSize = ResponsiveUtils.getResponsiveFontSize(context,
        mobile: 12, tablet: 13, desktop: 14);
    final unselectedFontSize = ResponsiveUtils.getResponsiveFontSize(context,
        mobile: 11, tablet: 12, desktop: 13);
    final logoSize = ResponsiveUtils.getResponsiveIconSize(context,
        mobile: 60, tablet: 68, desktop: 76);

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
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius),
            topRight: Radius.circular(borderRadius),
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
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: selectedFontSize,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: unselectedFontSize,
              ),
              elevation: 0,
              items: [
                _buildNavItem(
                    context, Icons.home_outlined, Icons.home, 'Home', 0),
                _buildNavItem(context, Icons.history_outlined, Icons.history,
                    'History', 1),
                _buildLogoNavItem(logoSize),
                _buildNavItem(context, Icons.notifications_outlined,
                    Icons.notifications, 'Notifications', 3),
                _buildNavItem(
                    context, Icons.person_outline, Icons.person, 'Profile', 4),
              ],
              currentIndex: currentIndex,
              onTap: onNavigationTap ?? _handleNavigation,
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(BuildContext context, IconData icon,
      IconData activeIcon, String label, int index) {
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context,
        mobile: 26, tablet: 28, desktop: 30);
    final activeIconSize = ResponsiveUtils.getResponsiveIconSize(context,
        mobile: 28, tablet: 30, desktop: 32);
    final iconPadding = ResponsiveUtils.getResponsiveSpacing(context,
        mobile: 4, tablet: 5, desktop: 6);

    return BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(bottom: iconPadding),
        child: Icon(
          index == currentIndex ? activeIcon : icon,
          size: index == currentIndex ? activeIconSize : iconSize,
          color: index == currentIndex
              ? const Color(0xFF00B894)
              : const Color(0xFF8E8E8E),
        ),
      ),
      label: label,
    );
  }

  BottomNavigationBarItem _buildLogoNavItem(double logoSize) {
    return BottomNavigationBarItem(
      icon: Container(
        height: logoSize,
        width: logoSize,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF101513),
        ),
        child: ClipOval(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF00B894), Color(0xFF008066)],
                center: Alignment(0.0, 0.0),
                focal: Alignment(0.0, 0.0),
                radius: 0.8,
              ),
            ),
            child: Center(
              child: LogoSpinAnimation(
                child: Image.asset(
                  'assets/images/chon.png',
                  width: logoSize * 0.93,
                  height: logoSize * 0.93,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Error loading logo image: $error');
                    return Text(
                      'CHON',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: logoSize * 0.23,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        shadows: const [
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
