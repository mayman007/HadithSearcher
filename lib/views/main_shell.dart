import 'package:flutter/material.dart';
import 'about/about_view.dart';
import 'favourites/favourites_view.dart';
import 'search/search_view.dart';
import 'settings/settings_view.dart';

/// Main shell widget with bottom navigation bar.
class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    SearchView(),
    FavouritesView(),
    SettingsView(),
    AboutView(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search, color: activeColor),
            label: 'البحث',
          ),
          NavigationDestination(
            icon: const Icon(Icons.star_outline),
            selectedIcon: Icon(Icons.star, color: activeColor),
            label: 'المفضلة',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: activeColor),
            label: 'الإعدادات',
          ),
          NavigationDestination(
            icon: const Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info, color: activeColor),
            label: 'حول',
          ),
        ],
      ),
    );
  }
}
