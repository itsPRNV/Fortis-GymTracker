import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/theme_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/user_provider.dart';
import 'providers/timer_provider.dart';
import 'providers/tab_state_provider.dart';
import 'providers/template_provider.dart';
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
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => TabStateProvider()),
        ChangeNotifierProvider(create: (_) => TemplateProvider()),
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
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1A1A1A),
        secondary: Color(0xFFFF6B6B),
        tertiary: Color(0xFF4ECDC4),
        surface: Color(0xFFF8F9FA),
        background: Color(0xFFFFFFFF),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1A1A1A),
        onBackground: Color(0xFF1A1A1A),
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineLarge: GoogleFonts.inter(
            fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A)),
        headlineMedium: GoogleFonts.inter(
            fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A)),
        headlineSmall: GoogleFonts.inter(
            fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A)),
        titleLarge: GoogleFonts.inter(
            fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A)),
        titleMedium: GoogleFonts.inter(
            fontWeight: FontWeight.w500, color: const Color(0xFF1A1A1A)),
        bodyLarge: GoogleFonts.inter(color: const Color(0xFF1A1A1A)),
        bodyMedium: GoogleFonts.inter(color: const Color(0xFF666666)),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFFF8F9FA),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B6B),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF6B6B),
        secondary: Color(0xFF4ECDC4),
        tertiary: Color(0xFFFFE66D),
        surface: Color(0xFF1E1E1E),
        background: Color(0xFF121212),
        onPrimary: Colors.white,
        onSecondary: Color(0xFF121212),
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme:
          GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        headlineLarge:
            GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
        headlineMedium:
            GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
        headlineSmall:
            GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge:
            GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
        titleMedium:
            GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.white),
        bodyLarge: GoogleFonts.inter(color: Colors.white),
        bodyMedium: GoogleFonts.inter(color: const Color(0xFFB0B0B0)),
        bodySmall: GoogleFonts.inter(color: const Color(0xFF888888)),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF1E1E1E),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B6B),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Color(0xFFFF6B6B),
        unselectedItemColor: Color(0xFF888888),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
