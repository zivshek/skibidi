import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:skibidi/models/resort.dart';
import 'package:skibidi/models/ski_session.dart';
import 'package:skibidi/models/session_statistics.dart';
import 'package:skibidi/screens/session_summary_screen.dart';
import 'package:skibidi/widgets/stat_card.dart';

class ActiveSessionScreen extends StatefulWidget {
  final Resort resort;

  const ActiveSessionScreen({super.key, required this.resort});

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  late SkiSession _session;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isPaused = false;

  // Mock stats that would come from session tracker
  int _runs = 0;
  double _vertical = 0;
  double _distance = 0;
  double _maxSpeed = 0;
  String _currentTrail = 'Not on trail';

  @override
  void initState() {
    super.initState();
    _session = SkiSession.create(
      id: const Uuid().v4(),
      resortId: widget.resort.id,
    );
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _elapsed = DateTime.now().difference(_session.startTime);
          // Mock data updates
          if (_elapsed.inSeconds % 10 == 0) {
            _runs++;
            _vertical += 150;
            _distance += 500;
            _maxSpeed = (_maxSpeed + 5).clamp(0, 70);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _endSession() {
    _timer?.cancel();

    // Navigate to summary
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SessionSummaryScreen(
          session: _session,
          stats: SessionStatistics(
            totalVertical: _vertical,
            totalDistance: _distance,
            maxSpeed: _maxSpeed,
            avgSpeed: _distance > 0
                ? (_distance / _elapsed.inSeconds) * 3.6
                : 0,
            timeSkiing: _elapsed,
            timeOnLift: Duration.zero,
            greenTrails: _runs ~/ 3,
            blueTrails: _runs ~/ 2,
            blackTrails: _runs - (_runs ~/ 3) - (_runs ~/ 2),
            doubleBlackTrails: 0,
            trailCounts: {},
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resort.name),
        actions: [
          if (_isPaused)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PAUSED',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Timer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.secondaryContainer,
                ],
              ),
            ),
            child: Column(
              children: [
                Text(
                  _formatDuration(_elapsed),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentTrail,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Stats Grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.arrow_downward,
                          label: 'Vertical',
                          value: _vertical.toStringAsFixed(0),
                          unit: 'm',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          icon: Icons.speed,
                          label: 'Max Speed',
                          value: _maxSpeed.toStringAsFixed(1),
                          unit: 'km/h',
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.route,
                          label: 'Runs',
                          value: _runs.toString(),
                          unit: '',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          icon: Icons.straighten,
                          label: 'Distance',
                          value: (_distance / 1000).toStringAsFixed(1),
                          unit: 'km',
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Control Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _togglePause,
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                    label: Text(_isPaused ? 'Resume' : 'Pause'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _endSession,
                    icon: const Icon(Icons.stop),
                    label: const Text('End Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
