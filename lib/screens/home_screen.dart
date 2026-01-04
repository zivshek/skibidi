import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:skibidi/core/interfaces/i_trail_data_repository.dart';
import 'package:skibidi/models/resort.dart';
import 'package:skibidi/screens/active_session_screen.dart';
import 'package:skibidi/screens/session_history_screen.dart';
import 'package:skibidi/widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _trailRepo = GetIt.I<ITrailDataRepository>();
  Resort? _selectedResort;
  List<Resort> _resorts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadResorts();
  }

  Future<void> _loadResorts() async {
    try {
      final resorts = await _trailRepo.getAllResorts();
      setState(() {
        _resorts = resorts;
        _selectedResort = resorts.isNotEmpty ? resorts.first : null;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _startSession() {
    if (_selectedResort == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActiveSessionScreen(resort: _selectedResort!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    backgroundColor: colorScheme.surface,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'Skibidi',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      centerTitle: false,
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.history),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SessionHistoryScreen(),
                            ),
                          );
                        },
                        tooltip: 'Session History',
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          // TODO: Settings screen
                        },
                        tooltip: 'Settings',
                      ),
                    ],
                  ),

                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Resort Selection
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Resort',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<Resort>(
                                  value: _selectedResort,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  items: _resorts.map((resort) {
                                    return DropdownMenuItem(
                                      value: resort,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            resort.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (resort.region != null)
                                            Text(
                                              '${resort.region}, ${resort.country}',
                                              style: theme.textTheme.bodySmall,
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (resort) {
                                    setState(() => _selectedResort = resort);
                                  },
                                ),
                                if (_selectedResort != null) ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(Icons.terrain, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Vertical: ${_selectedResort!.verticalDrop ?? 0}m',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Start Session Button
                        SizedBox(
                          height: 64,
                          child: ElevatedButton(
                            onPressed: _selectedResort != null
                                ? _startSession
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.play_arrow, size: 32),
                                const SizedBox(width: 12),
                                Text(
                                  'Start Session',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Quick Stats (placeholder - last session)
                        Text(
                          'Last Session',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                icon: Icons.arrow_downward,
                                label: 'Vertical',
                                value: '3,450',
                                unit: 'm',
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                icon: Icons.speed,
                                label: 'Max Speed',
                                value: '62.4',
                                unit: 'km/h',
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                icon: Icons.route,
                                label: 'Runs',
                                value: '12',
                                unit: '',
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                icon: Icons.timer,
                                label: 'Duration',
                                value: '4h 23m',
                                unit: '',
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
