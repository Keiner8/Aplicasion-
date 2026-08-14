import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/subtitle_models.dart';
import '../core/services/ffmpeg_service.dart';
import '../core/services/subtitle_export_service.dart';
import '../core/services/transcription_service.dart';
import '../core/services/video_picker_service.dart';

final videoPickerServiceProvider = Provider((ref) => VideoPickerService());
final transcriptionServiceProvider = Provider((ref) => TranscriptionService());
final subtitleFfmpegServiceProvider = Provider((ref) => FFmpegService());
final subtitleExportServiceProvider = Provider(
  (ref) => SubtitleExportService(),
);

final subtitleControllerProvider =
    StateNotifierProvider<SubtitleController, SubtitleState>((ref) {
      return SubtitleController(
        videoPickerService: ref.read(videoPickerServiceProvider),
        transcriptionService: ref.read(transcriptionServiceProvider),
        subtitleExportService: ref.read(subtitleExportServiceProvider),
        ffmpegService: ref.read(subtitleFfmpegServiceProvider),
      );
    });

class SubtitleState {
  final SubtitleStatus status;
  final SubtitleMode mode;
  final PickedVideo? video;
  final List<SubtitleLine> lines;
  final SubtitleStyleConfig style;
  final SubtitleTranslationTarget translationTarget;
  final String manualText;
  final int durationSeconds;
  final String? subtitleFilePath;
  final String? renderedVideoPath;
  final String? errorMessage;

  const SubtitleState({
    this.status = SubtitleStatus.idle,
    this.mode = SubtitleMode.speech,
    this.video,
    this.lines = const [],
    this.style = const SubtitleStyleConfig(),
    this.translationTarget = SubtitleTranslationTarget.original,
    this.manualText = '',
    this.durationSeconds = 240,
    this.subtitleFilePath,
    this.renderedVideoPath,
    this.errorMessage,
  });

  bool get needsManualText =>
      mode == SubtitleMode.manual || mode == SubtitleMode.musicLyrics;

  bool get canGenerate {
    if (video == null ||
        status == SubtitleStatus.generating ||
        status == SubtitleStatus.rendering) {
      return false;
    }
    if (needsManualText && manualText.trim().isEmpty) return false;
    return true;
  }

