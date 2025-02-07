import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userPhone;
  String? _verificationId;
  bool _isNewUser = false;
  double _balance = 0.0;
  List<Transaction> _transactions = [];

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userPhone => _userPhone;
  bool get isNewUser => _isNewUser;
  double get balance => _balance;
  List<Transaction> get transactions => _transactions;

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
        _balance = 1234.56; // Initial balance for testing
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
      _balance = 0.0; // New users start with 0 balance
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Deposit funds
  Future<bool> deposit(double amount, String method) async {
    try {
      // TODO: Implement actual deposit logic
      await Future.delayed(const Duration(seconds: 1));

      _balance += amount;
      _transactions.add(
        Transaction(
          type: TransactionType.deposit,
          amount: amount,
          method: method,
          timestamp: DateTime.now(),
          status: TransactionStatus.completed,
        ),
      );
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Withdraw funds
  Future<bool> withdraw(double amount, String method) async {
    try {
      // TODO: Implement actual withdrawal logic
      await Future.delayed(const Duration(seconds: 1));

      if (amount > _balance) {
        return false;
      }

      _balance -= amount;
      _transactions.add(
        Transaction(
          type: TransactionType.withdrawal,
          amount: amount,
          method: method,
          timestamp: DateTime.now(),
          status: TransactionStatus.completed,
        ),
      );
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
    _balance = 0.0;
    _transactions.clear();
    notifyListeners();
  }
}

enum TransactionType {
  deposit,
  withdrawal,
  gameWin,
  gameLoss,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
}

class Transaction {
  final TransactionType type;
  final double amount;
  final String method;
  final DateTime timestamp;
  final TransactionStatus status;

  Transaction({
    required this.type,
    required this.amount,
    required this.method,
    required this.timestamp,
    required this.status,
  });
}
