import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _api = ApiService();
  List<dynamic> _zones = [];
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _selectedZone;

  // Mount Kilimanjaro centre
  static const _kilikCenter = LatLng(-3.0674, 37.3556);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _api.getZones();
      setState(() {
        _zones = data['zones'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Cannot reach server.\nMake sure the backend is running\non your laptop.';
        _loading = false;
      });
    }
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text('FirePredict — Risk Map',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _kilikCenter,
              initialZoom: 10.5,
              onTap: (_, __) => setState(() => _selectedZone = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.firepredict.app',
              ),
              if (_zones.isNotEmpty)
                CircleLayer(
                  circles: _zones.map<CircleMarker>((z) {
                    final color = _hexToColor(z['risk_color'] ?? '#388E3C');
                    return CircleMarker(
                      point: LatLng(
                          (z['lat'] as num).toDouble(),
                          (z['lon'] as num).toDouble()),
                      radius: 6000,
                      color: color.withOpacity(0.28),
                      borderColor: color,
                      borderStrokeWidth: 2,
                      useRadiusInMeter: true,
                    );
                  }).toList(),
                ),
              if (_zones.isNotEmpty)
                MarkerLayer(
                  markers: _zones.map<Marker>((z) {
                    final color = _hexToColor(z['risk_color'] ?? '#388E3C');
                    return Marker(
                      point: LatLng(
                          (z['lat'] as num).toDouble(),
                          (z['lon'] as num).toDouble()),
                      width: 44,
                      height: 44,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedZone = z),
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 8)
                            ],
                          ),
                          child: const Icon(Icons.local_fire_department,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),

          // Loading overlay
          if (_loading)
            const Center(child: CircularProgressIndicator()),

          // Error banner
          if (_error != null)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(_error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),

          // Legend
          Positioned(
            top: 12,
            right: 12,
            child: _Legend(),
          ),

          // Selected zone card
          if (_selectedZone != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: _ZoneCard(
                zone: _selectedZone!,
                onClose: () => setState(() => _selectedZone = null),
                hexToColor: _hexToColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.93),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Risk Level',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          SizedBox(height: 4),
          _LegendItem(color: Color(0xFFD32F2F), label: 'High'),
          _LegendItem(color: Color(0xFFF57C00), label: 'Moderate'),
          _LegendItem(color: Color(0xFFFBC02D), label: 'Low'),
          _LegendItem(color: Color(0xFF388E3C), label: 'Very Low'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
              width: 12,
              height: 12,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final Map<String, dynamic> zone;
  final VoidCallback onClose;
  final Color Function(String) hexToColor;

  const _ZoneCard(
      {required this.zone,
      required this.onClose,
      required this.hexToColor});

  @override
  Widget build(BuildContext context) {
    final color = hexToColor(zone['risk_color'] ?? '#388E3C');
    final score = ((zone['risk_score'] as num) * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(zone['zone_name'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onClose),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  '${zone['risk_label']} Risk',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Text('Score: $score%',
                  style: const TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (zone['risk_score'] as num).toDouble(),
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
