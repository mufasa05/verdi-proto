import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:syncfusion_flutter_charts/charts.dart';
import '../data/analytics_export_service.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const orange = Color(0xFFF97316);
  static const blue = Color(0xFF2563EB);
  static const purple = Color(0xFF7C3AED);
  static const background = Color(0xFFF8FAFC);

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  String _selectedTimeframe = '7 Days';
  String _selectedRegion = 'All Regions';

  final List<String> _timeframes = const ['7 Days', '30 Days', '12 Months'];
  final List<String> _regions = const [
    'All Regions',
    'Masvingo',
    'Chiredzi',
    'Mutare',
    'Harare'
  ];

  double _getRegionScale() {
    switch (_selectedRegion) {
      case 'Masvingo':
        return 0.40;
      case 'Chiredzi':
        return 0.25;
      case 'Mutare':
        return 0.20;
      case 'Harare':
        return 0.15;
      default:
        return 1.0;
    }
  }

  // Generate dataset based on timeframe and region scale
  AnalyticsMockDataset _getDataset() {
    final scale = _getRegionScale();
    
    if (_selectedTimeframe == '30 Days') {
      return AnalyticsMockDataset(
        revenue: '\$${(52140 * scale).round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
        revenueChange: '+15.8%',
        revenueSpark: [12000, 11500, 13000, 12800, 14200, 14640],
        orders: '${(945 * scale).round()}',
        ordersChange: '+10.2%',
        ordersSpark: [180, 170, 210, 195, 230, 245],
        buyers: '${(142 * scale).round()}',
        buyersChange: '+7.4%',
        buyersSpark: [95, 100, 115, 112, 130, 142],
        fulfillment: '95.0%',
        fulfillmentChange: '+1.8%',
        fulfillmentSpark: [93, 94, 94.2, 94.8, 95, 95],
        revenueTrend: [
          ChartData('Wk 1', 11200 * scale, 10500 * scale),
          ChartData('Wk 2', 12800 * scale, 12000 * scale),
          ChartData('Wk 3', 13500 * scale, 13000 * scale),
          ChartData('Wk 4', 14640 * scale, 14000 * scale),
        ],
        cropVolumes: [
          CropVolumeData('Tomatoes', 3200 * scale, AnalyticsPage.green),
          CropVolumeData('Maize', 2800 * scale, AnalyticsPage.blue),
          CropVolumeData('Potatoes', 2100 * scale, AnalyticsPage.orange),
          CropVolumeData('Onions', 1700 * scale, AnalyticsPage.purple),
        ],
        categories: [
          CircularChartData('Vegetables', 48, AnalyticsPage.green),
          CircularChartData('Grains', 28, AnalyticsPage.blue),
          CircularChartData('Fruits', 14, AnalyticsPage.orange),
          CircularChartData('Others', 10, AnalyticsPage.purple),
        ],
        topProducts: [
          ProductLeaderboardItem('Tomatoes', 'Vegetables', '🍅', '\$${(22400 * scale).round()}', (185 * scale).round(), 0.97, 8.5),
          ProductLeaderboardItem('Maize', 'Grains', '🌽', '\$${(16800 * scale).round()}', (120 * scale).round(), 0.93, 3.4),
          ProductLeaderboardItem('Potatoes', 'Vegetables', '🥔', '\$${(9200 * scale).round()}', (94 * scale).round(), 0.90, -1.2),
          ProductLeaderboardItem('Onions', 'Vegetables', '🧅', '\$${(4740 * scale).round()}', (78 * scale).round(), 0.86, 2.1),
        ],
      );
    } else if (_selectedTimeframe == '12 Months') {
      return AnalyticsMockDataset(
        revenue: '\$${(680200 * scale).round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
        revenueChange: '+22.5%',
        revenueSpark: [45000, 48000, 52000, 50000, 58000, 62000, 68000, 75200],
        orders: (12480 * scale).round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'),
        ordersChange: '+14.3%',
        ordersSpark: [900, 950, 1100, 1050, 1200, 1300, 1450, 1530],
        buyers: '${(520 * scale).round()}',
        buyersChange: '+18.9%',
        buyersSpark: [320, 340, 380, 390, 420, 450, 490, 520],
        fulfillment: '96.5%',
        fulfillmentChange: '+3.1%',
        fulfillmentSpark: [92.5, 93.0, 94.1, 94.6, 95.2, 95.8, 96.2, 96.5],
        revenueTrend: [
          ChartData('Jan', 45000 * scale, 42000 * scale),
          ChartData('Feb', 48000 * scale, 45000 * scale),
          ChartData('Mar', 52000 * scale, 48000 * scale),
          ChartData('Apr', 50000 * scale, 50000 * scale),
          ChartData('May', 55000 * scale, 52000 * scale),
          ChartData('Jun', 58000 * scale, 55000 * scale),
          ChartData('Jul', 62000 * scale, 58000 * scale),
          ChartData('Aug', 60000 * scale, 60000 * scale),
          ChartData('Sep', 63000 * scale, 62000 * scale),
          ChartData('Oct', 68000 * scale, 65000 * scale),
          ChartData('Nov', 72000 * scale, 68000 * scale),
          ChartData('Dec', 75200 * scale, 70000 * scale),
        ],
        cropVolumes: [
          CropVolumeData('Tomatoes', 42000 * scale, AnalyticsPage.green),
          CropVolumeData('Maize', 38000 * scale, AnalyticsPage.blue),
          CropVolumeData('Potatoes', 30000 * scale, AnalyticsPage.orange),
          CropVolumeData('Onions', 22000 * scale, AnalyticsPage.purple),
        ],
        categories: [
          CircularChartData('Vegetables', 50, AnalyticsPage.green),
          CircularChartData('Grains', 25, AnalyticsPage.blue),
          CircularChartData('Fruits', 15, AnalyticsPage.orange),
          CircularChartData('Others', 10, AnalyticsPage.purple),
        ],
        topProducts: [
          ProductLeaderboardItem('Tomatoes', 'Vegetables', '🍅', '\$${(294000 * scale).round()}', (2480 * scale).round(), 0.98, 12.4),
          ProductLeaderboardItem('Maize', 'Grains', '🌽', '\$${(218000 * scale).round()}', (1910 * scale).round(), 0.94, 9.1),
          ProductLeaderboardItem('Potatoes', 'Vegetables', '🥔', '\$${(112000 * scale).round()}', (1420 * scale).round(), 0.92, 4.8),
          ProductLeaderboardItem('Onions', 'Vegetables', '🧅', '\$${(56200 * scale).round()}', (980 * scale).round(), 0.89, -0.6),
        ],
      );
    } else {
      // Default: 7 Days
      return AnalyticsMockDataset(
        revenue: '\$${(12480 * scale).round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
        revenueChange: '+12.4%',
        revenueSpark: [420, 520, 480, 680, 750, 840, 920],
        orders: '${(214 * scale).round()}',
        ordersChange: '+8.1%',
        ordersSpark: [18, 22, 19, 28, 31, 35, 42],
        buyers: '${(86 * scale).round()}',
        buyersChange: '+5.6%',
        buyersSpark: [72, 74, 76, 79, 81, 84, 86],
        fulfillment: '94.0%',
        fulfillmentChange: '+2.2%',
        fulfillmentSpark: [90.5, 91.2, 92.0, 92.5, 93.1, 93.8, 94.0],
        revenueTrend: [
          ChartData('Mon', 1200 * scale, 1100 * scale),
          ChartData('Tue', 1500 * scale, 1300 * scale),
          ChartData('Wed', 1400 * scale, 1400 * scale),
          ChartData('Thu', 2100 * scale, 1600 * scale),
          ChartData('Fri', 1800 * scale, 1800 * scale),
          ChartData('Sat', 2200 * scale, 2000 * scale),
          ChartData('Sun', 2280 * scale, 2100 * scale),
        ],
        cropVolumes: [
          CropVolumeData('Tomatoes', 850 * scale, AnalyticsPage.green),
          CropVolumeData('Maize', 620 * scale, AnalyticsPage.blue),
          CropVolumeData('Potatoes', 510 * scale, AnalyticsPage.orange),
          CropVolumeData('Onions', 390 * scale, AnalyticsPage.purple),
        ],
        categories: [
          CircularChartData('Vegetables', 45, AnalyticsPage.green),
          CircularChartData('Grains', 30, AnalyticsPage.blue),
          CircularChartData('Fruits', 15, AnalyticsPage.orange),
          CircularChartData('Others', 10, AnalyticsPage.purple),
        ],
        topProducts: [
          ProductLeaderboardItem('Tomatoes', 'Vegetables', '🍅', '\$${(5240 * scale).round()}', (42 * scale).round(), 0.96, 4.2),
          ProductLeaderboardItem('Maize', 'Grains', '🌽', '\$${(3980 * scale).round()}', (31 * scale).round(), 0.91, -2.1),
          ProductLeaderboardItem('Potatoes', 'Vegetables', '🥔', '\$${(2160 * scale).round()}', (24 * scale).round(), 0.88, 1.8),
          ProductLeaderboardItem('Onions', 'Vegetables', '🧅', '\$${(1100 * scale).round()}', (19 * scale).round(), 0.84, 0.5),
        ],
      );
    }
  }

  void _exportCSV() async {
    final dataset = _getDataset();
    final List<List<dynamic>> csvRows = [
      ['Analytics Report', 'Timeframe: $_selectedTimeframe', 'Region: $_selectedRegion'],
      [],
      ['Metric', 'Value', 'Change'],
      ['Revenue', dataset.revenue, dataset.revenueChange],
      ['Orders', dataset.orders, dataset.ordersChange],
      ['Buyers', dataset.buyers, dataset.buyersChange],
      ['Fulfillment', dataset.fulfillment, dataset.fulfillmentChange],
      [],
      ['Top Products', 'Category', 'Sales', 'Orders Count', 'Completion Rate'],
      ...dataset.topProducts.map((p) => [p.name, p.category, p.sales, p.ordersCount, '${(p.completion * 100).round()}%']),
    ];

    try {
      final file = await AnalyticsExportService.exportCsv(
        rows: csvRows,
        fileName: 'verdi_analytics_${_selectedTimeframe.toLowerCase().replaceAll(' ', '_')}.csv',
      );
      _showExportSuccessDialog(file.path);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _exportPDF() async {
    final dataset = _getDataset();
    final summaryLines = [
      'Timeframe: $_selectedTimeframe',
      'Region: $_selectedRegion',
      'Revenue Summary: ${dataset.revenue} (${dataset.revenueChange})',
      'Fulfillment Efficiency: ${dataset.fulfillment}',
      'Active Buyers Segmented: ${dataset.buyers} accounts',
      'Total Orders Placed: ${dataset.orders}',
      '',
      'Core Highlights:',
      '- High demand observed on local crops.',
      '- Distribution channels operating at stable ETA.',
    ];

    try {
      final file = await AnalyticsExportService.exportPdf(
        title: 'Verdi Platform Intelligence Report',
        summaryLines: summaryLines,
        fileName: 'verdi_analytics_${_selectedTimeframe.toLowerCase().replaceAll(' ', '_')}.pdf',
      );
      _showExportSuccessDialog(file.path);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _showExportSuccessDialog(String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle_outline, color: AnalyticsPage.green, size: 28),
            SizedBox(width: 10),
            Text('Export Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your report was successfully exported and stored at:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: SelectableText(
                path,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AnalyticsPage.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to export: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataset = _getDataset();

    return Scaffold(
      backgroundColor: AnalyticsPage.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analytics',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AnalyticsPage.dark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Real-time supply, demand, and yield insights.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AnalyticsPage.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'pdf') {
                        _exportPDF();
                      } else {
                        _exportCSV();
                      }
                    },
                    icon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.ios_share_outlined, size: 18, color: AnalyticsPage.dark),
                          SizedBox(width: 8),
                          Text(
                            'Export',
                            style: TextStyle(
                              color: AnalyticsPage.dark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    offset: const Offset(0, 48),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'pdf',
                        child: Row(
                          children: const [
                            Icon(Icons.picture_as_pdf_outlined, color: Colors.redAccent, size: 20),
                            SizedBox(width: 8),
                            Text('Export PDF Report'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'csv',
                        child: Row(
                          children: const [
                            Icon(Icons.table_view_outlined, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text('Export CSV Sheet'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter Controls Bar
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  final filters = [
                    // Timeframe Toggles
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _timeframes.map((timeframe) {
                          final isSelected = _selectedTimeframe == timeframe;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTimeframe = timeframe;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Text(
                                timeframe,
                                style: TextStyle(
                                  color: isSelected ? AnalyticsPage.dark : AnalyticsPage.muted,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    if (!isWide) const SizedBox(height: 12),
                    // Region Selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRegion,
                          icon: const Icon(Icons.keyboard_arrow_down, color: AnalyticsPage.muted),
                          style: GoogleFonts.inter(
                            color: AnalyticsPage.dark,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedRegion = val;
                              });
                            }
                          },
                          items: _regions.map((region) {
                            return DropdownMenuItem(
                              value: region,
                              child: Text(region),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ];

                  return isWide
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: filters,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: filters,
                        );
                },
              ),
              const SizedBox(height: 20),

              // KPI Card Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth > 1000
                      ? 4
                      : constraints.maxWidth > 600
                          ? 2
                          : 1;

                  return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: constraints.maxWidth > 1000 ? 1.6 : 2.0,
                    children: [
                      _buildKpiCard(
                        title: 'Total Revenue',
                        value: dataset.revenue,
                        change: dataset.revenueChange,
                        icon: Icons.payments_outlined,
                        color: AnalyticsPage.green,
                        sparkData: dataset.revenueSpark,
                      ),
                      _buildKpiCard(
                        title: 'Fulfillment Rate',
                        value: dataset.fulfillment,
                        change: dataset.fulfillmentChange,
                        icon: Icons.verified_outlined,
                        color: AnalyticsPage.blue,
                        sparkData: dataset.fulfillmentSpark,
                      ),
                      _buildKpiCard(
                        title: 'Active Buyers',
                        value: dataset.buyers,
                        change: dataset.buyersChange,
                        icon: Icons.people_outline,
                        color: AnalyticsPage.orange,
                        sparkData: dataset.buyersSpark,
                      ),
                      _buildKpiCard(
                        title: 'Orders Volume',
                        value: dataset.orders,
                        change: dataset.ordersChange,
                        icon: Icons.local_shipping_outlined,
                        color: AnalyticsPage.purple,
                        sparkData: dataset.ordersSpark,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Revenue vs Target Chart Card
              Container(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Revenue vs Target Projection',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AnalyticsPage.dark,
                          ),
                        ),
                        Row(
                          children: [
                            _chartLegendDot(AnalyticsPage.green, 'Actual'),
                            const SizedBox(width: 14),
                            _chartLegendDot(AnalyticsPage.muted.withOpacity(0.5), 'Projected'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 280,
                      child: SfCartesianChart(
                        plotAreaBorderWidth: 0,
                        margin: EdgeInsets.zero,
                        primaryXAxis: const CategoryAxis(
                          majorGridLines: MajorGridLines(width: 0),
                          labelStyle: TextStyle(color: AnalyticsPage.muted, fontSize: 11),
                        ),
                        primaryYAxis: const NumericAxis(
                          axisLine: AxisLine(width: 0),
                          majorTickLines: MajorTickLines(size: 0),
                          majorGridLines: MajorGridLines(
                            width: 1,
                            color: Color(0xFFF1F5F9),
                          ),
                          labelStyle: TextStyle(color: AnalyticsPage.muted, fontSize: 11),
                        ),
                        tooltipBehavior: TooltipBehavior(
                          enable: true,
                          color: AnalyticsPage.dark,
                          textStyle: const TextStyle(color: Colors.white),
                        ),
                        series: <CartesianSeries<ChartData, String>>[
                          SplineAreaSeries<ChartData, String>(
                            dataSource: dataset.revenueTrend,
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.target,
                            name: 'Target',
                            color: AnalyticsPage.muted.withOpacity(0.12),
                            borderWidth: 1.5,
                            borderColor: AnalyticsPage.muted.withOpacity(0.3),
                          ),
                          SplineAreaSeries<ChartData, String>(
                            dataSource: dataset.revenueTrend,
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.actual,
                            name: 'Actual',
                            color: AnalyticsPage.green.withOpacity(0.15),
                            borderColor: AnalyticsPage.green,
                            borderWidth: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Split Column Chart and Doughnut
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 950;

                  final cropVolumeCard = Container(
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
                          'Crop Trade Volume (kg)',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AnalyticsPage.dark,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 250,
                          child: SfCartesianChart(
                            plotAreaBorderWidth: 0,
                            margin: EdgeInsets.zero,
                            primaryXAxis: const CategoryAxis(
                              majorGridLines: MajorGridLines(width: 0),
                              labelStyle: TextStyle(color: AnalyticsPage.muted, fontSize: 11),
                            ),
                            primaryYAxis: const NumericAxis(
                              axisLine: AxisLine(width: 0),
                              majorTickLines: MajorTickLines(size: 0),
                              majorGridLines: MajorGridLines(
                                width: 1,
                                color: Color(0xFFF1F5F9),
                              ),
                              labelStyle: TextStyle(color: AnalyticsPage.muted, fontSize: 11),
                            ),
                            tooltipBehavior: TooltipBehavior(
                              enable: true,
                              color: AnalyticsPage.dark,
                              textStyle: const TextStyle(color: Colors.white),
                            ),
                            series: <CartesianSeries<CropVolumeData, String>>[
                              ColumnSeries<CropVolumeData, String>(
                                dataSource: dataset.cropVolumes,
                                xValueMapper: (CropVolumeData data, _) => data.crop,
                                yValueMapper: (CropVolumeData data, _) => data.volume,
                                pointColorMapper: (CropVolumeData data, _) => data.color,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                width: 0.5,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );

                  final categoryCard = Container(
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
                          'Revenue Share by Category',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AnalyticsPage.dark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 256,
                          child: SfCircularChart(
                            margin: EdgeInsets.zero,
                            legend: const Legend(
                              isVisible: true,
                              position: LegendPosition.bottom,
                              overflowMode: LegendItemOverflowMode.wrap,
                              textStyle: TextStyle(color: AnalyticsPage.dark, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <CircularSeries<CircularChartData, String>>[
                              DoughnutSeries<CircularChartData, String>(
                                dataSource: dataset.categories,
                                xValueMapper: (CircularChartData data, _) => data.category,
                                yValueMapper: (CircularChartData data, _) => data.value,
                                pointColorMapper: (CircularChartData data, _) => data.color,
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  labelPosition: ChartDataLabelPosition.outside,
                                  textStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                innerRadius: '65%',
                                explode: true,
                                explodeIndex: 0,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );

                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: cropVolumeCard),
                            const SizedBox(width: 16),
                            Expanded(child: categoryCard),
                          ],
                        )
                      : Column(
                          children: [
                            cropVolumeCard,
                            const SizedBox(height: 16),
                            categoryCard,
                          ],
                        );
                },
              ),
              const SizedBox(height: 20),

              // Leaderboard & Insights Section
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 950;

                  final leaderboardCard = Container(
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
                          'Top Performing Products',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AnalyticsPage.dark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: dataset.topProducts.map((item) {
                            return _buildLeaderboardTile(context, item);
                          }).toList(),
                        ),
                      ],
                    ),
                  );

                  final insightsCard = Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AnalyticsPage.green.withOpacity(0.04),
                          AnalyticsPage.green.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AnalyticsPage.green.withOpacity(0.18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.auto_awesome_outlined, color: AnalyticsPage.green),
                            SizedBox(width: 8),
                            Text(
                              'AI-Powered Analytics Insight',
                              style: TextStyle(
                                color: AnalyticsPage.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tomatoes volume continues to lead sales in the Southern region, exceeding projection by 12.4%. However, onions are experiencing local supply shortages, driving up unit margins by 8% over the past 3 days.',
                          style: TextStyle(
                            color: AnalyticsPage.dark,
                            fontSize: 13.5,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Recommendation: Re-route van ZW-14 to Gwanda Depot to accommodate rising demand for potato stock before regional prices stabilize.',
                          style: TextStyle(
                            color: AnalyticsPage.muted,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );

                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: leaderboardCard),
                            const SizedBox(width: 16),
                            Expanded(flex: 2, child: insightsCard),
                          ],
                        )
                      : Column(
                          children: [
                            leaderboardCard,
                            const SizedBox(height: 16),
                            insightsCard,
                          ],
                        );
                },
              ),
              const SizedBox(height: 24),
              // Customer Reach Info Section
              Container(
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
                      'Customer Reach & Traffic',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AnalyticsPage.dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Profile views, visitor engagement, and transaction ratios.',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AnalyticsPage.muted,
                      ),
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 600;
                        return GridView.count(
                          crossAxisCount: isWide ? 4 : 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: isWide ? 1.4 : 1.3,
                          children: [
                            _buildReachCard('Profile Views', '1,420', '+12.4%', Icons.visibility_outlined, Colors.blue),
                            _buildReachCard('Unique Visitors', '950', '+8.2%', Icons.people_outline, Colors.teal),
                            _buildReachCard('Inquiries Received', '185', '+15.3%', Icons.chat_bubble_outline, Colors.purple),
                            _buildReachCard('Conversion Rate', '13.0%', '+2.5%', Icons.swap_horiz_outlined, Colors.orange),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Buyer Locations Section
              Container(
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
                      'Active Buyer Locations Map',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AnalyticsPage.dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Geographic concentration of active buyers in the region (Non-interactive)',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AnalyticsPage.muted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    IgnorePointer(
                      child: Container(
                        height: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: FlutterMap(
                            options: const MapOptions(
                              initialCenter: LatLng(-19.5, 30.5),
                              initialZoom: 6.8,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.verdi.app',
                              ),
                              MarkerLayer(
                                markers: const [
                                  Marker(
                                    point: LatLng(-17.8292, 31.0522), // Harare
                                    width: 40,
                                    height: 40,
                                    child: Icon(Icons.location_pin, color: Colors.red, size: 28),
                                  ),
                                  Marker(
                                    point: LatLng(-20.0637, 30.8276), // Masvingo
                                    width: 40,
                                    height: 40,
                                    child: Icon(Icons.location_pin, color: Colors.blue, size: 28),
                                  ),
                                  Marker(
                                    point: LatLng(-21.05, 31.67), // Chiredzi
                                    width: 40,
                                    height: 40,
                                    child: Icon(Icons.location_pin, color: Colors.green, size: 28),
                                  ),
                                  Marker(
                                    point: LatLng(-18.97, 32.67), // Mutare
                                    width: 40,
                                    height: 40,
                                    child: Icon(Icons.location_pin, color: Colors.orange, size: 28),
                                  ),
                                  Marker(
                                    point: LatLng(-20.17, 28.56), // Bulawayo
                                    width: 40,
                                    height: 40,
                                    child: Icon(Icons.location_pin, color: Colors.purple, size: 28),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // AI Profile Insights Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AnalyticsPage.purple.withOpacity(0.04),
                      AnalyticsPage.purple.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AnalyticsPage.purple.withOpacity(0.18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome, color: AnalyticsPage.purple),
                        SizedBox(width: 8),
                        Text(
                          'AI Profile Activity Intelligence',
                          style: TextStyle(
                            color: AnalyticsPage.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Analysis of your reach metrics and buyer inquiry logs over the past week shows a strong growth trend in profile views (+12.4%) primarily centered on soybean and tomato listings.',
                      style: TextStyle(
                        color: AnalyticsPage.dark,
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '• Inquiry Conversion Rate is running at 13.0%, which is 2.5% higher than the platform average for Southern regional farms.\n'
                      '• Peak traffic periods for your profile are observed between 8:00 AM and 10:00 AM on Tuesdays and Thursdays.\n'
                      '• Response time to inquiries remains below 15 minutes, which maintains your profile badge as a "Fast Responder".',
                      style: TextStyle(
                        color: AnalyticsPage.dark,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Recommendation: Schedule listing updates to go live at 7:30 AM on weekdays to align with peak morning buyer searches in the Harare and Chiredzi logistics corridors.',
                      style: TextStyle(
                        color: AnalyticsPage.muted,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReachCard(String label, String value, String growth, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  growth,
                  style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AnalyticsPage.dark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AnalyticsPage.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: AnalyticsPage.muted, fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required Color color,
    required List<double> sparkData,
  }) {
    final isNegative = change.startsWith('-');
    final changeColor = isNegative ? Colors.red : color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AnalyticsPage.muted,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const Spacer(),
          // Middle Section (Val + Change)
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AnalyticsPage.dark,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Icon(
                    isNegative ? Icons.south_east : Icons.north_east,
                    size: 11,
                    color: changeColor,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    change,
                    style: TextStyle(
                      color: changeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Sparkline at the bottom
          SizedBox(
            height: 24,
            width: double.infinity,
            child: CustomPaint(
              painter: SparklinePainter(sparkData, color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(BuildContext context, ProductLeaderboardItem item) {
    final isNegative = item.trend < 0;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    final content = isSmallScreen
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(item.emoji, style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: AnalyticsPage.dark,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          item.category,
                          style: const TextStyle(
                            color: AnalyticsPage.muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.sales,
                        style: const TextStyle(
                          color: AnalyticsPage.dark,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isNegative ? Icons.trending_down : Icons.trending_up,
                            size: 10,
                            color: isNegative ? Colors.red : AnalyticsPage.green,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${isNegative ? '' : '+'}${item.trend}%',
                            style: TextStyle(
                              color: isNegative ? Colors.red : AnalyticsPage.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Target Fill', style: TextStyle(fontSize: 10, color: AnalyticsPage.muted, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: item.completion,
                        minHeight: 5,
                        backgroundColor: Colors.grey.shade300,
                        color: AnalyticsPage.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${(item.completion * 100).round()}%', style: const TextStyle(fontSize: 10, color: AnalyticsPage.dark, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          )
        : Row(
            children: [
              // Emojis/Icon
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              // Name / Category
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: AnalyticsPage.dark,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.category,
                      style: const TextStyle(
                        color: AnalyticsPage.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Progress Bar (Volume completion towards monthly average target)
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Target Fill', style: TextStyle(fontSize: 10, color: AnalyticsPage.muted, fontWeight: FontWeight.bold)),
                          Text('${(item.completion * 100).round()}%', style: const TextStyle(fontSize: 10, color: AnalyticsPage.dark, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: item.completion,
                          minHeight: 5,
                          backgroundColor: Colors.grey.shade300,
                          color: AnalyticsPage.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Sales / Trend
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.sales,
                      style: const TextStyle(
                        color: AnalyticsPage.dark,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          isNegative ? Icons.trending_down : Icons.trending_up,
                          size: 11,
                          color: isNegative ? Colors.red : AnalyticsPage.green,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${isNegative ? '' : '+'}${item.trend}%',
                          style: TextStyle(
                            color: isNegative ? Colors.red : AnalyticsPage.green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AnalyticsPage.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
        ),
        child: content,
      ),
    );
  }
}

// Sparkline Painter
class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  SparklinePainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double stepX = size.width / (data.length - 1);
    final double minVal = data.reduce((a, b) => a < b ? a : b);
    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    final double range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    for (int i = 0; i < data.length; i++) {
      final double x = i * stepX;
      final double y = size.height - ((data[i] - minVal) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
    
    // Draw area fill
    final areaPath = Path.from(path);
    areaPath.lineTo(size.width, size.height);
    areaPath.lineTo(0, size.height);
    areaPath.close();
    
    final fillPaint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color;
}

// Data models for mapping Syncfusion charts
class ChartData {
  final String x;
  final double actual;
  final double target;

  ChartData(this.x, this.actual, this.target);
}

class CropVolumeData {
  final String crop;
  final double volume;
  final Color color;

  CropVolumeData(this.crop, this.volume, this.color);
}

class CircularChartData {
  final String category;
  final double value;
  final Color color;

  CircularChartData(this.category, this.value, this.color);
}

class AnalyticsMockDataset {
  final String revenue;
  final String revenueChange;
  final List<double> revenueSpark;
  final String orders;
  final String ordersChange;
  final List<double> ordersSpark;
  final String buyers;
  final String buyersChange;
  final List<double> buyersSpark;
  final String fulfillment;
  final String fulfillmentChange;
  final List<double> fulfillmentSpark;

  final List<ChartData> revenueTrend;
  final List<CropVolumeData> cropVolumes;
  final List<CircularChartData> categories;
  final List<ProductLeaderboardItem> topProducts;

  AnalyticsMockDataset({
    required this.revenue,
    required this.revenueChange,
    required this.revenueSpark,
    required this.orders,
    required this.ordersChange,
    required this.ordersSpark,
    required this.buyers,
    required this.buyersChange,
    required this.buyersSpark,
    required this.fulfillment,
    required this.fulfillmentChange,
    required this.fulfillmentSpark,
    required this.revenueTrend,
    required this.cropVolumes,
    required this.categories,
    required this.topProducts,
  });
}

class ProductLeaderboardItem {
  final String name;
  final String category;
  final String emoji;
  final String sales;
  final int ordersCount;
  final double completion;
  final double trend;

  ProductLeaderboardItem(
    this.name,
    this.category,
    this.emoji,
    this.sales,
    this.ordersCount,
    this.completion,
    this.trend,
  );
}