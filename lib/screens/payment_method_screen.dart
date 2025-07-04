import 'package:flutter/material.dart';
import 'trivia_game_screen.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';

class PaymentMethodScreen extends StatefulWidget {
  final double amount;
  final String gameName;
  final String competitionId;

  const PaymentMethodScreen({
    super.key,
    required this.amount,
    required this.gameName,
    required this.competitionId,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int _selectedPaymentMethod = 0; // Default to Visa (first option)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090C0B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Payment Method',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(30, 30, 30, 20),
            child: Text(
              'Choose a Payment Gateway',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildPaymentOption(
            0,
            'Visa Card',
            Icons.credit_card,
            Colors.blue,
            'Just a random text here',
          ),
          _buildPaymentOption(
            1,
            'Master Card',
            Icons.credit_card,
            Colors.orange,
            'Just a random text here',
          ),
          _buildPaymentOption(
            2,
            'Apple Pay',
            Icons.apple,
            Colors.white,
            'Just a random text here',
          ),
          _buildPaymentOption(
            3,
            'Stripe',
            Icons.attach_money,
            Colors.purple,
            'Just a random text here',
          ),
          _buildPaymentOption(
            4,
            'PayPal',
            Icons.account_balance_wallet,
            Colors.blue,
            'Just a random text here',
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Process payment
                  _processPayment();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1E1D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(int index, String title, IconData icon,
      Color iconColor, String description) {
    bool isSelected = _selectedPaymentMethod == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF101513),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Logo with icon
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.grey,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(
                          Icons.circle,
                          size: 12,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processPayment() {
    // Show a success dialog or navigate to confirmation screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101513),
        title: const Text(
          'Payment Confirmation',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You are about to purchase ${widget.gameName} for \$${widget.amount.toInt()}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            const Text(
              'Do you want to proceed?',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _showPaymentSuccessAndNavigate();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }

  void _showPaymentSuccessAndNavigate() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101513),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text(
              'Payment Successful',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your payment for ${widget.gameName} has been processed successfully.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            const Text(
              'Get ready to play!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close success dialog
              Navigator.pop(context); // Close payment screen

              // Navigate to the trivia game screen
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              final playerId = authService.userId ?? 'player_demo';
              final playerName = authService.nickname ?? 'User';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TriviaGameScreen(
                    competitionId: widget.competitionId,
                    playerId: playerId,
                    playerName: playerName,
                    competitionDetails: const {}, // TODO: Replace with real details if available
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Game'),
          ),
        ],
      ),
    );
  }
}
