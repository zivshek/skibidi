import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:skibidi/models/ski_session.dart';
import 'package:skibidi/models/trail_visit.dart';

/// Service for local database operations
class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'skibidi.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Sessions table
    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        startTime TEXT NOT NULL,
        endTime TEXT,
        status TEXT NOT NULL,
        resortId TEXT NOT NULL,
        stats TEXT NOT NULL
      )
    ''');

    // Trail visits table
    await db.execute('''
      CREATE TABLE trail_visits (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        trailId TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        isLift INTEGER NOT NULL,
        path TEXT NOT NULL,
        maxSpeed REAL NOT NULL,
        verticalChange REAL NOT NULL,
        distance REAL NOT NULL,
        FOREIGN KEY (sessionId) REFERENCES sessions (id) ON DELETE CASCADE
      )
    ''');

    // Create index for faster session queries
    await db.execute('''
      CREATE INDEX idx_sessions_startTime ON sessions(startTime DESC)
    ''');
  }

  /// Save or update a session
  Future<void> saveSession(SkiSession session) async {
    final db = await database;
    final data = {
      'id': session.id,
      'startTime': session.startTime.toIso8601String(),
      'endTime': session.endTime?.toIso8601String(),
      'status': session.status.name,
      'resortId': session.resortId,
      'stats': json.encode(session.stats.toJson()),
    };

    await db.insert(
      'sessions',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Save trail visits
    for (final visit in session.visits) {
      await _saveTrailVisit(session.id, visit);
    }
  }

  Future<void> _saveTrailVisit(String sessionId, TrailVisit visit) async {
    final db = await database;
    final data = {
      'id': visit.id,
      'sessionId': sessionId,
      'trailId': visit.trailId,
      'startTime': visit.startTime.toIso8601String(),
      'endTime': visit.endTime.toIso8601String(),
      'isLift': visit.isLift ? 1 : 0,
      'path': json.encode(visit.path.map((p) => p.toJson()).toList()),
      'maxSpeed': visit.maxSpeed,
      'verticalChange': visit.verticalChange,
      'distance': visit.distance,
    };

    await db.insert(
      'trail_visits',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all sessions, ordered by most recent first
  Future<List<SkiSession>> getAllSessions() async {
    final db = await database;
    final sessionMaps = await db.query('sessions', orderBy: 'startTime DESC');

    final sessions = <SkiSession>[];
    for (final sessionMap in sessionMaps) {
      final session = await _sessionFromMap(sessionMap);
      sessions.add(session);
    }

    return sessions;
  }

  /// Get a specific session by ID
  Future<SkiSession?> getSession(String id) async {
    final db = await database;
    final sessionMaps = await db.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (sessionMaps.isEmpty) return null;
    return await _sessionFromMap(sessionMaps.first);
  }

  /// Delete a session and its trail visits
  Future<void> deleteSession(String id) async {
    final db = await database;
    await db.delete('sessions', where: 'id = ?', whereArgs: [id]);
    // Trail visits will be automatically deleted due to CASCADE
  }

  Future<SkiSession> _sessionFromMap(Map<String, dynamic> map) async {
    final db = await database;

    // Get trail visits for this session
    final visitMaps = await db.query(
      'trail_visits',
      where: 'sessionId = ?',
      whereArgs: [map['id']],
      orderBy: 'startTime ASC',
    );

    final visits = visitMaps.map((visitMap) {
      return TrailVisit.fromJson({
        'id': visitMap['id'],
        'trailId': visitMap['trailId'],
        'startTime': visitMap['startTime'],
        'endTime': visitMap['endTime'],
        'isLift': (visitMap['isLift'] as int) == 1,
        'path': json.decode(visitMap['path'] as String),
        'maxSpeed': visitMap['maxSpeed'],
        'verticalChange': visitMap['verticalChange'],
        'distance': visitMap['distance'],
      });
    }).toList();

    return SkiSession.fromJson({
      'id': map['id'],
      'startTime': map['startTime'],
      'endTime': map['endTime'],
      'status': map['status'],
      'resortId': map['resortId'],
      'visits': visits.map((v) => v.toJson()).toList(),
      'stats': json.decode(map['stats'] as String),
    });
  }

  /// Export session to JSON
  Future<String> exportSessionToJson(String sessionId) async {
    final session = await getSession(sessionId);
    if (session == null) return '{}';
    return json.encode(session.toJson());
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
