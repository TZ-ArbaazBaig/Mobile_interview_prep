import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatelessWidget {
  final String? text;
  final String? label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double? width;

  const AppButton({
    super.key,
    this.text,
    this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading && !isDisabled;
    final String displayLabel = label ?? text ?? '';
    
    Widget buttonContent = isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: _getTextColor(isEnabled)),
                const SizedBox(width: 8),
              ],
              Text(
                displayLabel,
                style: AppTextStyles.buttonText(
                  color: _getTextColor(isEnabled),
                ),
              ),
            ],
          );

    return SizedBox(
      width: width ?? double.infinity,
      height: 52,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: isEnabled && (variant == AppButtonVariant.primary || variant == AppButtonVariant.danger)
              ? [
                  BoxShadow(
                    color: (variant == AppButtonVariant.danger ? AppColors.error : AppColors.violet).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: _getButtonStyle(isEnabled),
          child: buttonContent,
        ),
      ),
    );
  }

  Color _getTextColor(bool isEnabled) {
    if (!isEnabled) return AppColors.textMuted;
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return Colors.white;
      case AppButtonVariant.secondary:
        return AppColors.violet;
      case AppButtonVariant.ghost:
        return AppColors.textSecondary;
    }
  }

  ButtonStyle _getButtonStyle(bool isEnabled) {
    final Color disabledBg = AppColors.bgSecondary.withOpacity(0.5);
    
    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColors.violet : disabledBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        );
      case AppButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.violet,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isEnabled ? AppColors.violet : AppColors.border,
              width: 1.5,
            ),
          ),
        );
      case AppButtonVariant.ghost:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textSecondary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      case AppButtonVariant.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColors.error : disabledBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        );
    }
  }
}
