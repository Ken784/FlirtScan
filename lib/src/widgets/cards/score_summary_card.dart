import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class ScoreSummaryCard extends StatefulWidget {
  const ScoreSummaryCard({
    super.key,
    required this.title,
    required this.stateText,
    required this.scoreMajor,
    required this.scoreMinor,
  });

  final String title;
  final String stateText;
  final int scoreMajor; // e.g., 9
  final int scoreMinor; // e.g., 10

  @override
  State<ScoreSummaryCard> createState() => _ScoreSummaryCardState();
}

class _ScoreSummaryCardState extends State<ScoreSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFD9E7),
        borderRadius: AppRadii.card,
        boxShadow: AppShadow.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: AppTextStyles.footnote),
              const SizedBox(height: AppSpacing.s4),
              Text(widget.stateText, style: AppTextStyles.title2),
            ],
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              // 動畫：從 0 跳動到目標值
              final animatedScore = (widget.scoreMajor * _animation.value).round();
              return RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$animatedScore',
                      style: const TextStyle(
                        fontSize: 80,
                        height: 0.75, // 調整行高使數字更緊湊，垂直置中
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF02D2D), // 使用明確的顏色值
                        fontFamily: 'SF Pro',
                      ),
                    ),
                    TextSpan(
                      text: '/${widget.scoreMinor}',
                      style: AppTextStyles.title3.copyWith(
                        color: AppColors.textBlack80,
                        height: 0.75, // 同樣調整小字的行高
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}







