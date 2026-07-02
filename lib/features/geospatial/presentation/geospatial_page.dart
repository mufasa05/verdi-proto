import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../state/app_state.dart';
import '../models/geospatial_models.dart';
import '../providers/geospatial_providers.dart';
import '../widgets/layer_chip_row.dart';
import '../widgets/map_header.dart';
import '../widgets/field_card.dart';
import 'field_detail_map_page.dart';
import 'zone_editor_page.dart';
import 'scouting_tasks_page.dart';
import 'layer_manager_page.dart';
import 'historical_compare_page.dart';

class GeospatialPage extends ConsumerStatefulWidget {
  const GeospatialPage({super.key});

  @override
  ConsumerState<GeospatialPage> createState() => _GeospatialPageState();
}

class _GeospatialPageState extends ConsumerState<GeospatialPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedRegion = 'All Regions';
  String _selectedCrop = 'All Crops';
  bool _pinDropMode = false;
  IrrigationScheme? _selectedScheme;

  final List<String> _regions = const [
    'All Regions',
    'Masvingo',
    'Chiredzi',
    'Mutare',
    'Harare',
    'Gwanda',
  ];
  final List<String> _crops = const [
    'All Crops',
    'Maize',
    'Tomatoes',
    'Potatoes',
    'Cabbages',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCoordinatesDialog() {
    final latController = TextEditingController();
    final lngController = TextEditingController();
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedSaveType = 'Pin';

    final appState = ref.read(appStateProvider);
    final isAdmin = appState.role == UserRole.admin;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: const [
                  Icon(Icons.explore_outlined, color: Color(0xFF16A34A)),
                  SizedBox(width: 8),
                  Text(
                    'Pinpoint Coordinates',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Enter GPS coordinates to fly the map or save a location.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: latController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Latitude',
                          hintText: 'e.g. -17.82',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.navigation_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final d = double.tryParse(v);
                          if (d == null) return 'Invalid number';
                          if (d < -90 || d > 90) {
                            return 'Must be between -90 and 90';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: lngController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Longitude',
                          hintText: 'e.g. 31.05',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.navigation_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final d = double.tryParse(v);
                          if (d == null) return 'Invalid number';
                          if (d < -180 || d > 180) {
                            return 'Must be between -180 and 180';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'Action:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          if (!isAdmin)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Read-Only',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedSaveType,
                        decoration: InputDecoration(
                          labelText: 'Save As',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Pin',
                            child: Text('Scouting Pin'),
                          ),
                          DropdownMenuItem(
                            value: 'Field',
                            child: Text('New Field Boundary'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => selectedSaveType = v);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: selectedSaveType == 'Pin'
                              ? 'Pin Label / Note'
                              : 'Field Name',
                          hintText: selectedSaveType == 'Pin'
                              ? 'e.g. GPS Waypoint'
                              : 'e.g. Custom Plot',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final lat = double.parse(latController.text.trim());
                      final lng = double.parse(lngController.text.trim());
                      final point = LatLng(lat, lng);

                      _mapController.move(point, 13.0);

                      final name = nameController.text.trim();
                      if (name.isNotEmpty) {
                        if (!isAdmin) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Read-Only Mode: Location shown. Saving is restricted to Admins.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        final selectedFieldId = ref.read(
                          selectedFieldIdProvider,
                        );
                        if (selectedSaveType == 'Pin') {
                          final newObs = GeoObservation(
                            id: 'OBS-${DateTime.now().millisecondsSinceEpoch}',
                            fieldId: selectedFieldId ?? 'FLD-01',
                            position: point,
                            title: name,
                            issueType: 'Other',
                            severity: 'Low',
                            notes: 'Manually pinned coordinate: ($lat, $lng)',
                            date:
                                'Today, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                          );
                          ref
                              .read(geoObservationsProvider.notifier)
                              .addObservation(newObs);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Scouting observation pin dropped successfully!',
                              ),
                            ),
                          );
                        } else {
                          final newField = GeoField(
                            id: 'FLD-${DateTime.now().millisecondsSinceEpoch}',
                            farmId: 'FRM-01',
                            name: name,
                            boundary: [
                              LatLng(lat + 0.005, lng - 0.005),
                              LatLng(lat + 0.005, lng + 0.005),
                              LatLng(lat - 0.005, lng + 0.005),
                              LatLng(lat - 0.005, lng - 0.005),
                            ],
                            hectares: 25.0,
                            crop: 'Maize',
                            healthScore: 0.75,
                            status: 'Healthy',
                            lastScoutDate: 'Just added',
                          );
                          ref
                              .read(geoFieldsProvider.notifier)
                              .addField(newField);
                          ref
                              .read(selectedFieldIdProvider.notifier)
                              .select(newField.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'New Field registered successfully!',
                              ),
                            ),
                          );
                        }
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Moved map view to coordinates: ($lat, $lng)',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Go to Location'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddPinDialog(LatLng point, String fieldId) {
    if (ref.read(appStateProvider).role != UserRole.admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Read-Only Mode: Dropping scouting pins requires Administrator clearance.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    String selectedType = 'Pest';
    String selectedSeverity = 'Medium';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('New Scouting Pin'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Issue Title',
                        hintText: 'e.g. Locust sighting',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Issue Type',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Pest',
                          child: Text('Pest / Insect'),
                        ),
                        DropdownMenuItem(
                          value: 'Disease',
                          child: Text('Crop Disease'),
                        ),
                        DropdownMenuItem(
                          value: 'Water',
                          child: Text('Water / Irrigation'),
                        ),
                        DropdownMenuItem(
                          value: 'Weed',
                          child: Text('Weeds / Growth'),
                        ),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedType = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedSeverity,
                      decoration: const InputDecoration(labelText: 'Severity'),
                      items: const [
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                        DropdownMenuItem(
                          value: 'Medium',
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(value: 'High', child: Text('High')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => selectedSeverity = v);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Describe details for the scouting team...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;

                    final newObs = GeoObservation(
                      id: 'OBS-${DateTime.now().millisecondsSinceEpoch}',
                      fieldId: fieldId,
                      position: point,
                      title: title,
                      issueType: selectedType,
                      severity: selectedSeverity,
                      notes: notesController.text.trim(),
                      date:
                          'Today, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                    );

                    ref
                        .read(geoObservationsProvider.notifier)
                        .addObservation(newObs);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Scouting observation pin dropped successfully!',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Drop Pin'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = ref.watch(geoFieldsProvider);
    final observations = ref.watch(geoObservationsProvider);
    final tasks = ref.watch(geoTasksProvider);
    final settings = ref.watch(geoLayerSettingsProvider);
    final selectedFieldId = ref.watch(selectedFieldIdProvider);
    final schemes = ref.watch(irrigationSchemesProvider);
    final appState = ref.watch(appStateProvider);
    final isAdmin = appState.role == UserRole.admin;

    // Filters
    final searchText = _searchController.text.toLowerCase();
    final filteredFields = fields.where((f) {
      final matchesSearch =
          f.name.toLowerCase().contains(searchText) ||
          f.crop.toLowerCase().contains(searchText);
      final matchesRegion =
          _selectedRegion == 'All Regions' ||
          f.name.contains(_selectedRegion) ||
          _selectedRegion.toLowerCase() == 'gwanda' &&
              f.id == 'FLD-04'; // mock logic to align regional centers
      final matchesCrop =
          _selectedCrop == 'All Crops' || f.crop == _selectedCrop;
      return matchesSearch && matchesRegion && matchesCrop;
    }).toList();

    final selectedField = fields.firstWhere(
      (f) => f.id == selectedFieldId,
      orElse: () => fields.first,
    );

    // Compute center stats
    final totalFields = filteredFields.length;
    final avgHealth = totalFields > 0
        ? filteredFields.map((e) => e.healthScore).reduce((a, b) => a + b) /
              totalFields
        : 0.0;

    // Tile template selection
    final tileUrl = settings.showSatellite
        ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
        : settings.showTerrain
        ? 'https://tile.opentopomap.org/{z}/{x}/{y}.png'
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    // Map Polygons mapping
    final polygons = filteredFields.map((f) {
      Color fill = const Color(0xFF16A34A).withOpacity(0.15);
      if (settings.showNdvi) {
        fill = f.healthScore >= 0.8
            ? const Color(0xFF22C55E).withOpacity(settings.opacityNdvi)
            : f.healthScore >= 0.6
            ? const Color(0xFFF97316).withOpacity(settings.opacityNdvi)
            : const Color(0xFFEF4444).withOpacity(settings.opacityNdvi);
      } else if (settings.showSoil) {
        fill = Colors.brown.withOpacity(settings.opacitySoil);
      }

      return Polygon(
        points: f.boundary,
        color: fill,
        borderColor: selectedFieldId == f.id
            ? Colors.yellow
            : const Color(0xFF16A34A),
        borderStrokeWidth: selectedFieldId == f.id ? 4 : 2,
        isFilled: true,
      );
    }).toList();

    if (settings.showIrrigation) {
      for (final s in schemes) {
        polygons.add(
          Polygon(
            points: s.boundary,
            color: Colors.blue.withOpacity(0.12),
            borderColor: Colors.blue.shade600,
            borderStrokeWidth: 2.5,
            isFilled: true,
          ),
        );
      }
    }

    // Irrigation layer polylines (mock layout pipes)
    final polylines = <Polyline>[];
    if (settings.showIrrigation) {
      polylines.add(
        Polyline(
          points: [
            LatLng(-17.80, 31.04),
            LatLng(-17.81, 31.045),
            LatLng(-17.82, 31.05),
          ],
          strokeWidth: 3.5,
          color: Colors.blue.shade400,
        ),
      );
      polylines.add(
        Polyline(
          points: [LatLng(-21.04, 31.66), LatLng(-21.05, 31.67)],
          strokeWidth: 3.5,
          color: Colors.blue.shade400,
        ),
      );
    }

    // Weather radar mock layers
    final circles = <CircleMarker>[];
    if (settings.showWeather) {
      circles.add(
        CircleMarker(
          point: LatLng(-17.81, 31.05),
          radius: 80,
          useRadiusInMeter: false,
          color: Colors.purple.withOpacity(settings.opacityWeather * 0.4),
          borderColor: Colors.purple.withOpacity(settings.opacityWeather),
          borderStrokeWidth: 1.5,
        ),
      );
      circles.add(
        CircleMarker(
          point: LatLng(-20.93, 29.00),
          radius: 120,
          useRadiusInMeter: false,
          color: Colors.blue.withOpacity(settings.opacityWeather * 0.3),
          borderColor: Colors.blue.withOpacity(settings.opacityWeather),
          borderStrokeWidth: 1.5,
        ),
      );
    }

    // Map Markers mapping
    final markers = <Marker>[];
    for (final obs in observations) {
      final severityColor = obs.severity == 'High'
          ? Colors.red
          : obs.severity == 'Medium'
          ? Colors.orange
          : Colors.blue;
      markers.add(
        Marker(
          point: obs.position,
          width: 38,
          height: 38,
          child: GestureDetector(
            onTap: () {
              ref.read(selectedFieldIdProvider.notifier).select(obs.fieldId);
              _mapController.move(obs.position, 14);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Obs: ${obs.title} (${obs.severity} Severity)'),
                  action: SnackBarAction(label: 'Scout', onPressed: () {}),
                ),
              );
            },
            child: Tooltip(
              message: obs.title,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: severityColor, width: 2.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                child: Icon(
                  obs.issueType == 'Pest'
                      ? Icons.bug_report
                      : obs.issueType == 'Water'
                      ? Icons.water_drop
                      : obs.issueType == 'Disease'
                      ? Icons.coronavirus
                      : Icons.warning,
                  color: severityColor,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (settings.showIrrigation) {
      for (final s in schemes) {
        markers.add(
          Marker(
            point: s.position,
            width: 42,
            height: 42,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedScheme = s;
                });
                _mapController.move(s.position, 12);
              },
              child: Tooltip(
                message: '${s.name} (${s.crop})',
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.shade600, width: 2.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: Icon(
                    Icons.shower,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    // Task markers mapping
    for (final task in tasks) {
      if (task.position != null) {
        markers.add(
          Marker(
            point: task.position!,
            width: 32,
            height: 32,
            child: GestureDetector(
              onTap: () {
                ref.read(selectedFieldIdProvider.notifier).select(task.fieldId);
                _mapController.move(task.position!, 14);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Task: ${task.title} - Assignee: ${task.assignee}',
                    ),
                    action: SnackBarAction(
                      label: 'Complete',
                      onPressed: () => ref
                          .read(geoTasksProvider.notifier)
                          .toggleTaskStatus(task.id),
                    ),
                  ),
                );
              },
              child: Tooltip(
                message: task.title,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // 1. Full-screen Interactive map
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(-19.5, 30.5),
                initialZoom: 7.0,
                onTap: (tapPosition, point) {
                  if (_pinDropMode) {
                    setState(() => _pinDropMode = false);
                    _showAddPinDialog(point, selectedFieldId ?? 'FLD-01');
                  } else {
                    // Click detection within field bounds
                    for (final field in fields) {
                      if (_isPointInPolygon(point, field.boundary)) {
                        ref
                            .read(selectedFieldIdProvider.notifier)
                            .select(field.id);
                        _mapController.move(point, 13.5);
                        return;
                      }
                    }
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: tileUrl,
                  userAgentPackageName: 'com.verdi.app',
                ),
                PolygonLayer(polygons: polygons),
                PolylineLayer(polylines: polylines),
                CircleLayer(circles: circles),
                MarkerLayer(markers: markers),
              ],
            ),
          ),

          if (!isAdmin)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.orange.shade800,
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 16,
                ),
                child: const Center(
                  child: Text(
                    'READ-ONLY MODE (Privileged data modification restricted to Admins)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

          // 2. Map HUD controls (Top layer)
          Positioned(
            top: isAdmin ? 16 : 38,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header Row
                MapHeader(
                  searchController: _searchController,
                  onSearchChanged: (v) => setState(() {}),
                  selectedRegion: _selectedRegion,
                  regions: _regions,
                  onRegionChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedRegion = v);
                      // Focus map to region center
                      final center = switch (v.toLowerCase()) {
                        'harare' => LatLng(-17.82, 31.05),
                        'masvingo' => LatLng(-20.06, 30.83),
                        'chiredzi' => LatLng(-21.05, 31.67),
                        'mutare' => LatLng(-18.97, 32.67),
                        'gwanda' => LatLng(-20.93, 29.00),
                        _ => LatLng(-19.5, 30.5),
                      };
                      _mapController.move(
                        center,
                        v == 'All Regions' ? 7.0 : 11.5,
                      );
                    }
                  },
                  selectedCrop: _selectedCrop,
                  crops: _crops,
                  onCropChanged: (v) {
                    if (v != null) setState(() => _selectedCrop = v);
                  },
                  totalFields: totalFields,
                  avgHealth: avgHealth,
                ),
                const SizedBox(height: 10),

                // Map Layers selection chips
                const LayerChipRow(),
              ],
            ),
          ),

          // 3. Side Actions / Screen Router (Top Right controls)
          Positioned(
            top: isAdmin ? 156 : 178,
            right: 16,
            child: Column(
              children: [
                _roundHudButton(
                  icon: Icons.explore_outlined,
                  tooltip: 'Pinpoint Location by Coordinates',
                  onTap: _showCoordinatesDialog,
                ),
                const SizedBox(height: 10),
                _roundHudButton(
                  icon: Icons.layers_outlined,
                  tooltip: 'Layer Settings Manager',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LayerManagerPage(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _roundHudButton(
                  icon: Icons.compare_outlined,
                  tooltip: 'Compare Seasons Side-by-Side',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoricalComparePage(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _roundHudButton(
                  icon: Icons.assignment_turned_in_outlined,
                  tooltip: 'Scouting Task Center',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScoutingTasksPage(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _roundHudButton(
                  icon: Icons.pin_drop,
                  tooltip: _pinDropMode
                      ? 'Tap Map to Drop Pin (Active)'
                      : 'Drop Scouting Pin',
                  color: _pinDropMode ? Colors.orange.shade700 : Colors.white,
                  iconColor: _pinDropMode ? Colors.white : Colors.blue.shade600,
                  onTap: () {
                    setState(() => _pinDropMode = !_pinDropMode);
                    if (_pinDropMode) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Pin Drop Mode Active. Tap anywhere on the map to add scouting note.',
                          ),
                          duration: Duration(seconds: 4),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // 4. Focus Card Overlay (Bottom sheet widget)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  onPressed: () {
                    final center = _mapController.camera.center;
                    _showAddPinDialog(center, selectedField.id);
                  },
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Add Observation Pin'),
                ),
                const SizedBox(height: 10),
                if (settings.showIrrigation && _selectedScheme != null)
                  _SchemeCard(
                    scheme: _selectedScheme!,
                    onClose: () => setState(() => _selectedScheme = null),
                  )
                else
                  FieldCard(
                    field: selectedField,
                    onViewDetails: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FieldDetailMapPage(fieldId: selectedField.id),
                        ),
                      );
                    },
                    onEditZones: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ZoneEditorPage(fieldId: selectedField.id),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundHudButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color color = Colors.white,
    Color iconColor = const Color(0xFF475569),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: iconColor),
        tooltip: tooltip,
        style: IconButton.styleFrom(padding: const EdgeInsets.all(12)),
      ),
    );
  }

  // Ray casting algorithm to determine if a LatLng is inside a Polygon boundary
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int i;
    int j = polygon.length - 1;
    bool inside = false;
    for (i = 0; i < polygon.length; i++) {
      if (((polygon[i].longitude < point.longitude &&
                  polygon[j].longitude >= point.longitude) ||
              (polygon[j].longitude < point.longitude &&
                  polygon[i].longitude >= point.longitude)) &&
          (polygon[i].latitude +
                  (point.longitude - polygon[i].longitude) /
                      (polygon[j].longitude - polygon[i].longitude) *
                      (polygon[j].latitude - polygon[i].latitude) <
              point.latitude)) {
        inside = !inside;
      }
      j = i;
    }
    return inside;
  }
}

class _SchemeCard extends StatelessWidget {
  final IrrigationScheme scheme;
  final VoidCallback onClose;

  const _SchemeCard({required this.scheme, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final utilizationPct = (scheme.utilization * 100).round();
    final green = const Color(0xFF16A34A);
    final dark = const Color(0xFF0F172A);
    final muted = const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shower_outlined,
                      color: Colors.blue.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Irrigation Scheme',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, size: 20),
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(28, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  scheme.name,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: dark,
                  ),
                ),
              ),
              Text(
                scheme.crop,
                style: GoogleFonts.inter(
                  color: muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Water Utilization ($utilizationPct%)',
                style: TextStyle(
                  fontSize: 12,
                  color: muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${scheme.waterUsed.toStringAsFixed(1)} / ${scheme.waterAllocated.toStringAsFixed(0)} m3',
                style: TextStyle(
                  fontSize: 12,
                  color: dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: scheme.utilization,
            minHeight: 8,
            backgroundColor: Colors.grey.shade100,
            color: Colors.blue.shade500,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Uptime',
                  value: '${(scheme.uptime * 100).round()}%',
                  icon: Icons.schedule_outlined,
                  color: green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Blocked',
                  value: '${scheme.blockedValves}',
                  icon: Icons.block_outlined,
                  color: scheme.blockedValves > 0 ? Colors.orange : muted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Alerts',
                  value: '${scheme.alerts}',
                  icon: Icons.warning_amber_outlined,
                  color: scheme.alerts > 0 ? Colors.red : muted,
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
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
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
