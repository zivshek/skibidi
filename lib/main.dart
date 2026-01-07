import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:skibidi/core/interfaces/i_trail_data_repository.dart';
import 'package:skibidi/core/interfaces/i_location_service.dart';
import 'package:skibidi/repositories/openskimap_trail_repository.dart';
import 'package:skibidi/services/implementations/flutter_bg_location_service.dart';
import 'package:skibidi/services/implementations/mock_location_service.dart';
import 'package:skibidi/services/database_service.dart';
import 'package:skibidi/services/mock_data_generator.dart';
import 'package:skibidi/screens/home_screen.dart';

final getIt = GetIt.instance;

// Toggle this to switch between mock and real tracking
const bool useMockTracking = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  await setupDependencies();

  // Generate mock session history for testing
  if (useMockTracking) {
    await _generateMockHistory();
  }

  runApp(const SkibidiApp());
}

Future<void> setupDependencies() async {
  // Register trail data repository
  getIt.registerSingleton<ITrailDataRepository>(OpenSkiMapTrailRepository());

  // Register location service (mock or real based on flag)
  if (useMockTracking) {
    getIt.registerSingleton<ILocationService>(MockLocationService());
    debugPrint('🎭 Using MOCK location service for testing');
  } else {
    getIt.registerSingleton<ILocationService>(FlutterBgLocationService());
    debugPrint('📍 Using REAL GPS location service');
  }

  // Register database service
  getIt.registerSingleton<DatabaseService>(DatabaseService.instance);
}

Future<void> _generateMockHistory() async {
  try {
    // Wait for database to be ready
    final db = getIt<DatabaseService>();

    // Check if we already have sessions
    final existingSessions = await db.getAllSessions();

    if (existingSessions.isEmpty) {
      // Generate 5 mock sessions
      final mockSessions = MockDataGenerator.generateMockHistory(
        resortId: 'mont_tremblant',
        count: 5,
      );

      // Save to database
      for (final session in mockSessions) {
        await db.saveSession(session);
      }

      debugPrint(
        '✅ Generated ${mockSessions.length} mock sessions for testing',
      );
    } else {
      debugPrint('ℹ️  Found ${existingSessions.length} existing sessions');
    }
  } catch (e) {
    debugPrint('❌ Error generating mock data: $e');
  }
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
