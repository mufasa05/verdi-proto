import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:verdi/features/crop_health/data/crop_health_models.dart';
import 'package:verdi/features/crop_health/data/mock_crop_health_repository.dart';
import 'package:verdi/features/crop_health/presentation/crop_health_provider.dart';

class CropHealthPage extends StatelessWidget {
  const CropHealthPage({super.key});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CropHealthProvider>(
      create: (_) =>
          CropHealthProvider(repository: const MockCropHealthRepository()),
      child: Consumer<CropHealthProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (provider.error != null) {
            return Scaffold(
              body: Center(
                child: Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final snapshot = provider.snapshot!;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Crop Health'),
              backgroundColor: green,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    snapshot.title,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: dark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    snapshot.summary,
                    style: GoogleFonts.inter(color: muted),
                  ),
                  const SizedBox(height: 20),
                  _OverviewPanel(snapshot: snapshot),
                  const SizedBox(height: 16),
                  _IndexGrid(readings: snapshot.fieldIndexReadings),
                  const SizedBox(height: 16),
                  _RiskPanel(weatherRisk: snapshot.weatherRisk),
                  const SizedBox(height: 16),
                  _FieldHealthList(fields: snapshot.fields),
                  const SizedBox(height: 16),
                  _StressZoneSection(zones: snapshot.stressZones),
                  const SizedBox(height: 16),
                  _ScoutNotesSection(notes: snapshot.scoutingNotes),
                  const SizedBox(height: 16),
                  _DiagnosisSection(diagnoses: snapshot.imageDiagnoses),
                  const SizedBox(height: 16),
                  _RecommendationsSection(
                    recommendations: snapshot.recommendations,
                  ),
                  const SizedBox(height: 16),
                  _TreatmentHistorySection(logs: snapshot.treatmentHistory),
                  const SizedBox(height: 16),
                  _ComparisonCard(comparison: snapshot.comparison),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OverviewPanel extends StatelessWidget {
  final CropHealthSnapshot snapshot;

  const _OverviewPanel({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Observe • Detect • Diagnose • Recommend • Track',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: CropHealthPage.green,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricBlock(
                  label: 'Snapshot time',
                  value: snapshot.capturedAt.toLocal().toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricBlock(
                  label: 'Active zones',
                  value: '${snapshot.stressZones.length}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IndexGrid extends StatelessWidget {
  final List<FieldIndexReading> readings;

  const _IndexGrid({required this.readings});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: readings
          .map(
            (reading) => SizedBox(
              width: 164,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reading.label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CropHealthPage.muted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      reading.value.toStringAsFixed(2),
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: CropHealthPage.dark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      reading.trend,
                      style: const TextStyle(
                        color: CropHealthPage.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reading.detail,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CropHealthPage.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _RiskPanel extends StatelessWidget {
  final WeatherRisk weatherRisk;

  const _RiskPanel({required this.weatherRisk});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weather & Risk Alerts',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: CropHealthPage.dark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            weatherRisk.summary,
            style: const TextStyle(fontSize: 13, color: CropHealthPage.muted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  weatherRisk.level,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: weatherRisk.alerts
                      .map(
                        (alert) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            alert,
                            style: const TextStyle(
                              fontSize: 12,
                              color: CropHealthPage.dark,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldHealthList extends StatelessWidget {
  final List<FieldHealthDetail> fields;

  const _FieldHealthList({required this.fields});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Field Health Details',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: CropHealthPage.dark,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: fields
              .map(
                (field) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _FieldHealthCard(field: field),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _StressZoneSection extends StatelessWidget {
  final List<StressZone> zones;

  const _StressZoneSection({required this.zones});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Problem Zones & Anomalies',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: CropHealthPage.dark,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: zones
              .map(
                (zone) => Container(
                  width: 200,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone.zoneLabel,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: CropHealthPage.dark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        zone.issue,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CropHealthPage.muted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Severity ${(zone.severity * 100).round()}%',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        zone.needsScouting
                            ? 'Scouting required'
                            : 'Monitor only',
                        style: const TextStyle(
                          color: CropHealthPage.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ScoutNotesSection extends StatelessWidget {
  final List<ScoutingNote> notes;

  const _ScoutNotesSection({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scouting Notes',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: CropHealthPage.dark,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: notes
              .map(
                (note) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                          child: Image.network(
                            note.photoUrl,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.title,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: CropHealthPage.dark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                note.location,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: CropHealthPage.muted,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                note.note,
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Recorded ${note.recordedAt}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: CropHealthPage.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _DiagnosisSection extends StatelessWidget {
  final List<ImageDiagnosis> diagnoses;

  const _DiagnosisSection({required this.diagnoses});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image Diagnosis',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: CropHealthPage.dark,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: diagnoses
              .map(
                (diagnosis) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            diagnosis.imageUrl,
                            height: 84,
                            width: 84,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                diagnosis.issue,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: CropHealthPage.dark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Confidence: ${diagnosis.confidence}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: CropHealthPage.muted,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                diagnosis.recommendedAction,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _RecommendationsSection extends StatelessWidget {
  final List<Recommendation> recommendations;

  const _RecommendationsSection({required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommendations',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: CropHealthPage.dark,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: recommendations
              .map(
                (recommendation) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation.title,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: CropHealthPage.dark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          recommendation.detail,
                          style: const TextStyle(
                            fontSize: 13,
                            color: CropHealthPage.muted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Priority: ${recommendation.priority}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _TreatmentHistorySection extends StatelessWidget {
  final List<TreatmentLog> logs;

  const _TreatmentHistorySection({required this.logs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Treatment Tracking',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: CropHealthPage.dark,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: logs
              .map(
                (log) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.action,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: CropHealthPage.dark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          log.date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: CropHealthPage.muted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(log.result, style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 8),
                        Text(
                          log.notes,
                          style: const TextStyle(
                            fontSize: 12,
                            color: CropHealthPage.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final HealthComparison comparison;

  const _ComparisonCard({required this.comparison});

  @override
  Widget build(BuildContext context) {
    final changeText = comparison.change >= 0
        ? '+${comparison.change.toStringAsFixed(2)}'
        : comparison.change.toStringAsFixed(2);
    final changeColor = comparison.change >= 0
        ? CropHealthPage.green
        : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Comparison',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: CropHealthPage.dark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            comparison.periodLabel,
            style: const TextStyle(fontSize: 13, color: CropHealthPage.muted),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MetricBlock(
                  label: 'Previous',
                  value: comparison.previousHealth.toStringAsFixed(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricBlock(
                  label: 'Current',
                  value: comparison.currentHealth.toStringAsFixed(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricBlock(
                  label: 'Change',
                  value: changeText,
                  valueColor: changeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Trend: ${comparison.trend}',
            style: const TextStyle(fontSize: 13, color: CropHealthPage.muted),
          ),
        ],
      ),
    );
  }
}

class _FieldHealthCard extends StatelessWidget {
  final FieldHealthDetail field;

  const _FieldHealthCard({required this.field});

  Color _statusColor() {
    if (field.healthScore >= 0.75) return CropHealthPage.green;
    if (field.healthScore >= 0.55) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    return Container(
      padding: const EdgeInsets.all(16),
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
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: CropHealthPage.dark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  field.fieldStatus,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniStat(label: 'NDVI', value: field.ndvi.toStringAsFixed(2)),
              _MiniStat(label: 'NDRE', value: field.ndre.toStringAsFixed(2)),
              _MiniStat(label: 'MSAVI', value: field.msavi.toStringAsFixed(2)),
              _MiniStat(
                label: 'Biomass',
                value: field.biomass.toStringAsFixed(2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: field.healthScore,
            minHeight: 10,
            color: color,
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(height: 10),
          Text(
            field.notes,
            style: const TextStyle(fontSize: 13, color: CropHealthPage.muted),
          ),
          const SizedBox(height: 10),
          Text(
            'Last scanned: ${field.lastScanned}',
            style: const TextStyle(fontSize: 12, color: CropHealthPage.muted),
          ),
        ],
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _MetricBlock({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: CropHealthPage.muted),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor ?? CropHealthPage.dark,
            ),
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
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: CropHealthPage.muted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: CropHealthPage.dark,
            ),
          ),
        ],
      ),
    );
  }
}
