import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import 'package:verdi/features/logistics/data/logistics_data.dart';
import 'package:verdi/features/logistics/presentation/widgets/tracking_map.dart';

class LogisticsPage extends StatefulWidget {
  const LogisticsPage({super.key});

  @override
  State<LogisticsPage> createState() => _LogisticsPageState();
}

class _LogisticsPageState extends State<LogisticsPage> {
  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const background = Color(0xFFF8FAFC);

  final List<String> _filters = const [
    'All',
    'Pending',
    'Picked up',
    'On the way',
    'Delivered',
  ];

  String _selectedFilter = 'All';
  late List<DeliveryItem> _deliveriesList;
  String _selectedDeliveryId = '#DLV-101';

  static const Map<String, LatLng> _locationCoordinates = {
    'Chiredzi Farm': LatLng(-21.05, 31.67),
    'Harare Market': LatLng(-17.8638, 31.0285),
    'Mambo Farm': LatLng(-19.45, 29.81),
    'Masvingo Depot': LatLng(-20.0637, 30.8276),
    'Sunrise Poultry': LatLng(-20.15, 28.58),
    'Bulawayo Center': LatLng(-20.17, 28.56),
    'Mufasa Ranch': LatLng(-20.93, 29.01),
    'Gwanda Yard': LatLng(-20.94, 29.02),
  };

  @override
  void initState() {
    super.initState();
    _deliveriesList = List.from(LogisticsMockData.deliveries);
  }

  List<DeliveryItem> get _deliveries {
    if (_selectedFilter == 'All') return _deliveriesList;
    return _deliveriesList
        .where((d) => d.status == _selectedFilter)
        .toList();
  }

