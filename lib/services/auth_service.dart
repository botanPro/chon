import 'package:flutter/material.dart';
import 'navigation_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/apiConnection.dart';

/// Service that handles all authentication and user-related functionality.
///
/// This includes user registration, login, session management, and financial transactions.
/// Currently uses dummy data and mock implementations that will be replaced with
/// actual API calls in production.
class AuthService extends ChangeNotifier {
  // User authentication state
  bool _isAuthenticated = false;
  String? _userId;
  String? _userPhone;
  String? _verificationId;
  bool _isNewUser = false;
  String? _token; // JWT token for API authentication
  String? _nickname; // User's nickname
  int _level = 0; // User's level
  String _language = 'English'; // User's preferred language

  // User financial data
  double _balance = 0.0;
  List<Transaction> _transactions = [];
  List<GameResult> _gameHistory = [];
  Map<String, dynamic>? _lastCompetitionLeaderboard;
  Map<String, dynamic>? _leaderboardHistory;

  // Public getters
  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userPhone => _userPhone;
  bool get isNewUser => _isNewUser;
  String? get token => _token; // Getter for JWT token
  String? get nickname => _nickname; // Getter for nickname
  int get level => _level; // Getter for level
  String get language => _language; // Getter for language
  double get balance => _balance;
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<GameResult> get gameHistory => List.unmodifiable(_gameHistory);
  Map<String, dynamic>? get lastCompetitionLeaderboard =>
      _lastCompetitionLeaderboard;
  Map<String, dynamic>? get leaderboardHistory => _leaderboardHistory;

  /// Sets the authentication state
  void setAuthenticated(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    if (!isAuthenticated) {
      _token = null; // Clear token on logout
      _userId = null; // Clear user ID on logout
      _nickname = null; // Clear nickname on logout
      _level = 0; // Reset level on logout
      _language = 'English'; // Reset language on logout
    }
    notifyListeners();
  }

  /// Sets the JWT token for API authentication
  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  /// Sets the user ID
  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  /// Sets the user's nickname
  void setNickname(String nickname) {
    _nickname = nickname;
    notifyListeners();
  }

  /// Sets the user's level
  void setLevel(int level) {
    _level = level;
    notifyListeners();
  }

  /// Sets the user's preferred language
  void setLanguage(String language) {
    _language = language;
    notifyListeners();
  }

