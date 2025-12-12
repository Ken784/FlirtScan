import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as img;

/// 截圖服務：用於生成長截圖並分享
class ScreenshotService {
  /// 從 RepaintBoundary 生成圖片並分享
  /// 
  /// [repaintBoundaryKey] RepaintBoundary 的 GlobalKey
  /// [pixelRatio] 圖片解析度倍數（預設 3.0，生成高解析度圖片）
  /// [context] BuildContext 用於獲取 sharePositionOrigin（iOS 需要）
  Future<void> captureAndShare({
    required GlobalKey repaintBoundaryKey,
    double pixelRatio = 3.0,
    BuildContext? context,
  }) async {
    try {
      // 獲取 RenderRepaintBoundary
      final RenderRepaintBoundary? boundary = repaintBoundaryKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('無法找到 RepaintBoundary');
      }

      // 等待多幀，確保所有內容都已渲染
      await Future.delayed(const Duration(milliseconds: 500));
      await SchedulerBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 100));

      // 生成圖片
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      
      // 將圖片轉換為 PNG bytes（用於讀取）
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('無法將圖片轉換為 bytes');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // 將 PNG 轉換為 JPG（帶背景色）
      // 讀取 PNG 圖片
      final img.Image? decodedImage = img.decodeImage(pngBytes);
      if (decodedImage == null) {
        throw Exception('無法解碼 PNG 圖片');
      }
      
      // 創建帶背景色的圖片（使用漸層背景色）
      // 背景色：從 AppColors.bgGradientTop 到 AppColors.bgGradientBottom
      const bgTop = Color(0xFFFFEEFE); // AppColors.bgGradientTop
      const bgBottom = Color(0xFFE8F2FF); // AppColors.bgGradientBottom
      
      // 創建新圖片，填充背景色
      final img.Image imageWithBg = img.Image(width: decodedImage.width, height: decodedImage.height);
      
      // 填充漸層背景
      for (int y = 0; y < imageWithBg.height; y++) {
        final double t = y / imageWithBg.height;
        final Color bgColor = Color.lerp(bgTop, bgBottom, t)!;
        final int r = (bgColor.r * 255.0).round().clamp(0, 255);
        final int g = (bgColor.g * 255.0).round().clamp(0, 255);
        final int b = (bgColor.b * 255.0).round().clamp(0, 255);
        
        for (int x = 0; x < imageWithBg.width; x++) {
          imageWithBg.setPixel(x, y, img.ColorRgb8(r, g, b));
        }
      }
      
      // 將原圖合成到背景上（處理透明像素）
      img.compositeImage(imageWithBg, decodedImage, dstX: 0, dstY: 0);
      
      // 編碼為 JPG
      final Uint8List jpgBytes = Uint8List.fromList(img.encodeJpg(imageWithBg, quality: 95));

      // 保存到臨時文件
      final Directory tempDir = await getTemporaryDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final File imageFile = File('${tempDir.path}/screenshot_$timestamp.jpg');
      await imageFile.writeAsBytes(jpgBytes);

      // 分享圖片
      // iOS 需要 sharePositionOrigin 參數
      if (defaultTargetPlatform == TargetPlatform.iOS && context != null && context.mounted) {
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          final sharePositionOrigin = box.localToGlobal(Offset.zero) & box.size;
          await Share.shareXFiles(
            [XFile(imageFile.path)],
            subject: '分析結果',
            text: '分享我的分析結果',
            sharePositionOrigin: sharePositionOrigin,
          );
        } else {
          await Share.shareXFiles(
            [XFile(imageFile.path)],
            subject: '分析結果',
            text: '分享我的分析結果',
          );
        }
      } else {
        await Share.shareXFiles(
          [XFile(imageFile.path)],
          subject: '分析結果',
          text: '分享我的分析結果',
        );
      }

      // 清理：延遲刪除臨時文件（給分享功能時間完成）
      Future.delayed(const Duration(seconds: 5), () async {
        try {
          if (await imageFile.exists()) {
            await imageFile.delete();
          }
        } catch (e) {
          // 忽略清理錯誤
          debugPrint('清理臨時文件失敗: $e');
        }
      });
    } catch (e) {
      debugPrint('截圖失敗: $e');
      rethrow;
    }
  }
}
