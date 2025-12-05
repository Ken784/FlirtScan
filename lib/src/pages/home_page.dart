import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String route = '/';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('選取圖片時發生錯誤：$e')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
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
        // 圖片預覽卡片
        Stack(
          children: [
            Container(
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
              child: ClipRRect(
                borderRadius: AppRadii.image,
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
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
        // 開始分析按鈕
        AppButton(
          label: '開始分析對話',
          variant: AppButtonVariant.primary,
          onPressed: () {
            // TODO: 導航到分析結果頁面
          },
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





