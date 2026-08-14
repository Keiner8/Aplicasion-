import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/subtitle_models.dart';

class TranscriptionService {
  static const _apiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const _transcriptionModel = String.fromEnvironment(
    'OPENAI_TRANSCRIPTION_MODEL',
    defaultValue: 'gpt-4o-transcribe',
  );
  static const _translationModel = String.fromEnvironment(
    'OPENAI_TRANSLATION_MODEL',
    defaultValue: 'gpt-5-mini',
  );

  Future<List<SubtitleLine>> generateSubtitles({
    required PickedVideo video,
    required SubtitleMode mode,
    String manualText = '',
    Duration duration = const Duration(minutes: 4),
    SubtitleTranslationTarget translationTarget =
        SubtitleTranslationTarget.original,
  }) async {
    if (_apiKey.isNotEmpty && video.path != null && video.path!.isNotEmpty) {
      try {
        final syncedLines = await _transcribeWithTimestamps(
          videoPath: video.path!,
          prompt: manualText,
        );
        if (syncedLines.isNotEmpty) {
          return _translateIfNeeded(syncedLines, translationTarget);
        }
      } catch (_) {
        // Keep the offline approximation available when the API/network fails.
      }
    }

    await Future.delayed(const Duration(seconds: 2));

    if (mode == SubtitleMode.manual || mode == SubtitleMode.musicLyrics) {
      final lines = _generateTimedTextLines(
        text: manualText,
        duration: duration,
        isLyrics: mode == SubtitleMode.musicLyrics,
      );
      return _translateIfNeeded(lines, translationTarget);
    }

    final List<SubtitleLine> lines = switch (mode) {
      SubtitleMode.speech => const [
        SubtitleLine(
          start: Duration(seconds: 0),
          end: Duration(seconds: 3),
          text: 'Detectando la voz principal del video...',
        ),
        SubtitleLine(
          start: Duration(seconds: 3),
          end: Duration(seconds: 7),
          text: 'Aqui apareceran los subtitulos sincronizados.',
        ),
        SubtitleLine(
          start: Duration(seconds: 7),
          end: Duration(seconds: 10),
          text: 'Listo para conectar con IA de transcripcion.',
        ),
      ],
      SubtitleMode.musicLyrics => const [],
      SubtitleMode.manual => const [],
    };
    return _translateIfNeeded(lines, translationTarget);
  }

  Future<List<SubtitleLine>> _transcribeWithTimestamps({
    required String videoPath,
    required String prompt,
  }) async {
    final file = File(videoPath);
    if (!await file.exists()) return const [];

    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse('https://api.openai.com/v1/audio/transcriptions'),
          )
          ..headers['Authorization'] = 'Bearer $_apiKey'
          ..fields['model'] = _transcriptionModel
          ..fields['response_format'] = 'verbose_json'
          ..fields['timestamp_granularities[]'] = 'segment';

    final cleanPrompt = prompt.trim();
    if (cleanPrompt.isNotEmpty) {
      request.fields['prompt'] = cleanPrompt;
    }

    request.files.add(await http.MultipartFile.fromPath('file', videoPath));

    final streamed = await request.send().timeout(const Duration(minutes: 3));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Transcription failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final segments = data['segments'];

    if (segments is List && segments.isNotEmpty) {
      return segments
          .whereType<Map>()
          .map((segment) {
            final start = _secondsToDuration(segment['start']);
            final end = _secondsToDuration(segment['end']);
            final text = (segment['text'] ?? '').toString().trim();
            if (text.isEmpty || end <= start) return null;
            return SubtitleLine(start: start, end: end, text: text);
          })
          .whereType<SubtitleLine>()
          .toList();
    }

    final text = (data['text'] ?? '').toString();
    if (text.trim().isEmpty) return const [];

    return _generateTimedTextLines(
      text: text,
      duration: const Duration(minutes: 4),
      isLyrics: true,
    );
  }

  Future<List<SubtitleLine>> _translateIfNeeded(
    List<SubtitleLine> lines,
    SubtitleTranslationTarget target,
  ) async {
    if (target == SubtitleTranslationTarget.original || lines.isEmpty) {
      return lines;
    }

    if (_apiKey.isEmpty) {
      return lines;
    }

    try {
      final translated = await _translateTexts(
        texts: lines.map((line) => line.text).toList(),
        target: target,
      );

      if (translated.length != lines.length) return lines;

      return List.generate(lines.length, (index) {
        final line = lines[index];
        return SubtitleLine(
          start: line.start,
          end: line.end,
          text: translated[index],
        );
      });
    } catch (_) {
      return lines;
    }
  }

  Future<List<String>> _translateTexts({
    required List<String> texts,
    required SubtitleTranslationTarget target,
  }) async {
    final response = await http
        .post(
          Uri.parse('https://api.openai.com/v1/responses'),
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': _translationModel,
            'input':
                '${target.instruction} Return only a JSON array of strings '
                'with exactly ${texts.length} items, preserving line order.\n'
                '${jsonEncode(texts)}',
          }),
        )
        .timeout(const Duration(minutes: 2));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Translation failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final outputText = _extractResponseText(data);
    final decoded = jsonDecode(outputText);

    if (decoded is! List) return texts;
    return decoded.map((item) => item.toString()).toList();
  }

  String _extractResponseText(Map<String, dynamic> data) {
    final outputText = data['output_text'];
    if (outputText is String && outputText.trim().isNotEmpty) {
      return outputText.trim();
    }

    final buffer = StringBuffer();
    final output = data['output'];
    if (output is List) {
      for (final item in output.whereType<Map>()) {
        final content = item['content'];
        if (content is List) {
          for (final part in content.whereType<Map>()) {
            final text = part['text'];
            if (text is String) buffer.write(text);
          }
        }
      }
    }

    return buffer.toString().trim();
  }

  Duration _secondsToDuration(dynamic value) {
    final seconds = switch (value) {
      num number => number.toDouble(),
      String text => double.tryParse(text) ?? 0,
      _ => 0.0,
    };
    return Duration(milliseconds: (seconds * 1000).round());
  }

  List<SubtitleLine> _generateTimedTextLines({
    required String text,
    required Duration duration,
    required bool isLyrics,
  }) {
    final segments = _splitText(text, isLyrics: isLyrics);
    if (segments.isEmpty) return [];

    final totalMs = duration.inMilliseconds;
    final segmentMs = (totalMs / segments.length)
        .round()
        .clamp(1200, totalMs)
        .toInt();

    return List.generate(segments.length, (index) {
      final startMs = index * segmentMs;
      final endMs = index == segments.length - 1
          ? totalMs
          : ((index + 1) * segmentMs).clamp(0, totalMs).toInt();

      return SubtitleLine(
        start: Duration(milliseconds: startMs),
        end: Duration(milliseconds: endMs),
        text: segments[index],
      );
    });
  }

  List<String> _splitText(String text, {required bool isLyrics}) {
    final byLines = text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (byLines.length > 1) return byLines;

    final cleaned = text.trim();
    if (cleaned.isEmpty) return [];

    final sentenceParts = cleaned
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (sentenceParts.length > 1) return sentenceParts;

    final words = cleaned.split(RegExp(r'\s+'));
    final chunkSize = isLyrics ? 6 : 9;
    final chunks = <String>[];

    for (var i = 0; i < words.length; i += chunkSize) {
      chunks.add(words.skip(i).take(chunkSize).join(' '));
    }

    return chunks;
  }
}
