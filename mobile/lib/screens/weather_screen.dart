import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'trends_screen.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _weather;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _api.getWeather();
      setState(() { _weather = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather & Fire Conditions'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _WeatherHeader(weather: _weather!),
                    const SizedBox(height: 16),
                    _WeatherGrid(weather: _weather!),
                    const SizedBox(height: 20),
                    _FireConditionBanner(weather: _weather!),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const TrendsScreen())),
                      icon: const Icon(Icons.show_chart),
                      label: const Text('View 7-Day Fire Risk Trend'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE53935),
                        side: const BorderSide(color: Color(0xFFE53935)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _WeatherHeader extends StatelessWidget {
  final Map<String, dynamic> weather;
  const _WeatherHeader({required this.weather});

  @override
  Widget build(BuildContext context) {
    final temp = weather['temperature'] ?? 0;
    final desc = weather['description'] ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFFF7043)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.wb_sunny, color: Colors.white, size: 52),
          const SizedBox(height: 8),
          Text('${temp.toStringAsFixed(1)}°C',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Mount Kilimanjaro Region',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(desc,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _WeatherGrid extends StatelessWidget {
  final Map<String, dynamic> weather;
  const _WeatherGrid({required this.weather});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _WeatherTile(
          icon: Icons.water_drop,
          color: const Color(0xFF1E88E5),
          label: 'Humidity',
          value: '${weather['humidity']?.toStringAsFixed(0)}%',
        ),
        _WeatherTile(
          icon: Icons.air,
          color: const Color(0xFF00ACC1),
          label: 'Wind Speed',
          value: '${weather['wind_speed']?.toStringAsFixed(1)} km/h',
        ),
        _WeatherTile(
          icon: Icons.umbrella,
          color: const Color(0xFF43A047),
          label: 'Rainfall',
          value: '${weather['rainfall']?.toStringAsFixed(1)} mm',
        ),
        _WeatherTile(
          icon: Icons.thermostat,
          color: const Color(0xFFF57C00),
          label: 'Min / Max',
          value:
              '${weather['min_temp']?.toStringAsFixed(0)}° / ${weather['max_temp']?.toStringAsFixed(0)}°',
        ),
      ],
    );
  }
}

class _WeatherTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _WeatherTile(
      {required this.icon,
      required this.color,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: TextStyle(color: color, fontSize: 11)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FireConditionBanner extends StatelessWidget {
  final Map<String, dynamic> weather;
  const _FireConditionBanner({required this.weather});

  @override
  Widget build(BuildContext context) {
    final humidity = (weather['humidity'] ?? 60) as num;
    final wind = (weather['wind_speed'] ?? 10) as num;
    final high = humidity < 40 || wind > 15;
    final color = high ? const Color(0xFFD32F2F) : const Color(0xFF388E3C);
    final label = high ? 'High Fire Weather Conditions' : 'Normal Fire Weather Conditions';
    final detail = high
        ? 'Low humidity and high winds increase fire spread risk significantly.'
        : 'Current weather conditions do not significantly elevate fire risk.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(high ? Icons.warning_amber_rounded : Icons.check_circle,
              color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(detail,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
