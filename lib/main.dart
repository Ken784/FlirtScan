import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flirt_scan/l10n/app_localizations.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/config/app_router.dart';
import 'src/core/config/firebase_config.dart';
import 'src/services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Firebase
  await FirebaseConfig.initialize();
  
  // 初始化 Google Mobile Ads
  await AdService.initialize();
  
  // 預載廣告
  AdService().loadRewardedAd();
  
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
      supportedLocales: const [
        Locale('zh', 'TW'),
      ],
      locale: const Locale('zh', 'TW'),
    );
  }
}

 
