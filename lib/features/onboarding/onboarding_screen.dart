import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_state/app_state.dart';
import '../../core/theme/app_spacing.dart';

class _OnboardPage {
  const _OnboardPage({required this.icon, required this.title, required this.teluguTitle, required this.body});
  final IconData icon;
  final String title;
  final String teluguTitle;
  final String body;
}

const _pages = [
  _OnboardPage(
    icon: Icons.calendar_month_rounded,
    title: 'A Panchangam built around Ugadi',
    teluguTitle: 'ఉగాది నుంచి ఉగాది వరకు',
    body: 'Browse the Telugu calendar year the way it is traditionally kept — from one Ugadi to the next, '
        'with Tithi, Nakshatra and Vara for every day.',
  ),
  _OnboardPage(
    icon: Icons.celebration_rounded,
    title: 'Never miss a Parva Dinam',
    teluguTitle: 'పండుగలు, పర్వదినాలు',
    body: 'Festival dates, significance and observance details in one place, with reminders you control — '
        '7 days, 1 day, and 2 hours before.',
  ),
  _OnboardPage(
    icon: Icons.auto_awesome_rounded,
    title: 'Your personal Jatakam',
    teluguTitle: 'మీ జాతకం',
    body: 'Add your birth details to see your Rāśi, Nakshatra and a full birth chart — kept private on this device.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  Future<void> _finish() async {
    await context.read<AppState>().completeOnboarding();
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TextButton(onPressed: _finish, child: const Text('దాటవేయండి')),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, shape: BoxShape.circle),
                          child: Icon(page.icon, size: 40, color: theme.colorScheme.onPrimaryContainer),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(page.teluguTitle, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          page.title,
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          page.body,
                          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final selected = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: selected ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: selected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (isLast) {
                      _finish();
                    } else {
                      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                    }
                  },
                  child: Text(isLast ? 'ప్రారంభించండి' : 'తదుపరి'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
