import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TraceabilityPage extends StatefulWidget {
  const TraceabilityPage({super.key});

  @override
  State<TraceabilityPage> createState() => _TraceabilityPageState();
}

class _TraceabilityPageState extends State<TraceabilityPage> {
  static const Color dark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);

  final List<_TraceBatch> batches = [
    _TraceBatch(
      id: 'B-10021',
      batchCode: 'VER-TR-10021',
      cropName: 'Mango',
      farmName: 'Chiredzi Unit A',
      fieldName: 'Block 4',
      harvestDate: '2026-06-12',
      quantity: 1200,
      unit: 'kg',
      status: 'Ready',
      readinessScore: 0.96,
      originVerified: true,
      inspectionPassed: true,
    ),
    _TraceBatch(
      id: 'B-10022',
      batchCode: 'VER-TR-10022',
      cropName: 'Tomatoes',
      farmName: 'Odzi Farm',
      fieldName: 'Greenhouse 2',
      harvestDate: '2026-06-13',
      quantity: 780,
      unit: 'kg',
      status: 'Review',
      readinessScore: 0.71,
      originVerified: true,
      inspectionPassed: false,
    ),
    _TraceBatch(
      id: 'B-10023',
      batchCode: 'VER-TR-10023',
      cropName: 'Maize',
      farmName: 'Mvurwi North',
      fieldName: 'Field 1',
      harvestDate: '2026-06-14',
      quantity: 2500,
      unit: 'kg',
      status: 'Blocked',
      readinessScore: 0.44,
      originVerified: false,
      inspectionPassed: false,
    ),
  ];

  _TraceBatch? selected;

  @override
  void initState() {
    super.initState();
    selected = batches.first;
  }

  List<_TraceEvent> _eventsFor(String batchId) {
    return [
      _TraceEvent(eventType: 'Planting', eventTime: '2026-03-01 07:00', actorName: 'Farm Manager', location: 'Block 4', notes: 'Seed lot recorded and field mapped.'),
      _TraceEvent(eventType: 'Input Applied', eventTime: '2026-04-11 09:30', actorName: 'Field Officer', location: 'Block 4', notes: 'Fertilizer applied at recommended rate.'),
      _TraceEvent(eventType: 'Harvest', eventTime: '2026-06-12 06:15', actorName: 'Harvest Team', location: 'Packhouse A', notes: 'Batch harvested and weighed.'),
      _TraceEvent(eventType: 'Inspection', eventTime: '2026-06-12 11:40', actorName: 'Inspector', location: 'Packhouse A', notes: 'Quality inspection completed.'),
      _TraceEvent(eventType: 'Dispatch', eventTime: '2026-06-13 15:20', actorName: 'Logistics', location: 'Depot', notes: 'Loaded for shipment.'),
    ];
  }

  List<_BatchDocument> _docsFor(String batchId) {
    return [
      _BatchDocument(docType: 'Harvest Log', fileName: '$batchId-harvest.pdf'),
      _BatchDocument(docType: 'Inspection Certificate', fileName: '$batchId-inspection.pdf'),
      _BatchDocument(docType: 'Dispatch Note', fileName: '$batchId-dispatch.pdf'),
    ];
  }

  List<_ScanLog> _scansFor(String batchId) {
    return [
      _ScanLog(scannedAt: '2026-06-12 11:50', scannerRole: 'Inspector', result: 'Verified'),
      _ScanLog(scannedAt: '2026-06-13 15:30', scannerRole: 'Driver', result: 'Loaded'),
      _ScanLog(scannedAt: '2026-06-14 08:10', scannerRole: 'Buyer', result: 'Viewed'),
    ];
  }

  double _overallReadiness() {
    if (batches.isEmpty) return 0;
    return batches.fold<double>(0, (sum, b) => sum + b.readinessScore) / batches.length;
  }

  @override
  Widget build(BuildContext context) {
    final batch = selected!;
    final events = _eventsFor(batch.id);
    final docs = _docsFor(batch.id);
    final scans = _scansFor(batch.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Traceability', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: dark)),
                      const SizedBox(height: 6),
                      Text('Track origin, events, documents, scans, and readiness.', style: GoogleFonts.inter(color: muted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.black12)),
                  child: Text(
                    'Avg ${( _overallReadiness() * 100).round()}%',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: dark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatCard(label: 'Batches', value: '${batches.length}', icon: Icons.inventory_2_outlined),
                _StatCard(label: 'Ready', value: '${batches.where((b) => b.status == 'Ready').length}', icon: Icons.verified_outlined),
                _StatCard(label: 'Review', value: '${batches.where((b) => b.status == 'Review').length}', icon: Icons.rate_review_outlined),
                _StatCard(label: 'Blocked', value: '${batches.where((b) => b.status == 'Blocked').length}', icon: Icons.block_outlined),
              ],
            ),
            const SizedBox(height: 16),
            Text('Batches', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
            const SizedBox(height: 10),
            ...batches.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BatchCard(
                batch: b,
                selected: b.id == batch.id,
                onTap: () => setState(() => selected = b),
              ),
            )),
            const SizedBox(height: 8),
            Text('Batch QR', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
              ),
              child: Center(
                child: Text(
                  'QR generator unavailable',
                  style: GoogleFonts.inter(color: muted),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Trace Events', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
            const SizedBox(height: 10),
            ...events.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _EventCard(event: e),
            )),
            const SizedBox(height: 16),
            Text('Documents', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
            const SizedBox(height: 10),
            ...docs.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DocCard(doc: d),
            )),
            const SizedBox(height: 16),
            Text('Scan Logs', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
            const SizedBox(height: 10),
            ...scans.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ScanCard(scan: s),
            )),
            const SizedBox(height: 16),
            Text('Live Scan', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: dark)),
            const SizedBox(height: 10),
            Container(
              height: 240,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black12)),
              child: Center(
              child: Text(
                'Live scan unavailable',
                style: GoogleFonts.inter(color: muted),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _TraceBatch {
  final String id;
  final String batchCode;
  final String cropName;
  final String farmName;
  final String fieldName;
  final String harvestDate;
  final int quantity;
  final String unit;
  final String status;
  final double readinessScore;
  final bool originVerified;
  final bool inspectionPassed;

  const _TraceBatch({
    required this.id,
    required this.batchCode,
    required this.cropName,
    required this.farmName,
    required this.fieldName,
    required this.harvestDate,
    required this.quantity,
    required this.unit,
    required this.status,
    required this.readinessScore,
    required this.originVerified,
    required this.inspectionPassed,
  });
}

class _TraceEvent {
  final String eventType;
  final String eventTime;
  final String actorName;
  final String location;
  final String notes;

  const _TraceEvent({
    required this.eventType,
    required this.eventTime,
    required this.actorName,
    required this.location,
    required this.notes,
  });
}

class _BatchDocument {
  final String docType;
  final String fileName;

  const _BatchDocument({required this.docType, required this.fileName});
}

class _ScanLog {
  final String scannedAt;
  final String scannerRole;
  final String result;

  const _ScanLog({
    required this.scannedAt,
    required this.scannerRole,
    required this.result,
  });
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

  static const Color green = Color(0xFF16A34A);
  static const Color dark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);

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
              color: green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: muted, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: dark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final _TraceBatch batch;
  final bool selected;
  final VoidCallback onTap;

  const _BatchCard({
    required this.batch,
    required this.selected,
    required this.onTap,
  });

  static const Color green = Color(0xFF16A34A);
  static const Color dark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);

  Color _color() {
    return batch.status == 'Ready'
        ? green
        : batch.status == 'Review'
            ? Colors.orange
            : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? color : Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${batch.batchCode} • ${batch.cropName}',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: dark),
                  ),
                ),
                Text(batch.status, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            Text('${batch.farmName} • ${batch.fieldName}', style: const TextStyle(color: muted)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Harvest ${batch.harvestDate}', style: const TextStyle(color: muted, fontSize: 12)),
                const Spacer(),
                Text('${batch.quantity} ${batch.unit}', style: const TextStyle(color: muted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: batch.readinessScore,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: color,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _MiniBadge(label: 'Origin', value: batch.originVerified ? 'Verified' : 'Missing', dark: dark, muted: muted)),
                const SizedBox(width: 10),
                Expanded(child: _MiniBadge(label: 'Inspection', value: batch.inspectionPassed ? 'Passed' : 'Pending', dark: dark, muted: muted)),
                const SizedBox(width: 10),
                Expanded(child: _MiniBadge(label: 'Readiness', value: '${(batch.readinessScore * 100).round()}%', dark: dark, muted: muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color dark;
  final Color muted;

  const _MiniBadge({
    required this.label,
    required this.value,
    required this.dark,
    required this.muted,
  });

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
          Text(label, style: TextStyle(fontSize: 11, color: muted)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: dark)),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final _TraceEvent event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
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
                  event.eventType,
                  style: const TextStyle(fontWeight: FontWeight.w800, color: _StatCard.dark),
                ),
              ),
              Text(event.eventTime, style: const TextStyle(color: _StatCard.muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text('${event.actorName} • ${event.location}', style: const TextStyle(color: _StatCard.muted)),
          const SizedBox(height: 4),
          Text(event.notes, style: const TextStyle(color: _StatCard.dark)),
        ],
      ),
    );
  }
}

class _DocCard extends StatelessWidget {
  final _BatchDocument doc;
  const _DocCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: _StatCard.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.docType, style: const TextStyle(fontWeight: FontWeight.w800, color: _StatCard.dark)),
                const SizedBox(height: 4),
                Text(doc.fileName, style: const TextStyle(color: _StatCard.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  final _ScanLog scan;
  const _ScanCard({required this.scan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code_scanner_outlined, color: _StatCard.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${scan.scannerRole} • ${scan.result}', style: const TextStyle(fontWeight: FontWeight.w800, color: _StatCard.dark)),
                const SizedBox(height: 4),
                Text(scan.scannedAt, style: const TextStyle(color: _StatCard.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}