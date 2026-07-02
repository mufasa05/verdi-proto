import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SatellitesPage extends StatefulWidget {
  const SatellitesPage({super.key});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);

  @override
  State<SatellitesPage> createState() => _SatellitesPageState();
}

class _SatellitesPageState extends State<SatellitesPage> {
  bool loading = false;
  DateTime updatedAt = DateTime.now();

  final fields = const [
    _SatelliteField(name: 'Mvurwi North', ndvi: 0.82, evi: 0.71, cloud: 12, freshnessHours: 6, anomaly: 'Low'),
    _SatelliteField(name: 'Odzi Block', ndvi: 0.51, evi: 0.46, cloud: 18, freshnessHours: 10, anomaly: 'Medium'),
    _SatelliteField(name: 'Gutu Plot', ndvi: 0.68, evi: 0.61, cloud: 7, freshnessHours: 4, anomaly: 'Low'),
    _SatelliteField(name: 'Chiredzi Unit', ndvi: 0.91, evi: 0.84, cloud: 5, freshnessHours: 2, anomaly: 'None'),
  ];

  Future<void> _refresh() async {
    setState(() => loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() {
      updatedAt = DateTime.now();
      loading = false;
    });
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(minutes: 5), (_) {
      if (mounted) setState(() => updatedAt = DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final avgNdvi = fields.fold<double>(0, (sum, f) => sum + f.ndvi) / fields.length;
    final avgEvi = fields.fold<double>(0, (sum, f) => sum + f.evi) / fields.length;
    final avgCloud = fields.fold<int>(0, (sum, f) => sum + f.cloud) ~/ fields.length;
    final freshScenes = fields.where((f) => f.freshnessHours <= 6).length;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Satellite Monitoring', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: SatellitesPage.dark)),
                    const SizedBox(height: 6),
                    Text('Live vegetation indices, cloud cover, and scan freshness.', style: GoogleFonts.inter(color: SatellitesPage.muted)),
                  ],
                ),
              ),
              IconButton(
                onPressed: _refresh,
                icon: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Updated ${_timeAgo(updatedAt)}', style: const TextStyle(color: SatellitesPage.muted, fontSize: 12)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(label: 'Avg NDVI', value: avgNdvi.toStringAsFixed(2), icon: Icons.area_chart_outlined),
              _StatCard(label: 'Avg EVI', value: avgEvi.toStringAsFixed(2), icon: Icons.auto_graph_outlined),
              _StatCard(label: 'Cloud Cover', value: '$avgCloud%', icon: Icons.cloud_outlined),
              _StatCard(label: 'Fresh Scenes', value: '$freshScenes', icon: Icons.timelapse_outlined),
            ],
          ),
          const SizedBox(height: 16),
          Text('Field Scenes', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: SatellitesPage.dark)),
          const SizedBox(height: 10),
          ...fields.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FieldCard(field: f),
          )),
          const SizedBox(height: 8),
          Text('Live Interactions', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: SatellitesPage.dark)),
          const SizedBox(height: 10),
          _ActionCard(title: 'Refresh scene', detail: 'Pull the latest vegetation tile and cloud mask.', icon: Icons.refresh_outlined),
          const SizedBox(height: 12),
          _ActionCard(title: 'Compare last 7 days', detail: 'Check NDVI trend changes against the previous scan.', icon: Icons.timeline_outlined),
          const SizedBox(height: 12),
          _ActionCard(title: 'Open anomaly map', detail: 'Highlight fields with a medium or high anomaly score.', icon: Icons.map_outlined),
        ],
      ),
    );
  }
}

class _SatelliteField {
  final String name;
  final double ndvi;
  final double evi;
  final int cloud;
  final int freshnessHours;
  final String anomaly;

  const _SatelliteField({
    required this.name,
    required this.ndvi,
    required this.evi,
    required this.cloud,
    required this.freshnessHours,
    required this.anomaly,
  });

  double get healthIndex => (ndvi * 0.65 + evi * 0.35).clamp(0.0, 1.0);
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    width: 170,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black12)),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: SatellitesPage.green.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: SatellitesPage.green)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: SatellitesPage.muted, fontSize: 13)), const SizedBox(height: 4), Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: SatellitesPage.dark))])),
    ]),
  );
}

class _FieldCard extends StatelessWidget {
  final _SatelliteField field;
  const _FieldCard({required this.field});

  Color _color() {
    if (field.anomaly == 'None') return SatellitesPage.green;
    if (field.anomaly == 'Low') return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    final healthPct = (field.healthIndex * 100).round();
    final ndviPct = (field.ndvi * 100).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(field.name, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: SatellitesPage.dark))),
            Text(field.anomaly, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Text('Health $healthPct%', style: const TextStyle(color: SatellitesPage.muted, fontSize: 12)),
            const Spacer(),
            Text('Freshness ${field.freshnessHours}h', style: const TextStyle(color: SatellitesPage.muted, fontSize: 12)),
          ]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: field.healthIndex, minHeight: 8, backgroundColor: Colors.grey.shade200, color: color),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _MiniStat(label: 'NDVI', value: '$ndviPct%')),
            const SizedBox(width: 10),
            Expanded(child: _MiniStat(label: 'EVI', value: '${(field.evi * 100).round()}%')),
            const SizedBox(width: 10),
            Expanded(child: _MiniStat(label: 'Cloud', value: '${field.cloud}%')),
          ]),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, color: SatellitesPage.muted)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: SatellitesPage.dark)),
    ]),
  );
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String detail;
  final IconData icon;
  const _ActionCard({required this.title, required this.detail, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black12)),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: SatellitesPage.green.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: SatellitesPage.green)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: SatellitesPage.dark)),
        const SizedBox(height: 4),
        Text(detail, style: const TextStyle(color: SatellitesPage.muted)),
      ])),
    ]),
  );
}