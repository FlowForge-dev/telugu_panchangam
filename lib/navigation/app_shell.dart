import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom-nav scaffold hosting the five primary destinations. go_router's
/// [StatefulShellRoute] keeps each tab's own navigation stack alive when
/// switching tabs.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'హోమ్', tooltip: 'Home'),
    (icon: Icons.calendar_month_outlined, selectedIcon: Icons.calendar_month_rounded, label: 'క్యాలెండర్', tooltip: 'Calendar'),
    (icon: Icons.auto_awesome_outlined, selectedIcon: Icons.auto_awesome_rounded, label: 'జాతకం', tooltip: 'Jatakam'),
    (icon: Icons.celebration_outlined, selectedIcon: Icons.celebration_rounded, label: 'పండుగలు', tooltip: 'Festivals'),
    (icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'ప్రొఫైల్', tooltip: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
              tooltip: d.tooltip,
            ),
        ],
      ),
    );
  }
}
