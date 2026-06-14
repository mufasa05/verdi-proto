import 'package:flutter/material.dart';
import 'package:verdi/core/widgets/metric_grid.dart';
import 'package:verdi/core/widgets/metric_item.dart';
import 'package:verdi/core/widgets/verdi_page_scaffold.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VerdiPageScaffold(
      title: 'Dashboard',
      subtitle: 'Overview of weather, trade, logistics, and finance activity.',
      child: MetricGrid(
        items: const [
          MetricItem(
            icon: Icons.groups,
            label: 'Active Farmers',
            value: '1,284',
            subtitle: '12% increase this week',
          ),
          MetricItem(
            icon: Icons.warning_amber_outlined,
            label: 'Weather Alerts',
            value: '6',
            subtitle: '2 high-priority alerts',
            accentColor: Colors.orange,
          ),
          MetricItem(
            icon: Icons.swap_horiz,
            label: 'Open Trades',
            value: '18',
            subtitle: '5 pending approvals',
            accentColor: Colors.green,
          ),
          MetricItem(
            icon: Icons.account_balance_wallet,
            label: 'Revenue',
            value: 'KES 2.4M',
            subtitle: 'This month so far',
            accentColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}