  void _showUpdateStatusDialog(DeliveryItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Status for ${item.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Pending', 'Picked up', 'On the way', 'Delivered'].map((status) {
              return ListTile(
                title: Text(status),
                trailing: item.status == status ? const Icon(Icons.check, color: green) : null,
                onTap: () {
                  Navigator.pop(context);
                  _updateDeliveryStatus(item.id, status);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _updateDeliveryStatus(String id, String newStatus) {
    setState(() {
      _deliveriesList = _deliveriesList.map((d) {
        if (d.id == id) {
          double progress = 0.12;
          if (newStatus == 'Picked up') progress = 0.45;
          if (newStatus == 'On the way') progress = 0.72;
          if (newStatus == 'Delivered') progress = 1.0;

          return DeliveryItem(
            id: d.id,
            customer: d.customer,
            product: d.product,
            quantity: d.quantity,
            from: d.from,
            to: d.to,
            status: newStatus,
            driver: d.driver,
            vehicle: d.vehicle,
            eta: newStatus == 'Delivered' ? 'Delivered' : d.eta,
            progress: progress,
          );
        }
        return d;
      }).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Delivery $id updated to $newStatus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deliveries = _deliveries;

    final selectedDelivery = _deliveriesList.firstWhere(
      (d) => d.id == _selectedDeliveryId,
      orElse: () => _deliveriesList.first,
    );

    final startPoint = _locationCoordinates[selectedDelivery.from] ?? const LatLng(-17.8292, 31.0522);
    final stopPoint = _locationCoordinates[selectedDelivery.to] ?? const LatLng(-17.8638, 31.0285);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1100;
            final isTablet =
                constraints.maxWidth >= 700 && constraints.maxWidth < 1100;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    isCompact: !isDesktop,
                    selectedFilter: _selectedFilter,
                    filters: _filters,
                    onFilterChanged: (v) =>
                        setState(() => _selectedFilter = v),
                  ),
                  const SizedBox(height: 16),
                  _StatsRow(
                    isTablet: isTablet,
                    isDesktop: isDesktop,
                    onStatSelected: (v) => setState(() => _selectedFilter = v),
                  ),
                  const SizedBox(height: 16),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _SectionCard(
                            title: 'Active Deliveries',
                            child: Column(
                              children: [
                                for (int i = 0; i < deliveries.length; i++) ...[
                                  _DeliveryCard(
                                    item: deliveries[i],
                                    onViewRoute: () {
                                      setState(() {
                                        _selectedDeliveryId = deliveries[i].id;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Showing route for ${deliveries[i].product} on the map.'),
                                        ),
                                      );
                                    },
                                    onUpdateStatus: () => _showUpdateStatusDialog(deliveries[i]),
                                  ),
                                  if (i != deliveries.length - 1)
                                    const SizedBox(height: 12),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _SectionCard(
                                title: 'Route Tracking',
                                child: TrackingMap(
                                  startPoint: startPoint,
                                  stopPoint: stopPoint,
                                  startLabel: selectedDelivery.from,
                                  stopLabel: selectedDelivery.to,
                                  eta: selectedDelivery.eta,
                                  distance: selectedDelivery.status == 'Delivered' ? '0 km' : '18.6 km',
                                ),
                              ),
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Vehicle Status',
                                child: const _VehicleStatusCard(),
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
                          title: 'Route Tracking',
                          child: TrackingMap(
                            startPoint: startPoint,
                            stopPoint: stopPoint,
                            startLabel: selectedDelivery.from,
                            stopLabel: selectedDelivery.to,
                            eta: selectedDelivery.eta,
                            distance: selectedDelivery.status == 'Delivered' ? '0 km' : '18.6 km',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Active Deliveries',
                          child: Column(
                            children: [
                              for (int i = 0; i < deliveries.length; i++) ...[
                                _DeliveryCard(
                                  item: deliveries[i],
                                  onViewRoute: () {
                                    setState(() {
                                      _selectedDeliveryId = deliveries[i].id;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Showing route for ${deliveries[i].product} on the map.'),
                                      ),
                                    );
                                  },
                                  onUpdateStatus: () => _showUpdateStatusDialog(deliveries[i]),
                                ),
                                if (i != deliveries.length - 1)
                                  const SizedBox(height: 12),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Vehicle Status',
                          child: const _VehicleStatusCard(),
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

class _Header extends StatelessWidget {
  final bool isCompact;
  final String selectedFilter;
  final List<String> filters;
  final ValueChanged<String> onFilterChanged;

  const _Header({
    required this.isCompact,
    required this.selectedFilter,
    required this.filters,
    required this.onFilterChanged,
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
                'Logistics',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: isCompact ? 24 : 28,
                  fontWeight: FontWeight.w800,
                  color: _LogisticsPageState.dark,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No new notifications.')),
                );
              },
              icon: const Icon(Icons.notifications_none_outlined),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.black12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Track active deliveries, drivers, and vehicle movement in real time.',
          style: GoogleFonts.inter(color: _LogisticsPageState.muted),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filters
              .map(
                (f) => ChoiceChip(
                  label: Text(f),
                  selected: selectedFilter == f,
                  selectedColor:
                      _LogisticsPageState.green.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: selectedFilter == f
                        ? _LogisticsPageState.green
                        : _LogisticsPageState.muted,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => onFilterChanged(f),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final bool isTablet;
  final bool isDesktop;
  final ValueChanged<String> onStatSelected;

  const _StatsRow({
    required this.isTablet,
    required this.isDesktop,
    required this.onStatSelected,
  });

  @override
  Widget build(BuildContext context) {
    final columns = isDesktop ? 4 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: LogisticsMockData.stats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 72,
      ),
      itemBuilder: (context, index) {
        final stat = LogisticsMockData.stats[index];
        return GestureDetector(
          onTap: () {
            if (index == 0) onStatSelected('All');
            if (index == 1) onStatSelected('Picked up');
            if (index == 2) onStatSelected('On the way');
            if (index == 3) onStatSelected('Pending');
          },
          child: Container(
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
                    color: _LogisticsPageState.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(stat.icon, color: _LogisticsPageState.green),
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
                          color: _LogisticsPageState.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stat.value,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _LogisticsPageState.dark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final DeliveryItem item;
  final VoidCallback onViewRoute;
  final VoidCallback onUpdateStatus;

  const _DeliveryCard({
    required this.item,
    required this.onViewRoute,
    required this.onUpdateStatus,
  });

  Color _statusColor() {
    switch (item.status) {
      case 'Pending':
        return Colors.orange;
      case 'Picked up':
        return Colors.blue;
      case 'On the way':
        return _LogisticsPageState.green;
      case 'Delivered':
        return Colors.grey;
      default:
        return _LogisticsPageState.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

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
                  '${item.product} • ${item.quantity}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _LogisticsPageState.dark,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${item.from} → ${item.to}',
            style: GoogleFonts.inter(color: _LogisticsPageState.muted),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: item.progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            color: _LogisticsPageState.green,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _InfoChip(icon: Icons.person_outline, label: item.driver),
              _InfoChip(
                  icon: Icons.local_shipping_outlined, label: item.vehicle),
              _InfoChip(icon: Icons.timer_outlined, label: item.eta),
              _InfoChip(icon: Icons.receipt_long_outlined, label: item.id),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewRoute,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _LogisticsPageState.green,
                    side: const BorderSide(color: _LogisticsPageState.green),
                  ),
                  child: const Text('View Route'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onUpdateStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _LogisticsPageState.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Update'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VehicleStatusCard extends StatelessWidget {
  const _VehicleStatusCard();

  @override
  Widget build(BuildContext context) {
    final vehicles = [
      ('Truck ZW-21', 'On route', 0.72),
      ('Truck ZW-09', 'Loading', 0.34),
      ('Van ZW-14', 'Idle', 0.10),
    ];

    return Column(
      children: vehicles.map((v) {
        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${v.$1} status: ${v.$2}')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _LogisticsPageState.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    color: _LogisticsPageState.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.$1,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        v.$2,
                        style: const TextStyle(
                          color: _LogisticsPageState.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: v.$3,
                        minHeight: 7,
                        backgroundColor: Colors.grey.shade200,
                        color: _LogisticsPageState.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

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

  const _SectionCard({
    required this.title,
    required this.child,
  });

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
              color: _LogisticsPageState.dark,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}