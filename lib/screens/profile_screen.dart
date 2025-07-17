import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/apiConnection.dart';
import '../utils/responsive_utils.dart';
import 'privacy_policy_screen.dart';
import 'social_media_screen.dart';
import '../l10n/app_localizations.dart';

/// ProfileScreen displays the user's profile information including their
/// balance, level, and account management options.
///
/// This screen uses a custom circular progress indicator to display the user's
/// balance with a teal accent color scheme on a dark background.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access auth service to get user data (currently using dummy data)
    final auth = context.watch<AuthService>();
    final balance = auth.balance;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1615), // Darker teal-black at top
              Color(0xFF0A0E0D), // Dark background in middle
              Color(0xFF0E1211), // Slightly lighter at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLevelIndicator(context),
                _buildBalanceCircle(),
                _buildAccountSection(),
                _buildMoreSection(),
                _buildLogoutButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the app bar with user name and avatar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // User nickname from AuthService
          Text(
            context.watch<AuthService>().nickname ??
                AppLocalizations.of(context)!.user,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // User avatar with teal border
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00B894),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback avatar if image fails to load
                  return CircleAvatar(
                    backgroundColor: const Color(0xFF00B894).withOpacity(0.2),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF00B894),
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      centerTitle: false,
    );
  }

  /// Builds the level indicator with star icon
  Widget _buildLevelIndicator(BuildContext context) {
    final level = context.watch<AuthService>().level;

    // Responsive sizing
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(
      context,
      mobile: 14.0,
      tablet: 16.0,
      desktop: 18.0,
    );

    final fontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      mobile: 12.0,
      tablet: 14.0,
      desktop: 16.0,
    );

    final horizontalPadding = ResponsiveUtils.getResponsiveSpacing(
      context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, animationValue, child) {
            return Opacity(
              opacity: animationValue,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - animationValue)),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 20,
                    vertical: isSmallScreen ? 8 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF94C1BA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF94C1BA).withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF94C1BA).withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1500),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, starValue, child) {
                          return Transform.scale(
                            scale: 0.5 + (0.5 * starValue),
                            child: Transform.rotate(
                              angle: starValue * 0.5,
                              child: Icon(
                                Icons.star,
                                color: const Color(0xFF94C1BA),
                                size: iconSize,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Text(
                        'Level $level',
                        style: TextStyle(
                          color: const Color(0xFF94C1BA),
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the circular balance display with progress indicator
  Widget _buildBalanceCircle() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive sizes based on screen width
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // Responsive sizing
        final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
        final isTablet = ResponsiveUtils.isTablet(context);

        // Calculate circle sizes based on screen size
        final outerCircleSize = isSmallScreen
            ? screenWidth * 0.7 // 70% of screen width for small screens
            : isTablet
                ? 280.0 // Fixed size for tablets
                : 320.0; // Fixed size for larger screens

        final progressCircleSize =
            outerCircleSize * 0.92; // 92% of outer circle
        final innerCircleSize = outerCircleSize * 0.75; // 75% of outer circle

        // Responsive font sizes
        final labelFontSize = ResponsiveUtils.getResponsiveFontSize(
          context,
          mobile: 12.0,
          tablet: 14.0,
          desktop: 16.0,
        );

        final pointsFontSize = ResponsiveUtils.getResponsiveFontSize(
          context,
          mobile: 28.0,
          tablet: 36.0,
          desktop: 42.0,
        );

        final unitFontSize = ResponsiveUtils.getResponsiveFontSize(
          context,
          mobile: 14.0,
          tablet: 18.0,
          desktop: 20.0,
        );

        // Responsive stroke width
        final strokeWidth = isSmallScreen ? 12.0 : 15.0;

        // Responsive padding
        final verticalPadding = isSmallScreen ? 20.0 : 40.0;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          child: Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1500),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, animationValue, child) {
                return Transform.scale(
                  scale: animationValue,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Enhanced outer glow effect with animation
                      AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: 0.5 + (0.5 * _glowController.value),
                            child: Transform.translate(
                              offset: Offset(0, 20 * _glowController.value),
                              child: Container(
                                width: outerCircleSize,
                                height: outerCircleSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF94C1BA)
                                          .withOpacity(
                                              0.15 * _glowController.value),
                                      blurRadius: 40 * _glowController.value,
                                      spreadRadius: 5 * _glowController.value,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF00B894)
                                          .withOpacity(
                                              0.1 * _glowController.value),
                                      blurRadius: 20 * _glowController.value,
                                      spreadRadius: 2 * _glowController.value,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Progress circle background with enhanced styling
                      Container(
                        width: progressCircleSize,
                        height: progressCircleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(
                            color: const Color(0xFF1A2322).withOpacity(0.9),
                            width: strokeWidth,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),

                      // Animated progress circle with smooth animation and pulsing effect
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return SizedBox(
                            width: progressCircleSize,
                            height: progressCircleSize,
                            child: TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 2000),
                              tween: Tween(begin: 0.0, end: 0.65),
                              builder: (context, progress, child) {
                                return Transform.rotate(
                                  angle: -progress * 2 * 3.14159,
                                  child: Transform.scale(
                                    scale:
                                        1.0 + (0.02 * _pulseController.value),
                                    child: CustomPaint(
                                      painter: CircleProgressPainter(
                                        progress: progress,
                                        progressColor: const Color(0xFF94C1BA),
                                        backgroundColor: Colors.transparent,
                                        strokeWidth: strokeWidth,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                      // Inner circle with enhanced styling and responsive content
                      Container(
                        width: innerCircleSize,
                        height: innerCircleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF0A0E0D),
                              const Color(0xFF0E1211),
                              const Color(0xFF0A1615),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: const Color(0xFF00B894).withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Info icon above points
                            Align(
                              alignment: Alignment.center,
                              child: IconButton(
                                icon: const Icon(Icons.priority_high_rounded,
                                    color: Color(0xFF94C1BA), size: 22),
                                padding: const EdgeInsets.only(bottom: 2),
                                constraints: const BoxConstraints(),
                                tooltip: 'What are points?',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Points Information'),
                                      content: const Text(
                                          'Points are accumulated through active participation in games. These points serve not only as a measure of user engagement and achievement, but also as a form of in-app currency. Certain games may initially be inaccessible; however, users can unlock these games by redeeming their earned points, thereby enhancing their overall experience and access within the application.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Animated label
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 800),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 10 * (1 - value)),
                                    child: Text(
                                      AppLocalizations.of(context)!.points,
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: labelFontSize,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 15),
                            // Animated points display
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 1200),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.scale(
                                    scale: 0.8 + (0.2 * value),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AnimatedBuilder(
                                          animation: _glowController,
                                          builder: (context, child) {
                                            final auth =
                                                context.watch<AuthService>();
                                            return Text(
                                              '${auth.totalScore}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: pointsFontSize,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.5,
                                                shadows: [
                                                  Shadow(
                                                    color: const Color(
                                                            0xFF00B894)
                                                        .withOpacity(0.3 +
                                                            (0.2 *
                                                                _glowController
                                                                    .value)),
                                                    blurRadius: 4 +
                                                        (2 *
                                                            _glowController
                                                                .value),
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: pointsFontSize * 0.3,
                                            left: 6,
                                          ),
                                          child: Text(
                                            'pts',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: unitFontSize,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Builds the Account section with menu items
  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, top: 16, bottom: 8),
          child: Text(
            AppLocalizations.of(context)!.account,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _buildMenuItem(
          icon: Icons.person_outline,
          title: AppLocalizations.of(context)!.editProfile,
          onTap: () {
            _showEditProfileDialog(context);
          },
        ),
        // _buildMenuItem(
        //   icon: Icons.notifications_outlined,
        //   title: AppLocalizations.of(context)!.notifications,
        //   onTap: () {
        //     // TODO: Navigate to Notifications screen
        //   },
        // ),
      ],
    );
  }

  /// Builds the More section with additional menu items
  Widget _buildMoreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, top: 24, bottom: 8),
          child: Text(
            AppLocalizations.of(context)!.more,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: 'Privacy & Policy',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicyScreen(),
              ),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.group_outlined,
          title: AppLocalizations.of(context)!.socialMedia,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SocialMediaScreen(),
              ),
            );
          },
        ),
        // Add Delete Account button here
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: SizedBox(
            width: 160,
            height: 36,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                textStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Delete Account'),
              onPressed: _onDeleteAccountPressed,
            ),
          ),
        ),
      ],
    );
  }

  void _onDeleteAccountPressed() async {
    print('[DEBUG] Delete Account button pressed');
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      await _performDeleteAccount();
    }
  }

  Future<void> _performDeleteAccount() async {
    print('[DEBUG] Entered _performDeleteAccount');
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B894)),
          ),
        ),
      );
      final authService = context.read<AuthService>();
      final token = authService.token;
      final url = '$apiUrl/api/players/me';
      print('[DEBUG] Attempting account deletion');
      print('[DEBUG] DELETE URL: ' + url);
      print('[DEBUG] JWT Token (for debug only, do not log in production): ' +
          (token ?? 'NULL'));
      if (token == null) throw Exception('Not authenticated');
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print('[DEBUG] Response status: ' + response.statusCode.toString());
      print('[DEBUG] Response body: ' + response.body);
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Log out user and show success
        await authService.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final errorMsg = response.body.isNotEmpty
            ? jsonDecode(response.body)['message'] ??
                'Failed to delete account.'
            : 'Failed to delete account.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete account error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Builds the logout button at the bottom of the screen
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ElevatedButton.icon(
        onPressed: () async {
          // Show confirmation dialog
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.logout),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Logout'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          );

          if (shouldLogout == true) {
            await _performLogout(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4D2626),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.logout),
        label: const Text(
          'Log out',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Performs the actual logout using AuthService
  Future<void> _performLogout(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B894)),
          ),
        ),
      );

      // Get auth service and perform logout
      final authService = context.read<AuthService>();
      await authService.signOut();

      // Hide loading indicator if still showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to AuthScreen and clear navigation stack
      Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
    } catch (e) {
      // Hide loading indicator if still showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      print('Logout - Error: $e');

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Reusable menu item widget used for both Account and More sections
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: Colors.white54,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditProfileDialog(BuildContext context) async {
    final auth = context.read<AuthService>();
    final TextEditingController controller =
        TextEditingController(text: auth.nickname ?? '');
    bool isLoading = false;
    String? errorMessage;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.editNickname),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Nickname',
                      errorText: errorMessage,
                    ),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final newNickname = controller.text.trim();
                          if (newNickname.isEmpty) {
                            setState(() =>
                                errorMessage = 'Nickname cannot be empty');
                            return;
                          }
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });
                          try {
                            final token = auth.token;
                            if (token == null) {
                              setState(() {
                                isLoading = false;
                                errorMessage = 'Not authenticated.';
                              });
                              return;
                            }
                            print('Token used for profile update: $token');
                            final response = await http.put(
                              Uri.parse('$apiUrl/api/players/profile'),
                              headers: {
                                'Content-Type': 'application/json',
                                'Authorization': 'Bearer $token',
                              },
                              body: jsonEncode({'nickname': newNickname}),
                            );
                            if (response.statusCode == 200) {
                              auth.setNickname(newNickname);
                              if (mounted) Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Nickname updated successfully'),
                                    backgroundColor: Colors.green),
                              );
                            } else {
                              setState(() {
                                isLoading = false;
                                errorMessage = 'Failed to update nickname.';
                              });
                            }
                            print('Response status: ${response.statusCode}');
                            print('Response body: ${response.body}');
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                              errorMessage = 'Network error: $e';
                            });
                          }
                        },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Custom painter that draws a circular progress indicator with customizable
/// colors and stroke width.
///
/// Used to create the balance progress circle in the profile screen.
class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  CircleProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    // Draw background circle if needed
    if (backgroundColor != Colors.transparent) {
      final backgroundPaint = Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawCircle(center, radius, backgroundPaint);
    }

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Using radians: 0 is at the right (3 o'clock), we want to start from top
    const startAngle = -90.0 * (3.14159 / 180); // Start from top (270 degrees)
    final sweepAngle = progress * 2 * 3.14159; // Full circle is 2*PI radians

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is CircleProgressPainter) {
      return oldDelegate.progress != progress ||
          oldDelegate.progressColor != progressColor ||
          oldDelegate.backgroundColor != backgroundColor ||
          oldDelegate.strokeWidth != strokeWidth;
    }
    return true;
  }
}
