import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kr')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'CHON'**
  String get appTitle;

  /// Compete text on auth screen
  ///
  /// In en, this message translates to:
  /// **'COMPETE'**
  String get compete;

  /// Win text on auth screen
  ///
  /// In en, this message translates to:
  /// **'WIN'**
  String get win;

  /// Earn text on auth screen
  ///
  /// In en, this message translates to:
  /// **'EARN'**
  String get earn;

  /// Sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// Welcome message in auth drawer
  ///
  /// In en, this message translates to:
  /// **'WELCOME TO OUR 🎮 GAME AREA'**
  String get welcomeToOurGameArea;

  /// Sign up account header
  ///
  /// In en, this message translates to:
  /// **'Sign Up Account'**
  String get signUpAccount;

  /// Sign in account header
  ///
  /// In en, this message translates to:
  /// **'Sign In Account'**
  String get signInAccount;

  /// Sign up description text
  ///
  /// In en, this message translates to:
  /// **'Enter your personal information to create your account'**
  String get signUpDescription;

  /// Sign in description text
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to access your account'**
  String get signInDescription;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Phone number field hint
  ///
  /// In en, this message translates to:
  /// **'750 999 9999'**
  String get phoneNumberHint;

  /// Nickname field label
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// Nickname field hint
  ///
  /// In en, this message translates to:
  /// **'Your nickname'**
  String get nicknameHint;

  /// Language field label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Kurdish Sorani language option
  ///
  /// In en, this message translates to:
  /// **'Kurdish Sorani'**
  String get kurdishSorani;

  /// Don't have account text
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// Already have account text
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Congratulations message in prize dialog
  ///
  /// In en, this message translates to:
  /// **'Congratulations! 🎉'**
  String get congratulations;

  /// You won text in prize dialog
  ///
  /// In en, this message translates to:
  /// **'You Won'**
  String get youWon;

  /// Score display
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String score(int score);

  /// Days label in countdown
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// Hours label in countdown
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// Minutes label in countdown
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// Seconds label in countdown
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get seconds;

  /// Game start countdown message
  ///
  /// In en, this message translates to:
  /// **'The Game will be started after 30 mos, 29 days, 29 hrs, 29 min.'**
  String get gameWillStart;

  /// Game name label
  ///
  /// In en, this message translates to:
  /// **'Game Name'**
  String get gameName;

  /// Since yesterday text
  ///
  /// In en, this message translates to:
  /// **'Since yesterday your '**
  String get sinceYesterday;

  /// Sales text
  ///
  /// In en, this message translates to:
  /// **'sales '**
  String get sales;

  /// Have increased text
  ///
  /// In en, this message translates to:
  /// **'have increased!'**
  String get haveIncreased;

  /// Level display
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String level(int level);

  /// Watch pattern instruction
  ///
  /// In en, this message translates to:
  /// **'Watch the pattern...'**
  String get watchPattern;

  /// Repeat pattern instruction
  ///
  /// In en, this message translates to:
  /// **'Repeat the pattern!'**
  String get repeatPattern;

  /// Get ready message
  ///
  /// In en, this message translates to:
  /// **'Get ready...'**
  String get getReady;

  /// Form a word instruction
  ///
  /// In en, this message translates to:
  /// **'Form a word'**
  String get formAWord;

  /// Type answer hint
  ///
  /// In en, this message translates to:
  /// **'Type your answer'**
  String get typeYourAnswer;

  /// First name field label
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// First name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get firstNameHint;

  /// Last name field label
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// Last name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get lastNameHint;

  /// Select city hint
  ///
  /// In en, this message translates to:
  /// **'Select your city'**
  String get selectCity;

  /// Fill details instruction
  ///
  /// In en, this message translates to:
  /// **'Please fill in your details to complete your profile'**
  String get fillDetails;

  /// Success dialog title
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Error dialog title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// OTP sent message
  ///
  /// In en, this message translates to:
  /// **'OTP sent to your number.'**
  String get otpSent;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Sign up failed message
  ///
  /// In en, this message translates to:
  /// **'Sign up failed.'**
  String get signUpFailed;

  /// Sign in failed message
  ///
  /// In en, this message translates to:
  /// **'Sign in failed.'**
  String get signInFailed;

  /// Network error title
  ///
  /// In en, this message translates to:
  /// **'Network or App Error'**
  String get networkError;

  /// Enter phone and nickname validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter phone, nickname, and select a language.'**
  String get enterPhoneNickname;

  /// Enter phone number validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number.'**
  String get enterPhoneNumber;

  /// Combo multiplier display
  ///
  /// In en, this message translates to:
  /// **'x{combo}'**
  String combo(int combo);

  /// Score multiplier display
  ///
  /// In en, this message translates to:
  /// **'x{multiplier}'**
  String multiplier(int multiplier);

  /// Notification button text
  ///
  /// In en, this message translates to:
  /// **'Notify Me'**
  String get notifyMe;

  /// Language switcher section title
  ///
  /// In en, this message translates to:
  /// **'Language Switcher'**
  String get languageSwitcher;

  /// Auth screen examples section title
  ///
  /// In en, this message translates to:
  /// **'Auth Screen Examples'**
  String get authScreenExamples;

  /// Form fields examples section title
  ///
  /// In en, this message translates to:
  /// **'Form Fields Examples'**
  String get formFieldsExamples;

  /// Game UI examples section title
  ///
  /// In en, this message translates to:
  /// **'Game UI Examples'**
  String get gameUIExamples;

  /// Status messages examples section title
  ///
  /// In en, this message translates to:
  /// **'Status Messages Examples'**
  String get statusMessagesExamples;

  /// Action buttons section title
  ///
  /// In en, this message translates to:
  /// **'Action Buttons'**
  String get actionButtons;

  /// Slogan label
  ///
  /// In en, this message translates to:
  /// **'Slogan'**
  String get slogan;

  /// Buttons label
  ///
  /// In en, this message translates to:
  /// **'Buttons'**
  String get buttons;

  /// Welcome message label
  ///
  /// In en, this message translates to:
  /// **'Welcome Message'**
  String get welcomeMessage;

  /// Time units label
  ///
  /// In en, this message translates to:
  /// **'Time Units'**
  String get timeUnits;

  /// Level display label
  ///
  /// In en, this message translates to:
  /// **'Level Display'**
  String get levelDisplay;

  /// Score display label
  ///
  /// In en, this message translates to:
  /// **'Score Display'**
  String get scoreDisplay;

  /// Success messages label
  ///
  /// In en, this message translates to:
  /// **'Success Messages'**
  String get successMessages;

  /// Error messages label
  ///
  /// In en, this message translates to:
  /// **'Error Messages'**
  String get errorMessages;

  /// Game instructions label
  ///
  /// In en, this message translates to:
  /// **'Game Instructions'**
  String get gameInstructions;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kr':
      return AppLocalizationsKr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
