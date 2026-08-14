import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/subtitle_models.dart';
import '../../providers/subtitle_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';

class SubtitlesScreen extends ConsumerWidget {
  const SubtitlesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subtitleControllerProvider);
    final controller = ref.read(subtitleControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Subtitulos', showBack: true),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(),
                const SizedBox(height: 20),
                _VideoPickerCard(
                  state: state,
                  onPickVideo: controller.pickVideo,
                ),
                const SizedBox(height: 18),
                _SubtitleModeSelector(
                  selectedMode: state.mode,
                  onChanged: controller.setMode,
                ),
                const SizedBox(height: 18),
                _TranslationSelector(
                  selectedTarget: state.translationTarget,
                  onChanged: controller.setTranslationTarget,
                ),
                if (state.needsManualText) ...[
                  const SizedBox(height: 18),
                  _ManualTextCard(
                    mode: state.mode,
                    text: state.manualText,
                    durationSeconds: state.durationSeconds,
                    onTextChanged: controller.setManualText,
                    onDurationChanged: controller.setDurationSeconds,
                  ),
                ],
                const SizedBox(height: 18),
                _StyleCard(
                  style: state.style,
                  onFontPresetChanged: controller.setFontPreset,
                  onFontSizeChanged: controller.setFontSize,
                  onHighlightChanged: controller.setHighlightWords,
                ),
                const SizedBox(height: 22),
                GradientButton(
                  label: state.status == SubtitleStatus.generating
                      ? 'Generando...'
                      : 'Generar subtitulos',
                  icon: Icons.auto_awesome_rounded,
                  onPressed: state.canGenerate
                      ? controller.generateSubtitles
                      : null,
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 14),
                  _ErrorMessage(message: state.errorMessage!),
                ],
                if (state.lines.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SubtitlePreview(lines: state.lines, style: state.style),
                  const SizedBox(height: 18),
                  GradientButton(
                    label: 'Crear archivo SRT',
                    icon: Icons.movie_filter_rounded,
                    onPressed: () async {
                      final path = await controller.exportSrt();
                      if (!context.mounted || path == null) return;

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          title: const Text(
                            'Subtitulos creados',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          content: Text(
                            'Se creo un archivo SRT con los tiempos:\n\n$path',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
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
                    },
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    label: 'Crear estilo para video',
                    icon: Icons.text_fields_rounded,
                    onPressed: () async {
                      final path = await controller.exportAss();
                      if (!context.mounted || path == null) return;

                      _showPathDialog(
                        context: context,
                        title: 'Estilo creado',
                        message:
                            'Se creo un archivo ASS con la fuente elegida:\n\n$path',
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    label: state.status == SubtitleStatus.rendering
                        ? 'Pegando subtitulos...'
                        : 'Pegar subtitulos al video',
                    icon: Icons.video_settings_rounded,
                    onPressed: state.status == SubtitleStatus.rendering
                        ? null
                        : () async {
                            final path = await controller
                                .renderVideoWithSubtitles();
                            if (!context.mounted || path == null) return;

                            _showPathDialog(
                              context: context,
                              title: 'Video creado',
                              message:
                                  'Tu video con subtitulos sincronizados esta listo:\n\n$path',
                            );
                          },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPathDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
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
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subtitulos inteligentes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Elige un video y prepara subtitulos para voz, letras musicales o edicion manual.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _VideoPickerCard extends StatelessWidget {
  final SubtitleState state;
  final VoidCallback onPickVideo;

  const _VideoPickerCard({required this.state, required this.onPickVideo});

  @override
  Widget build(BuildContext context) {
    final video = state.video;
    final isSelecting = state.status == SubtitleStatus.selecting;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.video_library_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video?.name ?? 'Ningun video seleccionado',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video?.readableSize ?? 'Selecciona desde tu telefono',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GradientButton(
            label: isSelecting ? 'Abriendo selector...' : 'Elegir video',
            icon: Icons.folder_open_rounded,
            height: 48,
            onPressed: isSelecting ? null : onPickVideo,
          ),
        ],
      ),
    );
  }
}

class _SubtitleModeSelector extends StatelessWidget {
  final SubtitleMode selectedMode;
  final ValueChanged<SubtitleMode> onChanged;

  const _SubtitleModeSelector({
    required this.selectedMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = const [
      (
        mode: SubtitleMode.speech,
        icon: Icons.record_voice_over_rounded,
        label: 'Voz',
      ),
      (
        mode: SubtitleMode.musicLyrics,
        icon: Icons.lyrics_rounded,
        label: 'Letra',
      ),
      (
        mode: SubtitleMode.manual,
        icon: Icons.edit_note_rounded,
        label: 'Manual',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Modo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: items.map((item) {
            final selected = item.mode == selectedMode;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onChanged(item.mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          item.icon,
                          color: selected
                              ? AppColors.secondary
                              : AppColors.textHint,
                          size: 22,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TranslationSelector extends StatelessWidget {
  final SubtitleTranslationTarget selectedTarget;
  final ValueChanged<SubtitleTranslationTarget> onChanged;

  const _TranslationSelector({
    required this.selectedTarget,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = const [
      (
        target: SubtitleTranslationTarget.original,
        icon: Icons.subtitles_rounded,
      ),
      (
        target: SubtitleTranslationTarget.spanish,
        icon: Icons.translate_rounded,
      ),
      (target: SubtitleTranslationTarget.english, icon: Icons.language_rounded),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Traduccion',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Mantiene el ritmo del audio y cambia el idioma de la letra.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: items.map((item) {
              final selected = item.target == selectedTarget;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onChanged(item.target),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.secondary.withValues(alpha: 0.16)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? AppColors.secondary
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            item.icon,
                            color: selected
                                ? AppColors.secondary
                                : AppColors.textHint,
                            size: 20,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.target.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ManualTextCard extends StatelessWidget {
  final SubtitleMode mode;
  final String text;
  final int durationSeconds;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<int> onDurationChanged;

  const _ManualTextCard({
    required this.mode,
    required this.text,
    required this.durationSeconds,
    required this.onTextChanged,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isLyrics = mode == SubtitleMode.musicLyrics;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLyrics ? 'Pega la letra completa' : 'Pega el texto manual',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isLyrics
                ? 'Cada linea se convierte en una parte sincronizada. Si pegas todo junto, CleanClip lo divide por frases.'
                : 'Escribe o pega el texto. CleanClip lo separa y lo reparte dentro de la duracion.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            minLines: 6,
            maxLines: 10,
            keyboardType: TextInputType.multiline,
            onChanged: onTextChanged,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.35,
            ),
            decoration: InputDecoration(
              hintText: isLyrics
                  ? 'Ejemplo:\nAmor de mi vida\nTu eres mi alegria\nNo quiero perderte'
                  : 'Pega aqui el texto que quieres convertir en subtitulos...',
              hintStyle: const TextStyle(color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_countParts(text)} partes aproximadas detectadas',
            style: const TextStyle(color: AppColors.textHint, fontSize: 11),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.timer_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Duracion del video',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const Spacer(),
              Text(
                _formatDuration(durationSeconds),
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Slider(
            value: durationSeconds.toDouble(),
            min: 15,
            max: 900,
            divisions: 59,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            onChanged: (value) => onDurationChanged(value.round()),
          ),
          const Text(
            'Para un video de 4 minutos deja la duracion en 04:00.',
            style: TextStyle(color: AppColors.textHint, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }

  int _countParts(String value) {
    final lines = value
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .length;
    if (lines > 0) return lines;

    final words = value.trim().split(RegExp(r'\s+'));
    if (words.length == 1 && words.first.isEmpty) return 0;
    return (words.length / 6).ceil();
  }
}

class _StyleCard extends StatelessWidget {
  final SubtitleStyleConfig style;
  final ValueChanged<SubtitleFontPreset> onFontPresetChanged;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<bool> onHighlightChanged;

  const _StyleCard({
    required this.style,
    required this.onFontPresetChanged,
    required this.onFontSizeChanged,
    required this.onHighlightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estilo rapido',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: SubtitleFontPreset.values.map((preset) {
              final selected = preset == style.fontPreset;
              return GestureDetector(
                onTap: () => onFontPresetChanged(preset),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 96,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.18)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Aa',
                        style: GoogleFonts.getFont(
                          preset.fontFamily,
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: preset.assBold == 1
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        preset.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected
                              ? AppColors.secondary
                              : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.format_size_rounded, color: AppColors.secondary),
              Expanded(
                child: Slider(
                  value: style.fontSize,
                  min: 16,
                  max: 34,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                  onChanged: onFontSizeChanged,
                ),
              ),
              Text(
                style.fontSize.toStringAsFixed(0),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          SwitchListTile(
            value: style.highlightWords,
            onChanged: onHighlightChanged,
            activeThumbColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Resaltar palabra activa',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtitlePreview extends StatelessWidget {
  final List<SubtitleLine> lines;
  final SubtitleStyleConfig style;

  const _SubtitlePreview({required this.lines, required this.style});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vista previa',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...lines.map((line) => _SubtitleLineTile(line: line, style: style)),
      ],
    );
  }
}

class _SubtitleLineTile extends StatelessWidget {
  final SubtitleLine line;
  final SubtitleStyleConfig style;

  const _SubtitleLineTile({required this.line, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(
            '${_formatTime(line.start)} - ${_formatTime(line.end)}',
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              line.text,
              style: GoogleFonts.getFont(
                style.fontPreset.fontFamily,
                color: Colors.white,
                fontSize: 13,
                fontWeight: style.fontPreset.assBold == 1
                    ? FontWeight.w800
                    : FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;

  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}
