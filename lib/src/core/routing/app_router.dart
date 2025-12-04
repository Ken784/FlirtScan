import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../pages/home_page.dart';
import '../../pages/uploaded_page.dart';
import '../../pages/result_page.dart';
import '../../pages/result_sentence_page.dart';
import '../../pages/history_page.dart';
import '../../pages/error_dialog_demo_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: HomePage.route,
    routes: [
      GoRoute(
        path: HomePage.route,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: UploadedPage.route,
        builder: (context, state) => const UploadedPage(),
      ),
      GoRoute(
        path: ResultPage.route,
        builder: (context, state) => const ResultPage(),
      ),
      GoRoute(
        path: ResultSentencePage.route,
        builder: (context, state) => const ResultSentencePage(),
      ),
      GoRoute(
        path: HistoryPage.route,
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: ErrorDialogDemoPage.route,
        builder: (context, state) => const ErrorDialogDemoPage(),
      ),
    ],
  );
});

