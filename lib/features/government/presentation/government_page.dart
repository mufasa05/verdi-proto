import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GovernmentPage extends StatefulWidget {
  const GovernmentPage({super.key});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);

  @override
  State<GovernmentPage> createState() => _GovernmentPageState();
}

class _GovernmentPageState extends State<GovernmentPage> {
  bool loading = false;
  DateTime updatedAt = DateTime.now();

  final districts = const [
    _District(name: 'Mashonaland Central', allocationPct: 92, compliancePct: 88, activeAlerts: 1, status: 'Stable'),
    _District(name: 'Manicaland', allocationPct: 79, compliancePct: 73, activeAlerts: 3, status: 'Watch'),
    _District(name: 'Masvingo', allocationPct: 86, compliancePct: 81, activeAlerts: 2, status: 'Stable'),
    _District(name: 'Matabeleland South', allocationPct: 68, compliancePct: 59, activeAlerts: 5, status: 'Alert'),
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
  Widget build(BuildContext context) {
    final avgAllocation = districts.fold<int>(0, (sum, d) => sum + d.allocationPct) ~/ districts.length;
    final avgCompliance = districts.fold<int>(0, (sum, d) => sum + d.compliancePct) ~/ districts.length;
    final alertCount = districts.fold<int>(0, (sum, d) => sum + d.activeAlerts);
    final watchCount = districts.where((d) => d.status == 'Watch').length;

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
                    Text('Government Dashboard', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: GovernmentPage.dark)),
                    const SizedBox(height: 6),
                    Text('Live district allocation, compliance, and alert overview.', style: GoogleFonts.inter(color: GovernmentPage.muted)),
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
          Text('Updated ${_timeAgo(updatedAt)}', style: const TextStyle(color: GovernmentPage.muted, fontSize: 12)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(label: 'Avg Allocation', value: '$avgAllocation%', icon: Icons.water_drop_outlined),
              _StatCard(label: 'Avg Compliance', value: '$avgCompliance%', icon: Icons.verified_outlined),
              _StatCard(label: 'Alerts', value: '$alertCount', icon: Icons.warning_amber_outlined),
              _StatCard(label: 'Watch Regions', value: '$watchCount', icon: Icons.remove_red_eye_outlined),
            ],
          ),
          const SizedBox(height: 16),
          Text('District Status', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: GovernmentPage.dark)),
          const SizedBox(height: 10),
          ...districts.map((d) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DistrictCard(district: d),
          )),
          const SizedBox(height: 8),
          Text('Latest Actions', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: GovernmentPage.dark)),
          const SizedBox(height: 10),
          _ActionCard(title: 'Released water schedule', detail: 'Updated irrigation allocation for 4 districts.', icon: Icons.schedule_outlined),
          const SizedBox(height: 12),
          _ActionCard(title: 'Compliance review queued', detail: '2 districts require manual verification.', icon: Icons.fact_check_outlined),
          const SizedBox(height: 12),
          _ActionCard(title: 'Alert escalation', detail: '1 district moved to high-priority watch.', icon: Icons.priority_high_outlined),
        ],
      ),
    );
  }
}

class _District {
  final String name;
  final int allocationPct;
  final int compliancePct;
  final int activeAlerts;
  final String status;
  const _District({
    required this.name,
    required this.allocationPct,
    required this.compliancePct,
    required this.activeAlerts,
    required this.status,
  });
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
      Container(width: 40, height: 40, decoration: BoxDecoration(color: GovernmentPage.green.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: GovernmentPage.green)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: GovernmentPage.muted, fontSize: 13)), const SizedBox(height: 4), Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: GovernmentPage.dark))])),
    ]),
  );
}

class _DistrictCard extends StatelessWidget {
  final _District district;
  const _DistrictCard({required this.district});

  Color _color() {
    return district.status == 'Stable'
        ? GovernmentPage.green
        : district.status == 'Watch'
            ? Colors.orange
            : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(district.name, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: GovernmentPage.dark))),
            Text(district.status, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Text('Allocation ${district.allocationPct}%', style: const TextStyle(color: GovernmentPage.muted, fontSize: 12)),
            const Spacer(),
            Text('Compliance ${district.compliancePct}%', style: const TextStyle(color: GovernmentPage.muted, fontSize: 12)),
          ]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: district.allocationPct / 100, minHeight: 8, backgroundColor: Colors.grey.shade200, color: color),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _MiniStat(label: 'Compliance', value: '${district.compliancePct}%')),
            const SizedBox(width: 10),
            Expanded(child: _MiniStat(label: 'Alerts', value: '${district.activeAlerts}')),
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
      Text(label, style: const TextStyle(fontSize: 11, color: GovernmentPage.muted)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: GovernmentPage.dark)),
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
      Container(width: 40, height: 40, decoration: BoxDecoration(color: GovernmentPage.green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: GovernmentPage.green)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: GovernmentPage.dark)),
        const SizedBox(height: 4),
        Text(detail, style: const TextStyle(color: GovernmentPage.muted)),
      ])),
    ]),
  );
}