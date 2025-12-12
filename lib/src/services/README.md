# 分析服務使用說明

## 使用方式

### 1. 在 Widget 中使用

```dart
import 'package:flirt_scan/src/services/analysis_service.dart';
import 'package:flirt_scan/src/services/image_service.dart';

// 創建服務實例
final analysisService = AnalysisService();
final imageService = ImageService();

// 選取並處理圖片
final imageFile = await imageService.pickImage();
if (imageFile != null) {
  final result = await imageService.compressAndConvertToBase64(imageFile);
  
  // 呼叫分析服務
  try {
    final analysisResult = await analysisService.analyzeConversation(
      imageBase64: result.base64String,
      language: 'zh-TW',
    );
    
    // 使用分析結果
    print('總分: ${analysisResult.totalScore}/10');
    print('關係狀態: ${analysisResult.relationshipStatus}');
    print('總結: ${analysisResult.summary}');
  } on AnalysisException catch (e) {
    if (e.type == AnalysisExceptionType.invalidImage) {
      // 處理無效圖片錯誤
      print('錯誤: ${e.message}');
    } else {
      // 處理其他錯誤
      print('分析失敗: ${e.message}');
    }
  }
}
```

### 2. 錯誤處理

```dart
try {
  final result = await analysisService.analyzeConversation(
    imageBase64: base64String,
  );
  // 處理成功結果
} on AnalysisException catch (e) {
  switch (e.type) {
    case AnalysisExceptionType.invalidImage:
      // 圖片不是對話截圖
      break;
    case AnalysisExceptionType.serverError:
      // 伺服器錯誤
      break;
    case AnalysisExceptionType.networkError:
      // 網路錯誤
      break;
    case AnalysisExceptionType.unknown:
      // 未知錯誤
      break;
  }
}
```

## 本地測試

1. 啟動 Firebase Functions Emulator：
```bash
cd firebase/functions
npm run serve
```

2. 啟動 Flutter App：
```bash
flutter run
```

App 會自動連接到本地 Emulator (localhost:5001)。




