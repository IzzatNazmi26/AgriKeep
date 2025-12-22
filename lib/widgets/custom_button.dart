import 'package:flutter/material.dart';
import 'package:agrikeep/utils/theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool fullWidth;
  final bool disabled;
  final Widget? icon;
  final bool loading;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.fullWidth = false,
    this.disabled = false,
    this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || onPressed == null;
    final buttonStyle = _getButtonStyle(variant, isDisabled);

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isDisabled || loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonStyle.backgroundColor,
          foregroundColor: buttonStyle.foregroundColor,
          side: buttonStyle.border,
          padding: _getPadding(size),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: loading
            ? SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              buttonStyle.foregroundColor,
            ),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: _getFontSize(size),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  EdgeInsets _getPadding(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getFontSize(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }

  _ButtonStyle _getButtonStyle(ButtonVariant variant, bool isDisabled) {
    if (isDisabled) {
      return _ButtonStyle(
        backgroundColor: AgriKeepTheme.borderColor,
        foregroundColor: AgriKeepTheme.textTertiary,
        border: BorderSide.none,
      );
    }

    switch (variant) {
      case ButtonVariant.primary:
        return _ButtonStyle(
          backgroundColor: AgriKeepTheme.primaryColor,
          foregroundColor: Colors.white,
          border: BorderSide.none,
        );
      case ButtonVariant.secondary:
        return _ButtonStyle(
          backgroundColor: AgriKeepTheme.secondaryColor,
          foregroundColor: Colors.white,
          border: BorderSide.none,
        );
      case ButtonVariant.outline:
        return _ButtonStyle(
          backgroundColor: Colors.transparent,
          foregroundColor: AgriKeepTheme.primaryColor,
          border: const BorderSide(
            color: AgriKeepTheme.primaryColor,
            width: 2,
          ),
        );
    }
  }
}

class _ButtonStyle {
  final Color backgroundColor;
  final Color foregroundColor;
  final BorderSide border;

  _ButtonStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.border,
  });
}

enum ButtonVariant { primary, secondary, outline }
enum ButtonSize { small, medium, large }