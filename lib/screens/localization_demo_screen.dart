import 'package:flutter/material.dart';
import '../widgets/language_switcher.dart';
import '../l10n/app_localizations.dart';

class LocalizationDemoScreen extends StatelessWidget {
  const LocalizationDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090C0B),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.language),
        backgroundColor: const Color(0xFF13131D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Switcher Section
              Card(
                color: const Color(0xFF151918),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.languageSwitcher,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      const LanguageSwitcher(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Auth Screen Examples
              Card(
                color: const Color(0xFF151918),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.authScreenExamples,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildTranslationExample(
                        context,
                        AppLocalizations.of(context)!.slogan,
                        '${AppLocalizations.of(context)!.compete} • ${AppLocalizations.of(context)!.win} • ${AppLocalizations.of(context)!.earn}',
                      ),
                      _buildTranslationExample(
                        context,
                        AppLocalizations.of(context)!.buttons,
                        '${AppLocalizations.of(context)!.signUp} / ${AppLocalizations.of(context)!.signIn}',
                      ),
                      _buildTranslationExample(
                        context,
                        AppLocalizations.of(context)!.welcomeMessage,
                        AppLocalizations.of(context)!.welcomeToOurGameArea,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Form Fields Examples
              Card(
                color: const Color(0xFF151918),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.formFieldsExamples,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildTranslationExample(
                        context,
                        AppLocalizations.of(context)!.phoneNumber,
                        AppLocalizations.of(context)!.phoneNumberHint,
                      ),
                      _buildTranslationExample(
                        context,
                        AppLocalizations.of(context)!.nickname,
                        AppLocalizations.of(context)!.nicknameHint,
                      ),
                      _buildTranslationExample(
                        context,
                        AppLocalizations.of(context)!.language,
                        '${AppLocalizations.of(context)!.english} / ${AppLocalizations.of(context)!.kurdishSorani}',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Game UI Examples
              Card(
                color: const Color(0xFF151918),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.gameUIExamples,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildTranslationExample(
                        context,
                        AppLocalizations.of(context)!.timeUnits,
                        '${AppLocalizations.of(context)!.days} • ${AppLocalizations.of(context)!.hours} • ${AppLocalizations.of(context)!.minutes} • ${AppLocalizations.of(context)!.seconds}',
                      ),
                      _buildTranslationExample(
                        context,
                        AppLocalizations.of(context)!.levelDisplay,
                        AppLocalizations.of(context)!.level(5),
                      ),
                      _buildTranslationExample(
                        context,
                        AppLocalizations.of(context)!.scoreDisplay,
                        AppLocalizations.of(context)!.score(1250),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Status Messages Examples
              Card(
                color: const Color(0xFF151918),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.statusMessagesExamples,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildTranslationExample(
                        context,
                        AppLocalizations.of(context)!.successMessages,
                        '${AppLocalizations.of(context)!.success} • ${AppLocalizations.of(context)!.otpSent}',
                      ),
                      _buildTranslationExample(
                        context,
                        AppLocalizations.of(context)!.errorMessages,
                        '${AppLocalizations.of(context)!.error} • ${AppLocalizations.of(context)!.signUpFailed}',
                      ),
                      _buildTranslationExample(
                        context,
                        AppLocalizations.of(context)!.gameInstructions,
                        '${AppLocalizations.of(context)!.watchPattern} • ${AppLocalizations.of(context)!.repeatPattern}',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Card(
                color: const Color(0xFF151918),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.actionButtons,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                              child: Text(AppLocalizations.of(context)!.signUp),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(AppLocalizations.of(context)!.signIn),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationExample(
    BuildContext context,
    String label,
    String translation,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF96C3BC),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            translation,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}
