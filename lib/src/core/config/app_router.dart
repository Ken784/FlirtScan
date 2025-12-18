import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../pages/home_page.dart';
import '../../pages/result_page.dart';
import '../../pages/result_sentence_page.dart';
import '../../pages/history_page.dart';
import '../../pages/welcome_page.dart';
import '../providers/onboarding_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final needsOnboarding = ref.watch(onboardingProvider);

  return GoRouter(
    initialLocation: needsOnboarding ? WelcomePage.route : HomePage.route,
    redirect: (context, state) {
      final isWelcomePage = state.uri.path == WelcomePage.route;
      final currentNeedsOnboarding = ref.read(onboardingProvider);

      // 如果不需要顯示歡迎頁面但在歡迎頁面，重定向到首頁
      if (!currentNeedsOnboarding && isWelcomePage) {
        return HomePage.route;
      }

      // 如果需要顯示歡迎頁面且不在歡迎頁面，重定向到歡迎頁面
      // 但排除結果頁面，因為結果頁面應該可以從首頁訪問
      if (currentNeedsOnboarding &&
          !isWelcomePage &&
          state.uri.path != ResultPage.route &&
          state.uri.path != ResultSentencePage.route) {
        return WelcomePage.route;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: WelcomePage.route,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: WelcomePage()),
      ),
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
