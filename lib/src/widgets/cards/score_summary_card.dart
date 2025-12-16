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
        color: const Color(0xFF350354),
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
              Text(
                widget.title,
                style: AppTextStyles.captionRegular.copyWith(
                  letterSpacing: 0,
                  height: 16 / 12,
                  color: Colors.white,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                widget.stateText,
                style: AppTextStyles.body1Semi.copyWith(
                  fontSize: 20,
                  height: 25 / 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.45,
                  color: Colors.white,
                ),
              ),
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
                      style: TextStyle(
                        fontSize: 72,
                        height: 72 / 72,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF509C),
                        fontFamily: AppTextStyles.primaryFontFamily,
                        letterSpacing: 0.38,
                      ),
                    ),
                    TextSpan(
                      text: '/${widget.scoreMinor}',
                      style: TextStyle(
                        fontSize: 16,
                        height: 16 / 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        fontFamily: AppTextStyles.primaryFontFamily,
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







