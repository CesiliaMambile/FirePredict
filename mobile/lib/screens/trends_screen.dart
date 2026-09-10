import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  final _api = ApiService();
  List<dynamic> _trend = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _api.getTrends();
      setState(() { _trend = data['trend'] ?? []; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('7-Day Fire Risk Trend')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildChart(),
                  const SizedBox(height: 20),
                  ..._trend.map((d) => _TrendRow(day: d)).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildChart() {
    final spots = _trend.asMap().entries.map((e) {
      final score = (e.value['risk_score'] as num).toDouble();
      return FlSpot(e.key.toDouble(), score);
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 1,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.25,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Color(0xFFFFCDD2), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 0.25,
                getTitlesWidget: (v, _) => Text(
                  '${(v * 100).toInt()}%',
                  style: const TextStyle(fontSize: 9, color: Colors.black38),
                ),
                reservedSize: 36,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= _trend.length) return const SizedBox();
                  return Text(
                    _trend[i]['day'] ?? '',
                    style: const TextStyle(fontSize: 10, color: Colors.black45),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFFE53935),
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFE53935).withOpacity(0.12),
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFFE53935),
                  strokeColor: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        '${(s.y * 100).toInt()}%',
                        const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendRow extends StatelessWidget {
  final Map<String, dynamic> day;
  const _TrendRow({required this.day});

  Color _hexToColor(String hex) =>
      Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(day['risk_color'] ?? '#388E3C');
    final score = ((day['risk_score'] as num) * 100).toInt();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: Text(day['day'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (day['risk_score'] as num).toDouble(),
                backgroundColor: Colors.grey[200],
                color: color,
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(10)),
            child: Text('$score%',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
