import 'package:flutter/material.dart';

class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fire Safety Tips')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SectionHeader(title: 'If You See Fire'),
          _SafetyTile(
            icon: Icons.phone,
            color: Color(0xFFE53935),
            title: 'Call Emergency Services',
            body: 'Call Tanzania Fire and Rescue Force: 115 or 199. Report fire location as precisely as possible.',
          ),
          _SafetyTile(
            icon: Icons.directions_run,
            color: Color(0xFFE53935),
            title: 'Evacuate Immediately',
            body: 'Do not attempt to fight a large fire. Move upwind and uphill away from the fire.',
          ),
          _SafetyTile(
            icon: Icons.camera_alt,
            color: Color(0xFFE53935),
            title: 'Document and Report',
            body: 'Use the "Document Fire" tab to report fire location with a photo. This helps rangers respond faster.',
          ),
          _SectionHeader(title: 'Prevention'),
          _SafetyTile(
            icon: Icons.no_meals,
            color: Color(0xFFF57C00),
            title: 'No Open Fires in Dry Season',
            body: 'Avoid lighting fires Aug–Nov. This is peak dry season and fire spreads rapidly.',
          ),
          _SafetyTile(
            icon: Icons.smoking_rooms,
            color: Color(0xFFF57C00),
            title: 'Extinguish Completely',
            body: 'Ensure campfires and agricultural burn piles are fully extinguished before leaving.',
          ),
          _SafetyTile(
            icon: Icons.agriculture,
            color: Color(0xFFF57C00),
            title: 'Coordinate Crop Burning',
            body: 'Always notify park rangers and local authorities before controlled burns near forest boundaries.',
          ),
          _SectionHeader(title: 'For Rangers & Officers'),
          _SafetyTile(
            icon: Icons.map,
            color: Color(0xFF1E88E5),
            title: 'Use the Risk Map',
            body: 'Check FirePredict risk map daily during dry season. High-risk zones need patrol priority.',
          ),
          _SafetyTile(
            icon: Icons.group,
            color: Color(0xFF1E88E5),
            title: 'Community Awareness',
            body: 'Share fire risk alerts with beekeepers and tourism operators in high-risk zones.',
          ),
          _SafetyTile(
            icon: Icons.water,
            color: Color(0xFF1E88E5),
            title: 'Firebreaks',
            body: 'Maintain cleared firebreak lines along forest edges before the dry season begins.',
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black45,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SafetyTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _SafetyTile(
      {required this.icon,
      required this.color,
      required this.title,
      required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(body,
              style: const TextStyle(
                  fontSize: 13, color: Colors.black54, height: 1.4)),
        ),
      ),
    );
  }
}
