import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'package:http/http.dart' as http;

class VideoInfo {
  final String title;
  final String author;
  final Duration duration;
  final String thumbnailUrl;
  final String downloadUrl; // URL sin marca de agua
  final String platform;

  VideoInfo({
    required this.title,
    required this.author,
    required this.duration,
    required this.thumbnailUrl,
    required this.downloadUrl,
    required this.platform,
  });
}

class VideoExtractorService {
  /// Extrae la metadata y el link directo SIN MARCA DE AGUA de TikTok u otra red.
  Future<VideoInfo?> extractVideoInfo(String url) async {
    try {
      if (url.contains('tiktok.com')) {
        return await _extractTikTok(url);
      }
      // Aquí se pueden agregar más redes (Instagram, Facebook) usando otras APIs
      return null;
    } catch (e) {
      log('Error extrayendo video: $e', name: 'VideoExtractorService');
      return null;
    }
  }

  /// Usa una API pública para obtener el video de TikTok sin marca de agua
  Future<VideoInfo?> _extractTikTok(String url) async {
    // API pública gratuita de TikWM
    final apiUrl = 'https://www.tikwm.com/api/';

    final response = await http
        .post(Uri.parse(apiUrl), body: {'url': url})
        .timeout(const Duration(seconds: 25));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['code'] == 0 && data['data'] != null) {
        final videoData = data['data'];

        // Obtener el enlace de reproducción (play) que no tiene marca de agua
        final noWatermarkUrl = (videoData['hdplay'] ?? videoData['play'] ?? '')
            .toString();
        final title = videoData['title'] ?? 'Video de TikTok';
        final author = videoData['author']?['nickname'] ?? 'Usuario de TikTok';
        final duration = Duration(seconds: videoData['duration'] ?? 0);
        final cover = videoData['cover'] ?? '';

        if (noWatermarkUrl.isEmpty) return null;

        return VideoInfo(
          title: title,
          author: author,
          duration: duration,
          thumbnailUrl: cover,
          downloadUrl: noWatermarkUrl,
          platform: 'TikTok',
        );
      }
    }
    return null;
  }
}
