import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Custom RTL Material Localizations Delegate for Kurdish
class RTLMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const RTLMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Support Kurdish as RTL
    return locale.languageCode == 'kr' || locale.languageCode == 'ar';
  }

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    if (locale.languageCode == 'kr') {
      // Use Arabic RTL behavior for Kurdish
      return const RTLMaterialLocalizations();
    }
    // Fall back to default
    return DefaultMaterialLocalizations();
  }

  @override
  bool shouldReload(RTLMaterialLocalizationsDelegate old) => false;
}

/// Custom RTL Material Localizations for Kurdish
class RTLMaterialLocalizations extends DefaultMaterialLocalizations {
  const RTLMaterialLocalizations();

  @override
  TextDirection get textDirection => TextDirection.rtl;

  @override
  String get backButtonTooltip => 'گەڕانەوە';

  @override
  String get closeButtonTooltip => 'داخستن';

  @override
  String get deleteButtonTooltip => 'سڕینەوە';

  @override
  String get moreButtonTooltip => 'زیاتر';

  @override
  String get searchFieldLabel => 'گەڕان';

  @override
  String get menuButtonTooltip => 'مێنیو';

  @override
  String get drawerLabel => 'مێنیوی ناوبری';

  @override
  String get popupMenuLabel => 'مێنیوی سەرەکی';

  @override
  String get dialogLabel => 'گفتوگۆ';

  @override
  String get alertDialogLabel => 'ئاگاداری';

  @override
  String get anteMeridiemAbbreviation => 'ب.ن';

  @override
  String get postMeridiemAbbreviation => 'د.ن';

  @override
  String get timePickerHourModeAnnouncement => 'کاتژمێر هەڵبژێرە';

  @override
  String get timePickerMinuteModeAnnouncement => 'خولەک هەڵبژێرە';

  @override
  String get modalBarrierDismissLabel => 'داخستن';

  @override
  String get signedInLabel => 'چووەتە ژوورەوە';

  @override
  String get hideAccountsLabel => 'شاردنەوەی هەژمارەکان';

  @override
  String get showAccountsLabel => 'پیشاندانی هەژمارەکان';

  @override
  String get reorderItemUp => 'بردنە سەرەوە';

  @override
  String get reorderItemDown => 'بردنە خوارەوە';

  @override
  String get reorderItemLeft => 'بردنە چەپ';

  @override
  String get reorderItemRight => 'بردنە ڕاست';

  @override
  String get expandedIconTapHint => 'داخستن';

  @override
  String get collapsedIconTapHint => 'کردنەوە';

  @override
  String get refreshIndicatorSemanticLabel => 'تازەکردنەوە';

  @override
  String get nextMonthTooltip => 'مانگی داهاتوو';

  @override
  String get previousMonthTooltip => 'مانگی پێشوو';

  @override
  String get nextPageTooltip => 'پەڕەی داهاتوو';

  @override
  String get previousPageTooltip => 'پەڕەی پێشوو';

  @override
  String get firstPageTooltip => 'یەکەم پەڕە';

  @override
  String get lastPageTooltip => 'کۆتا پەڕە';

  @override
  String get showMenuTooltip => 'پیشاندانی مێنیو';

  @override
  String aboutListTileTitle(String applicationName) {
    return 'دەربارەی $applicationName';
  }

  @override
  String pageRowsInfoTitle(int firstRowIndex, int lastRowIndex, int rowCount,
      bool rowCountIsApproximate) {
    return '$firstRowIndex–$lastRowIndex لە $rowCount';
  }

  @override
  String tabLabel({required int tabIndex, required int tabCount}) {
    return 'تابی $tabIndex لە $tabCount';
  }

  @override
  String selectedRowCountTitle(int selectedRowCount) {
    return '$selectedRowCount هەڵبژێردراو';
  }
}

/// Custom RTL Cupertino Localizations Delegate for Kurdish
class RTLCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const RTLCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'kr' || locale.languageCode == 'ar';
  }

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    if (locale.languageCode == 'kr') {
      return const RTLCupertinoLocalizations();
    }
    return DefaultCupertinoLocalizations();
  }

  @override
  bool shouldReload(RTLCupertinoLocalizationsDelegate old) => false;
}

/// Custom RTL Cupertino Localizations for Kurdish
class RTLCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const RTLCupertinoLocalizations();

  @override
  TextDirection get textDirection => TextDirection.rtl;

  @override
  String get alertDialogLabel => 'ئاگاداری';

  @override
  String get anteMeridiemAbbreviation => 'ب.ن';

  @override
  String get postMeridiemAbbreviation => 'د.ن';

  @override
  String get copyButtonLabel => 'کۆپیکردن';

  @override
  String get cutButtonLabel => 'بڕین';

  @override
  String get pasteButtonLabel => 'لکاندن';

  @override
  String get selectAllButtonLabel => 'هەموو هەڵبژێرە';

  @override
  String get searchTextFieldPlaceholderLabel => 'گەڕان';

  @override
  String get modalBarrierDismissLabel => 'داخستن';

  @override
  String tabSemanticsLabel({required int tabIndex, required int tabCount}) {
    return 'تابی $tabIndex لە $tabCount';
  }

  @override
  String timerPickerHour(int hour) => hour.toString();

  @override
  String timerPickerMinute(int minute) => minute.toString();

  @override
  String timerPickerSecond(int second) => second.toString();

  @override
  String get todayLabel => 'ئەمڕۆ';
}
