import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/storage_service.dart';

/// 歷史記錄狀態
class HistoryState {
  final List<AnalysisHistoryEntry> entries;
  final bool isLoading;
  final String? errorMessage;

  HistoryState({
    this.entries = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  HistoryState copyWith({
    List<AnalysisHistoryEntry>? entries,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HistoryState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 歷史記錄狀態 Notifier
class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(HistoryState()) {
    _loadHistory();
  }

  final StorageService _storageService = StorageService();

  /// 載入歷史記錄
  Future<void> _loadHistory() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final entries = await _storageService.getHistory();
      state = state.copyWith(
        entries: entries,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '載入歷史記錄失敗：${e.toString()}',
      );
    }
  }

  /// 重新載入歷史記錄
  Future<void> reload() async {
    await _loadHistory();
  }

  /// 刪除指定 ID 的歷史記錄
  Future<void> deleteById(String id) async {
    // 樂觀更新：先從 UI 中移除
    final updatedEntries = state.entries
        .where((entry) => entry.result.id != id)
        .toList();
    
    state = state.copyWith(entries: updatedEntries);

    try {
      // 從儲存中刪除
      await _storageService.deleteAnalysis(id);
      
      // 刪除成功，狀態已更新
    } catch (e) {
      // 刪除失敗，重新載入以確保一致性
      await _loadHistory();
      rethrow;
    }
  }
}

/// 歷史記錄狀態 Provider
final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier();
});

