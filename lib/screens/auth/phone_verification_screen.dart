import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/game_action_button.dart';
import 'otp_verification_screen.dart';

// Design tokens
const kSpacing = 8.0;
const kRadius = 16.0;
const kAnimationDuration = Duration(milliseconds: 300);

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: kAnimationDuration,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handlePhoneVerification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await context.read<AuthService>().checkPhoneAndSendOTP(
            _phoneController.text,
          );

      if (!mounted) return;

      if (success) {
        await _fadeController.reverse();
        if (!mounted) return;

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const OTPVerificationScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            transitionDuration: kAnimationDuration,
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to send verification code. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpacing * 3,
                    vertical: kSpacing * 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Hero(
                        tag: 'app_icon',
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(kRadius),
                          ),
                          child: Icon(
                            Icons.sports_esports,
                            size: 40,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: kSpacing * 3),
                      Text(
                        'Welcome! 👋',
                        style: theme.textTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: kSpacing),
                      Text(
                        'Enter your phone number to get started',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: kSpacing * 6),

                      // Phone Input Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phone Number',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: kSpacing),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(kRadius),
                                border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(kSpacing * 2),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              kRadius / 2),
                                          child: Image.network(
                                            'https://flagcdn.com/w40/iq.png',
                                            width: 24,
                                            height: 16,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: kSpacing),
                                        Text(
                                          '+964',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _phoneController,
                                      decoration: InputDecoration(
                                        hintText: '7XXXXXXXX',
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: kSpacing * 2,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.phone_iphone_rounded,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                        letterSpacing: 1.5,
                                      ),
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(9),
                                      ],
                                      onFieldSubmitted: (_) =>
                                          _handlePhoneVerification(),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your phone number';
                                        }
                                        if (value.length != 9) {
                                          return 'Phone number must be 9 digits';
                                        }
                                        if (!value.startsWith('7')) {
                                          return 'Phone number must start with 7';
                                        }
                                        if (!RegExp(r'^(75|77|78)\d{7}$')
                                            .hasMatch(value)) {
                                          return 'Invalid phone number format';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: kSpacing * 2),
                        Container(
                          padding: const EdgeInsets.all(kSpacing * 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(kRadius),
                            border: Border.all(
                              color: theme.colorScheme.error.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: kSpacing),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(),
                      GameActionButton(
                        label: _isLoading ? 'Sending code...' : 'Continue',
                        icon: _isLoading
                            ? Icons.hourglass_empty_rounded
                            : Icons.arrow_forward_rounded,
                        onPressed: _isLoading ? null : _handlePhoneVerification,
                        showShine: !_isLoading,
                      ),
                      const SizedBox(height: kSpacing * 2),
                      Text(
                        'By continuing, you agree to our Terms of Service and Privacy Policy',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
