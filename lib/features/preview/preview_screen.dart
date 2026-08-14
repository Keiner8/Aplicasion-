import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_app_bar.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/app_provider.dart';
import '../../providers/video_provider.dart';

/// Pantalla de vista previa del video procesado.
class PreviewScreen extends ConsumerStatefulWidget {
  const PreviewScreen({super.key});

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen>
    with SingleTickerProviderStateMixin {
  bool _showAfter = true;
  late AnimationController _controller;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _slideAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: AppStrings.previewTitle,
        showBack: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.share_rounded,
              color: AppColors.secondary,
              size: 24,
            ),
          ),
        ],
      ),
      body: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(_slideAnim),
        child: FadeTransition(
          opacity: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reproductor de video placeholder
                _VideoPlayer(),
                const SizedBox(height: 20),

                // Comparación Antes / Después
                _BeforeAfterToggle(
                  showAfter: _showAfter,
                  onToggle: (val) => setState(() => _showAfter = val),
                ),
                const SizedBox(height: 20),

                // Estadísticas del resultado
                _ResultStats(),
                const SizedBox(height: 24),

                // Botones de acción
                GradientButton(
                  label: AppStrings.save,
                  icon: Icons.download_rounded,
                  onPressed: () => _saveVideo(context, ref),
                ),
                const SizedBox(height: 12),
                _OutlineButton(
                  label: AppStrings.share,
                  icon: Icons.share_rounded,
                  onPressed: () {},
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveVideo(BuildContext context, WidgetRef ref) async {
    final path = ref.read(finalVideoPathProvider);
    if (path == null) return;

    final storage = ref.read(storageServiceProvider);

    // Mostrar loader de guardado
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await storage.saveVideoToGallery(path);

    if (context.mounted) Navigator.pop(context); // cerrar loader

    if (success && context.mounted) {
      // Guardar en historial
      final videoInfo = ref.read(currentVideoInfoProvider);
      if (videoInfo != null) {
        ref.read(appProvider.notifier).addProcessedVideo(videoInfo.downloadUrl);
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            '¡Video guardado!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: const Text(
            'Tu video sin marca de agua ha sido guardado en la galería.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Aceptar',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar o permisos denegados.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _VideoPlayer extends StatefulWidget {
  @override
  State<_VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<_VideoPlayer> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1040), Color(0xFF2D1B69)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: GestureDetector(
              onTap: () => setState(() => _playing = !_playing),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.9),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
          ),
        ),
        // Barra de progreso de video
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.35,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    color: AppColors.primary,
                    minHeight: 3,
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1:19',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    Text(
                      '3:45',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BeforeAfterToggle extends StatelessWidget {
  final bool showAfter;
  final ValueChanged<bool> onToggle;

  const _BeforeAfterToggle({required this.showAfter, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _ToggleBtn(
            label: 'Antes',
            selected: !showAfter,
            onTap: () => onToggle(false),
          ),
          _ToggleBtn(
            label: 'Después',
            selected: showAfter,
            onTap: () => onToggle(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textHint,
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GradientCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resultado del procesamiento',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatItem(
                label: 'Tamaño original',
                value: '128 MB',
                icon: Icons.storage_rounded,
                color: AppColors.error,
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.textHint,
                size: 20,
              ),
              const SizedBox(width: 12),
              _StatItem(
                label: 'Tamaño final',
                value: '42 MB',
                icon: Icons.compress_rounded,
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_down_rounded,
                  color: AppColors.success,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  '67% de reducción de tamaño',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textHint, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
