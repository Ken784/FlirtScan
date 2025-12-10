import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isAdShowing = false;
  
  final _adLoadedController = StreamController<bool>.broadcast();
  Stream<bool> get adLoadedStream => _adLoadedController.stream;
  
  // 用於中斷廣告的回調
  VoidCallback? _onAdInterrupted;

  // 測試廣告單元 ID（Android 和 iOS）
  static String get rewardedAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Android 測試 ID
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // iOS 測試 ID
    }
    return '';
  }

  /// 初始化 Google Mobile Ads SDK
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// 預載廣告
  Future<void> loadRewardedAd() async {
    if (_isAdLoaded) {
      return; // 廣告已載入
    }

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
          _adLoadedController.add(true);
          
          // 設定 Full Screen Content Callback
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _isAdShowing = true;
            },
            onAdDismissedFullScreenContent: (ad) {
              _isAdShowing = false;
              ad.dispose();
              _rewardedAd = null;
              _isAdLoaded = false;
              // 自動預載下一個廣告
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _isAdShowing = false;
              ad.dispose();
              _rewardedAd = null;
              _isAdLoaded = false;
              // 嘗試重新載入
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          _adLoadedController.add(false);
          // 延遲 5 秒後重試
          Future.delayed(const Duration(seconds: 5), () {
            loadRewardedAd();
          });
        },
      ),
    );
  }

  /// 顯示獎勵廣告
  /// [onUserEarnedReward] 當用戶看完廣告獲得獎勵時調用
  /// [onAdDismissed] 當廣告被關閉時調用（無論是否獲得獎勵）
  /// [onAdInterrupted] 當廣告被中斷時調用（用於錯誤處理）
  Future<void> showRewardedAd({
    required VoidCallback onUserEarnedReward,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailedToShow,
    VoidCallback? onAdInterrupted,
  }) async {
    if (_rewardedAd == null || !_isAdLoaded) {
      // 廣告未載入
      onAdFailedToShow?.call();
      return;
    }

    bool hasEarnedReward = false;
    _onAdInterrupted = onAdInterrupted;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isAdShowing = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        _isAdShowing = false;
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        _onAdInterrupted = null;
        
        // 先調用 dismiss callback
        onAdDismissed?.call();
        
        // 如果已經獲得獎勵，調用獎勵 callback
        if (hasEarnedReward) {
          onUserEarnedReward();
        }
        
        // 預載下一個廣告
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isAdShowing = false;
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        _onAdInterrupted = null;
        onAdFailedToShow?.call();
        // 嘗試重新載入
        loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        hasEarnedReward = true;
      },
    );
  }
  
  /// 中斷廣告播放（用於錯誤處理）
  void interruptAd() {
    if (_isAdShowing && _rewardedAd != null) {
      debugPrint('AdService: 中斷廣告播放');
      // 調用中斷回調
      _onAdInterrupted?.call();
      _onAdInterrupted = null;
      
      // 關閉廣告（這會觸發 onAdDismissedFullScreenContent）
      // 注意：Google Mobile Ads SDK 沒有直接的 dismiss 方法
      // 我們只能通過回調來處理
      _isAdShowing = false;
    }
  }

  /// 檢查廣告是否已載入
  bool get isAdLoaded => _isAdLoaded;

  /// 檢查廣告是否正在顯示
  bool get isAdShowing => _isAdShowing;

  /// 釋放資源
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdLoaded = false;
    _isAdShowing = false;
    _adLoadedController.close();
  }
}

