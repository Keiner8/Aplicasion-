import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/rounded_text_field.dart';
import '../../providers/app_provider.dart';
import '../../providers/video_provider.dart';

/// Pantalla de inicio con campo de URL, historial y accesos rápidos.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _urlController;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _animController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  void _analyze() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    final platform = _detectPlatform(url);
    if (platform == null || platform == 'Google') {
      _showMessage(
        'Ingresa un enlace de video compatible: TikTok, YouTube o Instagram.',
        AppColors.error,
      );
      return;
    }

    if (platform != 'TikTok') {
      _showMessage(
        '$platform todavia no esta conectado. Por ahora la descarga sin marca funciona con TikTok.',
        AppColors.warning,
      );
      return;
    }

    // Solo permitir TikTok por ahora (según el requerimiento principal)
    if (!url.contains('tiktok.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un enlace válido de TikTok.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final extractor = ref.read(videoExtractorProvider);
      final videoInfo = await extractor.extractVideoInfo(url);

      if (videoInfo != null && mounted) {
        ref.read(currentVideoInfoProvider.notifier).state = videoInfo;
        context.push(AppRoutes.analysis);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo encontrar el video. Revisa el enlace.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _detectPlatform(String url) {
    final value = url.toLowerCase();

    if (value.contains('tiktok.com') || value.contains('vm.tiktok.com')) {
      return 'TikTok';
    }
    if (value.contains('youtube.com') || value.contains('youtu.be')) {
      return 'YouTube';
    }
    if (value.contains('instagram.com')) {
      return 'Instagram';
    }
    if (value.contains('google.com') || value.contains('goo.gl')) {
      return 'Google';
    }

    return null;
  }

  void _showMessage(String message, Color backgroundColor) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final processedVideos = ref.watch(appProvider).processedVideos;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Header con logo
                  _HomeHeader(),

                  const SizedBox(height: 32),

                  // Sección principal de análisis
                  _AnalyzeSection(
                    controller: _urlController,
                    onAnalyze: _analyze,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 28),

                  // Accesos rápidos
                  _QuickActions(),

                  const SizedBox(height: 28),

                  // Historial reciente
                  if (processedVideos.isNotEmpty) ...[
                    _RecentHistory(videos: processedVideos),
                    const SizedBox(height: 16),
                  ],

                  // Banner informativo
                  _InfoBanner(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo pequeño
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 16,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              AppAssets.logo,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Clean',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: 'Clip',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Editor de video inteligente',
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ),
      ],
    );
  }
}

class _AnalyzeSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAnalyze;
  final bool isLoading;

  const _AnalyzeSection({
    required this.controller,
    required this.onAnalyze,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Procesa tu video',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pega el enlace de YouTube, TikTok o Instagram',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 18),
          RoundedTextField(
            hint: AppStrings.pasteLink,
            controller: controller,
            prefixIcon: Icons.link_rounded,
            showClearButton: true,
            keyboardType: TextInputType.url,
            onSubmitted: onAnalyze,
          ),
          const SizedBox(height: 14),
          GradientButton(
            label: isLoading ? 'Analizando...' : AppStrings.analyze,
            icon: isLoading
                ? Icons.hourglass_top_rounded
                : Icons.search_rounded,
            onPressed: isLoading ? null : onAnalyze,
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones rápidas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.videocam_rounded,
                label: 'Recortar\nVideo',
                color: AppColors.primary,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.volume_off_rounded,
                label: 'Quitar\nAudio',
                color: const Color(0xFF0EA5E9),
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.high_quality_rounded,
                label: 'Mejorar\nCalidad',
                color: AppColors.success,
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.subtitles_rounded,
                label: 'Subtitulos\nInteligentes',
                color: AppColors.secondary,
                onTap: () => context.push(AppRoutes.subtitles),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox.shrink()),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentHistory extends StatelessWidget {
  final List<String> videos;

  const _RecentHistory({required this.videos});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recientes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.history),
              child: const Text(
                'Ver todo',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...videos.take(3).map((url) => _VideoItem(url: url)),
      ],
    );
  }
}

class _VideoItem extends StatelessWidget {
  final String url;

  const _VideoItem({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textHint,
            size: 14,
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Procesamiento rápido!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Hasta 4K de resolución soportada',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
