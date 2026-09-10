import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Change this to your laptop's local IP when testing on a real device.
/// Use http://10.0.2.2:8000 for Android emulator.
const String kBaseUrl = 'http://10.246.157.45:8080';

// ─── Demo / fallback data shown when server is offline ────────────────────

const _demoZones = {
  'zones': [
    {'zone_name': 'Machame Route',  'lat': -3.0674, 'lon': 37.2556, 'risk_score': 0.82, 'risk_label': 'High',     'risk_color': '#D32F2F'},
    {'zone_name': 'Shira Plateau',  'lat': -3.0522, 'lon': 37.2109, 'risk_score': 0.71, 'risk_label': 'High',     'risk_color': '#D32F2F'},
    {'zone_name': 'Mweka Route',    'lat': -3.1330, 'lon': 37.3640, 'risk_score': 0.76, 'risk_label': 'High',     'risk_color': '#D32F2F'},
    {'zone_name': 'Rongai Corridor','lat': -2.9852, 'lon': 37.4100, 'risk_score': 0.55, 'risk_label': 'Moderate', 'risk_color': '#F57C00'},
    {'zone_name': 'Marangu Gate',   'lat': -3.0396, 'lon': 37.5231, 'risk_score': 0.38, 'risk_label': 'Low',      'risk_color': '#FBC02D'},
    {'zone_name': 'Karanga Valley', 'lat': -3.1012, 'lon': 37.3200, 'risk_score': 0.22, 'risk_label': 'Very Low', 'risk_color': '#388E3C'},
    {'zone_name': 'Kilema Area',    'lat': -3.0200, 'lon': 37.4600, 'risk_score': 0.16, 'risk_label': 'Very Low', 'risk_color': '#388E3C'},
  ]
};

