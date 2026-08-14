import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';
import '../features/analysis/analysis_screen.dart';
import '../features/processing/processing_screen.dart';
import '../features/preview/preview_screen.dart';
import '../features/subtitles/subtitles_screen.dart';
import '../features/history/history_screen.dart';
import '../features/settings/settings_screen.dart';
import '../widgets/main_shell.dart';

/// Configuración de rutas con GoRouter y transiciones suaves.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    // Splash - sin shell
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SplashScreen(),
        transitionsBuilder: _fadeTransition,
      ),
    ),

    // Shell con bottom nav (Home, History, Settings)
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: AppRoutes.history,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HistoryScreen(),
            transitionsBuilder: _slideTransition,
          ),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
            transitionsBuilder: _slideTransition,
          ),
        ),
      ],
    ),

    // Pantallas sin shell
    GoRoute(
      path: AppRoutes.analysis,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AnalysisScreen(),
        transitionsBuilder: _slideUpTransition,
      ),
    ),
    GoRoute(
      path: AppRoutes.processing,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ProcessingScreen(),
        transitionsBuilder: _fadeScaleTransition,
      ),
    ),
    GoRoute(
      path: AppRoutes.preview,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const PreviewScreen(),
        transitionsBuilder: _slideUpTransition,
      ),
    ),
    GoRoute(
      path: AppRoutes.subtitles,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SubtitlesScreen(),
        transitionsBuilder: _slideUpTransition,
      ),
    ),
  ],
);

// Transición: fade
Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
    child: child,
  );
}

// Transición: slide horizontal
Widget _slideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: child,
  );
}

// Transición: slide hacia arriba
Widget _slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: child,
  );
}

// Transición: fade + escala
Widget _fadeScaleTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: animation,
    child: ScaleTransition(
      scale: Tween<double>(
        begin: 0.9,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
      child: child,
    ),
  );
}
