import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// AppBar personalizada para CleanClip.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showLogo;

  const CustomAppBar({
    super.key,
    this.title = '',
    this.showBack = false,
    this.actions,
    this.leading,
    this.showLogo = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.background,
            AppColors.background.withValues(alpha: 0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Leading / Back button
              if (showBack)
                _BackButton()
              else if (leading != null)
                leading!
              else
                const SizedBox(width: 40),

              const Spacer(),

              // Título o logo
              if (showLogo)
                Row(
                  children: [
                    Image.asset(
                      'assets/images/logo_icon.png',
                      height: 34,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.play_circle_fill,
                        color: AppColors.primary,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _AppNameText(),
                  ],
                )
              else
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

              const Spacer(),

              // Actions
              if (actions != null)
                Row(mainAxisSize: MainAxisSize.min, children: actions!)
              else
                const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

class _AppNameText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'Clean',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: 'Clip',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
