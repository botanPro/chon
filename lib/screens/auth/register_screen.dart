import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/game_action_button.dart';

// Design tokens
const kSpacing = 8.0;
const kRadius = 16.0;
const kAnimationDuration = Duration(milliseconds: 300);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await context.read<AuthService>().completeRegistration(
            _passwordController.text,
          );

      if (!mounted) return;

      if (success) {
        await _fadeController.reverse();
        if (!mounted) return;

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _errorMessage = 'Failed to create account. Please try again.';
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
    final phone = context.read<AuthService>().userPhone ?? '';

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                    vertical: kSpacing * 2,
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
                            Icons.person_add_rounded,
                            size: 40,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: kSpacing * 3),
                      Text(
                        'Complete Registration',
                        style: theme.textTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: kSpacing),
                      Text(
                        'Set a password for $phone',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: kSpacing * 6),

                      // Password Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: kSpacing),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                prefixIcon: Icon(
                                  Icons.lock_rounded,
                                  color: theme.colorScheme.primary,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    color: theme.colorScheme.primary,
                                  ),
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                if (!value.contains(RegExp(r'[A-Z]'))) {
                                  return 'Password must contain at least one uppercase letter';
                                }
                                if (!value.contains(RegExp(r'[a-z]'))) {
                                  return 'Password must contain at least one lowercase letter';
                                }
                                if (!value.contains(RegExp(r'[0-9]'))) {
                                  return 'Password must contain at least one number';
                                }
                                if (!value.contains(
                                    RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                                  return 'Password must contain at least one special character';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: kSpacing * 3),
                            Text(
                              'Confirm Password',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: kSpacing),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                hintText: 'Confirm your password',
                                prefixIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  color: theme.colorScheme.primary,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    color: theme.colorScheme.primary,
                                  ),
                                  onPressed: () => setState(() =>
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: kSpacing * 3),

                      // Password Requirements
                      Container(
                        padding: const EdgeInsets.all(kSpacing * 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(kRadius),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password Requirements',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: kSpacing),
                            _buildRequirement(
                              theme,
                              'At least 8 characters',
                              _passwordController.text.length >= 8,
                            ),
                            _buildRequirement(
                              theme,
                              'One uppercase letter',
                              _passwordController.text
                                  .contains(RegExp(r'[A-Z]')),
                            ),
                            _buildRequirement(
                              theme,
                              'One lowercase letter',
                              _passwordController.text
                                  .contains(RegExp(r'[a-z]')),
                            ),
                            _buildRequirement(
                              theme,
                              'One number',
                              _passwordController.text
                                  .contains(RegExp(r'[0-9]')),
                            ),
                            _buildRequirement(
                              theme,
                              'One special character',
                              _passwordController.text
                                  .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
                            ),
                          ],
                        ),
                      ),

                      // Error Message
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

                      // Action Button
                      GameActionButton(
                        label: _isLoading
                            ? 'Creating account...'
                            : 'Create Account',
                        icon: _isLoading
                            ? Icons.hourglass_empty_rounded
                            : Icons.person_add_rounded,
                        onPressed: _isLoading ? null : _handleRegister,
                        showShine: !_isLoading,
                      ),
                      const SizedBox(height: kSpacing * 2),
                      Text(
                        'By creating an account, you agree to our Terms of Service and Privacy Policy',
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

  Widget _buildRequirement(ThemeData theme, String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacing),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 16,
            color: isMet
                ? Colors.green
                : theme.colorScheme.onBackground.withOpacity(0.5),
          ),
          const SizedBox(width: kSpacing),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isMet
                  ? Colors.green
                  : theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
