import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analysis_result.dart';
import '../../features/analysis/analysis_repository.dart';
import '../../services/analysis_service.dart';
import '../../services/storage_service.dart';
import 'locale_provider.dart';
import 'history_provider.dart';

/// 分析狀態
enum AnalysisStatus {
  idle, // 閒置
  analyzing, // 分析中
  completed, // 完成
  error, // 錯誤
}

/// 分析狀態類
class AnalysisState {
  final AnalysisStatus status;
  final AnalysisResult? result;
  final String? errorMessage;
  final String? imageBase64; // 當前正在分析的圖片

  AnalysisState({
    this.status = AnalysisStatus.idle,
    this.result,
    this.errorMessage,
    this.imageBase64,
  });

  AnalysisState copyWith({
    AnalysisStatus? status,
    AnalysisResult? result,
    String? errorMessage,
    String? imageBase64,
  }) {
    return AnalysisState(
      status: status ?? this.status,
      result: result,
      errorMessage: errorMessage,
      imageBase64: imageBase64 ?? this.imageBase64,
    );
  }

  bool get isAnalyzing => status == AnalysisStatus.analyzing;
  bool get hasError => status == AnalysisStatus.error;
  bool get isCompleted => status == AnalysisStatus.completed;
}

/// 分析狀態 Notifier
class AnalysisNotifier extends StateNotifier<AnalysisState> {
  AnalysisNotifier(this.ref) : super(AnalysisState());

  final Ref ref;
  final AnalysisRepository _analysisRepository = AnalysisRepository();
  final StorageService _storageService = StorageService();

  /// 開始分析
  Future<void> analyze(String imageBase64) async {
    // 如果已經在分析同一張圖片，不重複分析
    if (state.isAnalyzing && state.imageBase64 == imageBase64) {
      return;
    }

    state = AnalysisState(
      status: AnalysisStatus.analyzing,
      imageBase64: imageBase64,
    );

    try {
      // 從 localeProvider 取得當前語言代碼
      final language = ref.read(languageCodeProvider);

      final result = await _analysisRepository.analyzeConversation(
        imageBase64: imageBase64,
        language: language,
      );

      state = state.copyWith(
        status: AnalysisStatus.completed,
        result: result,
      );

      // 分析完成後，自動儲存到本地歷史紀錄
      final saveFuture = _storageService.saveAnalysis(
        result,
        imageBase64: imageBase64,
      );
      
      // 等待保存完成後，通知 historyProvider 重新載入（如果已初始化）
      saveFuture.then((_) {
        try {
          // 只有在 historyProvider 已初始化的情況下才通知
          // 使用 read 而不是 watch，避免不必要的依賴
          ref.read(historyProvider.notifier).reload();
        } catch (_) {
          // historyProvider 可能尚未初始化，這是正常的
          // 當用戶首次進入 HistoryPage 時會自動載入最新數據
        }
      });
      
      // 不等待保存完成，避免阻塞 UI
      unawaited(saveFuture);
    } on AnalysisException catch (e) {
      state = state.copyWith(
        status: AnalysisStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AnalysisStatus.error,
        errorMessage: '分析過程發生錯誤，請重試',
      );
    }
  }

  /// 重置狀態
  void reset() {
    state = AnalysisState();
  }

  /// 解鎖進階分析
  void unlockAdvancedAnalysis() {
    if (state.result != null) {
      final updatedResult = state.result!.copyWith(isAdvancedUnlocked: true);
      state = state.copyWith(result: updatedResult);

      // 將「進階已解鎖」狀態同步回歷史紀錄
      final saveFuture = _storageService.saveAnalysis(
        updatedResult,
        imageBase64: state.imageBase64,
      );
      
      // 等待保存完成後，通知 historyProvider 重新載入（如果已初始化）
      saveFuture.then((_) {
        try {
          ref.read(historyProvider.notifier).reload();
        } catch (_) {
          // historyProvider 可能尚未初始化，這是正常的
        }
      });
      
      unawaited(saveFuture);
    }
  }

  /// 從歷史紀錄載入結果
  /// 用於 HistoryPage 點擊某筆紀錄後再次查看完整結果
  void loadFromHistory(
    AnalysisResult result, {
    String? imageBase64,
  }) {
    state = AnalysisState(
      status: AnalysisStatus.completed,
      result: result,
      imageBase64: imageBase64,
    );
  }
}

/// 分析狀態 Provider
final analysisProvider =
    StateNotifierProvider<AnalysisNotifier, AnalysisState>((ref) {
  return AnalysisNotifier(ref);
});
