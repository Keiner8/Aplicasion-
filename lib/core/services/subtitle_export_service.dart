import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/subtitle_models.dart';

class SubtitleExportService {
  Future<String> exportSrt(List<SubtitleLine> lines) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/cleanclip_subtitles_$timestamp.srt');

    await file.writeAsString(_buildSrt(lines));
    return file.path;
  }

  Future<String> exportAss(
    List<SubtitleLine> lines,
    SubtitleStyleConfig style,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/cleanclip_subtitles_$timestamp.ass');

    await file.writeAsString(_buildAss(lines, style));
    return file.path;
  }

  String _buildSrt(List<SubtitleLine> lines) {
    final buffer = StringBuffer();

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      buffer
        ..writeln(i + 1)
        ..writeln('${_formatTime(line.start)} --> ${_formatTime(line.end)}')
        ..writeln(line.text)
        ..writeln();
    }

    return buffer.toString();
  }

  String _formatTime(Duration value) {
    final hours = value.inHours.toString().padLeft(2, '0');
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    final milliseconds = value.inMilliseconds
        .remainder(1000)
        .toString()
        .padLeft(3, '0');

    return '$hours:$minutes:$seconds,$milliseconds';
  }

  String _buildAss(List<SubtitleLine> lines, SubtitleStyleConfig style) {
    final buffer = StringBuffer()
      ..writeln('[Script Info]')
      ..writeln('ScriptType: v4.00+')
      ..writeln('ScaledBorderAndShadow: yes')
      ..writeln('PlayResX: 1080')
      ..writeln('PlayResY: 1920')
      ..writeln()
      ..writeln('[V4+ Styles]')
      ..writeln(
        'Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, '
        'OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, '
        'ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, '
        'Alignment, MarginL, MarginR, MarginV, Encoding',
      )
      ..writeln(
        'Style: Default,${style.fontPreset.fontFamily},'
        '${style.fontSize.round()},&H00FFFFFF,&H0000FFFF,&H00000000,'
        '&HAA000000,${style.fontPreset.assBold},0,0,0,100,100,0,0,1,'
        '4,2,2,80,80,170,1',
      )
      ..writeln()
      ..writeln('[Events]')
      ..writeln(
        'Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text',
      );

    for (final line in lines) {
      buffer.writeln(
        'Dialogue: 0,${_formatAssTime(line.start)},'
        '${_formatAssTime(line.end)},Default,,0,0,0,,${_escapeAss(line.text)}',
      );
    }

    return buffer.toString();
  }

  String _formatAssTime(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    final centiseconds = (value.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');

    return '$hours:$minutes:$seconds.$centiseconds';
  }

  String _escapeAss(String value) {
    return value
        .replaceAll('\\', r'\\')
        .replaceAll('{', r'\{')
        .replaceAll('}', r'\}')
        .replaceAll('\n', r'\N');
  }
}
