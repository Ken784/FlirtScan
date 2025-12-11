import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/analysis_result.dart';

/// 歷史紀錄項目：封裝 AnalysisResult 以及對話截圖（如有）
class AnalysisHistoryEntry {
  final AnalysisResult result;
  final String? imageBase64;

  AnalysisHistoryEntry({
    required this.result,
    this.imageBase64,
  });

  /// 兼容舊格式（直接存 AnalysisResult JSON）與新格式（包在 result 裡）
  factory AnalysisHistoryEntry.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('result')) {
      // 新格式
      final resultJson =
          Map<String, dynamic>.from(json['result'] as Map<dynamic, dynamic>);
      return AnalysisHistoryEntry(
        result: AnalysisResult.fromJson(resultJson),
        imageBase64: json['imageBase64'] as String?,
      );
    }

    // 舊格式：整個 json 就是 AnalysisResult
    final result = AnalysisResult.fromJson(json);
    return AnalysisHistoryEntry(result: result);
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result.toJson(),
      if (imageBase64 != null) 'imageBase64': imageBase64,
    };
  }
}

/// 本地儲存服務
/// 使用 shared_preferences 以 JSON 字串形式保存分析結果歷史紀錄
class StorageService {
  static const String _historyKey = 'analysis_history_v1';

  /// 儲存一次分析結果到歷史紀錄
  /// - 如果已有相同 id 的紀錄，會先移除舊的再插入新的
  /// - 新資料會放在列表最前面（時間倒序）
  Future<void> saveAnalysis(
    AnalysisResult result, {
    String? imageBase64,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList = prefs.getStringList(_historyKey) ?? [];

    // 移除相同 id 的舊紀錄（若有）
    final List<String> filtered = [];
    for (final item in rawList) {
      try {
        final Map<String, dynamic> map =
            jsonDecode(item) as Map<String, dynamic>;
        final entry = AnalysisHistoryEntry.fromJson(map);
        if (entry.result.id != result.id) {
          filtered.add(item);
        }
      } catch (_) {
        // 無法解析的資料直接略過，不再寫回
      }
    }

    // 新的結果放在最前面
    final entry = AnalysisHistoryEntry(
      result: result,
      imageBase64: imageBase64,
    );
    final String encoded = jsonEncode(entry.toJson());
    filtered.insert(0, encoded);

    await prefs.setStringList(_historyKey, filtered);
  }

  /// 取得所有歷史分析結果（時間倒序）
  Future<List<AnalysisHistoryEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList = prefs.getStringList(_historyKey) ?? [];

    final List<AnalysisHistoryEntry> results = [];

    for (final item in rawList) {
      try {
        final Map<String, dynamic> map =
            jsonDecode(item) as Map<String, dynamic>;
        final entry = AnalysisHistoryEntry.fromJson(map);
        results.add(entry);
      } catch (_) {
        // 單筆解析失敗就忽略，避免整體中斷
      }
    }

    // 安全保險：再依 createdAt 做一次時間倒序排序
    results.sort(
      (a, b) => b.result.createdAt.compareTo(a.result.createdAt),
    );
    return results;
  }

  /// 刪除指定 id 的分析紀錄
  Future<void> deleteAnalysis(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList = prefs.getStringList(_historyKey) ?? [];

    final List<String> filtered = [];
    for (final item in rawList) {
      try {
        final Map<String, dynamic> map =
            jsonDecode(item) as Map<String, dynamic>;
        final entry = AnalysisHistoryEntry.fromJson(map);
        if (entry.result.id != id) {
          filtered.add(item);
        }
      } catch (_) {
        // 無法解析的資料直接忽略
      }
    }

    await prefs.setStringList(_historyKey, filtered);
  }
}

