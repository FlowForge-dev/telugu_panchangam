// Smoke test: the app boots to the splash screen without throwing.
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:telugu_panchangam/app.dart';
import 'package:telugu_panchangam/app_state/app_state.dart';
import 'package:telugu_panchangam/app_state/repositories_scope.dart';
import 'package:telugu_panchangam/app_state/theme_controller.dart';

void main() {
  testWidgets('App boots and shows the splash screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final repositories = Repositories.mock();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Repositories>.value(value: repositories),
          ChangeNotifierProvider<ThemeController>(create: (_) => ThemeController()),
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

    expect(find.text('పంచాంగం'), findsOneWidget);

    // Let the splash screen's bootstrap timer/navigation settle so no
    // timers are left pending when the test tears down.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}
