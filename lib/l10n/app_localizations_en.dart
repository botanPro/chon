// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CHON';

  @override
  String get compete => 'COMPETE';

  @override
  String get win => 'WIN';

  @override
  String get earn => 'EARN';

  @override
  String get signUp => 'Sign up';

  @override
  String get signIn => 'Sign in';

  @override
  String get welcomeToOurGameArea => 'WELCOME TO OUR 🎮 GAME AREA';

  @override
  String get signUpAccount => 'Sign Up Account';

  @override
  String get signInAccount => 'Sign In Account';

  @override
  String get signUpDescription =>
      'Enter your personal information to create your account';

  @override
  String get signInDescription =>
      'Enter your credentials to access your account';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneNumberHint => '750 999 9999';

  @override
  String get nickname => 'Nickname';

  @override
  String get nicknameHint => 'Your nickname';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get kurdishSorani => 'Kurdish Sorani';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get congratulations => 'Congratulations! 🎉';

  @override
  String get youWon => 'You Won';

  @override
  String score(int score) {
    return 'Score: $score';
  }

  @override
  String get days => 'Days';

  @override
  String get hours => 'Hours';

  @override
  String get minutes => 'Minutes';

  @override
  String get seconds => 'Seconds';

  @override
  String get gameWillStart =>
      'The Game will be started after 30 mos, 29 days, 29 hrs, 29 min.';

  @override
  String get gameName => 'Game Name';

  @override
  String get sinceYesterday => 'Since yesterday your ';

  @override
  String get sales => 'sales ';

  @override
  String get haveIncreased => 'have increased!';

  @override
  String level(int level) {
    return 'Level $level';
  }

  @override
  String get watchPattern => 'Watch the pattern...';

  @override
  String get repeatPattern => 'Repeat the pattern!';

  @override
  String get getReady => 'Get ready...';

  @override
  String get formAWord => 'Form a word';

  @override
  String get typeYourAnswer => 'Type your answer';

  @override
  String get firstName => 'First Name';

  @override
  String get firstNameHint => 'Enter your first name';

  @override
  String get lastName => 'Last Name';

  @override
  String get lastNameHint => 'Enter your last name';

  @override
  String get selectCity => 'Select your city';

  @override
  String get fillDetails =>
      'Please fill in your details to complete your profile';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get otpSent => 'OTP sent to your number.';

  @override
  String get ok => 'OK';

  @override
  String get signUpFailed => 'Sign up failed.';

  @override
  String get signInFailed => 'Sign in failed.';

  @override
  String get networkError => 'Network or App Error';

  @override
  String get enterPhoneNickname =>
      'Please enter phone, nickname, and select a language.';

  @override
  String get enterPhoneNumber => 'Please enter your phone number.';

  @override
  String combo(int combo) {
    return 'x$combo';
  }

  @override
  String multiplier(int multiplier) {
    return 'x$multiplier';
  }
}
