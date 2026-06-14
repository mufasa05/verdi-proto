import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../state/location_state.dart';

class LogisticsDashboardPage extends ConsumerStatefulWidget {
  const LogisticsDashboardPage({super.key});

  @override
  ConsumerState<LogisticsDashboardPage> createState() => _LogisticsDashboardPageState();
}

class _LogisticsDashboardPageState extends ConsumerState<LogisticsDashboardPage> {
  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const orange = Color(0xFFF97316);
  static const blue = Color(0xFF2563EB);
  static const purple = Color(0xFF7C3AED);
  static const teal = Color(0xFF0F766E);

  final MapController _mapController = MapController();
  final ImagePicker _picker = ImagePicker();

  LatLng? _selectedHub;
  String _selectedHubName = 'Select a hub';
  String _etaText = '--';
  File? _proofImage;

  final List<_Hub> hubs = [
    _Hub('Harare Hub', const LatLng(-17.82772, 31.05337), green),
    _Hub('Bulawayo Hub', const LatLng(-20.15, 28.58333), orange),
    _Hub('Mutare Hub', const LatLng(-18.9707, 32.67086), blue),
    _Hub('Gweru Hub', const LatLng(-19.45, 29.81667), purple),
    _Hub('Masvingo Hub', const LatLng(-20.06373, 30.82766), teal),
    _Hub('Chitungwiza Hub', const LatLng(-18.01274, 31.07555), Colors.deepOrange),
  ];

  String _formatEta(double distanceMeters, double speedKmh) {
    final km = distanceMeters / 1000.0;
    final hours = km / speedKmh;
    final minutes = (hours * 60).round();
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }

  void _selectHub(_Hub hub, LatLng? userLocation) {
    setState(() {
      _selectedHub = hub.point;
      _selectedHubName = hub.name;
      if (userLocation != null) {
        final d = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          hub.point.latitude,
          hub.point.longitude,
        );
        _etaText = _formatEta(d, 45);
      }
    });
    _mapController.move(hub.point, 10);
  }

  void _autoSelectNearestHub(LatLng userLocation) {
    _Hub? nearest;
    double best = double.infinity;

    for (final hub in hubs) {
      final d = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        hub.point.latitude,
        hub.point.longitude,
      );
      if (d < best) {
        best = d;
        nearest = hub;
      }
    }

    if (nearest != null) {
      setState(() {
        _selectedHub = nearest!.point;
        _selectedHubName = nearest.name;
        _etaText = _formatEta(best, 45);
      });
    }
  }

  Future<void> _pickProofImage() async {
    final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 75);
    if (image == null) return;
    setState(() => _proofImage = File(image.path));
  }

  void _dispatchNow() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dispatch created for $_selectedHubName')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationStreamProvider);
    final position = locationAsync.value;
    final userLocation = position == null ? null : LatLng(position.latitude, position.longitude);

    if (userLocation != null && _selectedHub == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _autoSelectNearestHub(userLocation);
      });
    } else if (userLocation != null && _selectedHub != null) {
      final d = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        _selectedHub!.latitude,
        _selectedHub!.longitude,
      );
      _etaText = _formatEta(d, 45);
    }

    return Scaffold(
      endDrawer: _ActionDrawer(
        selectedHubName: _selectedHubName,
        etaText: _etaText,
        proofImage: _proofImage,
        onPickProofImage: _pickProofImage,
        onDispatchNow: _dispatchNow,
        onRefreshLocation: () async {
          ref.invalidate(locationStreamProvider);
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(
                'Logistics',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: dark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nearest hub, ETA, proof-of-delivery, and dispatch control.',
                style: GoogleFonts.inter(color: muted),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 1100;

                  final map = _MapCard(
                    mapController: _mapController,
                    markers: _markers(userLocation),
                    polylines: _polylines(userLocation),
                    onOpenDrawer: () => Scaffold.of(context).openEndDrawer(),
                    loadingLocation: locationAsync.isLoading,
                  );

                  final panel = _StatusPanel(
                    selectedHubName: _selectedHubName,
                    etaText: _etaText,
                    proofImage: _proofImage,
                    hasLocation: userLocation != null,
                    onRefreshLocation: () async {
                      ref.invalidate(locationStreamProvider);
                    },
                    onPickProofImage: _pickProofImage,
                    onDispatchNow: _dispatchNow,
                    onOpenDrawer: () => Scaffold.of(context).openEndDrawer(),
                  );

                  return wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: map),
                            const SizedBox(width: 16),
                            Expanded(child: panel),
                          ],
                        )
                      : Column(
                          children: [
                            map,
                            const SizedBox(height: 16),
                            panel,
                          ],
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Marker> _markers(LatLng? userLocation) {
    final list = <Marker>[];

    for (final hub in hubs) {
      list.add(
        Marker(
          point: hub.point,
          width: 120,
          height: 56,
          child: GestureDetector(
            onTap: () => _selectHub(hub, userLocation),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: hub.color,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    hub.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Icon(Icons.location_pin, color: hub.color, size: 32),
              ],
            ),
          ),
        ),
      );
    }

    if (userLocation != null) {
      list.add(
        Marker(
          point: userLocation,
          width: 42,
          height: 42,
          child: const Icon(Icons.my_location, color: Colors.blue, size: 28),
        ),
      );
    }

    return list;
  }

  List<Polyline> _polylines(LatLng? userLocation) {
    if (userLocation == null || _selectedHub == null) return [];
    return [
      Polyline(
        points: [userLocation, _selectedHub!],
        strokeWidth: 4,
        color: green,
      ),
    ];
  }
}

