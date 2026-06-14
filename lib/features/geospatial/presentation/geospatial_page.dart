import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeospatialPage extends StatefulWidget {
  const GeospatialPage({super.key});

  @override
  State<GeospatialPage> createState() => _GeospatialPageState();
}

class _GeospatialPageState extends State<GeospatialPage> {
  static const green = Color(0xFF16A34A);
  static const background = Color(0xFFF8FAFC);

  GoogleMapController? _mapController;

  final List<String> _layers = const [
    'All Zones',
    'Crop Health',
    'Stress Risk',
    'Water',
    'Weather',
  ];

  String _selectedLayer = 'All Zones';

  final ZoneItem _selectedZone = const ZoneItem(
    name: 'Zone D',
    region: 'Gwanda',
    crop: 'Cabbages',
    health: 0.49,
    risk: 'High',
    hectares: '88 ha',
    alert: 'Water stress',
    ndvi: 0.41,
    moisture: 0.32,
    temperature: 34,
    rainfall: 2,
    yieldEstimate: '18.2 t',
    lastScanned: '2h ago',
  );

  final List<ZoneItem> _zones = const [
    ZoneItem(
      name: 'Zone A',
      region: 'Masvingo',
      crop: 'Maize',
      health: 0.86,
      risk: 'Low',
      hectares: '120 ha',
      alert: 'Stable',
      ndvi: 0.82,
      moisture: 0.71,
      temperature: 28,
      rainfall: 12,
      yieldEstimate: '42.5 t',
      lastScanned: '30m ago',
    ),
    ZoneItem(
      name: 'Zone B',
      region: 'Chiredzi',
      crop: 'Tomatoes',
      health: 0.63,
      risk: 'Medium',
      hectares: '75 ha',
      alert: 'Heat stress',
      ndvi: 0.59,
      moisture: 0.44,
      temperature: 33,
      rainfall: 4,
      yieldEstimate: '21.7 t',
      lastScanned: '1h ago',
    ),
    ZoneItem(
      name: 'Zone C',
      region: 'Mutare',
      crop: 'Potatoes',
      health: 0.91,
      risk: 'Low',
      hectares: '54 ha',
      alert: 'Healthy',
      ndvi: 0.88,
      moisture: 0.76,
      temperature: 24,
      rainfall: 18,
      yieldEstimate: '30.1 t',
      lastScanned: '15m ago',
    ),
    ZoneItem(
      name: 'Zone D',
      region: 'Gwanda',
      crop: 'Cabbages',
      health: 0.49,
      risk: 'High',
      hectares: '88 ha',
      alert: 'Water stress',
      ndvi: 0.41,
      moisture: 0.32,
      temperature: 34,
      rainfall: 2,
      yieldEstimate: '18.2 t',
      lastScanned: '2h ago',
    ),
  ];

  List<ZoneItem> get _filteredZones {
    if (_selectedLayer == 'All Zones') return _zones;
    return _zones.where((z) {
      switch (_selectedLayer) {
        case 'Crop Health':
          return z.health >= 0.7;
        case 'Stress Risk':
          return z.risk != 'Low';
        case 'Water':
          return z.alert.contains('Water');
        case 'Weather':
          return z.alert.contains('Heat') || z.alert.contains('Storm');
        default:
          return true;
      }
    }).toList();
  }

