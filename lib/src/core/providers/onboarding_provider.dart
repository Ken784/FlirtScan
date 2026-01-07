import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 首次開啟狀態管理
/// state 為 true 表示需要顯示歡迎頁面，false 表示已看過
class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(true) {
    // 異步檢查狀態，預設為 true（顯示歡迎頁面）
    _checkOnboardingStatus();
  }

  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  /// 檢查是否已看過歡迎頁面
  Future<void> _checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeen = prefs.getBool(_hasSeenOnboardingKey) ?? false;
      state = !hasSeen; // 如果已看過，state 為 false（不需要顯示歡迎頁）
    } catch (e) {
      // 如果讀取失敗，預設顯示歡迎頁面（保持 state = true）
    }
  }

  /// 標記已看過歡迎頁面
  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasSeenOnboardingKey, true);
      state = false;
    } catch (e) {
      // 如果寫入失敗，仍然更新狀態
      state = false;
    }
  }

  /// 重置歡迎畫面狀態（用於新安裝時）
  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_hasSeenOnboardingKey);
      state = true; // 重置為需要顯示歡迎頁面
    } catch (e) {
      state = true;
    }
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier();
});
