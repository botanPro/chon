import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/game_action_button.dart';
import 'register_screen.dart';

// Design tokens
const kSpacing = 8.0;
const kRadius = 16.0;
const kAnimationDuration = Duration(milliseconds: 300);

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );
  bool _isLoading = false;
  String? _errorMessage;
  bool _canResend = false;
  int _resendTimer = 30;
  Timer? _timer;
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
    _startResendTimer();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() {
      _resendTimer = 30;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _onDigitInput(int index, String value) {
    if (value.isEmpty) {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    } else if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOTP();
      }
    }
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;
    if (_otp.length != 6) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      final success = await authService.verifyOTP(_otp);

      if (!mounted) return;

      if (success) {
        await _fadeController.reverse();
        if (!mounted) return;

        if (authService.isNewUser) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const RegisterScreen(),
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
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid verification code. Please try again.';
        });
        // Clear the OTP fields
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
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

  Future<void> _resendCode() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phone = context.read<AuthService>().userPhone;
      if (phone == null) {
        setState(() {
          _errorMessage = 'Phone number not found. Please try again.';
        });
        return;
      }

      final success =
          await context.read<AuthService>().checkPhoneAndSendOTP(phone);

      if (!mounted) return;

      if (success) {
        _startResendTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Verification code sent successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.secondary,
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
                            Icons.sms_rounded,
                            size: 40,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: kSpacing * 3),
                      Text(
                        'Verify Your Number',
                        style: theme.textTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: kSpacing),
                      Text(
                        'Enter the 6-digit code sent to $phone',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: kSpacing * 6),

                      // OTP Input Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                6,
                                (index) => SizedBox(
                                  width: 45,
                                  height: 56,
                                  child: TextFormField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    decoration: InputDecoration(
                                      counterText: '',
                                      filled: true,
                                      fillColor: theme.colorScheme.surface,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(kRadius),
                                        borderSide: BorderSide(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(kRadius),
                                        borderSide: BorderSide(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(kRadius),
                                        borderSide: BorderSide(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(kRadius),
                                        borderSide: BorderSide(
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                    ),
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(1),
                                    ],
                                    onChanged: (value) =>
                                        _onDigitInput(index, value),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: kSpacing * 3),

                      // Error Message
                      if (_errorMessage != null)
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

                      const Spacer(),

                      // Resend Timer
                      if (!_canResend)
                        Text(
                          'Resend code in ${_resendTimer}s',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.colorScheme.onBackground.withOpacity(0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),

                      // Action Buttons
                      const SizedBox(height: kSpacing * 2),
                      GameActionButton(
                        label: _isLoading ? 'Verifying...' : 'Verify',
                        icon: _isLoading
                            ? Icons.hourglass_empty_rounded
                            : Icons.check_circle_rounded,
                        onPressed: _isLoading ? null : _verifyOTP,
                        showShine: !_isLoading,
                      ),
                      const SizedBox(height: kSpacing * 2),
                      TextButton(
                        onPressed:
                            _isLoading || !_canResend ? null : _resendCode,
                        child: Text(
                          'Resend Code',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: _canResend
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onBackground
                                    .withOpacity(0.3),
                          ),
                        ),
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
