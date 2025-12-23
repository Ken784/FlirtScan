import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 廣告類型枚舉
enum AdType {
  /// 一般分析廣告（用於開始分析對話）
  startAnalysis,
  /// 進階分析廣告（用於進階逐句分析）
  advancedAnalysis,
}

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;

  // 為每種類型的廣告維護獨立的實例和狀態
  final Map<AdType, RewardedAd?> _rewardedAds = {};
  final Map<AdType, bool> _adLoadedStates = {};
  final Map<AdType, bool> _adShowingStates = {};
  final Map<AdType, StreamController<bool>> _adLoadedControllers = {};

  // 用於中斷廣告的回調（每種類型獨立）
  final Map<AdType, VoidCallback?> _onAdInterruptedCallbacks = {};

  // 初始化 StreamController
  AdService._internal() {
    for (final adType in AdType.values) {
      _adLoadedControllers[adType] = StreamController<bool>.broadcast();
    }
  }

  /// 根據廣告類型獲取對應的 Stream
  Stream<bool> adLoadedStream(AdType adType) =>
      _adLoadedControllers[adType]!.stream;

  /// 根據廣告類型獲取對應的廣告單元 ID
  /// 
  /// 注意：目前使用測試 ID，上線前請替換為真實的廣告單元 ID
  static String getRewardedAdUnitId(AdType adType) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      switch (adType) {
        case AdType.startAnalysis:
          // TODO: 替換為真實的一般分析廣告單元 ID
          return 'ca-app-pub-3940256099942544/5224354917'; // Android 測試 ID
        case AdType.advancedAnalysis:
          // TODO: 替換為真實的進階分析廣告單元 ID
          return 'ca-app-pub-3940256099942544/5224354917'; // Android 測試 ID
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      switch (adType) {
        case AdType.startAnalysis:
          return 'ca-app-pub-5593605813396679/5835888758'; // iOS 真實 ID
        case AdType.advancedAnalysis:
          return 'ca-app-pub-5593605813396679/6367846577'; // iOS 真實 ID
      }
    }
    return '';
  }

  /// 初始化 Google Mobile Ads SDK
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// 預載指定類型的廣告
  Future<void> loadRewardedAd(AdType adType) async {
    if (_adLoadedStates[adType] == true) {
      return; // 廣告已載入
    }

    final adUnitId = getRewardedAdUnitId(adType);

    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAds[adType] = ad;
          _adLoadedStates[adType] = true;
          _adLoadedControllers[adType]!.add(true);

          // 設定 Full Screen Content Callback
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _adShowingStates[adType] = true;
            },
            onAdDismissedFullScreenContent: (ad) {
              _adShowingStates[adType] = false;
              ad.dispose();
              _rewardedAds[adType] = null;
              _adLoadedStates[adType] = false;
              // 自動預載下一個廣告
              loadRewardedAd(adType);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _adShowingStates[adType] = false;
              ad.dispose();
              _rewardedAds[adType] = null;
              _adLoadedStates[adType] = false;
              // 嘗試重新載入
              loadRewardedAd(adType);
            },
          );
        },
        onAdFailedToLoad: (error) {
          _adLoadedStates[adType] = false;
          _adLoadedControllers[adType]!.add(false);
          debugPrint('AdService: 載入 ${adType.name} 廣告失敗: $error');
          // 延遲 5 秒後重試
          Future.delayed(const Duration(seconds: 5), () {
            loadRewardedAd(adType);
          });
        },
      ),
    );
  }

  /// 顯示獎勵廣告
  /// [adType] 廣告類型
  /// [onUserEarnedReward] 當用戶看完廣告獲得獎勵時調用
  /// [onAdDismissed] 當廣告被關閉時調用（無論是否獲得獎勵）
  /// [onAdFailedToShow] 當廣告顯示失敗時調用
  /// [onAdInterrupted] 當廣告被中斷時調用（用於錯誤處理）
  Future<void> showRewardedAd({
    required AdType adType,
    required VoidCallback onUserEarnedReward,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailedToShow,
    VoidCallback? onAdInterrupted,
  }) async {
    final ad = _rewardedAds[adType];
    if (ad == null || _adLoadedStates[adType] != true) {
      // 廣告未載入
      onAdFailedToShow?.call();
      return;
    }

    bool hasEarnedReward = false;
    _onAdInterruptedCallbacks[adType] = onAdInterrupted;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _adShowingStates[adType] = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        _adShowingStates[adType] = false;
        ad.dispose();
        _rewardedAds[adType] = null;
        _adLoadedStates[adType] = false;
        _onAdInterruptedCallbacks[adType] = null;

        // 先調用 dismiss callback
        onAdDismissed?.call();

        // 如果已經獲得獎勵，調用獎勵 callback
        if (hasEarnedReward) {
          onUserEarnedReward();
        }

        // 預載下一個廣告
        loadRewardedAd(adType);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _adShowingStates[adType] = false;
        ad.dispose();
        _rewardedAds[adType] = null;
        _adLoadedStates[adType] = false;
        _onAdInterruptedCallbacks[adType] = null;
        debugPrint('AdService: 顯示 ${adType.name} 廣告失敗: $error');
        onAdFailedToShow?.call();
        // 嘗試重新載入
        loadRewardedAd(adType);
      },
    );

    await ad.show(
      onUserEarnedReward: (ad, reward) {
        hasEarnedReward = true;
      },
    );
  }

  /// 中斷廣告播放（用於錯誤處理）
  /// [adType] 要中斷的廣告類型，如果為 null 則中斷所有正在顯示的廣告
  void interruptAd([AdType? adType]) {
    final typesToInterrupt = adType != null ? [adType] : AdType.values;

    for (final type in typesToInterrupt) {
      if (_adShowingStates[type] == true && _rewardedAds[type] != null) {
        debugPrint('AdService: 中斷 ${type.name} 廣告播放');
        // 調用中斷回調
        _onAdInterruptedCallbacks[type]?.call();
        _onAdInterruptedCallbacks[type] = null;

        // 注意：Google Mobile Ads SDK 沒有直接的 dismiss 方法
        // 我們只能通過回調來處理，這裡只是標記狀態
        _adShowingStates[type] = false;
      }
    }
  }

  /// 檢查指定類型的廣告是否已載入
  bool isAdLoaded(AdType adType) => _adLoadedStates[adType] == true;

  /// 檢查指定類型的廣告是否正在顯示
  bool isAdShowing(AdType adType) => _adShowingStates[adType] == true;

  /// 檢查是否有任何廣告正在顯示
  bool get isAnyAdShowing {
    return _adShowingStates.values.any((showing) => showing == true);
  }

  /// 釋放資源
  void dispose() {
    for (final adType in AdType.values) {
      _rewardedAds[adType]?.dispose();
      _rewardedAds[adType] = null;
      _adLoadedStates[adType] = false;
      _adShowingStates[adType] = false;
      _adLoadedControllers[adType]?.close();
    }
    _rewardedAds.clear();
    _adLoadedStates.clear();
    _adShowingStates.clear();
    _adLoadedControllers.clear();
    _onAdInterruptedCallbacks.clear();
  }
}
