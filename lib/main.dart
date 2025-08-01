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
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
              useMaterial3: true,
              textTheme: GoogleFonts.montserratTextTheme(
                Theme.of(context).textTheme,
              ).copyWith(
                headlineLarge: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                headlineMedium: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                headlineSmall: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                titleLarge: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                titleMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                titleSmall: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.dark,
              useMaterial3: true,
              textTheme: GoogleFonts.montserratTextTheme(
                ThemeData.dark().textTheme,
              ).copyWith(
                headlineLarge: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white),
                headlineMedium: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white),
                headlineSmall: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white),
                titleLarge: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white),
                titleMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white),
                titleSmall: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}