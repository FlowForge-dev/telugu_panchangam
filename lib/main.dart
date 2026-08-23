import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'app_state/app_state.dart';
import 'app_state/repositories_scope.dart';
import 'app_state/theme_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final repositories = Repositories.mock();
  final themeController = ThemeController()..load();

  runApp(
    MultiProvider(
      providers: [
        Provider<Repositories>.value(value: repositories),
        ChangeNotifierProvider<ThemeController>.value(value: themeController),
        ChangeNotifierProvider<AppState>(
          create: (_) => AppState(
            profileRepository: repositories.profile,
            jatakamRepository: repositories.jatakam,
            reminderRepository: repositories.reminder,
          ),
        ),
      ],
      child: const PanchangamApp(),
    ),
  );
}
