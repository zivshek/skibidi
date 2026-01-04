import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:skibidi/core/interfaces/i_trail_data_repository.dart';
import 'package:skibidi/core/interfaces/i_location_service.dart';
import 'package:skibidi/repositories/openskimap_trail_repository.dart';
import 'package:skibidi/services/implementations/flutter_bg_location_service.dart';
import 'package:skibidi/services/database_service.dart';
import 'package:skibidi/screens/home_screen.dart';

final getIt = GetIt.instance;

void main() {
  // Setup dependency injection
  setupDependencies();

  runApp(const SkibidiApp());
}

void setupDependencies() {
  // Register trail data repository
  getIt.registerSingleton<ITrailDataRepository>(OpenSkiMapTrailRepository());

  // Register location service
  getIt.registerSingleton<ILocationService>(FlutterBgLocationService());

  // Register database service
  getIt.registerSingleton<DatabaseService>(DatabaseService.instance);
}

class SkibidiApp extends StatelessWidget {
  const SkibidiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skibidi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: const CardThemeData(
          elevation: 2,
          color: Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
