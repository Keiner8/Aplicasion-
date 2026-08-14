import 'dart:io';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  /// Solicita los permisos necesarios para escribir en la galería.
  Future<bool> requestGalleryPermission() async {
    final hasAccess = await Gal.hasAccess();
    if (hasAccess) return true;

    return await Gal.requestAccess();
  }

  /// Guarda un archivo de video en la galería del dispositivo.
  Future<bool> saveVideoToGallery(String videoPath) async {
    try {
      final hasPermission = await requestGalleryPermission();
      if (!hasPermission) return false;

      await Gal.putVideo(videoPath);
      return true;
    } catch (e) {
      log('Error guardando en la galeria: $e', name: 'StorageService');
      return false;
    }
  }

  /// Genera una ruta temporal segura para guardar archivos procesados o descargados.
  Future<String> getTemporaryFilePath(String extension) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${directory.path}/cleanclip_video_$timestamp.$extension';
  }

  /// Descarga un video desde una URL y lo guarda en un archivo temporal.
  Future<String?> downloadVideoFromUrl(
    String url,
    Function(double)? onProgress,
  ) async {
    http.Client? client;
    IOSink? sink;
    String? filePath;

    try {
      if (url.isEmpty) return null;

      client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      final response = await client
          .send(request)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final total = response.contentLength ?? 0;
      int received = 0;

      filePath = await getTemporaryFilePath('mp4');
      final file = File(filePath);
      sink = file.openWrite();

      await for (final chunk in response.stream.timeout(
        const Duration(seconds: 45),
      )) {
        sink.add(chunk);
        received += chunk.length;
        if (total != 0 && onProgress != null) {
          onProgress(received / total);
        }
      }
      await sink.close();
      sink = null;
      return filePath;
    } catch (e) {
      log('Error descargando video: $e', name: 'StorageService');
      await sink?.close();
      sink = null;
      if (filePath != null) {
        await deleteFile(filePath);
      }
      return null;
    } finally {
      await sink?.close();
      client?.close();
    }
  }

  /// Elimina un archivo temporal.
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      log('Error borrando archivo $filePath: $e', name: 'StorageService');
    }
  }
}
