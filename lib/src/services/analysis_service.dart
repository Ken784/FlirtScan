import 'dart:io';
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import '../core/models/analysis_result.dart';

/// 分析服務
/// 負責呼叫 Firebase Functions 進行對話分析
class AnalysisService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  
  // #region agent log
  void _log(String location, String message, Map<String, dynamic> data, String hypothesisId) {
    try {
      final logEntry = {
        'location': location,
        'message': message,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'sessionId': 'debug-session',
        'runId': 'run1',
        'hypothesisId': hypothesisId,
      };
      final file = File('/Users/kenhuang/Desktop/FlirtScan/.cursor/debug.log');
      file.writeAsStringSync('${jsonEncode(logEntry)}\n', mode: FileMode.append);
    } catch (_) {}
  }
  // #endregion

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
      debugPrint('AnalysisService: 開始分析對話...');
      // #region agent log
      _log('analysis_service.dart:21', '開始分析請求', {'imageBase64Length': imageBase64.length, 'language': language}, 'C');
      // #endregion

      // 呼叫 Firebase Function
      final callable = _functions.httpsCallable('analyzeConversation');
      // #region agent log
      _log('analysis_service.dart:25', '創建 callable 後，準備發送請求', {'functionName': 'analyzeConversation'}, 'C');
      // #endregion

      // #region agent log
      _log('analysis_service.dart:27', '發送請求前', {'hasImageBase64': imageBase64.isNotEmpty, 'imageBase64Length': imageBase64.length, 'language': language}, 'C');
      // #endregion
      final result = await callable.call({
        'imageBase64': imageBase64,
        'language': language,
      });
      // #region agent log
      _log('analysis_service.dart:32', '收到回應', {'hasData': result.data != null}, 'C');
      // #endregion

      debugPrint('AnalysisService: 收到回應');

      // 檢查回應格式
      if (result.data == null) {
        throw Exception('分析服務未回傳數據');
      }

      // 安全地轉換類型：從 Map<Object?, Object?> 轉為 Map<String, dynamic>
      final responseData = Map<String, dynamic>.from(result.data as Map);

      // 檢查是否成功
      if (responseData['success'] == true && responseData['data'] != null) {
        // 同樣需要安全轉換嵌套的 Map
        final analysisData =
            Map<String, dynamic>.from(responseData['data'] as Map);

        // 確保有 ID：如果 Firebase 沒有返回 ID，生成一個
        if (analysisData['id'] == null) {
          analysisData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
        }

        // 轉換為 AnalysisResult
        final analysisResult = AnalysisResult.fromJson(analysisData);

        debugPrint('AnalysisService: 分析完成');
        debugPrint('AnalysisService: 結果 ID: ${analysisResult.id}');
        debugPrint('AnalysisService: 總分 ${analysisResult.totalScore}/10');
        debugPrint(
            'AnalysisService: 關係狀態 ${analysisResult.relationshipStatus}');

        return analysisResult;
      } else {
        throw Exception('分析服務回傳錯誤: ${responseData['error'] ?? '未知錯誤'}');
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
          'AnalysisService: Firebase Functions 錯誤 - ${e.code}: ${e.message}');
      // #region agent log
      _log('analysis_service.dart:66', 'Firebase Functions 異常', {'code': e.code, 'message': e.message, 'details': e.details?.toString()}, 'A');
      // #endregion

      // 處理特定錯誤
      if (e.code == 'invalid-argument' &&
          e.message?.contains('invalid_image_content') == true) {
        throw AnalysisException('這似乎不是對話紀錄喔',
            type: AnalysisExceptionType.invalidImage);
      }

      throw AnalysisException(
        e.message ?? '分析過程中發生錯誤',
        type: AnalysisExceptionType.serverError,
      );
    } catch (e) {
      debugPrint('AnalysisService: 未知錯誤 - $e');
      // #region agent log
      _log('analysis_service.dart:82', '未知錯誤', {'error': e.toString(), 'errorType': e.runtimeType.toString()}, 'D');
      // #endregion
      throw AnalysisException(
        '分析過程中發生錯誤: ${e.toString()}',
        type: AnalysisExceptionType.unknown,
      );
    }
  }
}

/// 分析異常類型
enum AnalysisExceptionType {
  invalidImage, // 無效圖片
  serverError, // 伺服器錯誤
  networkError, // 網路錯誤
  unknown, // 未知錯誤
}

/// 分析異常
class AnalysisException implements Exception {
  final String message;
  final AnalysisExceptionType type;

  AnalysisException(this.message, {required this.type});

  @override
  String toString() => message;
}
