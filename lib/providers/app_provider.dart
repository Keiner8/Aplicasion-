import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado global de la aplicación.
class AppState {
  final bool isDarkMode;
  final String language;
  final List<String> processedVideos;

  const AppState({
    this.isDarkMode = true,
    this.language = 'es',
    this.processedVideos = const [],
  });

  AppState copyWith({
    bool? isDarkMode,
    String? language,
    List<String>? processedVideos,
  }) {
    return AppState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      processedVideos: processedVideos ?? this.processedVideos,
    );
  }
}

/// Notifier que maneja el estado global de la app.
class AppNotifier extends StateNotifier<AppState> {
  AppNotifier() : super(const AppState());

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void setLanguage(String language) {
    state = state.copyWith(language: language);
  }

  void addProcessedVideo(String url) {
    final updated = [...state.processedVideos, url];
    state = state.copyWith(processedVideos: updated);
  }

  void removeProcessedVideo(String url) {
    final updated = state.processedVideos.where((v) => v != url).toList();
    state = state.copyWith(processedVideos: updated);
  }

  void clearHistory() {
    state = state.copyWith(processedVideos: []);
  }
}

/// Provider principal de la app.
final appProvider = StateNotifierProvider<AppNotifier, AppState>(
  (ref) => AppNotifier(),
);

/// Provider del campo de URL del video.
final videoUrlProvider = StateProvider<String>((ref) => '');

/// Provider del progreso de procesamiento (0.0 - 1.0).
final processingProgressProvider = StateProvider<double>((ref) => 0.0);
