import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/routing/app_router.dart';

void main() {
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

 
