import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Google UMP (User Messaging Platform) 授權管理類
/// 
/// 此類別負責處理 Google 的用戶同意管理流程，確保在顯示廣告之前
/// 先取得用戶的同意。主要功能包括：
/// - 請求授權資訊更新
/// - 載入並顯示授權表單（如果需要）
/// - 判斷是否可以請求廣告
/// - 支援調試模式，模擬歐盟環境進行測試
/// 
/// 使用流程：
/// 1. 在應用啟動時調用 [initialize] 初始化
/// 2. （可選）在開發環境中調用 [setDebugGeography] 啟用調試模式
/// 3. 調用 [requestConsentInfoUpdate] 請求授權
/// 4. 等待授權流程完成（包含彈窗顯示完畢）
/// 5. 檢查 [canRequestAds] 屬性，確認是否已取得用戶同意
/// 6. 只有在 [canRequestAds] 為 true 時，才初始化廣告 SDK 和載入廣告
/// 
/// 注意：此類別遵循「先取得授權，再初始化廣告 SDK」的原則
class AdConsentManager {
  /// 單例實例
  static final AdConsentManager _instance = AdConsentManager._internal();
  
  /// 工廠建構函數，返回單例實例
  factory AdConsentManager() => _instance;
  
  /// 私有建構函數
  AdConsentManager._internal();

  /// 授權資訊實例
  late final ConsentInformation _consentInformation;
  
  /// 授權表單實例
  ConsentForm? _consentForm;
  
  /// 是否已初始化
  bool _isInitialized = false;
  
  /// 是否正在處理授權流程
  bool _isProcessing = false;
  
  /// 授權狀態變更的 StreamController
  final StreamController<bool> _consentStatusController = 
      StreamController<bool>.broadcast();
  
  /// 授權狀態變更的 Stream
  /// 當 [canRequestAds] 狀態變更時會發出事件
  Stream<bool> get consentStatusStream => _consentStatusController.stream;

  /// 是否可以請求廣告
  /// 
  /// 此屬性表示是否已經取得用戶同意，可以用來判斷是否可以：
  /// - 初始化 Google Mobile Ads SDK
  /// - 載入和顯示廣告
  /// 
  /// 只有在用戶同意後，此屬性才會變為 true
  bool canRequestAds = false;

  /// 儲存的調試設定（用於 requestConsentInfoUpdate）
  DebugGeography? _storedDebugGeography;
  List<String>? _storedTestDeviceIds;

  /// 初始化授權管理器
  /// 
  /// 此方法應該在應用啟動時調用，用於初始化 UMP SDK
  /// 注意：此方法不會請求授權，只是初始化 SDK
  /// 
  /// 參數：
  /// - [debugGeography]: 調試地理位置設定（僅在調試模式下有效）
  ///   可選值：
  ///   - [DebugGeography.debugGeographyEea]: 模擬歐盟/歐洲經濟區
  ///   - [DebugGeography.debugGeographyOther]: 模擬非歐盟地區
  ///   - [DebugGeography.debugGeographyDisabled]: 禁用調試模式（預設）
  /// - [testDeviceIds]: 測試設備 ID 列表（僅在調試模式下有效）
  ///   可以從日誌中獲取設備的廣告 ID，用於指定測試設備
  void initialize({
    DebugGeography? debugGeography,
    List<String>? testDeviceIds,
  }) {
    if (_isInitialized) {
      debugPrint('AdConsentManager: 已經初始化，跳過重複初始化');
      return;
    }
    
    _consentInformation = ConsentInformation.instance;
    _isInitialized = true;
    
    // 如果提供了調試設定，則儲存設定（將在 requestConsentInfoUpdate 時使用）
    if (debugGeography != null) {
      _storedDebugGeography = debugGeography;
      _storedTestDeviceIds = testDeviceIds;
      setDebugGeography(debugGeography, testDeviceIds: testDeviceIds);
    }
    
    // 檢查現有的授權狀態（異步執行，但不等待，因為 initialize 是同步方法）
    _updateCanRequestAds();
    
    debugPrint('AdConsentManager: 初始化完成');
  }

