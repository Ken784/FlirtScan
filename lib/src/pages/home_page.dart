import 'dart:io';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_radii.dart';
import '../core/theme/app_shadows.dart';
import '../core/icons/app_icon_widgets.dart';
import '../widgets/navigation/page_header.dart';
import '../widgets/upload/upload_card.dart';
import '../widgets/navigation/bottom_nav.dart';
import '../widgets/buttons/app_button.dart';
import '../services/image_service.dart';
import '../services/analysis_service.dart';
import '../core/models/analysis_result.dart';
import '../pages/analysis_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String route = '/';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;
  File? _selectedImage;
  String? _preparedBase64String;
  bool _isProcessing = false;
  bool _isAnalyzing = false;
  final ImageService _imageService = ImageService();
  final AnalysisService _analysisService = AnalysisService();

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
      final ImageProcessResult result = await _imageService.compressAndConvertToBase64(imageFile);
      
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

  /// 開始分析對話
  Future<void> _startAnalysis() async {
    if (_preparedBase64String == null || _isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      debugPrint('準備上傳 Base64 字串（長度：${_preparedBase64String!.length}）');
      
      // 呼叫分析服務
      final analysisResult = await _analysisService.analyzeConversation(
        imageBase64: _preparedBase64String!,
        language: 'zh-TW',
      );

      debugPrint('分析完成！總分: ${analysisResult.totalScore}/10');
      debugPrint('關係狀態: ${analysisResult.relationshipStatus}');

      // 導航到分析頁面
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AnalysisPage(),
          ),
        );
      }
    } on AnalysisException catch (e) {
      debugPrint('分析錯誤: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('未知錯誤: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分析失敗: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgGradientTop, AppColors.bgGradientBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 標題欄
              PageHeader(
                title: '曖昧分析',
                leading: AppIconWidgets.heartOutline(size: 24),
              ),
              // 主要內容區域
              Expanded(
                child: _selectedImage == null
                    ? _buildInitialState()
                    : _buildImagePreviewState(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }

  Widget _buildInitialState() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      children: [
        const SizedBox(height: AppSpacing.s16),
        // 上傳卡片（按鈕在卡片內）
        UploadCard(
          onUploadPressed: _pickImage,
        ),
        const SizedBox(height: AppSpacing.s24),
        // 說明區域
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
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
      ],
    );
  }

  Widget _buildImagePreviewState() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      children: [
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
            child: Text(
              '正在處理圖片...',
              style: AppTextStyles.callout.copyWith(color: AppColors.textBlack80),
              textAlign: TextAlign.center,
            ),
          )
        else if (_isAnalyzing)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
            child: Text(
              '正在分析對話...',
              style: AppTextStyles.callout.copyWith(color: AppColors.textBlack80),
              textAlign: TextAlign.center,
            ),
          )
        else if (_preparedBase64String != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
            child: Text(
              '圖片已準備完成，可以開始分析',
              style: AppTextStyles.callout.copyWith(color: AppColors.success),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: AppSpacing.s16),
        // 開始分析按鈕
        AppButton(
          label: _isAnalyzing ? '分析中...' : '開始分析對話',
          variant: AppButtonVariant.primary,
          onPressed: _preparedBase64String != null && !_isProcessing && !_isAnalyzing
              ? _startAnalysis
              : null, // 未準備完成時禁用按鈕
        ),
        const SizedBox(height: AppSpacing.s16),
        // 說明文字
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
          child: Text(
            '深度解析對話中的情緒、語氣與曖昧指數，還能生成雷達圖和可分享的金句！',
            style: AppTextStyles.subheadline,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.s24),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});
  final String text;
  
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.title3,
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
        AppIconWidgets.check(size: 24, color: AppColors.success),
        const SizedBox(width: AppSpacing.s10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.callout,
          ),
        ),
      ],
    );
  }
}





