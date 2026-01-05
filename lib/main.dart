import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flirt_scan/l10n/app_localizations.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/config/app_router.dart';
import 'src/core/config/firebase_config.dart';
import 'src/services/ad_service.dart';
import 'src/services/ad_consent_manager.dart';
import 'src/core/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 預熱 SharedPreferences，避免首次訪問時的延遲
  unawaited(SharedPreferences.getInstance());

  // 初始化 Firebase
  await FirebaseConfig.initialize();

  // 初始化廣告授權管理器
  final consentManager = AdConsentManager();
  consentManager.initialize();

  // 請求授權資訊更新（包含顯示授權表單，如果需要）
  try {
    await consentManager.requestConsentInfoUpdate();
  } catch (e) {
    // 即使授權流程失敗，也不應該阻止 App 啟動
    debugPrint('main: 授權流程發生異常: $e');
  }

  // 只有在確認可以顯示廣告後，才初始化 Google Mobile Ads SDK
  if (consentManager.canRequestAds) {
    try {
      await AdService.initialize();

      // 預載兩個廣告（一般分析和進階分析）
      final adService = AdService();
      adService.loadRewardedAd(AdType.startAnalysis);
      adService.loadRewardedAd(AdType.advancedAnalysis);
    } catch (e) {
      // 即使廣告初始化失敗，也不應該阻止 App 啟動
      debugPrint('main: 廣告初始化發生異常: $e');
    }
  } else {
    debugPrint('main: 未取得廣告授權，跳過廣告初始化');
  }

  runApp(
    const ProviderScope(
      child: FlirtScanApp(),
    ),
  );
}

class FlirtScanApp extends ConsumerWidget {
  const FlirtScanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    // 使用 localeProvider 管理當前語言，未來可以支援動態切換
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'FlirtScan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: currentLocale,
    );
  }
}