  SubtitleState copyWith({
    SubtitleStatus? status,
    SubtitleMode? mode,
    PickedVideo? video,
    List<SubtitleLine>? lines,
    SubtitleStyleConfig? style,
    SubtitleTranslationTarget? translationTarget,
    String? manualText,
    int? durationSeconds,
    String? subtitleFilePath,
    String? renderedVideoPath,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SubtitleState(
      status: status ?? this.status,
      mode: mode ?? this.mode,
      video: video ?? this.video,
      lines: lines ?? this.lines,
      style: style ?? this.style,
      translationTarget: translationTarget ?? this.translationTarget,
      manualText: manualText ?? this.manualText,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      subtitleFilePath: subtitleFilePath ?? this.subtitleFilePath,
      renderedVideoPath: renderedVideoPath ?? this.renderedVideoPath,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class SubtitleController extends StateNotifier<SubtitleState> {
  final VideoPickerService _videoPickerService;
  final TranscriptionService _transcriptionService;
  final SubtitleExportService _subtitleExportService;
  final FFmpegService _ffmpegService;

  SubtitleController({
    required VideoPickerService videoPickerService,
    required TranscriptionService transcriptionService,
    required SubtitleExportService subtitleExportService,
    required FFmpegService ffmpegService,
  }) : _videoPickerService = videoPickerService,
       _transcriptionService = transcriptionService,
       _subtitleExportService = subtitleExportService,
       _ffmpegService = ffmpegService,
       super(const SubtitleState());

  void setMode(SubtitleMode mode) {
    state = state.copyWith(mode: mode, clearError: true);
  }

  void setManualText(String value) {
    state = state.copyWith(manualText: value, lines: [], clearError: true);
  }

  void setTranslationTarget(SubtitleTranslationTarget value) {
    state = state.copyWith(
      translationTarget: value,
      lines: [],
      clearError: true,
    );
  }

  void setDurationSeconds(int value) {
    final safeValue = value.clamp(15, 900).toInt();
    state = state.copyWith(
      durationSeconds: safeValue,
      lines: [],
      clearError: true,
    );
  }

  Future<void> pickVideo() async {
    state = state.copyWith(status: SubtitleStatus.selecting, clearError: true);

    try {
      final video = await _videoPickerService.pickVideo();
      if (video == null) {
        state = state.copyWith(status: SubtitleStatus.idle);
        return;
      }

      state = state.copyWith(
        status: SubtitleStatus.idle,
        video: video,
        lines: [],
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        status: SubtitleStatus.error,
        errorMessage: 'No se pudo abrir el selector de video.',
      );
    }
  }

  Future<void> generateSubtitles() async {
    final video = state.video;
    if (video == null) return;

    if (state.needsManualText && state.manualText.trim().isEmpty) {
      state = state.copyWith(
        status: SubtitleStatus.error,
        errorMessage: 'Pega la letra o el texto antes de generar.',
      );
      return;
    }

    state = state.copyWith(status: SubtitleStatus.generating, clearError: true);

    try {
      final lines = await _transcriptionService.generateSubtitles(
        video: video,
        mode: state.mode,
        manualText: state.manualText,
        duration: Duration(seconds: state.durationSeconds),
        translationTarget: state.translationTarget,
      );
      state = state.copyWith(status: SubtitleStatus.ready, lines: lines);
    } catch (_) {
      state = state.copyWith(
        status: SubtitleStatus.error,
        errorMessage: 'No se pudieron generar los subtitulos.',
      );
    }
  }

  void setFontSize(double value) {
    state = state.copyWith(style: state.style.copyWith(fontSize: value));
  }

  void setFontPreset(SubtitleFontPreset value) {
    state = state.copyWith(style: state.style.copyWith(fontPreset: value));
  }

  void setHighlightWords(bool value) {
    state = state.copyWith(style: state.style.copyWith(highlightWords: value));
  }

  Future<String?> exportAss() async {
    if (state.lines.isEmpty) {
      state = state.copyWith(
        status: SubtitleStatus.error,
        errorMessage: 'Primero genera los subtitulos.',
      );
      return null;
    }

    try {
      final path = await _subtitleExportService.exportAss(
        state.lines,
        state.style,
      );
      state = state.copyWith(subtitleFilePath: path, clearError: true);
      return path;
    } catch (_) {
      state = state.copyWith(
        status: SubtitleStatus.error,
        errorMessage: 'No se pudo crear el archivo de estilo para video.',
      );
      return null;
    }
  }

  Future<String?> renderVideoWithSubtitles() async {
    final videoPath = state.video?.path;
    if (videoPath == null || videoPath.isEmpty) {
      state = state.copyWith(
        status: SubtitleStatus.error,
        errorMessage: 'Selecciona un video guardado en el dispositivo.',
      );
      return null;
    }

    if (state.lines.isEmpty) {
      state = state.copyWith(
        status: SubtitleStatus.error,
        errorMessage: 'Primero genera los subtitulos.',
      );
      return null;
    }

    state = state.copyWith(status: SubtitleStatus.rendering, clearError: true);

    try {
      final subtitlesPath = await _subtitleExportService.exportAss(
        state.lines,
        state.style,
      );
      final renderedPath = await _ffmpegService.burnSubtitles(
        videoPath: videoPath,
        subtitlesPath: subtitlesPath,
      );

      if (renderedPath == null) {
        state = state.copyWith(
          status: SubtitleStatus.error,
          errorMessage: 'No se pudo pegar los subtitulos al video.',
        );
        return null;
      }

      state = state.copyWith(
        status: SubtitleStatus.ready,
        subtitleFilePath: subtitlesPath,
        renderedVideoPath: renderedPath,
        clearError: true,
      );
      return renderedPath;
    } catch (_) {
      state = state.copyWith(
        status: SubtitleStatus.error,
        errorMessage: 'No se pudo renderizar el video con subtitulos.',
      );
      return null;
    }
  }

  Future<String?> exportSrt() async {
    if (state.lines.isEmpty) {
      state = state.copyWith(
        status: SubtitleStatus.error,
        errorMessage: 'Primero genera los subtitulos.',
      );
      return null;
    }

    try {
      return await _subtitleExportService.exportSrt(state.lines);
    } catch (_) {
      state = state.copyWith(
        status: SubtitleStatus.error,
        errorMessage: 'No se pudo exportar el archivo de subtitulos.',
      );
      return null;
    }
  }
}
