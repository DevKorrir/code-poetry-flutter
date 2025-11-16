import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isGradient;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final Widget? leadingIcon;
  final Widget? trailingIcon;


  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isGradient = true,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.padding,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isOutlined) {
      return _buildOutlinedButton(context);
    }

    if (isGradient) {
      return _buildGradientButton(context);
    }

    return _buildSolidButton(context, isDark);
  }

  Widget _buildGradientButton(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryStart.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : () {
            HapticFeedback.lightImpact();
            onPressed?.call();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
            child: _buildContent(context, Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildSolidButton(BuildContext context, bool isDark) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : () {
          HapticFeedback.lightImpact();
          onPressed?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryStart,
          foregroundColor: textColor ?? Colors.white,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildContent(context, textColor ?? Colors.white),
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : () {
          HapticFeedback.lightImpact();
          onPressed?.call();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primaryStart,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          side: BorderSide(
            color: textColor ?? AppColors.primaryStart,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildContent(context, textColor ?? AppColors.primaryStart),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null) ...[
          leadingIcon!,
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: AppTextStyles.buttonMedium(color: color),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          trailingIcon!,
        ],
      ],
    );
  }
}