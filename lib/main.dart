import 'package:flutter/material.dart';
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/services/favorites_service.dart';
import 'package:liga_educa/theme.dart';

/// Main entry point for the application
///
/// This sets up:
/// - go_router navigation
/// - Material 3 theming with light/dark modes
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FavoritesService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Liga Educa',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,

      // Router configuration
      routerConfig: AppRouter.router,
    );
  }
}

