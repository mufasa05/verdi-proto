import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/mock_app_data.dart';
import '../../../state/app_state.dart';
import 'widgets/dashboard_navigation_rail.dart';
import 'widgets/dashboard_side_panel.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const cream = Color(0xFFF7F9FC);
  static const orange = Color(0xFFF97316);
  static const blue = Color(0xFF2563EB);
  static const purple = Color(0xFF7C3AED);
  static const teal = Color(0xFF0F766E);
  static const muted = Color(0xFF64748B);

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final roleLabel = switch (appState.role) {
      UserRole.farmer => 'Farmer',
      UserRole.buyer => 'Buyer',
      UserRole.driver => 'Driver',
      UserRole.admin => 'Admin',
    };

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 1180;

            final mainColumn = SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    greeting: _greeting(),
                    farmerName: MockAppData.farmerName,
                    location: MockAppData.location,
                    roleLabel: roleLabel,
                  ),
                  const SizedBox(height: 12),
                  _RoleSwitcher(currentRole: appState.role),
                  const SizedBox(height: 12),
                  _MiniStatsRow(),
                  const SizedBox(height: 12),
                  _InsightStrip(),
                  const SizedBox(height: 12),
                  
                  const _SectionTitle(
                    title: 'Market momentum',
                    subtitle: 'Short-term demand and price movement',
                  ),
                  const SizedBox(height: 10),
                  _MarketMomentumCard(),
                  const SizedBox(height: 12),
                  const _SectionTitle(
                    title: 'Top listings',
                    subtitle: 'Recent activity from your farm',
                  ),
                  const SizedBox(height: 10),
                  _ListingsCard(),
                  const SizedBox(height: 12),
                  const _SectionTitle(
                    title: 'Weather and crop health',
                    subtitle: 'Quick conditions and field status',
                  ),
                  const SizedBox(height: 10),
                  _WeatherCropSection(),
                  const SizedBox(height: 12),
                  _QuickActions(),
                  const SizedBox(height: 80),
                ],
              ),
            );

            if (!wide) return mainColumn;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardNavigationRail(currentRole: appState.role),
                Expanded(flex: 3, child: mainColumn),
                const SizedBox(
                  width: 340,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 16, 16, 16),
                    child: DashboardSidePanel(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String greeting;
  final String farmerName;
  final String location;
  final String roleLabel;

  const _Header({
    required this.greeting,
    required this.farmerName,
    required this.location,
    required this.roleLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF16A34A), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(Icons.agriculture_outlined, color: HomePage.green, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $farmerName',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$roleLabel dashboard • $location',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Live',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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

class _RoleSwitcher extends ConsumerWidget {
  final UserRole currentRole;

  const _RoleSwitcher({required this.currentRole});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(appStateProvider.notifier);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: UserRole.values.map((role) {
        final selected = role == currentRole;
        final label = switch (role) {
          UserRole.farmer => 'Farmer',
          UserRole.buyer => 'Buyer',
          UserRole.driver => 'Driver',
          UserRole.admin => 'Admin',
        };

        return ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => notifier.setRole(role),
          selectedColor: HomePage.green.withValues(alpha: 0.14),
          labelStyle: TextStyle(
            color: selected ? HomePage.green : HomePage.dark,
            fontWeight: FontWeight.w700,
          ),
          side: BorderSide(
            color: selected ? HomePage.green : HomePage.muted.withValues(alpha: 0.18),
          ),
        );
      }).toList(),
    );
  }
}

