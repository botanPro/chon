import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/apiConnection.dart';
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

class _ProfileScreenState extends State<ProfileScreen> {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.star,
            color: Color(0xFF94C1BA),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Level $level',
            style: const TextStyle(
              color: Color(0xFF94C1BA),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the circular balance display with progress indicator
  Widget _buildBalanceCircle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow effect
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF94C1BA).withOpacity(0.1),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),

            // Progress circle background (darker ring)
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(
                  color: const Color(0xFF1A2322).withOpacity(0.8),
                  width: 15,
                ),
              ),
            ),

            // Animated progress circle (65% complete)
            SizedBox(
              width: 220,
              height: 220,
              child: Transform.rotate(
                angle: -0.65, // Rotate to match design
                child: CustomPaint(
                  painter: CircleProgressPainter(
                    progress: 0.65,
                    progressColor: const Color(0xFF94C1BA),
                    backgroundColor: Colors.transparent,
                    strokeWidth: 15,
                  ),
                ),
              ),
            ),

            // Inner circle with balance display
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0A0E0D),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!
                        .points, // Change label to 'points'
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Points display (no dollar sign)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Removed dollar sign
                      const Text(
                        '1,000,000', // Replace with actual points variable if available
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10, left: 6),
                        child: Text(
                          'pts', // Add points unit
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
        _buildMenuItem(
          icon: Icons.notifications_outlined,
          title: AppLocalizations.of(context)!.notifications,
          onTap: () {
            // TODO: Navigate to Notifications screen
          },
        ),
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
          icon: Icons.star_outline,
          title: AppLocalizations.of(context)!.rateUs,
          onTap: () {
            // TODO: Implement app rating functionality
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
