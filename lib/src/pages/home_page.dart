import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flirt_scan/l10n/app_localizations.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_radii.dart';
import '../core/theme/app_shadows.dart';
import '../core/icons/app_icon_widgets.dart';
import '../core/providers/error_provider.dart';
import '../core/providers/analysis_provider.dart';
import '../widgets/navigation/page_header.dart';
import '../widgets/upload/upload_card.dart';
import '../widgets/navigation/bottom_nav.dart';
import '../widgets/buttons/app_button.dart';
import '../widgets/error_dialog.dart';
import '../services/image_service.dart';
import '../services/ad_service.dart';
import 'result_page.dart';
import 'history_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  static const String route = '/';

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _navIndex = 0;
  File? _selectedImage;
  String? _preparedBase64String;
  bool _isProcessing = false;
  bool _isAnalyzing = false;
  final ImageService _imageService = ImageService();
  bool _hasNavigatedToResult = false;

  Future<void> _pickImage() async {
    try {
      // 使用 ImageService 選取圖片（會檢查檔案大小）
      final File? imageFile = await _imageService.pickImage();

      if (imageFile != null) {
        // 立即更新 UI 顯示原始圖片
        setState(() {
          _selectedImage = imageFile;
          _preparedBase64String = null; // 重置 Base64
          _isProcessing = true;
        });

        // 非同步執行壓縮與 Base64 轉換
        _compressAndPrepareImage(imageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('選取圖片時發生錯誤：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 非同步壓縮圖片並轉換為 Base64
  Future<void> _compressAndPrepareImage(File imageFile) async {
    try {
      final ImageProcessResult result =
          await _imageService.compressAndConvertToBase64(imageFile);

      // 在 Console 印出 Base64 前 100 個字元
      final String preview = result.base64String.length > 100
          ? result.base64String.substring(0, 100)
          : result.base64String;
      debugPrint('HomePage: Base64 前 100 個字元: $preview');

      if (mounted) {
        setState(() {
          _preparedBase64String = result.base64String;
          _isProcessing = false;
        });
      }
    } catch (e) {
      debugPrint('HomePage: 壓縮圖片時發生錯誤 - $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('處理圖片時發生錯誤：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _preparedBase64String = null;
      _isProcessing = false;
      _isAnalyzing = false;
    });
  }

  /// 重置到初始狀態（清除圖片和分析狀態）
  void _resetToInitialState() {
    setState(() {
      _selectedImage = null;
      _preparedBase64String = null;
      _isProcessing = false;
      _isAnalyzing = false;
      _hasNavigatedToResult = false;
    });
    // 同時重置分析 provider 的狀態
    ref.read(analysisProvider.notifier).reset();
  }

  /// 開始分析對話
  Future<void> _startAnalysis() async {
    if (_preparedBase64String == null || _isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      debugPrint('準備開始分析（圖片長度：${_preparedBase64String!.length}）');

      // 使用 analysisProvider 開始背景分析
      ref.read(analysisProvider.notifier).analyze(_preparedBase64String!);

      // 播放全螢幕廣告
      await _showAd();

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      debugPrint('分析錯誤: $e');
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ref.read(errorProvider.notifier).showError(
              '發生錯誤: ${e.toString()}',
              title: AppLocalizations.of(context)!.errorTitle,
            );
      }
    }
  }

  /// 顯示全螢幕獎勵廣告
  Future<void> _showAd() async {
    final adService = AdService();

    // 檢查廣告是否已載入（使用一般分析廣告）
    if (!adService.isAdLoaded(AdType.startAnalysis)) {
      // 廣告未載入，顯示錯誤
      if (mounted) {
        ref.read(errorProvider.notifier).showError(
              AppLocalizations.of(context)!.errorAdNotLoaded,
              title: AppLocalizations.of(context)!.errorTitle,
            );
      }
      return;
    }

    bool adInterrupted = false;

      // 顯示全螢幕獎勵廣告（一般分析廣告）
    await adService.showRewardedAd(
      adType: AdType.startAnalysis,
      onUserEarnedReward: () {
        // 用戶看完廣告，跳轉到 ResultPage
        debugPrint('廣告播放完成，跳轉到結果頁面');
        if (mounted && !adInterrupted) {
          setState(() {
            _hasNavigatedToResult = true;
          });
          context.push(
            '${ResultPage.route}?imageBase64=${Uri.encodeComponent(_preparedBase64String!)}',
          ).then((_) {
            // 當從 ResultPage 返回時，檢查分析狀態
            if (mounted && _hasNavigatedToResult) {
              final analysisState = ref.read(analysisProvider);
              // 只有在有分析結果的情況下才清除圖片（正常返回）
              // 如果是錯誤狀態，保留圖片讓用戶可以重試
              if (analysisState.isCompleted && analysisState.result != null) {
                _resetToInitialState();
              } else {
                // 錯誤返回，重置分析狀態但保留圖片，讓用戶可以重試
                setState(() {
                  _hasNavigatedToResult = false;
                  _isAnalyzing = false;
                });
                // 重置分析 provider 的狀態，但保留圖片
                ref.read(analysisProvider.notifier).reset();
              }
            }
          });
        }
      },
      onAdDismissed: () {
        debugPrint('廣告被關閉');
      },
      onAdFailedToShow: () {
        // 廣告播放失敗
        if (mounted) {
          ref.read(errorProvider.notifier).showError(
                AppLocalizations.of(context)!.errorAdNotLoaded,
                title: AppLocalizations.of(context)!.errorTitle,
              );
        }
      },
      onAdInterrupted: () {
        // 廣告被中斷（因為錯誤）
        debugPrint('廣告被中斷');
        adInterrupted = true;
        // 不需要做任何事，因為錯誤已經在 errorProvider 中顯示
      },
    );
  }

  /// 顯示全螢幕圖片預覽
  void _showImagePreview() {
    if (_selectedImage == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(_selectedImage!),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 監聽錯誤狀態
    final errorState = ref.watch(errorProvider);

    // 監聽分析錯誤（必須在 build 方法中）
    ref.listen<AnalysisState>(analysisProvider, (previous, next) {
      if (next.hasError && mounted && !errorState.hasError) {
        debugPrint('HomePage: 偵測到分析錯誤，中斷廣告播放');

        // 中斷廣告播放（一般分析廣告）
        final adService = AdService();
        if (adService.isAdShowing(AdType.startAnalysis)) {
          adService.interruptAd(AdType.startAnalysis);
        }

        // 顯示錯誤
        ref.read(errorProvider.notifier).showError(
              next.errorMessage ??
                  AppLocalizations.of(context)!.errorAnalysisFailed,
              title: AppLocalizations.of(context)!.errorTitle,
            );

        setState(() {
          _isAnalyzing = false;
        });
      }
    });

    return Stack(
      children: [
        // 主要內容
        Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.bgGradientTop, AppColors.bgGradientBottom],
              ),
            ),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s20, 0, AppSpacing.s20, 120),
                children: [
                  // 標題欄
                  PageHeader(
                    title: '曖昧分析',
                    leading: AppIconWidgets.heartOutline(size: 24),
                  ),
                  // 主要內容區域
                  if (_selectedImage == null)
                    ..._buildInitialStateContent()
                  else
                    ..._buildImagePreviewStateContent(),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNav(
            currentIndex: _navIndex,
            onTap: (i) {
              if (i == _navIndex) return;
              setState(() => _navIndex = i);
              if (i == 0) {
                context.go(HomePage.route);
              } else {
                context.go(HistoryPage.route);
              }
            },
          ),
        ),

        // 錯誤遮罩和對話框
        if (errorState.hasError) _buildErrorOverlay(errorState),
      ],
    );
  }

  /// 建立錯誤遮罩
  Widget _buildErrorOverlay(ErrorState errorState) {
    return Container(
      color: Colors.black.withOpacity(0.5), // 黑色半透明遮罩
      child: Center(
        child: ErrorDialog(
          title: errorState.title ?? AppLocalizations.of(context)!.errorTitle,
          message: errorState.message!,
          buttonText: AppLocalizations.of(context)!.ok,
          onPressed: () {
            // 清除錯誤，關閉遮罩
            ref.read(errorProvider.notifier).clearError();
          },
        ),
      ),
    );
  }

  List<Widget> _buildInitialStateContent() {
    return [
      const SizedBox(height: AppSpacing.s16),
      // 上傳卡片（按鈕在卡片內）
      UploadCard(
        onUploadPressed: _pickImage,
      ),
      const SizedBox(height: AppSpacing.s24),
      // 說明區域
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SectionTitle(text: '如何更精準的分析你們的曖昧程度？'),
            SizedBox(height: AppSpacing.s16),
            _CheckItem(text: '確保截圖包含完整的上下文'),
            SizedBox(height: AppSpacing.s8),
            _CheckItem(text: '只能分析雙人對話'),
            SizedBox(height: AppSpacing.s8),
            _CheckItem(text: '建議包含5句以上的對話'),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.s24),
    ];
  }

  List<Widget> _buildImagePreviewStateContent() {
    return [
      const SizedBox(height: AppSpacing.s24),
      // 圖片預覽卡片（可點擊預覽）
      Stack(
        children: [
          GestureDetector(
            onTap: _showImagePreview,
            child: Container(
              height: 416,
              decoration: BoxDecoration(
                color: Colors.white, // 白色背景
                borderRadius: AppRadii.image,
                border: Border.all(
                  color: Colors.white,
                  width: 8,
                ),
                boxShadow: AppShadow.card,
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: AppRadii.image,
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  // 處理中遮罩
                  if (_isProcessing)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: AppRadii.image,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // 右上角刪除按鈕
          Positioned(
            top: AppSpacing.s16,
            right: AppSpacing.s16,
            child: GestureDetector(
              onTap: _removeImage,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.s24),
      // 處理狀態提示
      if (_isProcessing)
        Text(
          '正在處理圖片...',
          style:
              AppTextStyles.body3Regular.copyWith(color: AppColors.textBlack80),
          textAlign: TextAlign.center,
        )
      else if (_isAnalyzing)
        Text(
          '正在分析對話...',
          style:
              AppTextStyles.body3Regular.copyWith(color: AppColors.textBlack80),
          textAlign: TextAlign.center,
        ),
      const SizedBox(height: AppSpacing.s16),
      // 開始分析按鈕
      AppButton(
        label: _isAnalyzing ? '分析中...' : '開始分析對話',
        variant: AppButtonVariant.primary,
        onPressed:
            _preparedBase64String != null && !_isProcessing && !_isAnalyzing
                ? _startAnalysis
                : null, // 未準備完成時禁用按鈕
      ),
      const SizedBox(height: AppSpacing.s16),
      // 說明文字
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        child: Text(
          '深度解析對話中的情緒、語氣與曖昧指數，還能生成雷達圖和可分享的金句！',
          style:
              AppTextStyles.body3Regular.copyWith(color: AppColors.textBlack80),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: AppSpacing.s24),
    ];
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.body2Bold,
    );
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIconWidgets.check(size: 24, color: AppColors.green),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body3Regular
                .copyWith(color: AppColors.textBlack80),
          ),
        ),
      ],
    );
  }
}
