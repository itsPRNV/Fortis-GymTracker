import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/theme_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/user_provider.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Gym Tracker',
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    final baseTheme = ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
      useMaterial3: true,
    );
    
    return baseTheme.copyWith(
      textTheme: GoogleFonts.montserratTextTheme(baseTheme.textTheme).copyWith(
        headlineLarge: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        headlineSmall: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final baseTheme = ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
      useMaterial3: true,
    );
    
    return baseTheme.copyWith(
      textTheme: GoogleFonts.montserratTextTheme(baseTheme.textTheme).copyWith(
        headlineLarge: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        headlineSmall: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
      ),
    );
  }
}