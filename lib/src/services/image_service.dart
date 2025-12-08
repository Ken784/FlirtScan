import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

/// 圖片處理結果
class ImageProcessResult {
  final File originalFile;
  final String base64String;
  final int compressedSizeBytes;
  
  ImageProcessResult({
    required this.originalFile,
    required this.base64String,
    required this.compressedSizeBytes,
  });
}

/// 圖片服務類別
/// 處理圖片選取、壓縮、Base64 轉換等功能
class ImageService {
  final ImagePicker _picker = ImagePicker();
  
  /// 選取圖片並處理
  /// 
  /// [source] 圖片來源（相簿或相機）
  /// 返回原始 File 物件，壓縮和 Base64 轉換會在背景執行
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      
      if (image == null) {
        return null;
      }
      
      final File originalFile = File(image.path);
      
      // 檢查檔案大小（> 10MB 則阻擋）
      final int fileSize = await originalFile.length();
      const int maxSizeBytes = 10 * 1024 * 1024; // 10MB
      
      if (fileSize > maxSizeBytes) {
        throw Exception('圖片檔案過大（${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB），請選擇較小的圖片（最大 10MB）');
      }
      
      return originalFile;
    } catch (e) {
      debugPrint('ImageService: 選取圖片時發生錯誤 - $e');
      rethrow;
    }
  }
  
  /// 壓縮圖片並轉換為 Base64
  /// 
  /// [imageFile] 原始圖片檔案
  /// 返回處理結果，包含原始檔案、Base64 字串和壓縮後大小
  Future<ImageProcessResult> compressAndConvertToBase64(File imageFile) async {
    try {
      // 讀取原始圖片尺寸
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image decodedImage = frameInfo.image;
      final int originalWidth = decodedImage.width;
      final int originalHeight = decodedImage.height;
      
      // 釋放圖片資源
      decodedImage.dispose();
      
      // 計算壓縮後的尺寸（如果寬度超過 512px，等比壓縮到 512px）
      int targetWidth = originalWidth;
      int targetHeight = originalHeight;
      
      if (originalWidth > 512) {
        final double ratio = 512.0 / originalWidth;
        targetWidth = 512;
        targetHeight = (originalHeight * ratio).round();
      }
      
      // 取得臨時目錄
      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // 壓縮圖片
      final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 70, // 品質設為 70%
        minWidth: targetWidth,
        minHeight: targetHeight,
        format: CompressFormat.jpeg, // 轉為 JPEG
      );
      
      if (compressedFile == null) {
        throw Exception('圖片壓縮失敗');
      }
      
      // 讀取壓縮後的檔案並轉換為 Base64
      final Uint8List compressedBytes = await compressedFile.readAsBytes();
      final String base64String = base64Encode(compressedBytes);
      
      // 記錄壓縮後的大小
      final int compressedSizeBytes = compressedBytes.length;
      
      debugPrint('ImageService: 圖片壓縮完成');
      debugPrint('ImageService: 原始尺寸 ${originalWidth}x$originalHeight');
      debugPrint('ImageService: 壓縮後尺寸 ${targetWidth}x$targetHeight');
      debugPrint('ImageService: 壓縮後大小 ${(compressedSizeBytes / 1024).toStringAsFixed(2)}KB');
      debugPrint('ImageService: Base64 前 100 個字元: ${base64String.substring(0, base64String.length > 100 ? 100 : base64String.length)}');
      
      return ImageProcessResult(
        originalFile: imageFile,
        base64String: base64String,
        compressedSizeBytes: compressedSizeBytes,
      );
    } catch (e) {
      debugPrint('ImageService: 壓縮圖片時發生錯誤 - $e');
      rethrow;
    }
  }
  
  /// 檢查檔案大小
  /// 
  /// [file] 要檢查的檔案
  /// 返回檔案大小（位元組）
  Future<int> getFileSize(File file) async {
    return await file.length();
  }
  
  /// 檢查檔案是否超過大小限制
  /// 
  /// [file] 要檢查的檔案
  /// [maxSizeBytes] 最大大小（位元組），預設為 3MB
  /// 返回 true 如果超過限制
  Future<bool> isFileTooLarge(File file, {int maxSizeBytes = 10 * 1024 * 1024}) async {
    final int fileSize = await getFileSize(file);
    return fileSize > maxSizeBytes;
  }
}

