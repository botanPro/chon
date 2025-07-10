import 'package:flutter/material.dart';

/// Privacy Policy screen displaying dummy/lorem ipsum content
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
              Color(0xFF0A1615), // Darker teal-black at top
              Color(0xFF0A0E0D), // Dark background in middle
              Color(0xFF0E1211), // Slightly lighter at bottom
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
                  'Effective Date: January 1, 2024\n\n'
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                  'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                  'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris '
                  'nisi ut aliquip ex ea commodo consequat.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Information We Collect'),
                const SizedBox(height: 16),
                _buildPolicyText(
                  'Duis aute irure dolor in reprehenderit in voluptate velit esse '
                  'cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat '
                  'cupidatat non proident, sunt in culpa qui officia deserunt mollit '
                  'anim id est laborum.\n\n'
                  'Sed ut perspiciatis unde omnis iste natus error sit voluptatem '
                  'accusantium doloremque laudantium, totam rem aperiam, eaque ipsa '
                  'quae ab illo inventore veritatis et quasi architecto beatae vitae '
                  'dicta sunt explicabo.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('How We Use Your Information'),
                const SizedBox(height: 16),
                _buildPolicyText(
                  'Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit '
                  'aut fugit, sed quia consequuntur magni dolores eos qui ratione '
                  'voluptatem sequi nesciunt.\n\n'
                  'Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, '
                  'consectetur, adipisci velit, sed quia non numquam eius modi tempora '
                  'incidunt ut labore et dolore magnam aliquam quaerat voluptatem.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Data Security'),
                const SizedBox(height: 16),
                _buildPolicyText(
                  'Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis '
                  'suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? '
                  'Quis autem vel eum iure reprehenderit qui in ea voluptate velit '
                  'esse quam nihil molestiae consequatur.\n\n'
                  'At vero eos et accusamus et iusto odio dignissimos ducimus qui '
                  'blanditiis praesentium voluptatum deleniti atque corrupti quos '
                  'dolores et quas molestias excepturi sint occaecati cupiditate non provident.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Third-Party Services'),
                const SizedBox(height: 16),
                _buildPolicyText(
                  'Similique sunt in culpa qui officia deserunt mollitia animi, id est '
                  'laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita '
                  'distinctio. Nam libero tempore, cum soluta nobis est eligendi optio '
                  'cumque nihil impedit quo minus id quod maxime placeat facere possimus.\n\n'
                  'Omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem '
                  'quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet '
                  'ut et voluptates repudiandae sint et molestiae non recusandae.',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Contact Us'),
                const SizedBox(height: 16),
                _buildPolicyText(
                  'Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis '
                  'voluptatibus maiores alias consequatur aut perferendis doloribus '
                  'asperiores repellat.\n\n'
                  'If you have any questions about this Privacy Policy, please contact us at:\n'
                  'Email: privacy@example.com\n'
                  'Phone: +1 (555) 123-4567\n'
                  'Address: 123 Main Street, City, State, ZIP Code',
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the app bar with title and back button
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Privacy & Policy',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  /// Builds a section title with consistent styling
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

  /// Builds policy text with consistent styling
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
