import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GovernmentIrrigationView extends StatelessWidget {
  const GovernmentIrrigationView({super.key});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final schemes = [
      _Scheme(
        name: 'Mvurwi Scheme',
        crop: 'Maize',
        waterAllocated: 120.0,
        waterUsed: 103.2,
        uptime: 0.96,
        blockedValves: 1,
        alerts: 2,
      ),
      _Scheme(
        name: 'Odzi Scheme',
        crop: 'Tomatoes',
        waterAllocated: 90.0,
        waterUsed: 61.8,
        uptime: 0.88,
        blockedValves: 2,
        alerts: 4,
      ),
      _Scheme(
        name: 'Gutu Cluster',
        crop: 'Onions',
        waterAllocated: 75.0,
        waterUsed: 55.5,
        uptime: 0.92,
        blockedValves: 0,
        alerts: 1,
      ),
      _Scheme(
        name: 'Chiredzi Block',
        crop: 'Mango',
        waterAllocated: 150.0,
        waterUsed: 132.0,
        uptime: 0.99,
        blockedValves: 0,
        alerts: 0,
      ),
    ];

    final totalAllocated = schemes.fold<double>(
      0,
      (sum, s) => sum + s.waterAllocated,
    );
    final totalUsed = schemes.fold<double>(0, (sum, s) => sum + s.waterUsed);
    final avgUptime =
        schemes.fold<double>(0, (sum, s) => sum + s.uptime) / schemes.length;
    final totalAlerts = schemes.fold<int>(0, (sum, s) => sum + s.alerts);
    final totalBlocked = schemes.fold<int>(
      0,
      (sum, s) => sum + s.blockedValves,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Government Irrigation',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: dark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Track scheme efficiency, allocation, uptime, and blockages.',
            style: GoogleFonts.inter(color: muted),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(
                label: 'Water Allocated',
                value: '${totalAllocated.toStringAsFixed(0)} m3',
                icon: Icons.water_drop_outlined,
              ),
              _StatCard(
                label: 'Water Used',
                value: '${totalUsed.toStringAsFixed(1)} m3',
                icon: Icons.opacity_outlined,
              ),
              _StatCard(
                label: 'Avg Uptime',
                value: '${(avgUptime * 100).round()}%',
                icon: Icons.schedule_outlined,
              ),
              _StatCard(
                label: 'Alerts',
                value: '$totalAlerts',
                icon: Icons.warning_amber_outlined,
              ),
              _StatCard(
                label: 'Blocked Valves',
                value: '$totalBlocked',
                icon: Icons.block_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...schemes.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SchemeCard(scheme: s),
            ),
          ),
        ],
      ),
    );
  }
}

class _Scheme {
  final String name;
  final String crop;
  final double waterAllocated;
  final double waterUsed;
  final double uptime;
  final int blockedValves;
  final int alerts;

  const _Scheme({
    required this.name,
    required this.crop,
    required this.waterAllocated,
    required this.waterUsed,
    required this.uptime,
    required this.blockedValves,
    required this.alerts,
  });

  double get utilization =>
      waterAllocated == 0 ? 0 : (waterUsed / waterAllocated).clamp(0.0, 1.0);
  double get efficiency =>
      (uptime - (blockedValves * 0.04) - (alerts * 0.03)).clamp(0.0, 1.0);
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
              color: GovernmentIrrigationView.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: GovernmentIrrigationView.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: GovernmentIrrigationView.muted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: GovernmentIrrigationView.dark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  final _Scheme scheme;

  const _SchemeCard({required this.scheme});

  @override
  Widget build(BuildContext context) {
    final utilizationPct = (scheme.utilization * 100).round();
    final efficiencyPct = (scheme.efficiency * 100).round();

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
                  scheme.name,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: GovernmentIrrigationView.dark,
                  ),
                ),
              ),
              Text(
                scheme.crop,
                style: const TextStyle(color: GovernmentIrrigationView.muted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _MetricRow(
            label: 'Water Use',
            value:
                '${scheme.waterUsed.toStringAsFixed(1)} / ${scheme.waterAllocated.toStringAsFixed(0)} m3',
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: scheme.utilization,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            color: GovernmentIrrigationView.green,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Utilization $utilizationPct%',
                style: const TextStyle(
                  fontSize: 12,
                  color: GovernmentIrrigationView.muted,
                ),
              ),
              const Spacer(),
              Text(
                'Efficiency $efficiencyPct%',
                style: const TextStyle(
                  fontSize: 12,
                  color: GovernmentIrrigationView.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Uptime',
                  value: '${(scheme.uptime * 100).round()}%',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Blocked',
                  value: '${scheme.blockedValves}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(label: 'Alerts', value: '${scheme.alerts}'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetricRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: GovernmentIrrigationView.muted,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: GovernmentIrrigationView.dark,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: GovernmentIrrigationView.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: GovernmentIrrigationView.dark,
            ),
          ),
        ],
      ),
    );
  }
}
