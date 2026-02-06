import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/drawer_manager.dart'; // Added import

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: cs.outline.withValues(alpha: 0.40),
                width: 1,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              final wasDifferentTab = index != navigationShell.currentIndex;

              // For Home (0), News (2) and Favorites (3), we always want to reset to the root page.
              // For Competitions (1) and others (4 - Values), we preserve state unless the tab is already active.
              bool shouldReset = index == 0 || index == 2 || index == 3 || index == navigationShell.currentIndex;

              navigationShell.goBranch(
                index,
                initialLocation: shouldReset,
              );

              // Close drawer asynchronously to avoid blocking the navigation animation
              if (wasDifferentTab) {
                // Use scheduleMicrotask to defer the drawer close until after the current frame
                Future.microtask(() => drawerManager.closeDrawer());
              }
            },
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: _navigationDestinations,
          ),
        ),
      ),
    );
  }

  // Extract destinations as static const to avoid recreating them on every build
  static const List<NavigationDestination> _navigationDestinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Inicio',
    ),
    NavigationDestination(
      icon: Icon(Icons.emoji_events_outlined),
      selectedIcon: Icon(Icons.emoji_events),
      label: 'Comp.',
    ),
    NavigationDestination(
      icon: Icon(Icons.article_outlined),
      selectedIcon: Icon(Icons.article),
      label: 'Noticias',
    ),
    NavigationDestination(
      icon: Icon(Icons.star_outline),
      selectedIcon: Icon(Icons.star),
      label: 'Favoritos',
    ),
    NavigationDestination(
      icon: Icon(Icons.favorite_border),
      selectedIcon: Icon(Icons.favorite),
      label: 'Valores',
    ),
  ];
}
