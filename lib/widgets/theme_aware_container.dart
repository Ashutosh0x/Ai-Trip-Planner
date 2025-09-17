import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class ThemeAwareContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final double? width;
  final double? height;

  const ThemeAwareContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.decoration,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration ?? BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [
            const Color(0xFF1A1A2E), // Dark blue
            const Color(0xFF16213E), // Darker blue
          ] : [
            const Color(0xFF8EC5FC), // Light blue
            const Color(0xFFE0C3FC), // Light purple
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}

class ThemeAwareCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final BorderRadius? borderRadius;

  const ThemeAwareCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.9),
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}

class ThemeAwareText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ThemeAwareText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    return Text(
      text,
      style: style?.copyWith(
        color: isDark ? Colors.white : style?.color ?? Colors.black87,
      ) ?? TextStyle(
        color: isDark ? Colors.white : Colors.black87,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class ThemeAwareIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  const ThemeAwareIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    return Icon(
      icon,
      size: size,
      color: color ?? (isDark ? Colors.white70 : Colors.black87),
    );
  }
}
