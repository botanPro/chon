import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userPhone;
  String? _verificationId;
  bool _isNewUser = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userPhone => _userPhone;
  bool get isNewUser => _isNewUser;

  // Format phone number to standard format
  String _formatPhoneNumber(String phone) {
    // Remove any spaces, dashes, or other characters
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // If number starts with 0, replace it with +964
    if (phone.startsWith('0')) {
      phone = '+964${phone.substring(1)}';
    }
    // If number doesn't have country code, add it
    else if (!phone.startsWith('+')) {
      phone = '+964$phone';
    }

    return phone;
  }

  // Check if account exists and send OTP
  Future<bool> checkPhoneAndSendOTP(String phone) async {
    try {
      final formattedPhone = _formatPhoneNumber(phone);
      // TODO: Implement actual phone verification
      // For now, simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Simulate checking if user exists (for testing, assume numbers starting with 751 are existing users)
      _isNewUser = !formattedPhone.contains('751');
      _userPhone = formattedPhone;
      _verificationId = 'test-verification-id';

      // In real implementation, this would trigger actual OTP sending
      notifyListeners();
      return true;
    } catch (e) {
      _userPhone = null;
      _verificationId = null;
      notifyListeners();
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String otp) async {
    try {
      // TODO: Implement actual OTP verification
      await Future.delayed(const Duration(seconds: 1));

      if (otp == '123456') {
        // For testing purposes
        _isAuthenticated = true;
        _userId = 'user_${_userPhone}';
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Complete registration with additional details
  Future<bool> completeRegistration(String password) async {
    try {
      // TODO: Implement actual registration
      await Future.delayed(const Duration(seconds: 1));

      _isAuthenticated = true;
      _userId = 'user_${_userPhone}';
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    _userId = null;
    _userPhone = null;
    _verificationId = null;
    _isNewUser = false;
    notifyListeners();
  }
}
