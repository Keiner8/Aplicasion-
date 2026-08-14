import 'dart:developer';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

class FFmpegService {
  Future<bool> removeAudio(String inputPath, String outputPath) async {
    final command =
        '-y -i ${_quote(inputPath)} -c:v copy -an ${_quote(outputPath)}';
    return _run(command);
  }

  Future<bool> trimVideo(
    String inputPath,
    String outputPath,
    Duration start,
    Duration duration,
  ) async {
    final command =
        '-y -ss ${_formatDuration(start)} -i ${_quote(inputPath)} '
        '-t ${_formatDuration(duration)} -c copy ${_quote(outputPath)}';
    return _run(command);
  }

  Future<String?> burnSubtitles({
    required String videoPath,
    required String subtitlesPath,
  }) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${directory.path}/cleanclip_subtitled_$timestamp.mp4';
    final filterPath = _escapeFilterPath(subtitlesPath);

    final command =
        '-y -i ${_quote(videoPath)} -vf "ass=$filterPath" '
        '-c:v libx264 -preset veryfast -crf 22 -c:a copy '
        '${_quote(outputPath)}';

    final success = await _run(command);
    return success ? outputPath : null;
  }

  Future<bool> _run(String command) async {
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return true;
    }

    final output = await session.getOutput();
    if (output != null && output.isNotEmpty) {
      log(output, name: 'FFmpegService');
    }
    return false;
  }

  String _quote(String value) {
    return '"${value.replaceAll('"', r'\"')}"';
  }

  String _escapeFilterPath(String value) {
    return value
        .replaceAll('\\', '/')
        .replaceAll(':', r'\:')
        .replaceAll("'", r"\'");
  }

  String _formatDuration(Duration value) {
    final hours = value.inHours.toString().padLeft(2, '0');
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    final milliseconds = value.inMilliseconds
        .remainder(1000)
        .toString()
        .padLeft(3, '0');
    return '$hours:$minutes:$seconds.$milliseconds';
  }
}
