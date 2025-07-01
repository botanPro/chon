import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'personal_info_screen.dart';
import '../home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

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
                        onPressed: () {
                          // TODO: Implement resend code functionality
                        },
                        icon: const Icon(
                          Icons.refresh,
                          color: Color(0xFF96C3BC),
                          size: 18,
                        ),
                        label: Text(
                          'Resend Code',
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
                      setState(() => _isLoading = true);
                      try {
                        final requestBody = {
                          'whatsapp_number': widget.phoneNumber,
                          'otp_code': enteredOTP,
                        };

                        print('OTP Verification - Request Body: $requestBody');

                        final response = await http.post(
                          Uri.parse('http://127.0.0.1:3000/api/players/verify'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(requestBody),
                        );
                        final Map<String, dynamic> body =
                            jsonDecode(response.body);

                        print(
                            'OTP Verification - Status: ${response.statusCode}');
                        print('OTP Verification - Response Body: $body');

                        if ((response.statusCode == 200 ||
                                response.statusCode == 201) &&
                            body['success'] == true) {
                          // Update authentication state
                          final authService =
                              Provider.of<AuthService>(context, listen: false);
                          authService.setAuthenticated(true);

                          // Store the JWT token and player data from the response
                          print('OTP Verification Response Body: $body');

                          // The backend returns data.token and data.player
                          if (body['data'] != null) {
                            final data = body['data'];
                            print('Data from response: $data');

                            // Store the JWT token from data.token
                            if (data['token'] != null) {
                              print(
                                  'Storing token from data.token: ${data['token']}');
                              authService.setToken(data['token']);
                            } else {
                              print('No token found in data.token');
                            }

                            // Store player data from data.player
                            if (data['player'] != null) {
                              final player = data['player'];
                              print('Player data: $player');

                              if (player['id'] != null) {
                                authService.setUserId(player['id'].toString());
                              }
                              if (player['nickname'] != null) {
                                authService.setNickname(player['nickname']);
                              }
                              if (player['level'] != null) {
                                authService.setLevel(player['level']);
                              }
                            } else {
                              print('No player data found in data.player');
                            }
                          } else {
                            print('No data found in response');
                          }

                          print('Stored token: ${authService.token}');
                          print('Stored user ID: ${authService.userId}');
                          print('Stored nickname: ${authService.nickname}');
                          print(
                              'Token length: ${authService.token?.length ?? 0}');
                          print('Token is null: ${authService.token == null}');
                          print(
                              'Token is empty: ${authService.token?.isEmpty ?? true}');

                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Success'),
                              content: Text(
                                  body['message'] ?? 'Verification successful'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          );
                        } else {
                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('OTP Verification Failed'),
                              content: Text(
                                  body['message'] ?? 'Verification failed.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      } catch (e) {
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Network or App Error'),
                            content: Text(e.toString()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } finally {
                        setState(() => _isLoading = false);
                      }
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
