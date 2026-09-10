import 'package:flutter/material.dart';

class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildStatsGrid(),
            const SizedBox(height: 20),
            _buildStoryCard(),
            const SizedBox(height: 16),
            _buildDataSourcesCard(),
            const SizedBox(height: 16),
            _buildModelCard(),
            const SizedBox(height: 16),
            _buildTagline(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7F0000), Color(0xFFB71C1C), Color(0xFFE53935)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_fire_department,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FirePredict',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                  Text('by SmartEarth Solutions',
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Turning early warning\ninto early action.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'AI-powered forest fire prediction for\nMount Kilimanjaro, Tanzania.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalistBadge() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D1B5E), Color(0xFF1A3A8C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF0D1B5E).withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Text('🏆', style: TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('UNFCCC Technology Mechanism',
                      style: TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3)),
                  SizedBox(height: 2),
                  Text('AI for Climate Action Award 2026',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      _BadgeChip(label: 'Top 5 Global Finalist', color: Colors.amber),
                      SizedBox(width: 6),
                      _BadgeChip(label: '🇹🇿 Tanzania', color: Colors.green),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.verified, color: Colors.amber, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    const stats = [
      _Stat(value: '98%', label: 'AI Prediction\nAccuracy', icon: Icons.analytics, color: Color(0xFFE53935)),
      _Stat(value: '7', label: 'Kilimanjaro Zones\nMonitored', icon: Icons.map_outlined, color: Color(0xFF1E88E5)),
      _Stat(value: '4', label: 'Integrated\nData Sources', icon: Icons.hub, color: Color(0xFF43A047)),
      _Stat(value: '3+', label: 'Years of\nTraining Data', icon: Icons.history, color: Color(0xFFF57C00)),
      _Stat(value: '24/7', label: 'Real-Time\nMonitoring', icon: Icons.access_time, color: Color(0xFF8E24AA)),
      _Stat(value: 'Open', label: 'Source Risk\nMapping Tools', icon: Icons.code, color: Color(0xFF00897B)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('Impact at a Glance',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: stats.map((s) => _StatCard(stat: s)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.format_quote, color: Color(0xFFE53935), size: 26),
                SizedBox(width: 8),
                Text('The Story Behind FirePredict',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: const Text(
                '"On October 21, 2022, I watched a small line of fire on '
                'Mount Kilimanjaro grow into a wall of fire within hours. '
                'Animals were running in fear. People were struggling to stop it. '
                'And one thought hit me: we were not ready."',
                style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5D1A1A),
                    height: 1.65,
                    fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Color(0xFFE53935), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dr. Cesilia Mambile',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Researcher, University of Dodoma',
                          style: TextStyle(fontSize: 11, color: Colors.black45)),
                      Text('Founder, SmartEarth Solutions — Tanzania',
                          style: TextStyle(fontSize: 11, color: Colors.black45)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSourcesCard() {
    const sources = [
      _Source(icon: Icons.satellite_alt, color: Color(0xFF1E88E5),
          label: 'Satellite Images', sub: 'Sentinel-2 — NDVI, NBR, NDWI indices'),
      _Source(icon: Icons.cloud, color: Color(0xFF00897B),
          label: 'Weather Data', sub: 'Tanzania Meteorological Authority (TMA)'),
      _Source(icon: Icons.people, color: Color(0xFFF57C00),
          label: 'Human Activity', sub: 'Tourism, beekeeping, agricultural burning'),
      _Source(icon: Icons.history_edu, color: Color(0xFF8E24AA),
          label: 'Historical Fire Records', sub: 'Past fire occurrences 2015–2025'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.hub, color: Color(0xFFE53935), size: 20),
                SizedBox(width: 8),
                Text('How FirePredict Works',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              '4 data sources  →  ConvLSTM deep learning model  →  Early warning alert',
              style: TextStyle(fontSize: 11, color: Colors.black45),
            ),
            const SizedBox(height: 16),
            ...sources.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: s.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(s.icon, color: s.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.label,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(s.sub,
                          style: const TextStyle(fontSize: 11, color: Colors.black45)),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildModelCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCE93D8).withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology, color: Color(0xFF8E24AA), size: 22),
                SizedBox(width: 8),
                Text('The AI Model', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF6A1B9A))),
              ],
            ),
            const SizedBox(height: 10),
            _modelRow('Model', 'ConvLSTM (Convolutional LSTM)'),
            _modelRow('Accuracy', '98% prediction accuracy'),
            _modelRow('Validated', 'With rangers, experts & community leaders'),
            _modelRow('Training data', '2015–2025 fire records'),
            _modelRow('Dry season peak', 'Risk up to 0.90 (Sept–Nov)'),
            _modelRow('Spatial coverage', 'All Kilimanjaro slopes & corridors'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF8E24AA).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '🔓 Fire-risk mapping tools are open source',
                style: TextStyle(fontSize: 12, color: Color(0xFF6A1B9A), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modelRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 12, color: Color(0xFF4A148C), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildTagline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF1B5E20).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.forest, color: Colors.white, size: 38),
            const SizedBox(height: 10),
            const Text(
              'Protecting forests, wildlife,\nhomes, and lives before it is too late.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.45),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TagChip(label: '🌍 Tanzania'),
                const SizedBox(width: 8),
                _TagChip(label: '🛰️ AI + Satellite'),
                const SizedBox(width: 8),
                _TagChip(label: '🌿 Open Source'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Supporting data classes ───────────────────────────────────────────────

class _Stat {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _Stat({required this.value, required this.label, required this.icon, required this.color});
}

class _Source {
  final IconData icon;
  final Color color;
  final String label;
  final String sub;
  const _Source({required this.icon, required this.color, required this.label, required this.sub});
}

// ─── Small widgets ──────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final _Stat stat;
  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: stat.color.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: stat.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat.icon, color: stat.color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(stat.value,
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: stat.color,
                        height: 1.1)),
                Text(stat.label,
                    style: const TextStyle(fontSize: 10, color: Colors.black54, height: 1.25)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final Color color;
  const _BadgeChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
    );
  }
}
