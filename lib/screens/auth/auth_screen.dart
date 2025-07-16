import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../l10n/app_localizations.dart';
import 'verification_screen.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/apiConnection.dart';
import '../../utils/responsive_utils.dart';

// Animated gradient background painter
class AnimatedGradientPainter extends CustomPainter {
  final double animationValue;
  final List<Color> colors;

  AnimatedGradientPainter({
    required this.animationValue,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create a rect for the entire canvas
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Create more dynamic gradient with animated positions and colors
    final gradient = LinearGradient(
      begin: Alignment(
        0.0,
        -0.5 + 0.3 * sin(animationValue * pi * 2),
      ),
      end: Alignment(
        0.2 * cos(animationValue * pi),
        1.0,
      ),
      colors: [
        colors[0],
        Color.lerp(
                colors[1], colors[2], sin(animationValue * pi) * 0.5 + 0.5) ??
            colors[1],
        Color.lerp(colors[2], colors[3],
                cos(animationValue * pi * 0.5) * 0.5 + 0.5) ??
            colors[2],
        colors[3],
      ],
      stops: [
        0.0,
        0.3 + 0.2 * sin(animationValue * pi * 2),
        0.6 + 0.2 * cos(animationValue * pi),
        1.0,
      ],
    );

    // Draw the gradient
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Add animated overlay pattern
    final patternPaint = Paint()
      ..color = Colors.white.withOpacity(0.015)
      ..strokeWidth = 0.6;

    // Draw animated grid pattern
    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      final offset = 10 * sin((i / size.width + animationValue * 2) * pi * 2);
      canvas.drawLine(
          Offset(i, 0), Offset(i + offset, size.height), patternPaint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      final offset = 10 * cos((i / size.height + animationValue * 2) * pi * 2);
      canvas.drawLine(
          Offset(0, i), Offset(size.width, i + offset), patternPaint);
    }

    // Add some subtle moving light spots
    final spotPaint = Paint()..color = Colors.white.withOpacity(0.02);

    for (int i = 0; i < 5; i++) {
      final x = size.width * (0.2 + 0.6 * sin(animationValue * pi + i * 1.2));
      final y =
          size.height * (0.2 + 0.6 * cos(animationValue * pi * 0.7 + i * 0.8));
      final radius = 50.0 + 30.0 * sin(animationValue * pi * 2 + i);

      canvas.drawCircle(
        Offset(x, y),
        radius,
        spotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedGradientPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _backgroundAnimationController;

  // Background gradient colors
  final List<Color> _gradientColors = [
    const Color(0xFF1c2221), // Teal 50 (darkest)
    const Color(0xFF323e3c), // Teal 100
    const Color(0xFF495d5a), // Teal 200
    const Color(0xFF1c2221).withOpacity(0.9), // Darker overlay
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0), // Start from left side
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Initialize background animation controller with faster animation
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    // Start the animations after a brief delay
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
      _backgroundAnimationController.repeat();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _showSignUpDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SignUpDrawer(isSignIn: false),
    );
  }

  void _showSignInDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SignUpDrawer(isSignIn: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme();
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360 || screenSize.height < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF13131D),
      body: Stack(
        children: [
          // Animated gradient background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundAnimationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: AnimatedGradientPainter(
                    animationValue: _backgroundAnimationController.value,
                    colors: _gradientColors,
                  ),
                );
              },
            ),
          ),

          // Background grid pattern with reduced opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isSmallScreen ? 3 : 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth * 0.06,
                        vertical: 24.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(),
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _showSignUpDrawer,
                                borderRadius: BorderRadius.circular(12),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.signUp,
                                    style: textTheme.labelLarge?.copyWith(
                                      color: Colors.black,
                                      fontSize: isSmallScreen ? 11 : 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 56,
                            child: TextButton(
                              onPressed: _showSignInDrawer,
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF6F6F6F),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.signIn,
                                style: textTheme.labelLarge?.copyWith(
                                  fontSize: isSmallScreen ? 11 : 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                  color: const Color(0xFF6F6F6F),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Testing button - remove in production
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red, width: 1),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // Navigate directly to home screen for testing
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/home',
                                    (route) => false,
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Center(
                                  child: Text(
                                    'Login as guest',
                                    style: textTheme.labelLarge?.copyWith(
                                      color: Colors.white,
                                      fontSize: isSmallScreen ? 11 : 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    // Positioned Logo - using relative positioning
                    Positioned(
                      top: constraints.maxHeight * 0.45,
                      left: constraints.maxWidth * 0.08,
                      child: Container(
                        width: constraints.maxWidth * 0.18,
                        height: constraints.maxWidth * 0.18,
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/images/chon.png',
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              color: Colors.white.withOpacity(0.5),
                              size: 32,
                            );
                          },
                        ),
                      ),
                    ),
                    // Positioned Slogan with Animation - using relative positioning
                    Positioned(
                      top: constraints.maxHeight * 0.45 +
                          (constraints.maxWidth * 0.18) +
                          10,
                      left: constraints.maxWidth * 0.08,
                      right: constraints.maxWidth * 0.25,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF96c3bc), // Teal 500
                                Color(0xFF7b9f9a), // Teal 400
                                Color(0xFF627d79), // Teal 300
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ).createShader(bounds);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.compete,
                                style: textTheme.displaySmall?.copyWith(
                                  fontSize: isSmallScreen ? 28 : 38,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.0,
                                  letterSpacing: -1,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)!.win,
                                style: textTheme.displaySmall?.copyWith(
                                  fontSize: isSmallScreen ? 28 : 38,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.0,
                                  letterSpacing: -1,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)!.earn,
                                style: textTheme.displaySmall?.copyWith(
                                  fontSize: isSmallScreen ? 28 : 38,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.0,
                                  letterSpacing: -1,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SignUpDrawer extends StatefulWidget {
  final bool isSignIn;

  const SignUpDrawer({
    super.key,
    this.isSignIn = false,
  });

  @override
  State<SignUpDrawer> createState() => _SignUpDrawerState();
}

class _SignUpDrawerState extends State<SignUpDrawer>
    with TickerProviderStateMixin {
  bool _showPassword = false;
  bool _isLoading = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  String _selectedLanguage = 'en'; // Default language code for backend

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0), // Start from left side
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start the animation after a brief delay
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final modalHeight = ResponsiveUtils.getResponsiveModalHeight(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context,
        mobile: 32, tablet: 36, desktop: 40);

    return Container(
      height: modalHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E0D),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(borderRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ResponsiveContainer(
            mobilePadding: 20,
            tabletPadding: 24,
            desktopPadding: 32,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF96c3bc), // Teal 500
                    Color(0xFF7b9f9a), // Teal 400
                    Color(0xFF627d79), // Teal 300
                  ],
                  stops: [0.0, 0.5, 1.0],
                ).createShader(bounds);
              },
              child: ResponsiveText(
                AppLocalizations.of(context)!.welcomeToOurGameArea,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
                mobileFontSize: 20,
                tabletFontSize: 26,
                desktopFontSize: 30,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ResponsiveContainer(
            mobilePadding: 20,
            tabletPadding: 24,
            desktopPadding: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  widget.isSignIn
                      ? AppLocalizations.of(context)!.signInAccount
                      : AppLocalizations.of(context)!.signUpAccount,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  mobileFontSize: 18,
                  tabletFontSize: 20,
                  desktopFontSize: 22,
                ),
                const SizedBox(height: 8),
                ResponsiveText(
                  widget.isSignIn
                      ? AppLocalizations.of(context)!.signInDescription
                      : AppLocalizations.of(context)!.signUpDescription,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  mobileFontSize: 12,
                  tabletFontSize: 14,
                  desktopFontSize: 16,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: ResponsiveUtils.getResponsivePadding(context,
                        mobile: 20, tablet: 24, desktop: 32)
                    .left,
                right: ResponsiveUtils.getResponsivePadding(context,
                        mobile: 20, tablet: 24, desktop: 32)
                    .right,
                bottom: bottomInset > 0 ? bottomInset : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPhoneField(isSmallScreen),
                  const SizedBox(height: 16),
                  widget.isSignIn
                      ? const SizedBox.shrink() // No password field for sign in
                      : _buildNicknameField(isSmallScreen),
                  widget.isSignIn
                      ? const SizedBox.shrink() // No language field for sign in
                      : const SizedBox(height: 16),
                  widget.isSignIn
                      ? const SizedBox.shrink() // No language field for sign in
                      : _buildLanguageField(isSmallScreen),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: ResponsiveText(
                          widget.isSignIn
                              ? AppLocalizations.of(context)!.dontHaveAccount
                              : AppLocalizations.of(context)!
                                  .alreadyHaveAccount,
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          mobileFontSize: 12,
                          tabletFontSize: 14,
                          desktopFontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (widget.isSignIn) {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (context) =>
                                    const SignUpDrawer(isSignIn: false),
                              );
                            } else {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (context) =>
                                    const SignUpDrawer(isSignIn: true),
                              );
                            }
                          });
                        },
                        child: ResponsiveText(
                          widget.isSignIn
                              ? AppLocalizations.of(context)!.signUp
                              : AppLocalizations.of(context)!.signIn,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF96c3bc), // Teal 500
                            fontWeight: FontWeight.w600,
                          ),
                          mobileFontSize: 12,
                          tabletFontSize: 14,
                          desktopFontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (widget.isSignIn) {
                            _handleSignIn();
                          } else {
                            _handleSignUp();
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.black),
                                      ),
                                    )
                                  : ResponsiveText(
                                      widget.isSignIn
                                          ? AppLocalizations.of(context)!.signIn
                                          : AppLocalizations.of(context)!
                                              .signUp,
                                      style: GoogleFonts.inter(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      mobileFontSize: 12,
                                      tabletFontSize: 14,
                                      desktopFontSize: 16,
                                    ),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.black,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: max(32, bottomInset > 0 ? 16 : 32)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.phoneNumber,
          style: GoogleFonts.inter(
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF151918),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Text(
                  '+964 |',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: AppLocalizations.of(context)!.phoneNumberHint,
                    hintStyle: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNicknameField(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.nickname,
          style: GoogleFonts.inter(
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF151918),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _nicknameController,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              hintText: AppLocalizations.of(context)!.nicknameHint,
              hintStyle: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.3),
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageField(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.language,
          style: GoogleFonts.inter(
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF151918),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLanguage,
              isExpanded: true,
              dropdownColor: const Color(0xFF151918),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: isSmallScreen ? 14 : 16,
              ),
              items: [
                DropdownMenuItem<String>(
                  value: 'en',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(AppLocalizations.of(context)!.english),
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'kr',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(AppLocalizations.of(context)!.kurdishSorani),
                  ),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  print('Language changed to: $newValue');
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignUp() async {
    final phone = _phoneController.text.trim();
    final nickname = _nicknameController.text.trim();

    if (phone.isEmpty || nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.enterPhoneNickname)),
      );
      return;
    }

    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.registerUser(
        whatsappNumber: phone,
        nickname: nickname,
        language: _selectedLanguage,
      );

      if (result['success']) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.success),
            content: Text(
                result['message'] ?? AppLocalizations.of(context)!.otpSent),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(phoneNumber: phone),
          ),
        );
      } else {
        // Show appropriate error dialog based on error type
        String title = AppLocalizations.of(context)!.error;
        IconData icon = Icons.error;
        Color iconColor = Colors.red;

        if (result['error'] == 'no_internet' ||
            result['error'] == 'network_error') {
          title = 'Connection Error';
          icon = Icons.wifi_off;
          iconColor = Colors.orange;
        }

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 8),
                Text(title),
              ],
            ),
            content: Text(result['message'] ?? 'Registration failed'),
            actions: [
              if (result['error'] == 'no_internet' ||
                  result['error'] == 'network_error') ...[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _handleSignUp(); // Retry the registration
                  },
                  child: const Text('Retry'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),
              ],
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Sign Up - Error: $e');
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.networkError),
          content: Text('Error: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignIn() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.enterPhoneNumber)),
      );
      return;
    }

    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.requestLoginOTP(phone);

      if (result['success']) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.success),
            content: Text(
                result['message'] ?? AppLocalizations.of(context)!.otpSent),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              phoneNumber: phone,
              isSignIn: true, // Pass flag to indicate this is sign in flow
            ),
          ),
        );
      } else {
        // Show appropriate error dialog based on error type
        String title = AppLocalizations.of(context)!.error;
        IconData icon = Icons.error;
        Color iconColor = Colors.red;

        if (result['error'] == 'no_internet' ||
            result['error'] == 'network_error') {
          title = 'Connection Error';
          icon = Icons.wifi_off;
          iconColor = Colors.orange;
        }

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 8),
                Text(title),
              ],
            ),
            content: Text(result['message'] ?? 'Sign in failed'),
            actions: [
              if (result['error'] == 'no_internet' ||
                  result['error'] == 'network_error') ...[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _handleSignIn(); // Retry the sign in
                  },
                  child: const Text('Retry'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),
              ],
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Sign In - Error: $e');
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.networkError),
          content: Text('Error: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
