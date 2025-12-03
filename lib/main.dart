import 'package:flutter/material.dart';
import 'src/core/theme/app_theme.dart';
import 'src/pages/home_page.dart';
import 'src/pages/uploaded_page.dart';
import 'src/pages/result_page.dart';
import 'src/pages/result_sentence_page.dart';
import 'src/pages/history_page.dart';
import 'src/pages/error_dialog_demo_page.dart';

void main() {
  runApp(const FlirtScanApp());
}

class FlirtScanApp extends StatelessWidget {
  const FlirtScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlirtScan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      initialRoute: HomePage.route,
      routes: {
        HomePage.route: (_) => const HomePage(),
        UploadedPage.route: (_) => const UploadedPage(),
        ResultPage.route: (_) => const ResultPage(),
        ResultSentencePage.route: (_) => const ResultSentencePage(),
        HistoryPage.route: (_) => const HistoryPage(),
        ErrorDialogDemoPage.route: (_) => const ErrorDialogDemoPage(),
      },
    );
  }
}

 
