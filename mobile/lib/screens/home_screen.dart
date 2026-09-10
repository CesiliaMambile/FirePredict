import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'impact_screen.dart';
import 'map_screen.dart';
import 'alerts_screen.dart';
import 'weather_screen.dart';
import 'report_screen.dart';
import 'safety_screen.dart';
import 'results_screen.dart';
import 'scenario_screen.dart';
import 'trends_screen.dart';
import '../services/api_service.dart';

// ─── Simple language toggle ──────────────────────────────────────────────────

class _Lang {
  static bool swahili = false;

  static String get impact    => swahili ? 'Athari'          : 'Impact';
  static String get riskMap   => swahili ? 'Ramani'          : 'Risk Map';
  static String get alerts    => swahili ? 'Tahadhari'       : 'Alerts';
  static String get weather   => swahili ? 'Hali ya Hewa'    : 'Weather';
  static String get report    => swahili ? 'Ripoti'          : 'Report';
}

// ─── HomeScreen ──────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _screens = const [
    ImpactScreen(),
    AlertsScreen(),
    MapScreen(),
    WeatherScreen(),
    ReportScreen(),
  ];

  void _toggleLanguage() {
    setState(() => _Lang.swahili = !_Lang.swahili);
    final msg = _Lang.swahili
        ? '🇹🇿 Kiswahili — Tahadhari za Moto Kilimanjaro'
        : '🇬🇧 Switched to English';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF1A237E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text('FirePredict',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          // Language toggle
          TextButton(
            onPressed: _toggleLanguage,
            child: Text(
              _Lang.swahili ? '🇹🇿 SW' : '🇬🇧 EN',
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'results') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ResultsScreen()));
              } else if (value == 'scenario') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ScenarioScreen()));
              } else if (value == 'trends') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TrendsScreen()));
              } else if (value == 'safety') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SafetyScreen()));
              } else if (value == 'home') {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/onboarding', (r) => false);
              } else if (value == 'exit') {
                SystemNavigator.pop();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'results',
                child: Row(children: [
                  Icon(Icons.bar_chart, color: Color(0xFFE53935)),
                  SizedBox(width: 10),
                  Text('Model Results')
                ]),
              ),
              PopupMenuItem(
                value: 'scenario',
                child: Row(children: [
                  Icon(Icons.science, color: Color(0xFFE53935)),
                  SizedBox(width: 10),
                  Text('Scenario Testing')
                ]),
              ),
              PopupMenuItem(
                value: 'trends',
                child: Row(children: [
                  Icon(Icons.trending_up, color: Color(0xFFE53935)),
                  SizedBox(width: 10),
                  Text('7-Day Trends')
                ]),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'safety',
                child: Row(children: [
                  Icon(Icons.shield_outlined),
                  SizedBox(width: 10),
                  Text('Safety Guidelines')
                ]),
              ),
              PopupMenuItem(
                value: 'home',
                child: Row(children: [
                  Icon(Icons.home_outlined),
                  SizedBox(width: 10),
                  Text('Get Started')
                ]),
              ),
              PopupMenuItem(
                value: 'exit',
                child: Row(children: [
                  Icon(Icons.exit_to_app),
                  SizedBox(width: 10),
                  Text('Exit App')
                ]),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline banner — shows whenever server is unreachable
          if (ApiService.isOffline) const _OfflineBanner(),
          Expanded(
            child: IndexedStack(index: _index, children: _screens),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFFFEBEE),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart, color: Color(0xFFE53935)),
            label: _Lang.impact,
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_outlined),
            selectedIcon: const Icon(Icons.notifications, color: Color(0xFFE53935)),
            label: _Lang.alerts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map, color: Color(0xFFE53935)),
            label: _Lang.riskMap,
          ),
          NavigationDestination(
            icon: const Icon(Icons.wb_sunny_outlined),
            selectedIcon: const Icon(Icons.wb_sunny, color: Color(0xFFE53935)),
            label: _Lang.weather,
          ),
          NavigationDestination(
            icon: const Icon(Icons.camera_alt_outlined),
            selectedIcon: const Icon(Icons.camera_alt, color: Color(0xFFE53935)),
            label: _Lang.report,
          ),
        ],
      ),
    );
  }
}

// ─── Offline banner ──────────────────────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  String _formatTime(String? iso) {
    if (iso == null) return 'recently';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return 'recently';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFF57F17),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline Mode — showing cached data'
              '${ApiService.lastOnlineTime != null ? ' (last updated ${_formatTime(ApiService.lastOnlineTime)})' : ''}',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
