import 'package:flutter/material.dart';
import 'package:skibidi/models/ski_session.dart';
import 'package:skibidi/models/session_statistics.dart';
import 'package:skibidi/models/trail.dart';
import 'package:skibidi/widgets/stat_card.dart';

class SessionSummaryScreen extends StatelessWidget {
  final SkiSession session;
  final SessionStatistics stats;

  const SessionSummaryScreen({
    super.key,
    required this.session,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Summary'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Navigate back to home, removing all session screens
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Stats
            Text(
              'Great Session!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              session.duration.inHours > 0
                  ? '${session.duration.inHours}h ${session.duration.inMinutes.remainder(60)}m'
                  : '${session.duration.inMinutes}m',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            // Main Stats Grid
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.arrow_downward,
                    label: 'Total Vertical',
                    value: stats.totalVertical.toStringAsFixed(0),
                    unit: 'm',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.speed,
                    label: 'Max Speed',
                    value: stats.maxSpeed.toStringAsFixed(1),
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
                    label: 'Total Runs',
                    value: stats.totalRuns.toString(),
                    unit: '',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.straighten,
                    label: 'Distance',
                    value: (stats.totalDistance / 1000).toStringAsFixed(1),
                    unit: 'km',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Trail Breakdown
            Text(
              'Trail Breakdown',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _TrailDifficultyRow(
                      difficulty: 'Green',
                      count: stats.greenTrails,
                      color: TrailDifficulty.green.color,
                    ),
                    const Divider(height: 24),
                    _TrailDifficultyRow(
                      difficulty: 'Blue',
                      count: stats.blueTrails,
                      color: TrailDifficulty.blue.color,
                    ),
                    const Divider(height: 24),
                    _TrailDifficultyRow(
                      difficulty: 'Black',
                      count: stats.blackTrails,
                      color: TrailDifficulty.black.color,
                    ),
                    if (stats.doubleBlackTrails > 0) ...[
                      const Divider(height: 24),
                      _TrailDifficultyRow(
                        difficulty: 'Double Black',
                        count: stats.doubleBlackTrails,
                        color: TrailDifficulty.doubleBlack.color,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Time Breakdown
            Text(
              'Time Breakdown',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _TimeRow(
                      label: 'Skiing',
                      duration: stats.timeSkiing,
                      icon: Icons.downhill_skiing,
                      color: Colors.blue,
                    ),
                    const Divider(height: 24),
                    _TimeRow(
                      label: 'On Lifts',
                      duration: stats.timeOnLift,
                      icon: Icons.accessible_forward,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Back to Home Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrailDifficultyRow extends StatelessWidget {
  final String difficulty;
  final int count;
  final Color color;

  const _TrailDifficultyRow({
    required this.difficulty,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(difficulty, style: theme.textTheme.titleMedium)),
        Text(
          count.toString(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TimeRow extends StatelessWidget {
  final String label;
  final Duration duration;
  final IconData icon;
  final Color color;

  const _TimeRow({
    required this.label,
    required this.duration,
    required this.icon,
    required this.color,
  });

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
        Text(
          _formatDuration(duration),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
