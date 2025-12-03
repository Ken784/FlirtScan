import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

class UploadCard extends StatelessWidget {
  const UploadCard({
    super.key,
    this.image,
    this.onRemove,
  });

  final ImageProvider? image;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = image != null;
    return Container(
      height: 416,
      decoration: BoxDecoration(
        color: hasImage ? const Color(0xFFFCFC92) : AppColors.surface,
        borderRadius: AppRadii.image,
        boxShadow: AppShadow.card,
        border: hasImage ? Border.all(color: Colors.white, width: 8) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            Image(
              image: image!,
              fit: BoxFit.cover,
            )
          else
            Center(
              child: Icon(Icons.chat_bubble_outline, color: Colors.black26, size: 72),
            ),
          if (hasImage && onRemove != null)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(AppRadii.r16),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}



