import 'dart:ui';
import 'package:flutter/material.dart';

/// Premium glassmorphism container with frosted glass effect
class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double opacity;

  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 20,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.opacity = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor ??
                  (isDark
                      ? Colors.white.withValues(alpha: opacity)
                      : Colors.white.withValues(alpha: 0.6)),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ??
                    (isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.5)),
                width: 1,
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
