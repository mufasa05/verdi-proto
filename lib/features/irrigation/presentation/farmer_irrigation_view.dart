import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FarmerIrrigationView extends StatelessWidget {
  const FarmerIrrigationView({super.key});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final fields = [
      _Field(name: 'Field 1', crop: 'Maize', soilMoisture: 0.76, lastIrrigated: '2h ago', pumpStatus: 'Running', valvesOpen: 2, waterUsed: 3.2),
      _Field(name: 'Field 2', crop: 'Tomatoes', soilMoisture: 0.42, lastIrrigated: '10h ago', pumpStatus: 'Idle', valvesOpen: 0, waterUsed: 1.1),
      _Field(name: 'Field 3', crop: 'Vegetables', soilMoisture: 0.58, lastIrrigated: '5h ago', pumpStatus: 'Running', valvesOpen: 1, waterUsed: 2.3),
    ];

    final avgMoisture = fields.fold<double>(0, (sum, f) => sum + f.soilMoisture) / fields.length;
    final activePumps = fields.where((f) => f.pumpStatus == 'Running').length;
    final openValves = fields.fold<int>(0, (sum, f) => sum + f.valvesOpen);
    final waterUsed = fields.fold<double>(0, (sum, f) => sum + f.waterUsed);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Farmer E-Irrigation',
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: dark),
          ),
          const SizedBox(height: 6),
          Text(
            'Monitor field moisture, pump activity, and irrigation timing.',
            style: GoogleFonts.inter(color: muted),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(label: 'Avg Moisture', value: '${(avgMoisture * 100).round()}%', icon: Icons.water_drop_outlined),
              _StatCard(label: 'Active Pumps', value: '$activePumps', icon: Icons.play_circle_outline),
              _StatCard(label: 'Open Valves', value: '$openValves', icon: Icons.water_drop_outlined),
              _StatCard(label: 'Water Used', value: '${waterUsed.toStringAsFixed(1)} m3', icon: Icons.opacity_outlined),
            ],
          ),
          const SizedBox(height: 16),
          ...fields.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FieldCard(field: f),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field {
  final String name;
  final String crop;
  final double soilMoisture;
  final String lastIrrigated;
  final String pumpStatus;
  final int valvesOpen;
  final double waterUsed;

  const _Field({
    required this.name,
    required this.crop,
    required this.soilMoisture,
    required this.lastIrrigated,
    required this.pumpStatus,
    required this.valvesOpen,
    required this.waterUsed,
  });

  double get targetGap => (0.65 - soilMoisture).clamp(0.0, 1.0);
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
              color: FarmerIrrigationView.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: FarmerIrrigationView.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: FarmerIrrigationView.muted, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: FarmerIrrigationView.dark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  final _Field field;

  const _FieldCard({required this.field});

  @override
  Widget build(BuildContext context) {
    final moisturePct = (field.soilMoisture * 100).round();
    final needIrrigation = field.soilMoisture < 0.5;
    final statusColor = needIrrigation ? Colors.orange : FarmerIrrigationView.green;

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
                  '${field.name} • ${field.crop}',
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: FarmerIrrigationView.dark),
                ),
              ),
              Text(
                field.lastIrrigated,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Soil Moisture',
                style: const TextStyle(color: FarmerIrrigationView.muted, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '$moisturePct%',
                style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: field.soilMoisture,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            color: statusColor,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _MiniStat(label: 'Pump', value: field.pumpStatus)),
              const SizedBox(width: 10),
              Expanded(child: _MiniStat(label: 'Valves', value: '${field.valvesOpen} open')),
              const SizedBox(width: 10),
              Expanded(child: _MiniStat(label: 'Water', value: '${field.waterUsed.toStringAsFixed(1)} m3')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: Text(needIrrigation ? 'Schedule' : 'View'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FarmerIrrigationView.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Control'),
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
          Text(label, style: const TextStyle(fontSize: 11, color: FarmerIrrigationView.muted)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: FarmerIrrigationView.dark)),
        ],
      ),
    );
  }
}