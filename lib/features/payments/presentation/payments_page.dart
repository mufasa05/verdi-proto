import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const background = Color(0xFFF8FAFC);

  final List<String> _filters = const [
    'All',
    'Pending',
    'Completed',
    'Failed',
    'Refunded',
  ];

  String _selectedFilter = 'All';

  final List<PaymentItem> _payments = const [
    PaymentItem(
      id: '#PAY-1001',
      party: 'FreshMart Ltd',
      type: 'Buyer Payment',
      amount: 'US\$ 96',
      status: 'Completed',
      method: 'EcoCash',
      date: 'Today, 09:20',
      ref: 'TXN-8821',
      note: 'Tomatoes order',
    ),
    PaymentItem(
      id: '#PAY-1002',
      party: 'Green Basket',
      type: 'Buyer Payment',
      amount: 'US\$ 258',
      status: 'Pending',
      method: 'Bank Transfer',
      date: 'Today, 10:10',
      ref: 'TXN-8822',
      note: 'Maize order',
    ),
    PaymentItem(
      id: '#PAY-1003',
      party: 'City Grocers',
      type: 'Payout',
      amount: 'US\$ 176',
      status: 'Completed',
      method: 'Wallet',
      date: 'Yesterday, 16:45',
      ref: 'TXN-8819',
      note: 'Potatoes settlement',
    ),
    PaymentItem(
      id: '#PAY-1004',
      party: 'Hotel Supply Co',
      type: 'Buyer Payment',
      amount: 'US\$ 144',
      status: 'Failed',
      method: 'Card',
      date: 'Today, 11:05',
      ref: 'TXN-8823',
      note: 'Mango order',
    ),
  ];

  late PaymentItem _selectedPayment = _payments.first;

  List<PaymentItem> get _filteredPayments {
    if (_selectedFilter == 'All') return _payments;
    return _payments.where((p) => p.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final payments = _filteredPayments;

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
                    selectedFilter: _selectedFilter,
                    filters: _filters,
                    onFilterChanged: (v) {
                      setState(() {
                        _selectedFilter = v;
                        if (_filteredPayments.isNotEmpty) {
                          _selectedPayment = _filteredPayments.first;
                        }
                      });
                    },
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
                          child: _SectionCard(
                            title: 'Transactions',
                            child: Column(
                              children: [
                                for (int i = 0; i < payments.length; i++) ...[
                                  _PaymentCard(
                                    payment: payments[i],
                                    selected:
                                        payments[i].id == _selectedPayment.id,
                                    onTap: () {
                                      setState(() {
                                        _selectedPayment = payments[i];
                                      });
                                    },
                                  ),
                                  if (i != payments.length - 1)
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
                                title: 'Payment Detail',
                                child: _PaymentDetailPanel(
                                  payment: _selectedPayment,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Wallet Summary',
                                child: const _WalletSummary(),
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
                          title: 'Payment Detail',
                          child: _PaymentDetailPanel(payment: _selectedPayment),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Transactions',
                          child: Column(
                            children: [
                              for (int i = 0; i < payments.length; i++) ...[
                                _PaymentCard(
                                  payment: payments[i],
                                  selected:
                                      payments[i].id == _selectedPayment.id,
                                  onTap: () {
                                    setState(() {
                                      _selectedPayment = payments[i];
                                    });
                                  },
                                ),
                                if (i != payments.length - 1)
                                  const SizedBox(height: 12),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Wallet Summary',
                          child: const _WalletSummary(),
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
                'Payments',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: isCompact ? 24 : 28,
                  fontWeight: FontWeight.w800,
                  color: _PaymentsColors.dark,
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.account_balance_wallet_outlined),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.black12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Track settlements, buyer payments, payouts, refunds, and wallet activity.',
          style: GoogleFonts.inter(color: _PaymentsColors.muted),
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
                      _PaymentsColors.green.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: selectedFilter == f
                        ? _PaymentsColors.green
                        : _PaymentsColors.muted,
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
      _StatData('Received', 'US\$ 674', Icons.payments_outlined),
      _StatData('Pending', 'US\$ 258', Icons.hourglass_top_outlined),
      _StatData('Payouts', 'US\$ 176', Icons.send_outlined),
      _StatData('Refunds', 'US\$ 0', Icons.undo_outlined),
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
                  color: _PaymentsColors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(stat.icon, color: _PaymentsColors.green),
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
                        color: _PaymentsColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat.value,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _PaymentsColors.dark,
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

class _PaymentCard extends StatelessWidget {
  final PaymentItem payment;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentCard({
    required this.payment,
    required this.selected,
    required this.onTap,
  });

  Color _statusColor() {
    switch (payment.status) {
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return _PaymentsColors.green;
      case 'Failed':
        return Colors.red;
      case 'Refunded':
        return Colors.blueGrey;
      default:
        return _PaymentsColors.muted;
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
          color: selected ? _PaymentsColors.green.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? _PaymentsColors.green : Colors.black12,
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
                    '${payment.id} • ${payment.party}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _PaymentsColors.dark,
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
                    payment.status,
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
              '${payment.type} • ${payment.note}',
              style: GoogleFonts.inter(color: _PaymentsColors.muted),
            ),
            const SizedBox(height: 6),
            Text(
              '${payment.method} • ${payment.date}',
              style: const TextStyle(fontSize: 12, color: _PaymentsColors.muted),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: _progressValue(payment.status),
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
        return 0.35;
      case 'Completed':
        return 1.0;
      case 'Failed':
        return 0.05;
      case 'Refunded':
        return 0.75;
      default:
        return 0.35;
    }
  }
}

class _PaymentDetailPanel extends StatelessWidget {
  final PaymentItem payment;

  const _PaymentDetailPanel({required this.payment});

  Color _statusColor() {
    switch (payment.status) {
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return _PaymentsColors.green;
      case 'Failed':
        return Colors.red;
      case 'Refunded':
        return Colors.blueGrey;
      default:
        return _PaymentsColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          payment.id,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _PaymentsColors.dark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          payment.party,
          style: const TextStyle(color: _PaymentsColors.muted),
        ),
        const SizedBox(height: 16),
        _DetailRow(label: 'Type', value: payment.type),
        _DetailRow(label: 'Amount', value: payment.amount),
        _DetailRow(label: 'Method', value: payment.method),
        _DetailRow(label: 'Status', value: payment.status),
        _DetailRow(label: 'Reference', value: payment.ref),
        _DetailRow(label: 'Date', value: payment.date),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _progressValue(payment.status),
          minHeight: 8,
          backgroundColor: Colors.grey.shade200,
          color: statusColor,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MiniChip(label: payment.note, icon: Icons.receipt_long_outlined),
            _MiniChip(label: 'View invoice', icon: Icons.picture_as_pdf_outlined),
            _MiniChip(label: 'Send receipt', icon: Icons.send_outlined),
            _MiniChip(label: 'Flag issue', icon: Icons.report_outlined),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: _PaymentsColors.green,
                  side: const BorderSide(color: _PaymentsColors.green),
                ),
                child: const Text('Export'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _PaymentsColors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reconcile'),
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
        return 0.35;
      case 'Completed':
        return 1.0;
      case 'Failed':
        return 0.05;
      case 'Refunded':
        return 0.75;
      default:
        return 0.35;
    }
  }
}

class _WalletSummary extends StatelessWidget {
  const _WalletSummary();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Available Balance', 'US\$ 1,240'),
      ('Pending Settlements', 'US\$ 258'),
      ('Today\'s Inflow', 'US\$ 430'),
      ('Today\'s Outflow', 'US\$ 176'),
    ];

    return Column(
      children: [
        for (final item in items) ...[
          _WalletRow(label: item.$1, value: item.$2),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _WalletRow extends StatelessWidget {
  final String label;
  final String value;

  const _WalletRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: _PaymentsColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: _PaymentsColors.dark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
                color: _PaymentsColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _PaymentsColors.dark,
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
              color: _PaymentsColors.dark,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class PaymentItem {
  final String id;
  final String party;
  final String type;
  final String amount;
  final String status;
  final String method;
  final String date;
  final String ref;
  final String note;

  const PaymentItem({
    required this.id,
    required this.party,
    required this.type,
    required this.amount,
    required this.status,
    required this.method,
    required this.date,
    required this.ref,
    required this.note,
  });
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;

  _StatData(this.label, this.value, this.icon);
}

class _PaymentsColors {
  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
}