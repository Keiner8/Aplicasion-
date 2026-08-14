import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/video_extractor_service.dart';
import '../core/services/ffmpeg_service.dart';
import '../core/services/storage_service.dart';

final videoExtractorProvider = Provider((ref) => VideoExtractorService());
final ffmpegServiceProvider = Provider((ref) => FFmpegService());
final storageServiceProvider = Provider((ref) => StorageService());

// Estado para almacenar la info del video actual
final currentVideoInfoProvider = StateProvider<VideoInfo?>((ref) => null);

// Ruta del video editado/final
final finalVideoPathProvider = StateProvider<String?>((ref) => null);

// Opciones seleccionadas
final removeAudioOptionProvider = StateProvider<bool>((ref) => false);
