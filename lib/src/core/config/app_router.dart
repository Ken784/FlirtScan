import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../pages/home_page.dart';
import '../../pages/result_page.dart';
import '../../pages/result_sentence_page.dart';
import '../../pages/history_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: HomePage.route,
    routes: [
      GoRoute(
        path: HomePage.route,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: HomePage()),
      ),
      GoRoute(
        path: ResultPage.route,
        builder: (context, state) {
          final imageBase64 = state.uri.queryParameters['imageBase64'];
          return ResultPage(imageBase64: imageBase64);
        },
      ),
      GoRoute(
        path: ResultSentencePage.route,
        builder: (context, state) => const ResultSentencePage(),
      ),
      GoRoute(
        path: HistoryPage.route,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: HistoryPage()),
      ),
    ],
  );
});