  /// Formats a phone number to the standard international format.
  ///
  /// Handles different input formats and ensures the number has the correct
  /// country code prefix (+964 for Iraq).
  ///
  /// [phone] The phone number to format
  /// Returns the formatted phone number
  String _formatPhoneNumber(String phone) {
    // Remove any non-digit characters
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

  /// Checks if an account exists for the given phone number and sends OTP.
  ///
  /// This is the first step in the authentication flow. It determines if the
  /// user is new or existing and triggers the OTP verification process.
  ///
  /// [phone] The phone number to check
  /// Returns true if OTP was sent successfully, false otherwise
  Future<bool> checkPhoneAndSendOTP(String phone) async {
    try {
      final formattedPhone = _formatPhoneNumber(phone);

      // TODO: Replace with actual API call to verify phone and send OTP
      await Future.delayed(const Duration(seconds: 1));

      // MOCK IMPLEMENTATION: Simulate checking if user exists
      // In production, this would be an API call to the backend
      _isNewUser = !formattedPhone.contains('751');
      _userPhone = formattedPhone;
      _verificationId = 'test-verification-id';

      notifyListeners();
      return true;
    } catch (e) {
      _userPhone = null;
      _verificationId = null;
      notifyListeners();
      return false;
    }
  }

  /// Verifies the OTP code entered by the user.
  ///
  /// This is the second step in the authentication flow. If successful,
  /// it will either complete the login process or prompt for additional
  /// registration information for new users.
  ///
  /// [otp] The OTP code entered by the user
  /// Returns true if verification was successful, false otherwise
  Future<bool> verifyOTP(String otp) async {
    try {
      // TODO: Replace with actual OTP verification API call
      await Future.delayed(const Duration(seconds: 1));

      // MOCK IMPLEMENTATION: For testing purposes, accept "123456" as valid
      if (otp == '123456') {
        _isAuthenticated = true;
        _userId = 'user_${_userPhone}';
        _balance = 1000000; // Initial balance for testing

        // Add sample game history for testing UI
        _addSampleGameHistory();

        notifyListeners();

        // Navigate to home screen
        NavigationService().navigateToReplacement('/home');

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Adds a new game result to the user's history.
  ///
  /// Also updates the user's balance and transaction history if the game
  /// resulted in a financial win or loss.
  ///
  /// [result] The game result to add
  void addGameResult(GameResult result) {
    _gameHistory.add(result);

    // Also add a transaction if there was a win or loss with money
    if (result.winAmount > 0) {
      _transactions.add(
        Transaction(
          type: TransactionType.gameWin,
          amount: result.winAmount,
          method: result.gameType,
          timestamp: result.timestamp,
          status: TransactionStatus.completed,
        ),
      );
      _balance += result.winAmount;
    }

    notifyListeners();
  }

  /// Adds sample game history data for testing purposes.
  ///
  /// This is used to populate the UI with realistic-looking data
  /// during development and testing.
  void _addSampleGameHistory() {
    _gameHistory = [
      GameResult(
        gameType: 'Trivia Challenge',
        position: 'Top 1',
        score: 3,
        totalQuestions: 3,
        winAmount: 50.0,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      GameResult(
        gameType: 'Daily Quiz',
        position: 'Top 3',
        score: 7,
        totalQuestions: 10,
        winAmount: 20.0,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      GameResult(
        gameType: 'Speed Challenge',
        position: 'Top 5',
        score: 4,
        totalQuestions: 5,
        winAmount: 10.0,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      GameResult(
        gameType: 'Trivia Challenge',
        position: 'Top 10',
        score: 2,
        totalQuestions: 3,
        winAmount: 5.0,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
      GameResult(
        gameType: 'Daily Quiz',
        position: 'Top 20',
        score: 5,
        totalQuestions: 10,
        winAmount: 0.0,
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];

    // Add corresponding transactions for wins
    for (final game in _gameHistory) {
      if (game.winAmount > 0) {
        _transactions.add(
          Transaction(
            type: TransactionType.gameWin,
            amount: game.winAmount,
            method: game.gameType,
            timestamp: game.timestamp,
            status: TransactionStatus.completed,
          ),
        );
      }
    }
  }

  /// Completes the registration process for new users.
  ///
  /// This is called after OTP verification for new users to collect
  /// additional required information.
  ///
  /// [password] The user's chosen password
  /// Returns true if registration was completed successfully, false otherwise
  Future<bool> completeRegistration(String password) async {
    try {
      // TODO: Replace with actual API call to complete registration
      await Future.delayed(const Duration(seconds: 1));

      _isAuthenticated = true;
      _userId = 'user_${_userPhone}';
      _balance = 0.0; // New users start with 0 balance
      notifyListeners();

      // Navigate to home screen
      NavigationService().navigateToReplacement('/home');

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Deposits funds into the user's account.
  ///
  /// [amount] The amount to deposit
  /// [method] The payment method used (e.g., "Credit Card", "PayPal")
  /// Returns true if deposit was successful, false otherwise
  Future<bool> deposit(double amount, String method) async {
    try {
      // TODO: Replace with actual payment gateway integration
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

  /// Withdraws funds from the user's account.
  ///
  /// [amount] The amount to withdraw
  /// [method] The withdrawal method (e.g., "Bank Transfer")
  /// Returns true if withdrawal was successful, false otherwise
  Future<bool> withdraw(double amount, String method) async {
    try {
      // TODO: Replace with actual withdrawal API integration
      await Future.delayed(const Duration(seconds: 1));

      // Validate sufficient funds
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

  /// Signs out the current user and clears all user data.
  ///
  /// This resets the authentication state and navigates back to the auth screen.
  Future<void> signOut() async {
    // Reset all user-related data
    _isAuthenticated = false;
    _userId = null;
    _userPhone = null;
    _verificationId = null;
    _isNewUser = false;
    _balance = 0.0;
    _transactions.clear();
    _gameHistory.clear();
    _lastCompetitionLeaderboard = null; // Clear leaderboard on sign out
    _leaderboardHistory = null; // Clear leaderboard history on sign out

    // Reset navigation state and redirect to auth screen
    final navigationService = NavigationService();
    navigationService.resetNavigation();
    navigationService.navigateToReplacement('/auth');

    notifyListeners();
  }

  /// Registers a new user with the given WhatsApp number and nickname.
  ///
  /// Returns true if registration was successful, false otherwise.
  static Future<bool> register({
    required String whatsappNumber,
    required String nickname,
    required String language,
  }) async {
    print('Sending language: $language'); // Debug print
    final url = Uri.parse('$apiUrl/api/players/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'whatsapp_number': whatsappNumber,
          'nickname': nickname,
          'language': language,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Optionally parse response.body if needed
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Fetches the last competition leaderboard for the authenticated user.
  Future<bool> fetchLastCompetitionLeaderboard() async {
    if (_token == null) return false;
    final url = Uri.parse('$apiUrl/api/players/history/last');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          _lastCompetitionLeaderboard = data['data'];
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Fetches the full leaderboard history for the authenticated user.
  Future<bool> fetchLeaderboardHistory() async {
    if (_token == null) return false;
    final url = Uri.parse('$apiUrl/api/players/history');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          _leaderboardHistory = {'history': data['data']};
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

/// Represents the type of financial transaction.
enum TransactionType {
  /// Money added to the account
  deposit,

  /// Money removed from the account
  withdrawal,

  /// Money won from playing games
  gameWin,

  /// Money lost from playing games
  gameLoss,
}

/// Represents the status of a transaction.
enum TransactionStatus {
  /// Transaction is being processed
  pending,

  /// Transaction completed successfully
  completed,

  /// Transaction failed to complete
  failed,
}

/// Represents a financial transaction in the user's account.
class Transaction {
  /// The type of transaction (deposit, withdrawal, etc.)
  final TransactionType type;

  /// The monetary amount of the transaction
  final double amount;

  /// The method or source of the transaction
  final String method;

  /// When the transaction occurred
  final DateTime timestamp;

  /// Current status of the transaction
  final TransactionStatus status;

  /// Creates a new transaction record
  Transaction({
    required this.type,
    required this.amount,
    required this.method,
    required this.timestamp,
    required this.status,
  });
}

/// Represents the result of a game played by the user.
class GameResult {
  /// The type or name of the game
  final String gameType;

  /// The user's position in the game (e.g., "Top 1")
  final String position;

  /// The user's score in the game
  final int score;

  /// The total number of questions or challenges in the game
  final int totalQuestions;

  /// The amount of money won (0 if no win)
  final double winAmount;

  /// When the game was played
  final DateTime timestamp;

  /// Creates a new game result record
  GameResult({
    required this.gameType,
    required this.position,
    required this.score,
    required this.totalQuestions,
    required this.winAmount,
    required this.timestamp,
  });
}