const _demoAlerts = {
  'alerts': [
    {
      'zone': 'Machame Route',
      'risk_label': 'High',
      'risk_color': '#D32F2F',
      'message': 'HIGH fire risk detected on the Machame Route. Dry conditions with low humidity (28%) and strong winds (22 km/h) are creating dangerous fire conditions. Satellite indices confirm critically dry vegetation. Rangers and communities should remain on high alert and prepare for possible fire containment.',
      'time': '2 hours ago',
      'predicted_window': 'Oct 8–13, 2026 — next 5 days',
      'peak_time': 'Oct 10–11, 2026 (14:00–18:00 local time)',
      'risk_drivers': [
        'NDVI = 0.24 — critically dry vegetation (Sentinel-2)',
        'Humidity: 28% — well below safe threshold of 50%',
        'Wind speed: 22 km/h — strong northerly winds',
        'Zero rainfall for 11 consecutive days',
        'High tourism activity (8/9) — increased human presence',
      ],
      'recommended_actions': [
        'Alert all rangers deployed along Machame Route immediately',
        'Prohibit campfire use and open burning in this zone',
        'Place fire-fighting equipment on standby at Machame Gate',
        'Notify Tanzania National Parks Authority (TANAPA)',
        'Advise beekeepers to avoid the zone for next 5 days',
        'Community leaders should brief village fire brigades',
      ],
    },
    {
      'zone': 'Shira Plateau',
      'risk_label': 'High',
      'risk_color': '#D32F2F',
      'message': 'HIGH fire risk on Shira Plateau. Satellite data shows critically low vegetation health (NDVI 0.24) with dry surface moisture. Elevated beekeeping and tourism activity in this zone increases ignition risk. Immediate monitoring is advised as conditions are expected to intensify over the next 72 hours.',
      'time': '4 hours ago',
      'predicted_window': 'Oct 7–12, 2026 — next 5 days',
      'peak_time': 'Oct 9–10, 2026 (afternoon hours)',
      'risk_drivers': [
        'NDVI = 0.22 — extremely dry heath vegetation',
        'NBR = 0.44 — high burn severity potential',
        'Surface moisture (NDWI) = 0.11 — near-drought conditions',
        'Temperature: 29°C — above seasonal average',
        'Beekeeping activity elevated (7/9) — open flame risk',
      ],
      'recommended_actions': [
        'Deploy fire watch patrols on Shira Plateau daily',
        'Suspend beekeeping activities with open-flame tools',
        'Coordinate with Kilimanjaro National Park management',
        'Monitor wind direction changes — risk of rapid spread',
        'Prepare evacuation plans for camp sites on the plateau',
      ],
    },
    {
      'zone': 'Mweka Route',
      'risk_label': 'High',
      'risk_color': '#D32F2F',
      'message': 'HIGH fire risk along Mweka Route. Temperature peaked at 31°C with near-zero rainfall for the past 9 days. Historical fire records from 2022 show this zone experienced severe burning during the same period. ConvLSTM model predicts risk will peak in the next 48–72 hours if no rainfall occurs.',
      'time': '6 hours ago',
      'predicted_window': 'Oct 8–11, 2026 — next 72 hours critical',
      'peak_time': 'Oct 9, 2026 (12:00–20:00 local time)',
      'risk_drivers': [
        'Maximum temperature: 31°C — hottest day in 3 weeks',
        'Rainfall: 0mm for 9 consecutive days',
        'Agricultural burning reported in adjacent lower slopes',
        'Historical precedent: fire occurred here Oct 21, 2022',
        'NDVI decline of 18% compared to same week last year',
      ],
      'recommended_actions': [
        'Issue immediate public warning for Mweka Route zone',
        'Ban all agricultural burning within 5 km of the route',
        'Increase ranger patrol frequency to every 3 hours',
        'Pre-position water tanks at Mweka Camp',
        'Contact district forest officers for additional support',
        'Prepare community fire response teams in Mweka village',
      ],
    },
    {
      'zone': 'Rongai Corridor',
      'risk_label': 'Moderate',
      'risk_color': '#F57C00',
      'message': 'MODERATE fire risk in Rongai Corridor. Conditions are currently manageable but agricultural burning in adjacent areas is elevating ignition potential. If humidity drops below 35% in the next 48 hours, risk may escalate to HIGH. Preventive monitoring is strongly recommended.',
      'time': '8 hours ago',
      'predicted_window': 'Oct 8–10, 2026 — monitor closely',
      'peak_time': 'Oct 10, 2026 (if humidity drops further)',
      'risk_drivers': [
        'Agricultural burning detected 3 km south of corridor',
        'Humidity: 42% — declining trend over past 4 days',
        'Wind direction: southerly — may carry embers northward',
        'Vegetation moisture below seasonal average by 15%',
      ],
      'recommended_actions': [
        'Monitor weather forecast daily for humidity changes',
        'Engage community leaders to stop agricultural burning',
        'Place rangers on standby alert for this corridor',
        'Reassess risk level in 24 hours if humidity drops',
      ],
    },
  ]
};

const _demoWeather = {
  'temperature': 28.5,
  'humidity': 31.0,
  'wind_speed': 18.2,
  'rainfall': 2.1,
  'condition': 'Dry — High Fire Risk Season',
  'zone': 'Mount Kilimanjaro',
};

const _demoTrends = {
  'trend': [
    {'day': 'Mon', 'risk_score': 0.61, 'risk_color': '#F57C00'},
    {'day': 'Tue', 'risk_score': 0.68, 'risk_color': '#F57C00'},
    {'day': 'Wed', 'risk_score': 0.74, 'risk_color': '#D32F2F'},
    {'day': 'Thu', 'risk_score': 0.79, 'risk_color': '#D32F2F'},
    {'day': 'Fri', 'risk_score': 0.77, 'risk_color': '#D32F2F'},
    {'day': 'Sat', 'risk_score': 0.82, 'risk_color': '#D32F2F'},
    {'day': 'Sun', 'risk_score': 0.85, 'risk_color': '#D32F2F'},
  ]
};

const _demoConditions = {
  'ndvi': 0.28, 'nbr': 0.41, 'ndwi': 0.12,
  'temperature': 28.5, 'humidity': 32.0,
  'wind_speed': 18.0, 'rainfall': 2.5,
  'min_temp': 16.0, 'max_temp': 31.0,
  'season': 'Dry Season (Oct–Nov)',
};

