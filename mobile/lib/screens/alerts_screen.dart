import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final _api = ApiService();
  List<dynamic> _alerts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _api.getAlerts();
    setState(() {
      _alerts = data['alerts'] ?? [];
      _loading = false;
    });
  }

  Color _hexToColor(String hex) =>
      Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Fire Alerts'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _alerts.isEmpty
                  ? const _NoAlerts()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      itemCount: _alerts.length + 1,
                      itemBuilder: (ctx, i) {
                        if (i == 0) {
                          return _AlertSummaryBanner(count: _alerts.length);
                        }
                        return _AlertCard(
                          alert: _alerts[i - 1],
                          hexToColor: _hexToColor,
                        );
                      },
                    ),
            ),
    );
  }
}

// ── Summary banner ───────────────────────────────────────────────────────────

class _AlertSummaryBanner extends StatelessWidget {
  final int count;
  const _AlertSummaryBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE53935).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE53935),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count Active Alert${count == 1 ? '' : 's'} — Mount Kilimanjaro',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFFB71C1C)),
                ),
                const Text(
                  'Tap any alert to see full prediction details.',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _NoAlerts extends StatelessWidget {
  const _NoAlerts();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 72, color: Color(0xFF4CAF50)),
          SizedBox(height: 16),
          Text('No Active Alerts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Fire risk is currently low in all monitored zones.',
              style: TextStyle(color: Colors.black45)),
        ],
      ),
    );
  }
}

// ── Alert card ───────────────────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;
  final Color Function(String) hexToColor;
  const _AlertCard({required this.alert, required this.hexToColor});

  void _showDetails(BuildContext context, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AlertDetailSheet(alert: alert, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = hexToColor(alert['risk_color'] ?? '#E53935');
    final isHigh = (alert['risk_label'] ?? '') == 'High';

    return GestureDetector(
      onTap: () => _showDetails(context, color),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.35), width: 1.5),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.06),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                    child: Icon(
                      isHigh
                          ? Icons.local_fire_department
                          : Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${alert['risk_label']} Fire Risk',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: color),
                        ),
                        Text(
                          '📍 ${alert['zone'] ?? ''}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          alert['risk_label'] ?? '',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (alert['time'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          alert['time'],
                          style: const TextStyle(
                              fontSize: 10, color: Colors.black38),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Short preview
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Text(
                alert['message'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, color: Colors.black54, height: 1.5),
              ),
            ),

            // When prediction row
            if (alert['predicted_window'] != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 13, color: Color(0xFFE53935)),
                    const SizedBox(width: 4),
                    Text(
                      'When: ${alert['predicted_window']}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFE53935),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

            // Tap for details hint + action row
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _showDetails(context, color),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Full Details',
                        style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(foregroundColor: color),
                  ),
                  const Spacer(),
                  if (isHigh)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.flash_on,
                              size: 12, color: Color(0xFFE53935)),
                          SizedBox(width: 4),
                          Text('Act Now',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFE53935),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Full detail bottom sheet ──────────────────────────────────────────────────

class _AlertDetailSheet extends StatelessWidget {
  final Map<String, dynamic> alert;
  final Color color;
  const _AlertDetailSheet({required this.alert, required this.color});

  void _copyAlert(BuildContext context) {
    final zone = alert['zone'] ?? '';
    final label = alert['risk_label'] ?? '';
    final message = alert['message'] ?? '';
    final window = alert['predicted_window'] ?? '';
    final actions = (alert['recommended_actions'] as List?)?.join('\n• ') ?? '';
    final text =
        '🔥 FirePredict Alert — $label Risk\n'
        '📍 Where: $zone\n'
        '⏰ When: $window\n\n'
        '$message\n\n'
        'Recommended Actions:\n• $actions\n\n'
        '— FirePredict Early Warning System\n'
        '   Mount Kilimanjaro, Tanzania\n'
        '   SmartEarth Solutions';
    Clipboard.setData(ClipboardData(text: text));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Alert copied! Paste in WhatsApp or SMS to share.'),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions =
        (alert['recommended_actions'] as List?)?.cast<String>() ?? [];
    final drivers =
        (alert['risk_drivers'] as List?)?.cast<String>() ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Risk badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                  child: const Icon(Icons.local_fire_department,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${alert['risk_label']} Fire Risk Alert',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: color),
                    ),
                    Text(
                      'Generated by FirePredict ConvLSTM Model',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.black45),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // WHERE & WHEN section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _detailRow(
                    icon: Icons.location_on,
                    color: color,
                    label: 'WHERE',
                    value: alert['zone'] ?? '',
                  ),
                  const Divider(height: 20),
                  _detailRow(
                    icon: Icons.access_time,
                    color: color,
                    label: 'WHEN (Predicted)',
                    value: alert['predicted_window'] ??
                        'Elevated risk in next 72 hours',
                  ),
                  if (alert['peak_time'] != null) ...[
                    const Divider(height: 20),
                    _detailRow(
                      icon: Icons.warning_amber_rounded,
                      color: color,
                      label: 'PEAK RISK WINDOW',
                      value: alert['peak_time'],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Full message
            const Text('Alert Details',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              alert['message'] ?? '',
              style: const TextStyle(
                  fontSize: 13, color: Colors.black87, height: 1.65),
            ),
            const SizedBox(height: 16),

            // Risk drivers
            if (drivers.isNotEmpty) ...[
              const Text('Risk Drivers Detected',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              ...drivers.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.circle, size: 8, color: color),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(d,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black87)),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
            ],

            // Recommended actions
            if (actions.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield, color: Color(0xFF2E7D32), size: 18),
                        SizedBox(width: 8),
                        Text('Recommended Actions',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF2E7D32))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...actions.map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle,
                                  size: 15, color: Color(0xFF4CAF50)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(a,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF2E7D32))),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Close'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black54,
                      side: const BorderSide(color: Colors.black26),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _copyAlert(context),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy & Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
