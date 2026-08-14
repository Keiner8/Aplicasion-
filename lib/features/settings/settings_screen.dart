import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/glass_card.dart';
import '../../providers/app_provider.dart';
import '../../core/constants/app_constants.dart';

/// Pantalla de ajustes de la aplicación.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: AppStrings.settingsTab),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Perfil / Logo de la app
            _ProfileCard(),
            const SizedBox(height: 24),

            // Sección Apariencia
            _SectionTitle(label: 'Apariencia'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _SwitchTile(
                  icon: Icons.dark_mode_rounded,
                  iconColor: AppColors.secondary,
                  label: 'Modo oscuro',
                  subtitle: 'Tema oscuro activo',
                  value: appState.isDarkMode,
                  onChanged: (val) =>
                      ref.read(appProvider.notifier).toggleDarkMode(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sección Idioma
            _SectionTitle(label: 'Idioma'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _SelectTile(
                  icon: Icons.language_rounded,
                  iconColor: const Color(0xFF0EA5E9),
                  label: 'Idioma de la app',
                  value: appState.language == 'es' ? 'Español' : 'English',
                  onTap: () => _showLanguageSheet(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sección Sobre la app
            _SectionTitle(label: 'Información'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _TapTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColors.primary,
                  label: 'Acerca de CleanClip',
                  subtitle: 'Versión 1.0.0',
                  onTap: () => _showAboutDialog(context),
                ),
                const _Divider(),
                _TapTile(
                  icon: Icons.privacy_tip_outlined,
                  iconColor: AppColors.success,
                  label: 'Política de privacidad',
                  onTap: () {},
                ),
                const _Divider(),
                _TapTile(
                  icon: Icons.article_outlined,
                  iconColor: AppColors.warning,
                  label: 'Términos de uso',
                  onTap: () {},
                ),
                const _Divider(),
                _TapTile(
                  icon: Icons.star_outline_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  label: 'Calificar la app',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sección Soporte
            _SectionTitle(label: 'Soporte'),
            const SizedBox(height: 12),
            _SettingsCard(
              children: [
                _TapTile(
                  icon: Icons.help_outline_rounded,
                  iconColor: AppColors.secondary,
                  label: 'Centro de ayuda',
                  onTap: () {},
                ),
                const _Divider(),
                _TapTile(
                  icon: Icons.bug_report_outlined,
                  iconColor: AppColors.error,
                  label: 'Reportar un problema',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Footer
            Center(
              child: Column(
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Clean',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: 'Clip',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'v1.0.0 • Hecho con ❤️',
                    style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona un idioma',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _LangOption(
              label: '🇪🇸  Español',
              selected: ref.read(appProvider).language == 'es',
              onTap: () {
                ref.read(appProvider.notifier).setLanguage('es');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            _LangOption(
              label: '🇺🇸  English',
              selected: ref.read(appProvider).language == 'en',
              onTap: () {
                ref.read(appProvider.notifier).setLanguage('en');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'CleanClip',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        ),
        content: const Text(
          'CleanClip es una aplicación profesional de edición y procesamiento de video. Versión 1.0.0\n\n© 2024 CleanClip. Todos los derechos reservados.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                AppAssets.logo,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CleanClip Pro',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Editor de video inteligente',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textHint,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _IconBox(icon: icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 12)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SelectTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _IconBox(icon: icon, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
            ),
            Text(value,
                style: const TextStyle(
                    color: AppColors.secondary, fontSize: 14)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}

class _TapTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _TapTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _IconBox(icon: icon, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: const TextStyle(
                            color: AppColors.textHint, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
        height: 1, color: AppColors.border, indent: 68, endIndent: 16);
  }
}

class _LangOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangOption(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          children: [
            Text(label,
                style: TextStyle(
                  color: selected ? AppColors.primary : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                )),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_rounded,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