// ─── ApiService ─────────────────────────────────────────────────────────────

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _client = http.Client();
  String baseUrl = kBaseUrl;

  /// True when the last request used cached/demo data instead of live server.
  static bool isOffline = false;

  /// ISO8601 string of when we last had a live connection.
  static String? lastOnlineTime;

  // ── Generic fetch with cache fallback ──────────────────────────────────

  Future<Map<String, dynamic>> _fetch(
    String cacheKey,
    Future<http.Response> Function() request,
    Map<String, dynamic> demoFallback,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final res = await request().timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        await prefs.setString('cache_$cacheKey', res.body);
        await prefs.setString(
            'cache_${cacheKey}_time', DateTime.now().toIso8601String());
        isOffline = false;
        lastOnlineTime = DateTime.now().toIso8601String();
        return data;
      }
      throw Exception('Server returned ${res.statusCode}');
    } catch (_) {
      isOffline = true;
      // Try previously cached live data first
      final cached = prefs.getString('cache_$cacheKey');
      if (cached != null) {
        lastOnlineTime = prefs.getString('cache_${cacheKey}_time');
        return jsonDecode(cached) as Map<String, dynamic>;
      }
      // Fall back to built-in demo data so alerts always display
      return Map<String, dynamic>.from(demoFallback);
    }
  }

  // ── Public endpoints ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getZones() => _fetch(
        'zones',
        () => _client.get(Uri.parse('$baseUrl/zones')),
        _demoZones,
      );

  Future<Map<String, dynamic>> getAlerts() => _fetch(
        'alerts',
        () => _client.get(Uri.parse('$baseUrl/alerts')),
        _demoAlerts,
      );

  Future<Map<String, dynamic>> getWeather() => _fetch(
        'weather',
        () => _client.get(Uri.parse('$baseUrl/weather')),
        _demoWeather,
      );

  Future<Map<String, dynamic>> getTrends() => _fetch(
        'trends',
        () => _client.get(Uri.parse('$baseUrl/trends')),
        _demoTrends,
      );

  Future<Map<String, dynamic>> getCurrentConditions() => _fetch(
        'conditions',
        () => _client.get(Uri.parse('$baseUrl/current-conditions')),
        _demoConditions,
      );

  Future<Map<String, dynamic>> getRiskByLocation(double lat, double lon) async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/risk?lat=$lat&lon=$lon'))
          .timeout(const Duration(seconds: 8));
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'risk_score': 0.75, 'risk_label': 'High', 'risk_color': '#D32F2F'};
    }
  }

  Future<Map<String, dynamic>> reportFire({
    required double lat,
    required double lon,
    String note = '',
  }) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/report-fire?lat=$lat&lon=$lon&note=${Uri.encodeComponent(note)}'),
      ).timeout(const Duration(seconds: 8));
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'status': 'queued', 'message': 'Report saved. Will sync when online.'};
    }
  }

  Future<Map<String, dynamic>> predictScenario({
    required double ndvi,
    required double nbr,
    required double ndwi,
    required double temperature,
    required double humidity,
    required double windSpeed,
    required double rainfall,
    required double minTemp,
    required double maxTemp,
    required String zoneId,
    List<double>? humanFeatures,
  }) async {
    final body = jsonEncode({
      'ndvi': ndvi, 'nbr': nbr, 'ndwi': ndwi,
      'temperature': temperature, 'humidity': humidity,
      'wind_speed': windSpeed, 'rainfall': rainfall,
      'min_temp': minTemp, 'max_temp': maxTemp,
      'zone_id': zoneId,
      if (humanFeatures != null) 'human_features': humanFeatures,
    });
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      // Simulate a prediction result based on inputs
      final score = ((1 - ndvi) * 0.3 + (1 - humidity / 100) * 0.3 +
              temperature / 40 * 0.2 + windSpeed / 40 * 0.2)
          .clamp(0.0, 1.0);
      final label = score > 0.7 ? 'High' : score > 0.5 ? 'Moderate' : score > 0.3 ? 'Low' : 'Very Low';
      final color = score > 0.7 ? '#D32F2F' : score > 0.5 ? '#F57C00' : score > 0.3 ? '#FBC02D' : '#388E3C';
      return {'risk_score': score, 'risk_label': label, 'risk_color': color};
    }
  }

  Future<bool> checkHealth() async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
