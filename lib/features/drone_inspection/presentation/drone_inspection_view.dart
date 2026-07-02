import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DroneInspectionView extends StatelessWidget {
  const DroneInspectionView({super.key});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final missions = [
      _Mission(title: 'Mvurwi Scheme Survey', status: 'Completed', ndvi: 0.82, hotspots: 2, anomalyScore: 0.18, coverage: 0.94),
      _Mission(title: 'Field 2 Moisture Scan', status: 'In Flight', ndvi: 0.51, hotspots: 5, anomalyScore: 0.44, coverage: 0.67),
      _Mission(title: 'Odzi Canal Check', status: 'Issues', ndvi: 0.44, hotspots: 7, anomalyScore: 0.69, coverage: 0.53),
    ];

    final avgNdvi = missions.fold<double>(0, (sum, m) => sum + m.ndvi) / missions.length;
    final totalHotspots = missions.fold<int>(0, (sum, m) => sum + m.hotspots);
    final completedFlights = missions.where((m) => m.status == 'Completed').length;
    final activeFlights = missions.where((m) => m.status == 'In Flight').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Drone Inspection',
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: dark),
          ),
          const SizedBox(height: 6),
          Text(
            'Review crop health, anomalies, and mission status.',
            style: GoogleFonts.inter(color: muted),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(label: 'Avg NDVI', value: avgNdvi.toStringAsFixed(2), icon: Icons.area_chart_outlined),
              _StatCard(label: 'Hotspots', value: '$totalHotspots', icon: Icons.warning_amber_outlined),
              _StatCard(label: 'Completed', value: '$completedFlights', icon: Icons.verified_outlined),
              _StatCard(label: 'Active', value: '$activeFlights', icon: Icons.flight_outlined),
            ],
          ),
          const SizedBox(height: 16),
          ...missions.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MissionCard(mission: m),
            ),
          ),
        ],
      ),
    );
  }
}

class _Mission {
  final String title;
  final String status;
  final double ndvi;
  final int hotspots;
  final double anomalyScore;
  final double coverage;

  const _Mission({
    required this.title,
    required this.status,
    required this.ndvi,
    required this.hotspots,
    required this.anomalyScore,
    required this.coverage,
  });

  double get healthIndex => (ndvi * 0.7 + (1 - anomalyScore) * 0.3).clamp(0.0, 1.0);
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DroneInspectionView.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: DroneInspectionView.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: DroneInspectionView.muted, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: DroneInspectionView.dark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final _Mission mission;

  const _MissionCard({required this.mission});

  Color _color() {
    return mission.status == 'Completed'
        ? DroneInspectionView.green
        : mission.status == 'In Flight'
            ? Colors.blue
            : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    final healthPct = (mission.healthIndex * 100).round();
    final ndviPct = (mission.ndvi * 100).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  mission.title,
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: DroneInspectionView.dark),
                ),
              ),
              Text(
                mission.status,
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Coverage ${(mission.coverage * 100).round()}%', style: const TextStyle(color: DroneInspectionView.muted, fontSize: 12)),
              const Spacer(),
              Text('Health $healthPct%', style: const TextStyle(color: DroneInspectionView.muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: mission.coverage,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            color: color,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _MiniStat(label: 'NDVI', value: '$ndviPct%')),
              const SizedBox(width: 10),
              Expanded(child: _MiniStat(label: 'Hotspots', value: '${mission.hotspots}')),
              const SizedBox(width: 10),
              Expanded(child: _MiniStat(label: 'Anomaly', value: '${(mission.anomalyScore * 100).round()}%')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Analyze'))),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DroneInspectionView.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Dispatch'),
                ),
              ),
            ],
          ),
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: DroneInspectionView.muted)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: DroneInspectionView.dark)),
        ],
      ),
    );
  }
}