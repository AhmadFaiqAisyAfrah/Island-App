import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GlassHint extends StatelessWidget {
  final String text;
  final VoidCallback onDismiss;
  final bool isNight;
  final EdgeInsets margin;
  final double? maxWidth;

  const GlassHint({
    super.key,
    required this.text,
    required this.onDismiss,
    this.isNight = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 24),
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isNight
        ? Colors.white.withOpacity(0.12)
        : Colors.white.withOpacity(0.7);
    final borderColor = isNight
        ? Colors.white.withOpacity(0.18)
        : Colors.white.withOpacity(0.85);
    final textColor = isNight ? Colors.white.withOpacity(0.92) : AppColors.textMain;
    final iconColor = isNight ? Colors.white.withOpacity(0.6) : AppColors.textSub;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? 360),
        child: Container(
          margin: margin,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: isNight
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        text,
                        style: AppTextStyles.body.copyWith(
                          color: textColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onDismiss,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.close_rounded, size: 16, color: iconColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
