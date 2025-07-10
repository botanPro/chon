import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'navigation_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/apiConnection.dart';

/// Service that handles all authentication and user-related functionality.
///
/// This service manages user authentication, token persistence, and secure
/// communication with the backend API.
class AuthService extends ChangeNotifier {
  // SharedPreferences keys for persistent storage
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _nicknameKey = 'nickname';
  static const String _levelKey = 'level';
  static const String _phoneKey = 'phone';
  static const String _languageKey = 'language';
  static const String _isVerifiedKey = 'is_verified';

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
  bool _isVerified = false;
  bool _isLoading = false;

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
  String? get token => _token;
  String? get nickname => _nickname;
  int get level => _level;
  String get language => _language;
  bool get isVerified => _isVerified;
  bool get isLoading => _isLoading;
  double get balance => _balance;
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<GameResult> get gameHistory => List.unmodifiable(_gameHistory);
  Map<String, dynamic>? get lastCompetitionLeaderboard =>
      _lastCompetitionLeaderboard;
  Map<String, dynamic>? get leaderboardHistory => _leaderboardHistory;

  /// Checks if the device has internet connectivity
  Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      // Check if device is connected to a network
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // For web platform, connectivity check is sufficient
      // For mobile/desktop, do an additional HTTP check
      if (connectivityResult == ConnectivityResult.wifi ||
          connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.ethernet) {
        // Try to make a simple HTTP request to verify actual connectivity
        try {
          final response = await http.get(
            Uri.parse('https://www.google.com'),
            headers: {'User-Agent': 'CHON-App'},
          ).timeout(const Duration(seconds: 5));

          return response.statusCode == 200;
        } catch (e) {
          // If HTTP request fails, still return true if we have network connectivity
          // This handles cases where the test URL might be blocked but internet works
          print('HTTP connectivity test failed, but network is available: $e');
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Internet connectivity check failed: $e');
      return false;
    }
  }

  /// Handles network-related errors and returns appropriate error messages
  Map<String, dynamic> _handleNetworkError(dynamic error) {
    String message = 'Network error occurred';

    if (error.toString().contains('SocketException') ||
        error.toString().contains('No internet connection')) {
      message =
          'No internet connection. Please check your network and try again.';
    } else if (error.toString().contains('TimeoutException')) {
      message = 'Request timed out. Please check your internet connection.';
    } else if (error.toString().contains('Connection refused') ||
        error.toString().contains('Failed to connect')) {
      message =
          'Unable to connect to server. Please check your internet connection.';
    } else if (error.toString().contains('Connection reset') ||
        error.toString().contains('Connection closed')) {
      message =
          'Connection lost. Please check your internet connection and try again.';
    }

    return {'success': false, 'message': message, 'error': 'network_error'};
  }

  /// Initialize the service and restore authentication state from persistent storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token != null) {
        // Validate token with backend
        final isValid = await _validateToken(token);

