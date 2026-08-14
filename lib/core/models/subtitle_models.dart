enum SubtitleMode { speech, musicLyrics, manual }

enum SubtitleStatus { idle, selecting, generating, ready, rendering, error }

enum SubtitleTranslationTarget { original, spanish, english }

extension SubtitleTranslationTargetLabel on SubtitleTranslationTarget {
  String get label {
    return switch (this) {
      SubtitleTranslationTarget.original => 'Original',
      SubtitleTranslationTarget.spanish => 'Espanol',
      SubtitleTranslationTarget.english => 'Ingles',
    };
  }

  String get instruction {
    return switch (this) {
      SubtitleTranslationTarget.original => 'Keep the original language.',
      SubtitleTranslationTarget.spanish => 'Translate every line to Spanish.',
      SubtitleTranslationTarget.english => 'Translate every line to English.',
    };
  }
}

enum SubtitleFontPreset { clean, neon, bold, viral, cinematic }

extension SubtitleFontPresetLabel on SubtitleFontPreset {
  String get label {
    return switch (this) {
      SubtitleFontPreset.clean => 'Limpia',
      SubtitleFontPreset.neon => 'Neon',
      SubtitleFontPreset.bold => 'Fuerte',
      SubtitleFontPreset.viral => 'Viral',
      SubtitleFontPreset.cinematic => 'Cine',
    };
  }

  String get fontFamily {
    return switch (this) {
      SubtitleFontPreset.clean => 'Montserrat',
      SubtitleFontPreset.neon => 'Poppins',
      SubtitleFontPreset.bold => 'Anton',
      SubtitleFontPreset.viral => 'Bebas Neue',
      SubtitleFontPreset.cinematic => 'Oswald',
    };
  }

  int get assBold {
    return switch (this) {
      SubtitleFontPreset.bold || SubtitleFontPreset.viral => 1,
      _ => 0,
    };
  }
}

class PickedVideo {
  final String name;
  final String? path;
  final int sizeBytes;

  const PickedVideo({
    required this.name,
    required this.path,
    required this.sizeBytes,
  });

  String get readableSize {
    if (sizeBytes <= 0) return 'Tamano desconocido';
    final mb = sizeBytes / (1024 * 1024);
    if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
    final kb = sizeBytes / 1024;
    return '${kb.toStringAsFixed(0)} KB';
  }
}

class SubtitleLine {
  final Duration start;
  final Duration end;
  final String text;

  const SubtitleLine({
    required this.start,
    required this.end,
    required this.text,
  });
}

class SubtitleStyleConfig {
  final double fontSize;
  final String position;
  final bool highlightWords;
  final SubtitleFontPreset fontPreset;

  const SubtitleStyleConfig({
    this.fontSize = 22,
    this.position = 'Inferior',
    this.highlightWords = true,
    this.fontPreset = SubtitleFontPreset.clean,
  });

  SubtitleStyleConfig copyWith({
    double? fontSize,
    String? position,
    bool? highlightWords,
    SubtitleFontPreset? fontPreset,
  }) {
    return SubtitleStyleConfig(
      fontSize: fontSize ?? this.fontSize,
      position: position ?? this.position,
      highlightWords: highlightWords ?? this.highlightWords,
      fontPreset: fontPreset ?? this.fontPreset,
    );
  }
}
