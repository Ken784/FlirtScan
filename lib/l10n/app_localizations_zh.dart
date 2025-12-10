// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'FlirtScan';

  @override
  String get homePageTitle => '曖昧分析';

  @override
  String get analyzing => '正在揣摩他/她的心思';

  @override
  String get errorTitle => '分析失敗';

  @override
  String get errorNotOneOnOneChat => '請上傳一對一對話截圖';

  @override
  String get errorAdNotLoaded => '廣告載入失敗，請稍後再試';

  @override
  String get errorAnalysisFailed => '分析過程發生錯誤，請重試';

  @override
  String get ok => '確定';

  @override
  String get retry => '重試';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => 'FlirtScan';

  @override
  String get homePageTitle => '曖昧分析';

  @override
  String get analyzing => '正在揣摩他/她的心思';

  @override
  String get errorTitle => '分析失敗';

  @override
  String get errorNotOneOnOneChat => '請上傳一對一對話截圖';

  @override
  String get errorAdNotLoaded => '廣告載入失敗，請稍後再試';

  @override
  String get errorAnalysisFailed => '分析過程發生錯誤，請重試';

  @override
  String get ok => '確定';

  @override
  String get retry => '重試';
}
