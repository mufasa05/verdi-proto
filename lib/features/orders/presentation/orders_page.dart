import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/platform_data_state.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  final List<String> _filters = const [
    'All',
    'Pending',
    'Confirmed',
    'In Transit',
    'Delivered',
    'Cancelled',
  ];

  String _selectedFilter = 'All';
  String? _selectedOrderId;

  List<OrderItem> _filteredOrders(List<OrderItem> allOrders) {
    if (_selectedFilter == 'All') return allOrders;
    return allOrders.where((o) => o.status == _selectedFilter).toList();
  }


  @override
  Widget build(BuildContext context) {
    final allOrders = ref.watch(ordersListProvider);
    final orders = _filteredOrders(allOrders);

    if (_selectedOrderId == null && orders.isNotEmpty) {
      _selectedOrderId = orders.first.id;
    }
    final selectedOrder = orders.firstWhere(
      (o) => o.id == _selectedOrderId,
      orElse: () => orders.isNotEmpty ? orders.first : const OrderItem(
        id: '', buyer: '', product: '', quantity: '', destination: '',
        status: '', payment: '', total: '', date: '', eta: '', priority: ''
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
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
                    selectedFilter: _selectedFilter,
                    filters: _filters,
                    onFilterChanged: (v) {
                      setState(() {
                        _selectedFilter = v;
                        final filtered = _filteredOrders(allOrders);
                        if (filtered.isNotEmpty) {
                          _selectedOrderId = filtered.first.id;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _StatsGrid(isDesktop: isDesktop),
                  const SizedBox(height: 16),
                  if (orders.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No orders found matching this filter.'),
                      ),
                    )
                  else if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _SectionCard(
                            title: 'Orders',
                            child: Column(
                              children: [
                                for (int i = 0; i < orders.length; i++) ...[
                                  _OrderCard(
                                    order: orders[i],
                                    selected: orders[i].id == _selectedOrderId,
                                    onTap: () {
                                      setState(() => _selectedOrderId = orders[i].id);
                                    },
                                  ),
                                  if (i != orders.length - 1)
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
                                title: 'Order Detail',
                                child: _OrderDetailPanel(order: selectedOrder),
                              ),
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Fulfillment Timeline',
                                child: _Timeline(order: selectedOrder),
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
                          title: 'Order Detail',
                          child: _OrderDetailPanel(order: selectedOrder),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Orders',
                          child: Column(
                            children: [
                              for (int i = 0; i < orders.length; i++) ...[
                                _OrderCard(
                                  order: orders[i],
                                  selected: orders[i].id == _selectedOrderId,
                                  onTap: () {
                                    setState(() => _selectedOrderId = orders[i].id);
                                  },
                                ),
                                if (i != orders.length - 1)
                                  const SizedBox(height: 12),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Fulfillment Timeline',
                          child: _Timeline(order: selectedOrder),
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
                'Orders',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: isCompact ? 24 : 28,
                  fontWeight: FontWeight.w800,
                  color: _OrdersColors.dark,
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.local_shipping_outlined),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.black12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Track buyer requests, fulfillment progress, payment status, and delivery movement.',
          style: GoogleFonts.inter(color: _OrdersColors.muted),
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
                  selectedColor: _OrdersColors.green.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: selectedFilter == f
                        ? _OrdersColors.green
                        : _OrdersColors.muted,
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

class _StatsGrid extends StatelessWidget {
  final bool isDesktop;

  const _StatsGrid({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatData('Orders', '4', Icons.receipt_long_outlined),
      _StatData('Pending', '1', Icons.pending_actions_outlined),
      _StatData('In Transit', '1', Icons.delivery_dining_outlined),
      _StatData('Revenue', 'US\$ 674', Icons.payments_outlined),
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
                  color: _OrdersColors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(stat.icon, color: _OrdersColors.green),
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
                        color: _OrdersColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat.value,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _OrdersColors.dark,
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

class _OrderCard extends StatelessWidget {
  final OrderItem order;
  final bool selected;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.selected,
    required this.onTap,
  });

  Color _statusColor() {
    switch (order.status) {
      case 'Pending':
        return Colors.orange;
      case 'Confirmed':
        return Colors.blue;
      case 'In Transit':
        return _OrdersColors.green;
      case 'Delivered':
        return Colors.grey;
      case 'Cancelled':
        return Colors.red;
      default:
        return _OrdersColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _OrdersColors.green.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? _OrdersColors.green : Colors.black12,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${order.id} • ${order.buyer}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _OrdersColors.dark,
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
                    order.status,
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
              '${order.product} • ${order.quantity}',
              style: GoogleFonts.inter(color: _OrdersColors.muted),
            ),
            const SizedBox(height: 6),
            Text(
              '${order.destination} • ${order.date}',
              style: const TextStyle(fontSize: 12, color: _OrdersColors.muted),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: _progressValue(order.status),
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: statusColor,
            ),
          ],
        ),
      ),
    );
  }

  double _progressValue(String status) {
    switch (status) {
      case 'Pending':
        return 0.2;
      case 'Confirmed':
        return 0.45;
      case 'In Transit':
        return 0.75;
      case 'Delivered':
        return 1.0;
      case 'Cancelled':
        return 0.0;
      default:
        return 0.2;
    }
  }
}

class _OrderDetailPanel extends StatelessWidget {
  final OrderItem order;

  const _OrderDetailPanel({required this.order});

  Color _statusColor() {
    switch (order.status) {
      case 'Pending':
        return Colors.orange;
      case 'Confirmed':
        return Colors.blue;
      case 'In Transit':
        return _OrdersColors.green;
      case 'Delivered':
        return Colors.grey;
      case 'Cancelled':
        return Colors.red;
      default:
        return _OrdersColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.id,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _OrdersColors.dark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          order.buyer,
          style: const TextStyle(color: _OrdersColors.muted),
        ),
        const SizedBox(height: 16),
        _DetailRow(label: 'Product', value: order.product),
        _DetailRow(label: 'Quantity', value: order.quantity),
        _DetailRow(label: 'Destination', value: order.destination),
        _DetailRow(label: 'Total', value: order.total),
        _DetailRow(label: 'Payment', value: order.payment),
        _DetailRow(label: 'Priority', value: order.priority),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _progressValue(order.status),
          minHeight: 8,
          backgroundColor: Colors.grey.shade200,
          color: statusColor,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MiniChip(label: order.status, icon: Icons.info_outline),
            _MiniChip(label: order.eta, icon: Icons.timer_outlined),
            _MiniChip(label: 'Open route', icon: Icons.alt_route_outlined),
            _MiniChip(label: 'Message buyer', icon: Icons.chat_bubble_outline),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: _OrdersColors.green,
                  side: const BorderSide(color: _OrdersColors.green),
                ),
                child: const Text('View Invoice'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _OrdersColors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Update Status'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _progressValue(String status) {
    switch (status) {
      case 'Pending':
        return 0.2;
      case 'Confirmed':
        return 0.45;
      case 'In Transit':
        return 0.75;
      case 'Delivered':
        return 1.0;
      case 'Cancelled':
        return 0.0;
      default:
        return 0.2;
    }
  }
}

class _Timeline extends StatelessWidget {
  final OrderItem order;

  const _Timeline({required this.order});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Order placed', true),
      ('Seller confirmed', order.status != 'Pending' && order.status != 'Cancelled'),
      ('Packed for dispatch', order.status == 'In Transit' || order.status == 'Delivered'),
      ('Delivered', order.status == 'Delivered'),
    ];

    return Column(
      children: steps.map((step) {
        final done = step.$2;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: done ? _OrdersColors.green : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.$1,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: done ? _OrdersColors.dark : _OrdersColors.muted,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _OrdersColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _OrdersColors.dark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MiniChip({
    required this.label,
    required this.icon,
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
              color: _OrdersColors.dark,
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

class _OrdersColors {
  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
}