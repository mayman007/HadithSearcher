import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hadithsearcher/views/about_view.dart';
import 'package:hadithsearcher/views/favourites_view.dart';
import 'package:hadithsearcher/views/search_view.dart';
import 'package:hadithsearcher/views/settings_view.dart';
import 'package:hadithsearcher/views/similar_hadith_view.dart';
import 'constants/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'db/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper sqlDb = DatabaseHelper();
  await sqlDb.initialDb();
  final theme = await sqlDb.getTheme();
  await dotenv.load(fileName: ".env");
  runApp(HomePage(theme: theme));
}

class HomePage extends StatelessWidget {
  final String theme;

  const HomePage({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("ar", "AE"),
      ],
      locale: const Locale("ar", "AE"),
      title: 'Hadith Searcher',
      theme: ThemeData(
        // Light theme settings
        brightness: Brightness.light,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1.5, color: Colors.black),
            borderRadius: BorderRadius.circular(50),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1.5, color: Colors.black),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 2,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Colors.blue,
          onPrimary: Colors.blue,
          primaryContainer: Color.fromARGB(255, 225, 226, 230),
          secondaryContainer: Colors.black,
          secondary: Colors.blue,
          onSecondary: Colors.blue,
          background: Colors.white,
          onBackground: Colors.blue,
          error: Colors.red,
          onError: Colors.red,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      ),
      darkTheme: ThemeData(
        // Dark theme settings
        brightness: Brightness.dark,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1.5, color: Colors.white),
            borderRadius: BorderRadius.circular(50),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1.5, color: Colors.white),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 2,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Colors.blue,
          onPrimary: Colors.blue,
          primaryContainer: Color.fromARGB(255, 40, 38, 41),
          secondaryContainer: Colors.white,
          secondary: Colors.blue,
          onSecondary: Colors.blue,
          background: Colors.black,
          onBackground: Colors.blue,
          error: Colors.red,
          onError: Colors.red,
          surface: Colors.black,
          onSurface: Colors.white,
        ),
      ),
      themeMode: getThemeMode(),
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
  }

  ThemeMode getThemeMode() {
    if (theme == 'dark') {
      return ThemeMode.dark;
    } else if (theme == 'light') {
      return ThemeMode.light;
    } else {
      // If the theme is 'system' or any other unexpected value,
      // the app will follow the system's theme.
      return ThemeMode.system;
    }
  }
}
