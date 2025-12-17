import 'package:flutter/foundation.dart';
import '../../core/models/analysis_result.dart';
import '../../services/analysis_service.dart';

/// 分析資料庫倉儲
/// 負責呼叫 Firebase Function 進行對話分析
class AnalysisRepository {
  final AnalysisService _analysisService = AnalysisService();

  /// 分析對話截圖
  /// 
  /// [imageBase64] 壓縮後的對話截圖 Base64 字串
  /// [language] App 當前語言代碼（例如：'zh-TW'，預設為 'zh-TW' 作為後備）
  /// 
  /// 返回分析結果
  Future<AnalysisResult> analyzeConversation({
    required String imageBase64,
    String language = 'zh-TW', // 預設值僅作為後備，通常應從 localeProvider 傳入
  }) async {
    try {
      debugPrint('AnalysisRepository: 開始分析對話...');

      final analysisResult = await _analysisService.analyzeConversation(
        imageBase64: imageBase64,
        language: language,
      );

      debugPrint('AnalysisRepository: 分析完成');
      debugPrint('AnalysisRepository: 總分 ${analysisResult.totalScore}/10');
      debugPrint('AnalysisRepository: 關係狀態 ${analysisResult.relationshipStatus}');

      return analysisResult;
    } on AnalysisException catch (e) {
      debugPrint('AnalysisRepository: 分析錯誤 - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('AnalysisRepository: 未知錯誤 - $e');
      throw AnalysisException(
        '分析過程中發生錯誤: ${e.toString()}',
        type: AnalysisExceptionType.unknown,
      );
    }
  }
}