  /// 設置調試地理位置（用於開發和測試）
  /// 
  /// UMP SDK 在生產環境中會根據用戶的實際地理位置來決定是否顯示授權表單。
  /// 在開發環境中，可以使用此方法來模擬不同的地理位置，方便測試授權流程。
  /// 
  /// 參數：
  /// - [geography]: 調試地理位置設定
  ///   - [DebugGeography.debugGeographyEea]: 模擬歐盟/歐洲經濟區（會顯示 GDPR 授權表單）
  ///   - [DebugGeography.debugGeographyOther]: 模擬非歐盟地區（通常不顯示授權表單）
  ///   - [DebugGeography.debugGeographyDisabled]: 禁用調試模式，使用實際地理位置
  /// - [testDeviceIds]: 測試設備 ID 列表（可選）
  ///   可以從日誌中獲取設備的廣告 ID，用於指定哪些設備使用調試模式
  /// 
  /// 注意：
  /// - 此方法僅在調試模式下有效，在生產環境中會被忽略
  /// - 建議在開發環境中使用，方便測試授權流程
  /// - 調試設定需要在 [requestConsentInfoUpdate] 時通過參數傳遞
  /// 
  /// 範例：
  /// ```dart
  /// // 模擬歐盟環境，強制顯示授權表單
  /// consentManager.setDebugGeography(DebugGeography.debugGeographyEea);
  /// 
  /// // 模擬非歐盟環境，不顯示授權表單
  /// consentManager.setDebugGeography(DebugGeography.debugGeographyOther);
  /// 
  /// // 為特定測試設備啟用調試模式
  /// consentManager.setDebugGeography(
  ///   DebugGeography.debugGeographyEea,
  ///   testDeviceIds: ['TEST_DEVICE_ID_1', 'TEST_DEVICE_ID_2'],
  /// );
  /// ```
  void setDebugGeography(
    DebugGeography geography, {
    List<String>? testDeviceIds,
  }) {
    if (!_isInitialized) {
      debugPrint('AdConsentManager: 尚未初始化，無法設置調試地理位置');
      return;
    }

    // 注意：在 7.0.0 版本中，debugSettings 需要通過 ConsentRequestParameters 傳遞
    // 這裡只是儲存設定，實際使用時會在 requestConsentInfoUpdate 中應用
    debugPrint('AdConsentManager: 已設置調試地理位置: $geography');
    if (testDeviceIds != null && testDeviceIds.isNotEmpty) {
      debugPrint('AdConsentManager: 測試設備 ID: ${testDeviceIds.join(", ")}');
    }
  }