        if (isValid) {
          // Restore user data from storage
          _token = token;
          _userId = prefs.getString(_userIdKey);
          _nickname = prefs.getString(_nicknameKey);
          _level = prefs.getInt(_levelKey) ?? 0;
          _userPhone = prefs.getString(_phoneKey);
          _language = prefs.getString(_languageKey) ?? 'English';
          _isVerified = prefs.getBool(_isVerifiedKey) ?? false;
          _isAuthenticated = true;

          print('Authentication restored from storage');
        } else {
          // Token is invalid, clear stored data
          await _clearStoredAuthData();
          print('Stored token is invalid, cleared auth data');
        }
      }
    } catch (e) {
      print('Error initializing auth service: $e');
      await _clearStoredAuthData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Validates a JWT token with the backend
  Future<bool> _validateToken(String token) async {
    try {
      // Basic token format validation
      if (token.isEmpty ||
          !token.contains('.') ||
          token.split('.').length != 3) {
        print('Invalid token format');
        return false;
      }

      final url = Uri.parse('$apiUrl/api/players/profile');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10)); // Add timeout

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else if (response.statusCode == 401) {
        print('Token expired or invalid');
        return false;
      }
      return false;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  /// Saves authentication data to persistent storage
  Future<void> _saveAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_token != null) {
        await prefs.setString(_tokenKey, _token!);
      }
      if (_userId != null) {
        await prefs.setString(_userIdKey, _userId!);
      }
      if (_nickname != null) {
        await prefs.setString(_nicknameKey, _nickname!);
      }
      if (_userPhone != null) {
        await prefs.setString(_phoneKey, _userPhone!);
      }

      await prefs.setInt(_levelKey, _level);
      await prefs.setString(_languageKey, _language);
      await prefs.setBool(_isVerifiedKey, _isVerified);

      print('Authentication data saved to storage');
    } catch (e) {
      print('Error saving auth data: $e');
    }
  }

  /// Clears all authentication data from persistent storage
  Future<void> _clearStoredAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_nicknameKey);
      await prefs.remove(_levelKey);
      await prefs.remove(_phoneKey);
      await prefs.remove(_languageKey);
      await prefs.remove(_isVerifiedKey);

      print('Authentication data cleared from storage');
    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }

  /// Sets the authentication state
  void setAuthenticated(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    if (!isAuthenticated) {
      _token = null;
      _userId = null;
      _nickname = null;
      _level = 0;
      _language = 'English';
      _isVerified = false;
      _userPhone = null;
      _clearStoredAuthData();
    }
    notifyListeners();
  }

  /// Sets the JWT token for API authentication
  void setToken(String token) {
    _token = token;
    _saveAuthData();
    notifyListeners();
  }

  /// Sets the user ID
  void setUserId(String userId) {
    _userId = userId;
    _saveAuthData();
    notifyListeners();
  }

  /// Sets the user's nickname
  void setNickname(String nickname) {
    _nickname = nickname;
    _saveAuthData();
    notifyListeners();
  }

  /// Sets the user's level
  void setLevel(int level) {
    _level = level;
    _saveAuthData();
    notifyListeners();
  }

  /// Sets the user's preferred language
  void setLanguage(String language) {
    _language = language;
    _saveAuthData();
    notifyListeners();
  }

  /// Formats a phone number to the standard international format.
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

  /// Registers a new user with the backend
  Future<Map<String, dynamic>> registerUser({
    required String whatsappNumber,
    required String nickname,
    required String language,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check internet connectivity first
      final hasInternet = await _hasInternetConnection();
      if (!hasInternet) {
        return {
          'success': false,
          'message':
              'No internet connection. Please check your network and try again.',
          'error': 'no_internet'
        };
      }

      final formattedPhone = _formatPhoneNumber(whatsappNumber);
      final url = Uri.parse('$apiUrl/api/players/register');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'whatsapp_number': formattedPhone,
              'nickname': nickname,
              'language': language,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _userPhone = formattedPhone;
        _nickname = nickname;
        _language = language;
        _isNewUser = true;

        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful',
          'data': data['data']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
          'error': data['error']
        };
      }
    } catch (e) {
      print('Registration error: $e');
      return _handleNetworkError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Requests login OTP for an existing user
  Future<Map<String, dynamic>> requestLoginOTP(String whatsappNumber) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check internet connectivity first
      final hasInternet = await _hasInternetConnection();
      if (!hasInternet) {
        return {
          'success': false,
          'message':
              'No internet connection. Please check your network and try again.',
          'error': 'no_internet'
        };
      }

      final formattedPhone = _formatPhoneNumber(whatsappNumber);
      final url = Uri.parse('$apiUrl/api/players/login');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'whatsapp_number': formattedPhone,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _userPhone = formattedPhone;
        _isNewUser = false;

        return {
          'success': true,
          'message': data['message'] ?? 'Login OTP sent',
          'data': data['data']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
          'error': data['error']
        };
      }
    } catch (e) {
      print('Login OTP request error: $e');
      return _handleNetworkError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verifies the OTP code entered by the user
  Future<Map<String, dynamic>> verifyOTP(String otp) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_userPhone == null) {
        return {
          'success': false,
          'message': 'Phone number not set',
          'error': 'No phone number'
        };
      }

      // Check internet connectivity first
      final hasInternet = await _hasInternetConnection();
      if (!hasInternet) {
        return {
          'success': false,
          'message':
              'No internet connection. Please check your network and try again.',
          'error': 'no_internet'
        };
      }

      final url = Uri.parse('$apiUrl/api/players/verify');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'whatsapp_number': _userPhone,
              'otp_code': otp,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final playerData = data['data'];

        // Set authentication data
        _token = playerData['token'];
        _userId = playerData['player']['id'].toString();
        _nickname = playerData['player']['nickname'];
        _level = playerData['player']['level'] ?? 0;
        _isVerified = playerData['player']['is_verified'] ?? false;
        _isAuthenticated = true;

        // Save to persistent storage
        await _saveAuthData();

        // Navigate to home screen
        NavigationService().navigateToReplacement('/home');

        return {
          'success': true,
          'message': data['message'] ?? 'Verification successful',
          'data': playerData
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Verification failed',
          'error': data['error']
        };
      }
    } catch (e) {
      print('OTP verification error: $e');
      return _handleNetworkError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Checks if an account exists for the given phone number and sends OTP
  Future<bool> checkPhoneAndSendOTP(String phone) async {
    try {
      final formattedPhone = _formatPhoneNumber(phone);

      // First, try to request login OTP (for existing users)
      final loginResult = await requestLoginOTP(formattedPhone);

      if (loginResult['success']) {
        _isNewUser = false;
        return true;
      }

      // If login failed, the user might be new, so we'll handle this in the UI
      // by showing registration form
      _userPhone = formattedPhone;
      _isNewUser = true;
      notifyListeners();
      return true;
    } catch (e) {
      print('Phone check error: $e');
      return false;
    }
  }

  /// Signs out the current user and clears all user data
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Call backend logout endpoint if we have a token
      if (_token != null) {
        final url = Uri.parse('$apiUrl/api/players/logout');
        try {
          // Check internet connectivity, but don't block logout if no internet
          final hasInternet = await _hasInternetConnection();
          if (hasInternet) {
            await http.post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_token',
              },
            ).timeout(const Duration(seconds: 15));
            print('Backend logout successful');
          } else {
            print('No internet connection - proceeding with local logout only');
          }
        } catch (e) {
          print('Backend logout error: $e');
          // Continue with local logout even if backend call fails
        }
      }

      // Clear all authentication data
      await _clearStoredAuthData();

      // Reset all user-related data
      _isAuthenticated = false;
      _userId = null;
      _userPhone = null;
      _verificationId = null;
      _isNewUser = false;
      _token = null;
      _nickname = null;
      _level = 0;
      _language = 'English';
      _isVerified = false;
      _balance = 0.0;
      _transactions.clear();
      _gameHistory.clear();
      _lastCompetitionLeaderboard = null;
      _leaderboardHistory = null;

      // Reset navigation state and redirect to auth screen
      final navigationService = NavigationService();
      navigationService.resetNavigation();
      navigationService.navigateToReplacement('/auth');

      print('User signed out successfully');
    } catch (e) {
      print('Sign out error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new game result to the user's history
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

  /// Fetches the last competition leaderboard for the authenticated user
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
      ).timeout(const Duration(seconds: 15));
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
      print('Error fetching last competition leaderboard: $e');
      return false;
    }
  }

  /// Fetches the full leaderboard history for the authenticated user
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
      ).timeout(const Duration(seconds: 15));
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
      print('Error fetching leaderboard history: $e');
      return false;
    }
  }

  /// Deposits funds into the user's account
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
      print('Deposit error: $e');
      return false;
    }
  }

  /// Withdraws funds from the user's account
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
      print('Withdrawal error: $e');
      return false;
    }
  }

  /// Completes the registration process for new users
  Future<bool> completeRegistration(String password) async {
    try {
      // TODO: Replace with actual API call to complete registration
      await Future.delayed(const Duration(seconds: 1));

      _isAuthenticated = true;
      _userId = 'user_${_userPhone}';
      _balance = 0.0; // New users start with 0 balance
      await _saveAuthData();
      notifyListeners();

      // Navigate to home screen
      NavigationService().navigateToReplacement('/home');

      return true;
    } catch (e) {
      print('Registration completion error: $e');
      return false;
    }
  }

  /// Static method for registering a new user (backward compatibility)
  static Future<bool> register({
    required String whatsappNumber,
    required String nickname,
    required String language,
  }) async {
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
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Static registration error: $e');
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
