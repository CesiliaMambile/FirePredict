import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ScenarioScreen extends StatefulWidget {
  const ScenarioScreen({super.key});

  @override
  State<ScenarioScreen> createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends State<ScenarioScreen> {
  final _api = ApiService();

  bool _loading = true;
  bool _predicting = false;
  String _season = '';

  // Satellite indices
  double _ndvi = 0.5;
  double _nbr = 0.3;
  double _ndwi = 0.3;

  // Weather
  double _temperature = 25.0;
  double _humidity = 50.0;
  double _windSpeed = 12.0;
  double _rainfall = 20.0;
  double _minTemp = 15.0;
  double _maxTemp = 28.0;

  // Human activity (1–9 scale)
  double _tourism = 5.0;
  double _beekeeping = 5.0;
  double _agriculture = 5.0;

  String _selectedZone = 'south_slope';
  Map<String, dynamic>? _result;

  final _zones = const [
    {'id': 'north_slope', 'name': 'North Slope'},
    {'id': 'south_slope', 'name': 'South Slope'},
    {'id': 'east_corridor', 'name': 'East Corridor'},
    {'id': 'west_forest', 'name': 'West Forest Belt'},
    {'id': 'core_park', 'name': 'Core National Park'},
  ];

  @override
  void initState() {
    super.initState();
    _loadConditions();
  }

  Future<void> _loadConditions() async {
    try {
      final data = await _api.getCurrentConditions();
      setState(() {
        _ndvi = (data['ndvi'] as num).toDouble();
        _nbr = (data['nbr'] as num).toDouble();
        _ndwi = (data['ndwi'] as num).toDouble();
        _temperature = (data['temperature'] as num).toDouble();
        _humidity = (data['humidity'] as num).toDouble();
        _windSpeed = (data['wind_speed'] as num).toDouble();
        _rainfall = (data['rainfall'] as num).toDouble();
        _minTemp = (data['min_temp'] as num).toDouble();
        _maxTemp = (data['max_temp'] as num).toDouble();
        _season = data['season'] ?? '';
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _applyDrySeason() {
    setState(() {
      _ndvi = 0.28; _nbr = 0.41; _ndwi = 0.12;
      _temperature = 28.5; _humidity = 32.0;
      _windSpeed = 18.0; _rainfall = 2.5;
      _minTemp = 16.0; _maxTemp = 31.0;
      _tourism = 8.0; _beekeeping = 8.0; _agriculture = 7.0;
      _result = null;
    });
  }

  void _applyWetSeason() {
    setState(() {
      _ndvi = 0.62; _nbr = 0.18; _ndwi = 0.45;
      _temperature = 22.0; _humidity = 72.0;
      _windSpeed = 9.0; _rainfall = 48.0;
      _minTemp = 14.0; _maxTemp = 25.0;
      _tourism = 3.0; _beekeeping = 3.0; _agriculture = 2.0;
      _result = null;
    });
  }

  Future<void> _predict() async {
    setState(() { _predicting = true; _result = null; });
    try {
      final res = await _api.predictScenario(
        ndvi: _ndvi, nbr: _nbr, ndwi: _ndwi,
        temperature: _temperature, humidity: _humidity,
        windSpeed: _windSpeed, rainfall: _rainfall,
        minTemp: _minTemp, maxTemp: _maxTemp,
        zoneId: _selectedZone,
      );
      setState(() { _result = res; _predicting = false; });
    } catch (_) {
      setState(() => _predicting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prediction failed. Check server connection.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scenario Testing')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline, color: Color(0xFF1E88E5)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                        'Values auto-loaded from server ($_season). Use presets or adjust sliders to test scenarios.',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF1565C0)),
                      )),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Preset buttons
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _applyWetSeason,
                        icon: const Icon(Icons.water_drop, size: 16),
                        label: const Text('Wet Season', style: TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1E88E5),
                          side: const BorderSide(color: Color(0xFF1E88E5)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _applyDrySeason,
                        icon: const Icon(Icons.wb_sunny, size: 16),
                        label: const Text('Dry Season', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // Zone selector
                  const Text('Select Zone',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[50],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedZone,
                        onChanged: (v) => setState(() => _selectedZone = v!),
                        items: _zones.map((z) => DropdownMenuItem(
                          value: z['id'], child: Text(z['name']!),
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Satellite Indices
                  _sectionHeader('Satellite Indices (Sentinel-2)', Icons.satellite_alt),
                  _slider('NDVI — Vegetation Health', _ndvi, 0.0, 1.0,
                      (v) => setState(() => _ndvi = v),
                      low: 'Dry/Burnt', high: 'Healthy'),
                  _slider('NBR — Burn Severity', _nbr, 0.0, 1.0,
                      (v) => setState(() => _nbr = v),
                      low: 'Low', high: 'High severity'),
                  _slider('NDWI — Surface Moisture', _ndwi, 0.0, 1.0,
                      (v) => setState(() => _ndwi = v),
                      low: 'Dry', high: 'Moist'),
                  const SizedBox(height: 8),

                  // Weather
                  _sectionHeader('Weather Conditions (TMA)', Icons.thermostat),
                  _slider('Temperature (°C)', _temperature, 10.0, 40.0,
                      (v) => setState(() => _temperature = v),
                      low: 'Cool', high: 'Hot'),
                  _slider('Humidity (%)', _humidity, 10.0, 100.0,
                      (v) => setState(() => _humidity = v),
                      low: 'Dry', high: 'Humid'),
                  _slider('Wind Speed (km/h)', _windSpeed, 0.0, 40.0,
                      (v) => setState(() => _windSpeed = v),
                      low: 'Calm', high: 'Strong'),
                  _slider('Rainfall (mm)', _rainfall, 0.0, 100.0,
                      (v) => setState(() => _rainfall = v),
                      low: 'No rain', high: 'Heavy rain'),
                  const SizedBox(height: 8),

                  // Human Activity
                  _sectionHeader('Human Activity Indicators', Icons.people),
                  _slider('Tourism Activity', _tourism, 1.0, 9.0,
                      (v) => setState(() => _tourism = v),
                      low: 'Very low', high: 'Very high'),
                  _slider('Beekeeping Activity', _beekeeping, 1.0, 9.0,
                      (v) => setState(() => _beekeeping = v),
                      low: 'Very low', high: 'Very high'),
                  _slider('Agricultural Burning', _agriculture, 1.0, 9.0,
                      (v) => setState(() => _agriculture = v),
                      low: 'Very low', high: 'Very high'),
                  const SizedBox(height: 20),

                  // Predict button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _predicting ? null : _predict,
                      icon: _predicting
                          ? const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.bolt),
                      label: Text(_predicting ? 'Predicting...' : 'Run Prediction'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  if (_result != null) ...[
                    const SizedBox(height: 20),
                    _ResultCard(result: _result!),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, size: 18, color: const Color(0xFFE53935)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ]),
    );
  }

  Widget _slider(String label, double value, double min, double max,
      ValueChanged<double> onChanged, {required String low, required String high}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(value.toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 13, color: Color(0xFFE53935))),
          ),
        ]),
        Slider(value: value, min: min, max: max, divisions: 80,
            activeColor: const Color(0xFFE53935), onChanged: onChanged),
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(low, style: const TextStyle(fontSize: 11, color: Colors.black38)),
            Text(high, style: const TextStyle(fontSize: 11, color: Colors.black38)),
          ]),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final score = (result['risk_score'] as num).toDouble();
    final label = result['risk_label'] as String;
    final colorHex = result['risk_color'] as String;
    final color = Color(int.parse(colorHex.replaceFirst('#', 'FF'), radix: 16));
    final percent = (score * 100).toStringAsFixed(1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.local_fire_department, color: color, size: 32),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Prediction Result',
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 28,
                fontWeight: FontWeight.bold, color: color)),
          ]),
        ]),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: score, minHeight: 12,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 8),
        Text('Risk Score: $percent%',
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
        const SizedBox(height: 6),
        const Text(
          'Generated live by ConvLSTM model using the input values above.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.black45),
        ),
      ]),
    );
  }
}