  /// 請求授權資訊更新
  /// 
  /// 此方法會向 Google UMP 服務請求最新的授權資訊，並根據情況：
  /// - 如果需要顯示授權表單，會自動載入並顯示
  /// - 如果不需要顯示表單，會直接更新 [canRequestAds] 狀態
  /// 
  /// 此方法使用 Completer 確保整個授權流程（包含彈窗顯示完畢）結束後，
  /// 才會完成 Future，確保外部調用 `await requestConsentInfoUpdate()` 時
  /// 能夠正確等待整個流程完成。
  /// 
  /// 參數：
  /// - [tagForUnderAgeOfConsent]: 是否標記為未成年用戶（預設為 false）
  /// 
  /// 返回值：
  /// - 當整個授權流程完成時（包含表單顯示完畢），Future 才會完成
  /// 
  /// 注意：此方法應該在應用啟動時調用，在初始化廣告 SDK 之前
  /// 
  /// 範例：
  /// ```dart
  /// final consentManager = AdConsentManager();
  /// consentManager.initialize();
  /// 
  /// // 等待授權流程完全結束（包含彈窗顯示完畢）
  /// await consentManager.requestConsentInfoUpdate();
  /// 
  /// // 此時可以安全地檢查授權狀態
  /// if (consentManager.canRequestAds) {
  ///   await AdService.initialize();
  /// }
  /// ```
  Future<void> requestConsentInfoUpdate({
    bool tagForUnderAgeOfConsent = false,
  }) async {
    if (!_isInitialized) {
      debugPrint('AdConsentManager: 尚未初始化，請先調用 initialize()');
      initialize();
    }

    if (_isProcessing) {
      debugPrint('AdConsentManager: 授權流程正在處理中，跳過重複請求');
      return;
    }

    _isProcessing = true;
    debugPrint('AdConsentManager: 開始請求授權資訊更新...');

    // 使用 Completer 確保整個流程完成後才結束 Future
    final completer = Completer<void>();

    try {
      // 建立調試設定（如果有儲存的話）
      ConsentDebugSettings? debugSettings;
      if (_storedDebugGeography != null) {
        debugSettings = ConsentDebugSettings(
          debugGeography: _storedDebugGeography,
          testIdentifiers: _storedTestDeviceIds,
        );
      }

      // 建立授權請求參數
      final params = ConsentRequestParameters(
        tagForUnderAgeOfConsent: tagForUnderAgeOfConsent,
        consentDebugSettings: debugSettings,
      );

      // 請求授權資訊更新（注意：此方法返回 void，使用回調）
      _consentInformation.requestConsentInfoUpdate(
        params,
        // 成功回調：授權資訊已更新
        () async {
          debugPrint('AdConsentManager: 授權資訊更新成功');
          
          try {
            // 檢查是否需要顯示授權表單
            final isFormAvailable = await _consentInformation.isConsentFormAvailable();
            if (isFormAvailable) {
              debugPrint('AdConsentManager: 需要顯示授權表單');
              // 載入並顯示授權表單（此方法內部也使用 Completer，會等待表單關閉）
              await loadAndShowConsentFormIfRequired();
            } else {
              debugPrint('AdConsentManager: 不需要顯示授權表單');
              // 直接更新狀態
              await _updateCanRequestAds();
            }
            
            // 整個流程完成，完成 Future
            if (!completer.isCompleted) {
              completer.complete();
            }
          } catch (e) {
            debugPrint('AdConsentManager: 處理授權表單時發生異常: $e');
            // 即使發生異常，也完成 Future（避免永遠等待）
            if (!completer.isCompleted) {
              completer.complete();
            }
          } finally {
            _isProcessing = false;
          }
        },
        // 失敗回調：處理錯誤
        (FormError error) {
          debugPrint('AdConsentManager: 請求授權資訊更新失敗: ${error.message} (code: ${error.errorCode})');
          
          // 即使請求失敗，也嘗試更新狀態（可能使用緩存的狀態）
          // 注意：這裡不使用 await，因為失敗回調是同步的，但 _updateCanRequestAds 是異步的
          // 為了不阻塞，我們讓它異步執行
          _updateCanRequestAds();
          
          // 完成 Future（即使失敗也要完成，避免永遠等待）
          if (!completer.isCompleted) {
            completer.complete();
          }
          
          _isProcessing = false;
        },
      );
    } catch (e) {
      debugPrint('AdConsentManager: 請求授權資訊時發生異常: $e');
      _isProcessing = false;
      
      // 發生異常時也要完成 Future
      if (!completer.isCompleted) {
        completer.completeError(e);
      } else {
        rethrow;
      }
    }

    // 等待整個流程完成（包含表單顯示完畢）
    return completer.future;
  }

