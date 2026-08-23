import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state/theme_controller.dart';
import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';

class PanchangamApp extends StatelessWidget {
  const PanchangamApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    return MaterialApp.router(
      title: 'Telugu Panchangam',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeController.mode,
      routerConfig: appRouter,
    );
  }
}
