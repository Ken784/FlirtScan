## FlirtScan Flutter Demo

如何驗證（需先安裝 Flutter 3.x）：

```bash
flutter pub get
flutter run -d chrome
```

主要路由：
- `/` 首頁（上傳 + 指引）
- `/uploaded` 已選擇截圖頁
- `/result` 分析結果頁
- `/result-sentence` 逐句分析頁
- `/history` 分析記錄頁
- `/error` 錯誤 Dialog 範例

程式碼重點：
- 設計代幣：`lib/src/core/theme/*`
- 元件：`lib/src/widgets/**`
- 頁面：`lib/src/pages/**`








