import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'personal_info_screen.dart';
import '../home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/apiConnection.dart';

class VerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isSignIn;

  const VerificationScreen({
    super.key,
    required this.phoneNumber,
    this.isSignIn = false,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  /// Resends OTP to the user's phone number
  Future<void> _resendOTP() async {
    if (_isResending) return;

    setState(() => _isResending = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      // Determine if this is a sign in or sign up flow
      final result = widget.isSignIn
          ? await authService.requestLoginOTP(widget.phoneNumber)
          : await authService.registerUser(
              whatsappNumber: widget.phoneNumber,
              nickname: 'User', // This will be ignored for existing users
              language: 'en',
            );

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP code resent successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          String title = 'Resend Failed';
          IconData icon = Icons.error;
          Color iconColor = Colors.red;

          if (result['error'] == 'no_internet' ||
              result['error'] == 'network_error') {
            title = 'Connection Error';
            icon = Icons.wifi_off;
            iconColor = Colors.orange;
          }

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(icon, color: iconColor, size: 24),
                  const SizedBox(width: 8),
                  Text(title),
                ],
              ),
              content: Text(result['message'] ?? 'Failed to resend OTP'),
              actions: [
                if (result['error'] == 'no_internet' ||
                    result['error'] == 'network_error') ...[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _resendOTP();
                    },
                    child: const Text('Retry'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                ],
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Network error: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  /// Verifies the OTP with the auth service
  Future<void> _verifyOTP(String enteredOTP) async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.verifyOTP(enteredOTP);

      if (result['success']) {
        // Success - user is now authenticated and navigated to home
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Verification successful'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Show error message with appropriate icon for network errors
        if (mounted) {
          String title = 'Verification Failed';
          IconData icon = Icons.error;
          Color iconColor = Colors.red;

          if (result['error'] == 'no_internet' ||
              result['error'] == 'network_error') {
            title = 'Connection Error';
            icon = Icons.wifi_off;
            iconColor = Colors.orange;
          }

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(icon, color: iconColor, size: 24),
                  const SizedBox(width: 8),
                  Text(title),
                ],
              ),
              content: Text(result['message'] ?? 'Invalid OTP code'),
              actions: [
                if (result['error'] == 'no_internet' ||
                    result['error'] == 'network_error') ...[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Retry verification with the same OTP
                      _verifyOTP(enteredOTP);
                    },
                    child: const Text('Retry'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                ],
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Network error: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360 || screenSize.height < 600;

    // Get keyboard height to adjust padding
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final bottomPadding =
        keyboardVisible ? MediaQuery.of(context).viewInsets.bottom - 10 : 0.0;

    // Calculate OTP field size based on screen width
    final otpFieldSize = (screenSize.width - 24 * 2 - 5 * 8) / 6;
    final otpFieldHeight = otpFieldSize * 1.2;

    return Scaffold(
      backgroundColor: const Color(0xFF010202),
      // Don't resize automatically - we'll handle it manually
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              label: Text(
                'Back',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Network status indicator
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Consumer<AuthService>(
              builder: (context, authService, child) {
                if (authService.hasInternetConnection) {
                  return const SizedBox.shrink();
                }

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wifi_off,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No internet connection. Please check your network.',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Main content in a scrollable container
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.06,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/otp.png',
                      height: isSmallScreen ? 160 : 208,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: isSmallScreen ? 24 : 40),
                    Text(
                      'Check your inbox',
                      style: GoogleFonts.inter(
                        fontSize: isSmallScreen ? 24 : 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We\'ve sent a unique code to your Phone Number,\nType it in here to verify.',
                      style: GoogleFonts.inter(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? 24 : 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        6,
                        (index) => SizedBox(
                          width: otpFieldSize,
                          height: otpFieldHeight,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            cursorColor: const Color(0xFF96C3BC),
                            style: GoogleFonts.inter(
                              fontSize: isSmallScreen ? 18 : 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: const Color(0xFF090C0B),
                              hintText: '0',
                              hintStyle: GoogleFonts.inter(
                                fontSize: isSmallScreen ? 18 : 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 8 : 12,
                                horizontal: 2,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) => _onCodeChanged(value, index),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF090C0B),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 16 : 24,
                            vertical: isSmallScreen ? 8 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isResending ? null : _resendOTP,
                        icon: _isResending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF96C3BC)),
                                ),
                              )
                            : const Icon(
                                Icons.refresh,
                                color: Color(0xFF96C3BC),
                                size: 18,
                              ),
                        label: Text(
                          _isResending ? 'Resending...' : 'Resend Code',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF96C3BC),
                            fontWeight: FontWeight.w500,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                      ),
                    ),
                    // Add extra space at the bottom to ensure scrolling works well
                    SizedBox(height: keyboardVisible ? 120 : 80),
                  ],
                ),
              ),
            ),
          ),

          // Next button positioned at the bottom, above the keyboard
          Positioned(
            left: screenSize.width * 0.06,
            right: screenSize.width * 0.06,
            bottom: bottomPadding + 24,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 240, 240, 240),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    String enteredOTP = _controllers.map((c) => c.text).join();
                    if (enteredOTP.length == 6) {
                      await _verifyOTP(enteredOTP);
                    } else {
                      // Show message for incomplete OTP
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please enter the complete 6-digit OTP'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF090C0B)),
                                ),
                              )
                            : Text(
                                'Next',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF090C0B),
                                  fontSize: isSmallScreen ? 11 : 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: const Color(0xFF090C0B),
                          size: isSmallScreen ? 18 : 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
