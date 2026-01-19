import 'package:flutter/material.dart';
import 'package:agrikeep/utils/theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? leading;
  final Widget? action;
  final bool showDivider;

  const AppHeader({
    super.key,
    required this.title,
    this.onBack,
    this.leading,
    this.action,
    this.showDivider = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AgriKeepTheme.surfaceColor,
        border: showDivider
            ? Border(
          bottom: BorderSide(
            color: AgriKeepTheme.borderColor,
            width: 1,
          ),
        )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              // Back button OR leading widget
              if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                  color: AgriKeepTheme.textPrimary,
                  splashRadius: 20,
                )
              else if (leading != null)
                leading!
              else
                const SizedBox(width: 48),

              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AgriKeepTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // Action widget or placeholder
              action ??
                  (onBack != null || leading != null
                      ? const SizedBox(width: 48)
                      : const SizedBox(width: 16)),
            ],
          ),
        ),
      ),
    );
  }
}