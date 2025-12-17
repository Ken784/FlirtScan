import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 將 Locale 轉換為語言代碼字串（例如：Locale('zh', 'TW') -> 'zh-TW'）
String localeToLanguageCode(Locale locale) {
  if (locale.countryCode != null) {
    return '${locale.languageCode}-${locale.countryCode}';
  }
  return locale.languageCode;
}

/// Locale Provider
/// 提供當前的 Locale 設定，預設為 zh-TW
final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('zh', 'TW');
});

/// 語言代碼 Provider
/// 提供當前的語言代碼字串（例如：'zh-TW'）
final languageCodeProvider = Provider<String>((ref) {
  final locale = ref.watch(localeProvider);
  return localeToLanguageCode(locale);
});
