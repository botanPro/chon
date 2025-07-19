import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Privacy Policy screen displaying real content for Chon App
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1615),
              Color(0xFF0A0E0D),
              Color(0xFF0E1211),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildSectionTitle('Privacy Policy'),
                const SizedBox(height: 16),
                _buildPolicyText(
                  'Effective Date: July 12, 2025\n\n'
                  'Welcome to Chon, a fun and educational quiz game that promotes science learning across all age groups. '
                  'We care about your privacy and are committed to protecting your personal information. '
                  'This policy outlines how we handle your data while you enjoy using Chon.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Information We Collect'),
                const SizedBox(height: 16),
                _buildPolicyText(
                  'To enhance your experience and manage your progress in the app, we collect:\n\n'
                  '- Nickname \n'
                  '- Phone number (only if you choose to register or compete with friends)\n\n'
                  'We do not collect any sensitive or personally identifiable data unless explicitly provided by you.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('How We Use Your Information'),
                const SizedBox(height: 16),
                _buildPolicyText(
                  'We use your information to:\n\n'
                  '- Track your score and progress in quizzes\n'
                  '- Unlock games and challenges based on your score\n'
                  '- Allow you to compete with friends and other players\n'
                  '- Enhance learning content based on user feedback\n'
                  '- Ensure a safe, secure, and fair gameplay experience',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Data Security'),
                const SizedBox(height: 16),
                _buildPolicyText(
                  'Your data is encrypted and stored securely. We use the latest security practices to prevent unauthorized access. '
                  'We do not sell or share your personal data with third parties except when legally required.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Third-Party Services'),
                const SizedBox(height: 16),
                _buildPolicyText(
                  'We may use anonymous analytics tools to improve performance. These services do not collect personal information. '
                  'Any data shared with third parties is anonymized and used only for app improvement.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Your Rights'),
                const SizedBox(height: 16),
                _buildPolicyText(
                  'You have the right to:\n'
                  '- Access or update your profile info (nickname)\n'
                  '- Delete your account and associated data\n'
                  '- Contact us with questions about your data or privacy',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Terms & Conditions'),
                const SizedBox(height: 16),
                _buildPolicyText(
                  'By using Chon, you agree to the following:\n\n'
                  '- Use the app for educational and entertainment purposes only\n'
                  '- Do not misuse or attempt to disrupt the app’s operations\n'
                  '- Respect others when participating in friend competitions\n'
                  '- All quiz content and app design are owned by Chon and may not be copied\n'
                  '- We may update the app and these terms; you’ll be notified through the app interface',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Contact Us'),
                const SizedBox(height: 16),
                _buildPolicyText(
                  'If you have any questions or concerns about your data or this policy, please contact us:\n\n'
                  'Email: info@granddola.com\n'
                  'Phone: +964 750 650 44 44',
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        AppLocalizations.of(context)!.privacyPolicy,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildPolicyText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.8),
        fontSize: 16,
        height: 1.5,
      ),
    );
  }
}
