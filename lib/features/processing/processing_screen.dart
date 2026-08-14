import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/app_provider.dart';
import '../../providers/video_provider.dart';
import '../../theme/app_colors.dart';

/// Pantalla de procesamiento con progreso, descarga y estado de error.
class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({super.key});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  int _currentStep = 0;
  bool _hasError = false;
  String? _errorMessage;

  final List<_ProcessStep> _steps = const [
    _ProcessStep(label: 'Preparando enlace...', icon: Icons.link_rounded),
    _ProcessStep(
      label: 'Validando video limpio...',
      icon: Icons.auto_fix_high_rounded,
    ),
    _ProcessStep(
      label: 'Descargando video limpio...',
      icon: Icons.download_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startProcessing();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startProcessing() async {
    try {
      final videoInfo = ref.read(currentVideoInfoProvider);
      if (videoInfo == null) {
        _showProcessingError('No hay informacion del video para procesar.');
        return;
      }

      if (videoInfo.downloadUrl.isEmpty) {
        _showProcessingError('TikTok no entrego un enlace de descarga valido.');
        return;
      }

      setState(() {
        _hasError = false;
        _errorMessage = null;
        _currentStep = 0;
      });
      ref.read(processingProgressProvider.notifier).state = 0.1;
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      setState(() => _currentStep = 1);
      ref.read(processingProgressProvider.notifier).state = 0.2;
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      setState(() => _currentStep = 2);
      ref.read(processingProgressProvider.notifier).state = 0.25;

      final storageService = ref.read(storageServiceProvider);
      final path = await storageService.downloadVideoFromUrl(
        videoInfo.downloadUrl,
        (progress) {
          if (!mounted) return;
          ref.read(processingProgressProvider.notifier).state =
              0.25 + (progress * 0.75);
        },
      );

      if (path == null) {
        _showProcessingError(
          'No se pudo descargar el video limpio. Revisa tu conexion o prueba otro enlace.',
        );
        return;
      }

      if (!mounted) return;
      ref.read(finalVideoPathProvider.notifier).state = path;
      ref.read(processingProgressProvider.notifier).state = 1;
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) context.pushReplacement(AppRoutes.preview);
    } catch (_) {
      _showProcessingError(
        'El procesamiento tardo demasiado o el servicio externo no respondio.',
      );
    }
  }

  void _showProcessingError(String message) {
    if (!mounted) return;
    setState(() {
      _hasError = true;
      _errorMessage = message;
    });
  }

  void _retryProcessing() {
    ref.read(processingProgressProvider.notifier).state = 0;
    _startProcessing();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(processingProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -60,
              child: _GlowOrb(color: AppColors.primary, size: 220),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: _GlowOrb(color: AppColors.secondary, size: 280),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    ScaleTransition(
                      scale: _pulseAnim,
                      child: SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 6,
                                backgroundColor: AppColors.border.withValues(
                                  alpha: 0.4,
                                ),
                                valueColor: AlwaysStoppedAnimation(
                                  _hasError
                                      ? AppColors.error
                                      : AppColors.primary,
                                ),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  _hasError ? 'detenido' : 'completado',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      _hasError
                          ? 'No se pudo procesar'
                          : AppStrings.processingTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _hasError
                          ? 'Puedes reintentar con el mismo enlace'
                          : 'No cierres la aplicacion',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ...List.generate(_steps.length, (i) {
                      final done = !_hasError && i < _currentStep;
                      final active = !_hasError && i == _currentStep;
                      return _StepTile(
                        step: _steps[i],
                        done: done,
                        active: active,
                      );
                    }),
                    if (_hasError) ...[
                      const SizedBox(height: 18),
                      _ProcessingErrorCard(
                        message:
                            _errorMessage ??
                            'No se pudo completar el procesamiento.',
                        onRetry: _retryProcessing,
                        onBack: () => context.go(AppRoutes.home),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcessingErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _ProcessingErrorCard({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Volver'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Reintentar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _ProcessStep {
  final String label;
  final IconData icon;

  const _ProcessStep({required this.label, required this.icon});
}

class _StepTile extends StatelessWidget {
  final _ProcessStep step;
  final bool done;
  final bool active;

  const _StepTile({
    required this.step,
    required this.done,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.15)
            : done
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active
              ? AppColors.primary
              : done
              ? AppColors.success
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : done
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.border.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              done ? Icons.check_rounded : step.icon,
              color: active
                  ? AppColors.primary
                  : done
                  ? AppColors.success
                  : AppColors.textHint,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              step.label,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : done
                    ? AppColors.success
                    : AppColors.textHint,
                fontSize: 14,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          if (active)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          if (done)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 20,
            ),
        ],
      ),
    );
  }
}
