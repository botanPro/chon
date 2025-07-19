import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import '../l10n/app_localizations.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool showTitle;
  final bool isCompact;

  const LanguageSwitcher({
    super.key,
    this.showTitle = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTitle && !isCompact)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  AppLocalizations.of(context)!.language,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            Directionality(
              textDirection: localizationService.textDirection,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF151918),
                  borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: localizationService.currentLanguageCode,
                    isExpanded: !isCompact,
                    dropdownColor: const Color(0xFF151918),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: isCompact ? 16 : 20,
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isCompact ? 12 : 14,
                      fontFamily: 'Inter',
                    ),
                    items: LocalizationService.supportedLocales.map((locale) {
                      final languageCode = locale.languageCode;
                      final languageName =
                          _getLanguageName(context, languageCode);

                      return DropdownMenuItem<String>(
                        value: languageCode,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 8 : 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _getLanguageFlag(languageCode),
                              const SizedBox(width: 8),
                              Text(
                                languageName,
                                style: TextStyle(
                                  fontSize: isCompact ? 12 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newLanguageCode) {
                      if (newLanguageCode != null) {
                        localizationService.changeLanguage(newLanguageCode);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getLanguageName(BuildContext context, String languageCode) {
    switch (languageCode) {
      case 'en':
        return AppLocalizations.of(context)!.english;
      case 'kr':
        return AppLocalizations.of(context)!.kurdishSorani;
      default:
        return 'English';
    }
  }

  Widget _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return Container(
          width: 20,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: const Color(0xFF012169),
          ),
          child: const Center(
            child: Text(
              '🇺🇸',
              style: TextStyle(fontSize: 10),
            ),
          ),
        );
      case 'kr':
        return Container(
          width: 20,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: const Color(0xFFCE1126),
          ),
          child: const Center(
            child: Text(
              '🏳️',
              style: TextStyle(fontSize: 10),
            ),
          ),
        );
      default:
        return const SizedBox(width: 20, height: 14);
    }
  }
}

class CompactLanguageSwitcher extends StatelessWidget {
  const CompactLanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return const LanguageSwitcher(
      showTitle: false,
      isCompact: true,
    );
  }
}
