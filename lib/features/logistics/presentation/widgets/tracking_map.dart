import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrackingMap extends StatelessWidget {
  final LatLng startPoint;
  final LatLng stopPoint;
  final String startLabel;
  final String stopLabel;
  final String eta;
  final String distance;

  const TrackingMap({
    super.key,
    required this.startPoint,
    required this.stopPoint,
    required this.startLabel,
    required this.stopLabel,
    required this.eta,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final midpoint = LatLng(
      (startPoint.latitude + stopPoint.latitude) / 2,
      (startPoint.longitude + stopPoint.longitude) / 2,
    );

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: midpoint,
                  initialZoom: 8.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.verdi.app',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [startPoint, stopPoint],
                        strokeWidth: 4,
                        color: const Color(0xFF16A34A),
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: startPoint,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.blue,
                          size: 32,
                        ),
                      ),
                      Marker(
                        point: stopPoint,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: _RouteBadge(label: 'Start: $startLabel', color: Colors.blue),
            ),
            Positioned(
              top: 48,
              left: 12,
              child: _RouteBadge(label: 'Stop: $stopLabel', color: Colors.red),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _RouteSummaryCard(eta: eta, distance: distance, stopLabel: stopLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _RouteBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteSummaryCard extends StatelessWidget {
  final String eta;
  final String distance;
  final String stopLabel;

  const _RouteSummaryCard({
    required this.eta,
    required this.distance,
    required this.stopLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Route ETA: $eta',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text('$stopLabel • $distance'),
        ],
      ),
    );
  }
}