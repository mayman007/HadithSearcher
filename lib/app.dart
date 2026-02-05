import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/constants/routes.dart';
import 'core/theme/app_theme.dart';
import 'viewmodels/favourites_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/similar_hadith_viewmodel.dart';
import 'views/about/about_view.dart';
import 'views/favourites/favourites_view.dart';
import 'views/search/search_view.dart';
import 'views/settings/settings_view.dart';
import 'views/similar_hadith/similar_hadith_view.dart';

/// Main app widget with Provider setup.
class HadithSearcherApp extends StatelessWidget {
  final ThemeMode initialThemeMode;

  const HadithSearcherApp({
    super.key,
    required this.initialThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel()..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavouritesViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => SimilarHadithViewModel(),
        ),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsVm, _) {
          // Use initial theme until settings are loaded
          final themeMode =
              settingsVm.isLoading ? initialThemeMode : settingsVm.themeMode;

          return MaterialApp(
            localizationsDelegates: const [
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'AE'),
            ],
            locale: const Locale('ar', 'AE'),
            title: 'Hadith Searcher',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            home: const SearchView(),
            routes: {
              searchRoute: (context) => const SearchView(),
              similarHadithRoute: (context) => const SimilarHadithView(),
              favouritesRoute: (context) => const FavouritesView(),
              settingsRoute: (context) => const SettingsView(),
              aboutRoute: (context) => const AboutView(),
            },
          );
        },
      ),
    );
  }
}