  /// 載入並顯示授權表單（如果需要）
  /// 
  /// 此方法會：
  /// 1. 載入授權表單
  /// 2. 檢查授權狀態，如果狀態為 [ConsentStatus.required]，則顯示表單
  /// 3. 更新 [canRequestAds] 狀態
  /// 
  /// 此方法使用 Completer 確保表單顯示完畢（用戶關閉表單）後，
  /// 才會完成 Future，確保外部調用能夠正確等待表單關閉。
  /// 
  /// 注意：
  /// - 此方法通常由 [requestConsentInfoUpdate] 自動調用
  /// - 也可以手動調用，例如在用戶點擊「管理授權」時
  /// 
  /// 對於 iOS 的 ATT (App Tracking Transparency)：
  /// - UMP SDK 會自動處理 ATT 彈窗（如果已配置）
  /// - 確保在 Info.plist 中配置了 NSUserTrackingUsageDescription
  /// - 如果需要手動處理 ATT，可以使用 app_tracking_transparency 套件
  /// 
  /// 返回值：
  /// - 當表單顯示完畢（用戶關閉表單）時，Future 才會完成
  Future<void> loadAndShowConsentFormIfRequired() async {
    if (!_isInitialized) {
      debugPrint('AdConsentManager: 尚未初始化，無法載入授權表單');
      return;
    }

    // 使用 Completer 確保表單關閉後才完成 Future
    final completer = Completer<void>();

    try {
      // 載入授權表單（使用靜態方法）
      ConsentForm.loadConsentForm(
        // 成功回調：表單已載入
        (ConsentForm form) async {
          _consentForm = form;
          debugPrint('AdConsentManager: 授權表單載入成功');
          
          // 檢查授權狀態
          final consentStatus = await _consentInformation.getConsentStatus();
          debugPrint('AdConsentManager: 當前授權狀態: $consentStatus');
          
          // 如果授權狀態為 required，需要顯示表單
          if (consentStatus == ConsentStatus.required) {
            debugPrint('AdConsentManager: 顯示授權表單');
            
            try {
              // 顯示授權表單
              // 注意：show 方法會立即返回，表單的關閉是在回調中處理的
              // 因此我們不 await show，而是等待回調中的 completer 完成
              _consentForm?.show(
                // 表單關閉回調
                (FormError? error) {
                  if (error != null) {
                    debugPrint('AdConsentManager: 顯示授權表單時發生錯誤: ${error.message} (code: ${error.errorCode})');
                  } else {
                    debugPrint('AdConsentManager: 授權表單已關閉');
                  }
                  
                  // 更新狀態（異步執行，不等待）
                  _updateCanRequestAds();
                  
                  // 表單已關閉，完成 Future
                  if (!completer.isCompleted) {
                    completer.complete();
                  }
                },
              );
            } catch (e) {
              debugPrint('AdConsentManager: 顯示授權表單時發生異常: $e');
              // 即使發生異常，也完成 Future
              if (!completer.isCompleted) {
                completer.complete();
              }
            }
          } else {
            // 不需要顯示表單，直接更新狀態並完成 Future
            debugPrint('AdConsentManager: 不需要顯示授權表單，當前狀態: $consentStatus');
            await _updateCanRequestAds();
            
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        },
        // 失敗回調：載入表單失敗
        (FormError error) {
          debugPrint('AdConsentManager: 載入授權表單失敗: ${error.message} (code: ${error.errorCode})');
          
          // 即使載入失敗，也嘗試更新狀態（異步執行，不等待）
          _updateCanRequestAds();
          
          // 完成 Future（即使失敗也要完成，避免永遠等待）
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      );
    } catch (e) {
      debugPrint('AdConsentManager: 載入授權表單時發生異常: $e');
      // 異步更新狀態，不等待
      _updateCanRequestAds();
      
      // 發生異常時也要完成 Future
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    // 等待表單關閉
    return completer.future;
  }

  /// 更新 [canRequestAds] 狀態
  /// 
  /// 此方法會根據當前的授權資訊更新 [canRequestAds] 屬性，
  /// 並通過 Stream 通知監聽者狀態變更
  Future<void> _updateCanRequestAds() async {
    if (!_isInitialized) {
      return;
    }

    final previousValue = canRequestAds;
    canRequestAds = await _consentInformation.canRequestAds();
    
    final consentStatus = await _consentInformation.getConsentStatus();
    debugPrint('AdConsentManager: 更新授權狀態 - canRequestAds: $canRequestAds, consentStatus: $consentStatus');
    
    // 如果狀態變更，通知監聽者
    if (previousValue != canRequestAds) {
      _consentStatusController.add(canRequestAds);
      debugPrint('AdConsentManager: 授權狀態已變更: $previousValue -> $canRequestAds');
    }
  }

  /// 重置授權狀態
  /// 
  /// 此方法會重置授權資訊，用於測試或開發目的
  /// 注意：在生產環境中應該謹慎使用
  Future<void> reset() async {
    if (!_isInitialized) {
      return;
    }

    debugPrint('AdConsentManager: 重置授權狀態');
    await _consentInformation.reset();
    await _updateCanRequestAds();
  }

  /// 獲取當前授權狀態
  /// 
  /// 返回當前的 [ConsentStatus]，可用於調試或日誌記錄
  Future<ConsentStatus?> getConsentStatus() async {
    if (!_isInitialized) {
      return null;
    }
    return await _consentInformation.getConsentStatus();
  }

  /// 檢查授權表單是否可用
  /// 
  /// 返回授權表單是否已載入並可用
  Future<bool> isConsentFormAvailable() async {
    if (!_isInitialized) {
      return false;
    }
    return await _consentInformation.isConsentFormAvailable();
  }

  /// 釋放資源
  /// 
  /// 在應用關閉時調用，用於清理資源
  void dispose() {
    _consentForm = null;
    _consentStatusController.close();
    _isInitialized = false;
    _isProcessing = false;
    debugPrint('AdConsentManager: 資源已釋放');
  }
}