class _MapCard extends StatelessWidget {
  final MapController mapController;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final VoidCallback onOpenDrawer;
  final bool loadingLocation;

  const _MapCard({
    required this.mapController,
    required this.markers,
    required this.polylines,
    required this.onOpenDrawer,
    required this.loadingLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 540,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: const MapOptions(
                initialCenter: LatLng(-19.0, 30.5),
                initialZoom: 6.2,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.verdi.app',
                ),
                PolylineLayer(polylines: polylines),
                MarkerLayer(markers: markers),
              ],
            ),
            Positioned(
              top: 12,
              right: 12,
              child: FloatingActionButton.small(
                onPressed: onOpenDrawer,
                backgroundColor: _Colors.green,
                foregroundColor: Colors.white,
                child: const Icon(Icons.route_outlined),
              ),
            ),
            if (loadingLocation)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x33FFFFFF),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  final String selectedHubName;
  final String etaText;
  final bool hasLocation;
  final File? proofImage;
  final Future<void> Function() onRefreshLocation;
  final Future<void> Function() onPickProofImage;
  final VoidCallback onDispatchNow;
  final VoidCallback onOpenDrawer;

  const _StatusPanel({
    required this.selectedHubName,
    required this.etaText,
    required this.hasLocation,
    required this.proofImage,
    required this.onRefreshLocation,
    required this.onPickProofImage,
    required this.onDispatchNow,
    required this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      ('Active routes', '12', Icons.alt_route_outlined, _Colors.green),
      ('On-time deliveries', '91%', Icons.timer_outlined, _Colors.blue),
      ('Pending pickups', '6', Icons.inventory_2_outlined, _Colors.orange),
      ('In transit', '18', Icons.local_shipping_outlined, _Colors.purple),
    ];

    return Column(
      children: [
        _SectionCard(
          title: 'Selected hub',
          child: ListTile(
            leading: const Icon(Icons.place_outlined),
            title: Text(selectedHubName),
            subtitle: Text(hasLocation ? 'ETA: $etaText' : 'Location not active yet'),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: cards
              .map(
                (item) => _MetricCard(
                  title: item.$1,
                  value: item.$2,
                  icon: item.$3,
                  color: item.$4,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Proof of delivery',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (proofImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    proofImage!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 180,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('No proof image captured yet'),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onPickProofImage,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Capture'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDispatchNow,
                      icon: const Icon(Icons.send_outlined),
                      label: const Text('Dispatch'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Action queue',
          child: Column(
            children: const [
              _ActionTile('Dispatch new harvest load', 'Ready for pickup at farm gate'),
              _ActionTile('Confirm buyer delivery', 'Wholesale order awaiting proof'),
              _ActionTile('Check vehicle fuel status', 'Truck below threshold'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onRefreshLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Refresh live location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onOpenDrawer,
                icon: const Icon(Icons.route_outlined),
                label: const Text('More actions'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _Colors.green,
                  side: const BorderSide(color: _Colors.green),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionDrawer extends StatelessWidget {
  final String selectedHubName;
  final String etaText;
  final File? proofImage;
  final Future<void> Function() onPickProofImage;
  final VoidCallback onDispatchNow;
  final Future<void> Function() onRefreshLocation;

  const _ActionDrawer({
    required this.selectedHubName,
    required this.etaText,
    required this.proofImage,
    required this.onPickProofImage,
    required this.onDispatchNow,
    required this.onRefreshLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Logistics Actions',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Selected hub: $selectedHubName'),
              Text('ETA: $etaText'),
              const SizedBox(height: 12),
              if (proofImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(proofImage!, height: 150, width: double.infinity, fit: BoxFit.cover),
                )
              else
                Container(
                  height: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Proof photo not captured'),
                ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Capture proof'),
                onTap: () async => onPickProofImage(),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.send_outlined),
                title: const Text('Dispatch now'),
                onTap: onDispatchNow,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.my_location),
                title: const Text('Refresh location'),
                onTap: () async => onRefreshLocation(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title),
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ActionTile(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.check_circle_outline),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

class _Hub {
  final String name;
  final LatLng point;
  final Color color;

  _Hub(this.name, this.point, this.color);
}

class _Colors {
  static const green = Color(0xFF16A34A);
  static const blue = Color(0xFF2563EB);
  static const orange = Color(0xFFF97316);
  static const purple = Color(0xFF7C3AED);
}