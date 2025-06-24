import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'verification_screen.dart';
import 'dart:math';

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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
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
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
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
                                'Sign up',
                                style: textTheme.labelLarge?.copyWith(
                                  color: Colors.black,
                                  fontSize: 12,
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
                            'Sign in',
                            style: textTheme.labelLarge?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                              color: const Color(0xFF6F6F6F),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // Positioned Logo
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.48,
                  left: 32,
                  child: Container(
                    width: 70,
                    height: 70,
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
                // Positioned Slogan with Animation
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.45 + 100,
                  left: 24,
                  right: 85,
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
                            'COMPETE',
                            style: textTheme.displaySmall?.copyWith(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.0,
                              letterSpacing: -1,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Text(
                            'WIN',
                            style: textTheme.displaySmall?.copyWith(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.0,
                              letterSpacing: -1,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Text(
                            'EARN',
                            style: textTheme.displaySmall?.copyWith(
                              fontSize: 38,
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
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E0D),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
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
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
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
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WELCOME TO',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              fontSize: 30,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'OUR ',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  fontSize: 30,
                                ),
                              ),
                              const Icon(
                                Icons.sports_esports,
                                color: Colors.white,
                                size: 30,
                              ),
                              Text(
                                ' GAME AREA',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  fontSize: 30,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isSignIn ? 'Sign In Account' : 'Sign Up Account',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isSignIn
                      ? 'Enter your credentials to access your account'
                      : 'Enter your personal information to create your account',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPhoneField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.isSignIn
                            ? 'Don\'t have an account? '
                            : 'Already have an account? ',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
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
                        child: Text(
                          widget.isSignIn ? 'Sign up' : 'Sign in',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF96c3bc), // Teal 500
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
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
                            // Handle sign in - for now, just navigate to home
                            // In a real app, you'd validate credentials first
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/home',
                              (route) => false,
                            );
                          } else {
                            // Handle sign up - navigate to verification
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VerificationScreen(
                                  phoneNumber: '+964 ${_phoneController.text}',
                                ),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.isSignIn ? 'Sign in' : 'Sign up',
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
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
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: GoogleFonts.inter(
            fontSize: 14,
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
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '750 999 9999',
                    hintStyle: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 16,
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

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: GoogleFonts.inter(
            fontSize: 14,
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
            controller: _passwordController,
            obscureText: !_showPassword,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              hintText: '@Example25',
              hintStyle: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.3),
                fontSize: 16,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white.withOpacity(0.5),
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
