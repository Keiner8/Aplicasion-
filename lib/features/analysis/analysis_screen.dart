import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_app_bar.dart';
import '../../providers/video_provider.dart';

/// Pantalla de análisis del video.
class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoInfo = ref.watch(currentVideoInfoProvider);
    if (videoInfo == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'No hay información del video.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: AppStrings.analysisTitle,
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Miniatura del video
            _VideoThumbnail(
              imageUrl: videoInfo.thumbnailUrl,
              durationStr: _formatDuration(videoInfo.duration),
            ),
            const SizedBox(height: 24),

            // Información del video
            const Text(
              'Información del video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            _VideoInfoGrid(
              durationStr: _formatDuration(videoInfo.duration),
              platform: videoInfo.platform,
            ),
            const SizedBox(height: 24),

            // Vista previa del título
            GradientCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Título del video',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    videoInfo.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Opciones de procesamiento
            const Text(
              'Opciones de edición',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            _EditOptions(),
            const SizedBox(height: 28),

            // Botón continuar
            GradientButton(
              label: AppStrings.continueText,
              icon: Icons.arrow_forward_rounded,
              onPressed: () => context.push(AppRoutes.processing),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }
}

class _VideoThumbnail extends StatelessWidget {
  final String imageUrl;
  final String durationStr;

  const _VideoThumbnail({required this.imageUrl, required this.durationStr});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1040), Color(0xFF2D1B69)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: AppColors.textHint,
                        size: 64,
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: AppColors.primary,
                      size: 64,
                    ),
                  ),
          ),
        ),
        // Badge de duración
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              durationStr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoInfoGrid extends StatelessWidget {
  final String durationStr;
  final String platform;

  const _VideoInfoGrid({required this.durationStr, required this.platform});

  @override
  Widget build(BuildContext context) {
    final infos = [
      _InfoItem(
        icon: Icons.schedule_rounded,
        label: 'Duración',
        value: durationStr,
      ),
      _InfoItem(
        icon: Icons.language_rounded,
        label: 'Plataforma',
        value: platform,
      ),
      const _InfoItem(
        icon: Icons.hd_rounded,
        label: 'Calidad',
        value: 'Original',
      ),
      const _InfoItem(
        icon: Icons.water_drop_rounded,
        label: 'Marca',
        value: 'Removida',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: infos.map((info) => _InfoCard(info: info)).toList(),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _InfoCard extends StatelessWidget {
  final _InfoItem info;

  const _InfoCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(info.icon, color: AppColors.secondary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  info.label,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                  ),
                ),
                Text(
                  info.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

class _EditOptions extends StatefulWidget {
  @override
  State<_EditOptions> createState() => _EditOptionsState();
}

class _EditOptionsState extends State<_EditOptions> {
  final Set<int> _selected = {0};

  final options = const [
    (icon: Icons.cut_rounded, label: 'Recortar'),
    (icon: Icons.volume_off_rounded, label: 'Sin audio'),
    (icon: Icons.high_quality_rounded, label: 'Mejorar calidad'),
    (icon: Icons.subtitles_rounded, label: 'Subtítulos'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(options.length, (i) {
        final selected = _selected.contains(i);
        return GestureDetector(
          onTap: () => setState(() {
            if (i == 3) {
              context.push(AppRoutes.subtitles);
              return;
            }
            if (options[i].label == 'SubtÃ­tulos') {
              context.push(AppRoutes.subtitles);
              return;
            }
            if (selected) {
              _selected.remove(i);
            } else {
              _selected.add(i);
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  options[i].icon,
                  color: selected ? AppColors.primary : AppColors.textHint,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  options[i].label,
                  style: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textHint,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