class _MiniStatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Active listings', '12', Icons.storefront_outlined, HomePage.green),
      ('New buyers', '3', Icons.people_outline, HomePage.blue),
      ('Deliveries', '5', Icons.local_shipping_outlined, HomePage.orange),
      ('Est revenue', '\$1,245', Icons.payments_outlined, HomePage.purple),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 1000
            ? 4
            : constraints.maxWidth > 650
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3.8,
          ),
          itemBuilder: (context, index) {
            final item = stats[index];
            return _StatCard(
              title: item.$1,
              value: item.$2,
              icon: item.$3,
              color: item.$4,
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 11, color: HomePage.muted)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: HomePage.dark,
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

class _InsightStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _InsightCardData(
        title: '3 buyers in Chiredzi need tomatoes',
        subtitle: 'Demand is high near your farm this morning.',
        action: 'View buyers',
        imageUrl: 'https://images.unsplash.com/photo-1546470427-227c2e6b1b4c?auto=format&fit=crop&w=1200&q=80',
        color: HomePage.green,
      ),
      _InsightCardData(
        title: 'Tomato price trend is up 12%',
        subtitle: 'You may want to list more inventory today.',
        action: 'See trend',
        imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=1200&q=80',
        color: HomePage.orange,
      ),
      _InsightCardData(
        title: 'Rain expected tomorrow',
        subtitle: 'Delivery timing may need adjustment.',
        action: 'View forecast',
        imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80',
        color: HomePage.blue,
      ),
      _InsightCardData(
        title: 'Crop stress detected in East field',
        subtitle: 'Monitor moisture and leaf health soon.',
        action: 'Check field',
        imageUrl: 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?auto=format&fit=crop&w=1200&q=80',
        color: HomePage.purple,
      ),
    ];

    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _InsightCard(data: items[index]),
      ),
    );
  }
}

class _InsightCardData {
  final String title;
  final String subtitle;
  final String action;
  final String imageUrl;
  final Color color;

  _InsightCardData({
    required this.title,
    required this.subtitle,
    required this.action,
    required this.imageUrl,
    required this.color,
  });
}

class _InsightCard extends StatelessWidget {
  final _InsightCardData data;

  const _InsightCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: NetworkImage(data.imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.42),
            BlendMode.darken,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Farmer insight',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              data.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.92), fontSize: 11),
            ),
            const SizedBox(height: 8),
            Text(
              data.action,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketMomentumCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.5,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withValues(alpha: 0.18),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  final i = value.toInt();
                  if (i < 0 || i >= days.length) return const SizedBox.shrink();
                  return Text(days[i], style: const TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 1.6),
                FlSpot(1, 2.0),
                FlSpot(2, 1.8),
                FlSpot(3, 2.4),
                FlSpot(4, 2.6),
                FlSpot(5, 2.9),
                FlSpot(6, 3.1),
              ],
              isCurved: true,
              color: HomePage.green,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: HomePage.green.withValues(alpha: 0.10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final listings = MockAppData.topListings;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 720),
          child: DataTable(
            headingRowHeight: 42,
            dataRowMinHeight: 48,
            dataRowMaxHeight: 56,
            columns: const [
              DataColumn(label: Text('Product')),
              DataColumn(label: Text('Quantity')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Views')),
              DataColumn(label: Text('Inquiries')),
              DataColumn(label: Text('Status')),
            ],
            rows: listings
                .map(
                  (e) => DataRow(
                    cells: [
                      DataCell(Text(e.product)),
                      DataCell(Text(e.quantity)),
                      DataCell(Text(e.price)),
                      DataCell(Text('${e.views}')),
                      DataCell(Text('${e.inquiries}')),
                      DataCell(Text(e.status)),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _WeatherCropSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weather = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Weather', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text('Chiredzi, 24°C'),
          SizedBox(height: 4),
          Text('Humidity 80% • Wind 17 km/h'),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ForecastChip('Fri 24°/16°'),
              _ForecastChip('Sat 25°/17°'),
              _ForecastChip('Sun 26°/18°'),
              _ForecastChip('Mon 24°/15°'),
              _ForecastChip('Tue 23°/14°'),
            ],
          ),
        ],
      ),
    );

    final crop = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Crop health', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80',
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          const Text('NDVI score: 0.63'),
          const SizedBox(height: 3),
          const Text('Status: Moderate'),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 900;
        return wide
            ? Row(
                children: [
                  Expanded(child: weather),
                  const SizedBox(width: 12),
                  Expanded(child: crop),
                ],
              )
            : Column(
                children: [
                  weather,
                  const SizedBox(height: 12),
                  crop,
                ],
              );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 13, color: HomePage.muted)),
      ],
    );
  }
}

class _ForecastChip extends StatelessWidget {
  final String text;

  const _ForecastChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(text));
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      ('Sell produce', Icons.storefront_outlined),
      ('Find buyers', Icons.people_outline),
      ('Find transport', Icons.local_shipping_outlined),
      ('Ask AI assistant', Icons.auto_awesome_outlined),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick actions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3.2,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(item.$2, size: 18),
              label: Text(item.$1),
              style: ElevatedButton.styleFrom(
                backgroundColor: HomePage.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}