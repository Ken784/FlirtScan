import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analysis_result.dart';
import '../../features/analysis/analysis_repository.dart';
import '../../services/analysis_service.dart';
import '../../services/storage_service.dart';

/// 分析狀態
enum AnalysisStatus {
  idle,       // 閒置
  analyzing,  // 分析中
  completed,  // 完成
  error,      // 錯誤
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
  AnalysisNotifier() : super(AnalysisState());

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
      final result = await _analysisRepository.analyzeConversation(
        imageBase64: imageBase64,
        language: 'zh-TW',
      );

      state = state.copyWith(
        status: AnalysisStatus.completed,
        result: result,
      );

      // 分析完成後，自動儲存到本地歷史紀錄
      unawaited(
        _storageService.saveAnalysis(
          result,
          imageBase64: imageBase64,
        ),
      );
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
       unawaited(
         _storageService.saveAnalysis(
           updatedResult,
           imageBase64: state.imageBase64,
         ),
       );
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
final analysisProvider = StateNotifierProvider<AnalysisNotifier, AnalysisState>((ref) {
  return AnalysisNotifier();
});

