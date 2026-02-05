import 'package:flutter/material.dart';
import '../core/constants/routes.dart';

/// Navigation drawer for the app.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 60),
          const Image(
            image: AssetImage('assets/icons/logo.png'),
            height: 220,
          ),
          _DrawerItem(
            icon: Icons.search,
            title: 'البحث',
            onTap: () => _navigateTo(context, searchRoute),
          ),
          _DrawerItem(
            icon: Icons.star,
            title: 'المفضلة',
            onTap: () => _navigateTo(context, favouritesRoute),
          ),
          _DrawerItem(
            icon: Icons.settings,
            title: 'الإعدادات',
            onTap: () => _navigateTo(context, settingsRoute),
          ),
          _DrawerItem(
            icon: Icons.info,
            title: 'حول',
            onTap: () => _navigateTo(context, aboutRoute),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(30),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
