# Multi-Language Support Guide for CHON Game App

This guide explains how to use and extend the multi-language (internationalization) system implemented in the CHON Flutter app.

## Overview

The app now supports two languages:

-   **English (en)** - Default language
-   **Kurdish Sorani (kr)** - Secondary language

## Architecture

### Key Components

1. **Localization Service** (`lib/services/localization_service.dart`)

    - Manages current language state
    - Persists language preference using SharedPreferences
    - Provides language switching functionality

2. **Translation Files** (`lib/l10n/`)

    - `app_en.arb` - English translations
    - `app_kr.arb` - Kurdish Sorani translations
    - `app_localizations.dart` - Generated localization class

3. **Language Switcher Widget** (`lib/widgets/language_switcher.dart`)

    - Full language switcher with title
    - Compact language switcher for limited space

4. **Demo Screen** (`lib/screens/localization_demo_screen.dart`)
    - Showcases all translated UI elements
    - Accessible via route `/localization-demo`

## Setup and Configuration

### 1. Dependencies

The following packages are configured in `pubspec.yaml`:

```yaml
dependencies:
    flutter_localizations:
        sdk: flutter
    intl: ^0.20.2
    shared_preferences: ^2.2.2
    provider: ^6.1.1

flutter:
    generate: true
```

### 2. Configuration Files

-   `l10n.yaml` - Configures localization generation
-   Generated files are placed in `lib/l10n/`

## Usage

### Getting Translated Text

```dart
import '../l10n/app_localizations.dart';

// Basic text
Text(AppLocalizations.of(context)!.signUp)

// Text with parameters
Text(AppLocalizations.of(context)!.level(5))
Text(AppLocalizations.of(context)!.score(1250))
```

### Using Language Switcher

```dart
// Full language switcher
const LanguageSwitcher()

// Compact version (for toolbars, headers)
const CompactLanguageSwitcher()
```

### Programmatic Language Change

```dart
import 'package:provider/provider.dart';
import '../services/localization_service.dart';

// Get the service
final localizationService = Provider.of<LocalizationService>(context, listen: false);

// Change language
await localizationService.changeLanguage('kr'); // Switch to Kurdish
await localizationService.changeLanguage('en'); // Switch to English

// Get current language
final currentLang = localizationService.currentLanguageCode;
```

## Implementation Examples

### 1. Updated Auth Screen

The auth screen now uses localized text for:

-   Slogan (COMPETE, WIN, EARN)
-   Button labels (Sign up, Sign in)
-   Form field labels and hints
-   Error and success messages
-   Account switching prompts

### 2. Updated Home Screen

-   Time unit labels (Days, Hours, Minutes, Seconds)
-   Level display
-   Countdown messages
-   Compact language switcher in header

### 3. Demo Screen

Access via route `/localization-demo` to see all translated elements in action.

## Adding New Translations

### 1. Add to English ARB file (`lib/l10n/app_en.arb`)

```json
{
	"newKey": "English Text",
	"@newKey": {
		"description": "Description of what this text is for"
	}
}
```

### 2. Add to Kurdish ARB file (`lib/l10n/app_kr.arb`)

```json
{
	"newKey": "کوردی",
	"@newKey": {
		"description": "Description of what this text is for"
	}
}
```

### 3. Regenerate Localization Files

```bash
flutter gen-l10n
```

### 4. Use in Code

```dart
Text(AppLocalizations.of(context)!.newKey)
```

## Advanced Features

### Text with Parameters

For dynamic content, use placeholders:

**ARB file:**

```json
{
	"welcomeMessage": "Welcome back, {username}!",
	"@welcomeMessage": {
		"description": "Welcome message with username",
		"placeholders": {
			"username": {
				"type": "String",
				"example": "John"
			}
		}
	}
}
```

**Usage:**

```dart
Text(AppLocalizations.of(context)!.welcomeMessage('John'))
```

### Pluralization

For text that changes based on quantity:

**ARB file:**

```json
{
	"itemCount": "{count, plural, =0{No items} =1{One item} other{{count} items}}",
	"@itemCount": {
		"description": "Item count with pluralization",
		"placeholders": {
			"count": {
				"type": "num",
				"format": "compact"
			}
		}
	}
}
```

## Testing

### 1. Run the Demo Screen

Navigate to `/localization-demo` to test all translations:

```dart
Navigator.pushNamed(context, '/localization-demo');
```

### 2. Test Language Switching

-   Use the language switcher in the demo screen
-   Verify text changes immediately
-   Confirm language preference persists after app restart

### 3. Test in Different Screens

-   Auth screen: Form fields and messages
-   Home screen: Time units and level display
-   All dialog boxes and error messages

## Best Practices

### 1. Always Use Context

```dart
// ✅ Good
AppLocalizations.of(context)!.signUp

// ❌ Bad - don't store references
final localizations = AppLocalizations.of(context)!;
```

### 2. Handle Null Safety

```dart
// ✅ Good
AppLocalizations.of(context)?.signUp ?? 'Sign Up'

// ✅ Better with null assertion if you're sure context has localizations
AppLocalizations.of(context)!.signUp
```

### 3. Organize Translation Keys

Use consistent naming conventions:

-   `screenName_elementType_purpose` (e.g., `auth_button_signUp`)
-   Group related translations together in ARB files

### 4. Provide Context in Descriptions

Always include meaningful descriptions in ARB files to help translators understand context.

## File Structure

```
lib/
├── l10n/
│   ├── app_en.arb              # English translations
│   ├── app_kr.arb              # Kurdish translations
│   ├── app_localizations.dart  # Generated base class
│   ├── app_localizations_en.dart # Generated English class
│   └── app_localizations_kr.dart # Generated Kurdish class
├── services/
│   └── localization_service.dart # Language management
├── widgets/
│   └── language_switcher.dart    # Language switcher widgets
└── screens/
    ├── localization_demo_screen.dart # Demo screen
    └── ... (other screens with localization)
```

## Future Enhancements

1. **Add More Languages**: Extend support to Arabic, Turkish, etc.
2. **Right-to-Left (RTL) Support**: For languages like Arabic
3. **Date/Number Formatting**: Locale-specific formatting
4. **Dynamic Language Loading**: Load translations from server
5. **Translation Management**: Integration with translation services

## Troubleshooting

### Common Issues

1. **Localization not working**

    - Run `flutter gen-l10n` after changes
    - Ensure `flutter: generate: true` in pubspec.yaml

2. **Context errors**

    - Ensure widget is wrapped in MaterialApp with localization delegates
    - Check if context has access to AppLocalizations

3. **Language not persisting**

    - Verify SharedPreferences permissions
    - Check LocalizationService initialization in main.dart

4. **Missing translations**
    - Ensure keys exist in both ARB files
    - Regenerate with `flutter gen-l10n`

### Debug Commands

```bash
# Regenerate localization files
flutter gen-l10n

# Clean and rebuild
flutter clean && flutter pub get && flutter gen-l10n

# Check for localization issues
flutter analyze
```

## Conclusion

The multi-language system is now fully integrated into the CHON app. Users can switch between English and Kurdish Sorani seamlessly, with all UI text properly translated and language preferences persisted across app sessions.

For questions or issues, refer to the demo screen (`/localization-demo`) which showcases all implemented features.