  Set<Marker> get _markers {
    return _zones.asMap().entries.map((entry) {
      final i = entry.key;
      final zone = entry.value;
      final lat = 19.0 + (i * 0.18);
      final lng = 29.0 + (i * 0.14);

      final hue = zone.health >= 0.8
          ? BitmapDescriptor.hueGreen
          : zone.health >= 0.6
          ? BitmapDescriptor.hueOrange
          : BitmapDescriptor.hueRed;

      return Marker(
        markerId: MarkerId(zone.name),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        infoWindow: InfoWindow(
          title: '${zone.name} • ${zone.region}',
          snippet: '${zone.crop} • ${zone.risk}',
        ),
        onTap: () {
          setState(() {});
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(lat, lng), 10),
          );
        },
      );
    }).toSet();
  }

  Set<Polygon> get _polygons {
    return _zones.asMap().entries.map((entry) {
      final i = entry.key;
      final zone = entry.value;
      final lat = 19.0 + (i * 0.18);
      final lng = 29.0 + (i * 0.14);

      final fill = zone.health >= 0.8
          ? Colors.green.withValues(alpha: 0.18)
          : zone.health >= 0.6
          ? Colors.orange.withValues(alpha: 0.18)
          : Colors.red.withValues(alpha: 0.18);

      return Polygon(
        polygonId: PolygonId(zone.name),
        points: [
          LatLng(lat, lng),
          LatLng(lat + 0.06, lng + 0.06),
          LatLng(lat + 0.11, lng - 0.01),
          LatLng(lat + 0.03, lng - 0.08),
        ],
        strokeColor: green,
        strokeWidth: 2,
        fillColor: fill,
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final zones = _filteredZones;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1100;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    isCompact: !isDesktop,
                    selectedLayer: _selectedLayer,
                    layers: _layers,
                    onLayerChanged: (v) => setState(() => _selectedLayer = v),
                  ),
                  const SizedBox(height: 16),
                  _StatsGrid(isDesktop: isDesktop),
                  const SizedBox(height: 16),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              _SectionCard(
                                title: 'Farm Zone Map',
                                child: _MapCard(
                                  markers: _markers,
                                  polygons: _polygons,
                                  onMapCreated: (controller) =>
                                      _mapController = controller,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Satellite Indicators',
                                child: const _SatelliteIndicators(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _SectionCard(
                                title: 'Zone Summary',
                                child: Column(
                                  children: [
                                    for (int i = 0; i < zones.length; i++) ...[
                                      _ZoneCard(zone: zones[i]),
                                      if (i != zones.length - 1)
                                        const SizedBox(height: 12),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Zone Health Detail',
                                child: _ZoneDetailPanel(zone: _selectedZone),
                              ),
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'AI Insight',
                                child: const _AiInsightCard(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _SectionCard(
                          title: 'Farm Zone Map',
                          child: _MapCard(
                            markers: _markers,
                            polygons: _polygons,
                            onMapCreated: (controller) =>
                                _mapController = controller,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Satellite Indicators',
                          child: const _SatelliteIndicators(),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Zone Summary',
                          child: Column(
                            children: [
                              for (int i = 0; i < zones.length; i++) ...[
                                _ZoneCard(zone: zones[i]),
                                if (i != zones.length - 1)
                                  const SizedBox(height: 12),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Zone Health Detail',
                          child: _ZoneDetailPanel(zone: _selectedZone),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'AI Insight',
                          child: const _AiInsightCard(),
                        ),
                      ],
                    ),
                  const SizedBox(height: 48),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  final Set<Marker> markers;
  final Set<Polygon> polygons;
  final ValueChanged<GoogleMapController> onMapCreated;

  const _MapCard({
    required this.markers,
    required this.polygons,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 340,
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(19.0, 29.0),
            zoom: 7,
          ),
          mapType: MapType.hybrid,
          markers: markers,
          polygons: polygons,
          onMapCreated: onMapCreated,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: true,
          tiltGesturesEnabled: true,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }
}

class _ZoneDetailPanel extends StatelessWidget {
  final ZoneItem zone;

  const _ZoneDetailPanel({required this.zone});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${zone.name} • ${zone.region}',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _GeospatialColors.dark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${zone.crop} • ${zone.hectares} • scanned ${zone.lastScanned}',
          style: const TextStyle(color: _GeospatialColors.muted),
        ),
        const SizedBox(height: 16),
        _MetricRow(
          label: 'Crop health',
          value: '${(zone.health * 100).round()}%',
        ),
        _MetricBar(value: zone.health, color: _metricColor(zone.health)),
        const SizedBox(height: 12),
        _MetricRow(label: 'NDVI', value: zone.ndvi.toStringAsFixed(2)),
        _MetricBar(value: zone.ndvi, color: Colors.green),
        const SizedBox(height: 12),
        _MetricRow(
          label: 'Moisture',
          value: '${(zone.moisture * 100).round()}%',
        ),
        _MetricBar(value: zone.moisture, color: Colors.blue),
        const SizedBox(height: 12),
        _MetricRow(label: 'Temperature', value: '${zone.temperature} C'),
        _MetricBar(value: zone.temperature / 40, color: Colors.orange),
        const SizedBox(height: 12),
        _MetricRow(label: 'Rainfall', value: '${zone.rainfall} mm'),
        _MetricBar(value: zone.rainfall / 50, color: Colors.indigo),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MiniChip(label: zone.alert, icon: Icons.info_outline),
            _MiniChip(label: 'Scout zone', icon: Icons.travel_explore_outlined),
            _MiniChip(label: 'Adjust route', icon: Icons.alt_route_outlined),
          ],
        ),
      ],
    );
  }

  Color _metricColor(double value) {
    if (value >= 0.8) return Colors.green;
    if (value >= 0.6) return Colors.orange;
    return Colors.red;
  }
}

class ZoneItem {
  final String name;
  final String region;
  final String crop;
  final double health;
  final String risk;
  final String hectares;
  final String alert;
  final double ndvi;
  final double moisture;
  final int temperature;
  final int rainfall;
  final String yieldEstimate;
  final String lastScanned;

  const ZoneItem({
    required this.name,
    required this.region,
    required this.crop,
    required this.health,
    required this.risk,
    required this.hectares,
    required this.alert,
    required this.ndvi,
    required this.moisture,
    required this.temperature,
    required this.rainfall,
    required this.yieldEstimate,
    required this.lastScanned,
  });
}

class _Header extends StatelessWidget {
  final bool isCompact;
  final String selectedLayer;
  final List<String> layers;
  final ValueChanged<String> onLayerChanged;

  const _Header({
    required this.isCompact,
    required this.selectedLayer,
    required this.layers,
    required this.onLayerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Geospatial Intelligence',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: isCompact ? 24 : 28,
                  fontWeight: FontWeight.w800,
                  color: _GeospatialColors.dark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Monitor farm zones, crop health, and risk patterns from space and ground intelligence.',
          style: GoogleFonts.inter(color: _GeospatialColors.muted),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: layers
              .map(
                (layer) => ChoiceChip(
                  label: Text(layer),
                  selected: selectedLayer == layer,
                  selectedColor: _GeospatialColors.green.withValues(
                    alpha: 0.15,
                  ),
                  labelStyle: TextStyle(
                    color: selectedLayer == layer
                        ? _GeospatialColors.green
                        : _GeospatialColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => onLayerChanged(layer),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final bool isDesktop;

  const _StatsGrid({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatData('Zones', '4', Icons.grid_view_outlined),
      _StatData('Healthy', '2', Icons.verified_outlined),
      _StatData('Risk', '2', Icons.warning_amber_outlined),
      _StatData('Alerts', '3', Icons.notifications_active_outlined),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 72,
      ),
      itemBuilder: (context, index) {
        final stat = cards[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _GeospatialColors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(stat.icon, color: _GeospatialColors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stat.label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _GeospatialColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat.value,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _GeospatialColors.dark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final ZoneItem zone;

  const _ZoneCard({required this.zone});

  @override
  Widget build(BuildContext context) {
    final healthColor = zone.health >= 0.8
        ? Colors.green
        : zone.health >= 0.6
        ? Colors.orange
        : Colors.red;

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
          Text('${zone.name} • ${zone.region}'),
          const SizedBox(height: 8),
          Text('${zone.crop} • ${zone.hectares}'),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: zone.health,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            color: healthColor,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniChip(label: zone.alert, icon: Icons.info_outline),
              _MiniChip(label: 'Open map', icon: Icons.map_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class _SatelliteIndicators extends StatelessWidget {
  const _SatelliteIndicators();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Vegetation index', 0.84),
      ('Moisture signal', 0.62),
      ('Heat stress', 0.38),
      ('Cloud cover', 0.21),
    ];

    return Column(
      children: items.map((item) {
        final value = item.$2;
        final color = value >= 0.7
            ? Colors.green
            : value >= 0.4
            ? Colors.orange
            : Colors.red;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.$1,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  color: color,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 42,
                child: Text(
                  '${(value * 100).round()}%',
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _AiInsightCard extends StatelessWidget {
  const _AiInsightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _GeospatialColors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _GeospatialColors.green.withValues(alpha: 0.2),
        ),
      ),
      child: const Text(
        'Zone D shows rising water stress. Prioritize irrigation planning, field scouting, and logistics scheduling within the next 24 hours.',
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
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _MetricBar extends StatelessWidget {
  final double value;
  final Color color;

  const _MetricBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 12),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 8,
        backgroundColor: Colors.grey.shade200,
        color: color,
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MiniChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _GeospatialColors.dark,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;

  _StatData(this.label, this.value, this.icon);
}

class _GeospatialColors {
  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
}
