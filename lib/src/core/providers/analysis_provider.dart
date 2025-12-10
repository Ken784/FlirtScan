import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analysis_result.dart';
import '../../services/analysis_service.dart';

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

  final AnalysisService _analysisService = AnalysisService();

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
      final result = await _analysisService.analyzeConversation(
        imageBase64: imageBase64,
        language: 'zh-TW',
      );

      state = state.copyWith(
        status: AnalysisStatus.completed,
        result: result,
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
    }
  }
}

/// 分析狀態 Provider
final analysisProvider = StateNotifierProvider<AnalysisNotifier, AnalysisState>((ref) {
  return AnalysisNotifier();
});

