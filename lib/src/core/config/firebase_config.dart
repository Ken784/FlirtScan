import 'dart:io';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import '../../../firebase_options.dart';

/// Firebase 初始化配置
class FirebaseConfig {
  static bool _initialized = false;
  
  // #region agent log
  static void _log(String location, String message, Map<String, dynamic> data, String hypothesisId) {
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

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      // 使用 firebase_options.dart 中的配置初始化 Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      debugPrint('Firebase: 初始化成功');
    } catch (e) {
      debugPrint('Firebase: 初始化警告 - $e');
      debugPrint('Firebase: 將繼續使用 Cloud Functions（可能需要配置）');
      _initialized = true; // 即使初始化失敗也標記為已初始化，避免重複嘗試
    }

    // 在開發模式下使用本地 Emulator
    if (kDebugMode) {
      try {
        // #region agent log
        _log('firebase_config.dart:31', '配置 Emulator 前', {'host': '192.168.0.42', 'port': 5001, 'kDebugMode': kDebugMode}, 'B');
        // #endregion
        FirebaseFunctions.instance.useFunctionsEmulator('192.168.0.42', 5001);
        debugPrint('Firebase Functions: 使用本地 Emulator (192.168.0.42:5001)');
        // #region agent log
        _log('firebase_config.dart:34', 'Emulator 配置成功', {'host': '192.168.0.42', 'port': 5001}, 'B');
        // #endregion
      } catch (e) {
        debugPrint('Firebase Functions: 無法連接到本地 Emulator - $e');
        debugPrint('Firebase Functions: 將使用生產環境');
        // #region agent log
        _log('firebase_config.dart:37', 'Emulator 配置失敗', {'error': e.toString()}, 'B');
        // #endregion
      }
    }
  }
}
