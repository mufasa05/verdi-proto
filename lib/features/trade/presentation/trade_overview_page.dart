import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/trade_providers.dart';
import '../widgets/trade_widgets.dart';

class TradeOverviewPage extends ConsumerWidget {
  const TradeOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliers = ref.watch(tradeSupplierProvider);
    final purchaseOrders = ref.watch(purchaseOrderProvider);
    final batches = ref.watch(stockBatchProvider);
    final salesOrders = ref.watch(salesOrderProvider);
    final alerts = ref.watch(openAlertsProvider);
    final prices = ref.watch(pricePointProvider);
    final auditLog = ref.watch(auditLogProvider);

    final verifiedSuppliers = suppliers.where((s) => s.isVerified).length;
    final openPOs = purchaseOrders.where((p) => p.status == 'Sent' || p.status == 'Confirmed').length;
    final stockAlerts = batches.where((b) => b.quantityKg < 2000).length;
    final revenueMtd = salesOrders
        .where((so) => so.status != 'Cancelled')
        .fold<double>(0, (sum, so) => sum + so.totalValue);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TradePageHeader(
            title: 'Hub Overview',
            subtitle: 'Live snapshot of trade activity across the value chain.',
          ),

          // Alert banners
          if (alerts.isNotEmpty) ...[
            for (final alert in alerts.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TradeAlertBanner(
                  message: alert.message,
                  severity: alert.severity,
                  onDismiss: () => ref.read(tradeAlertProvider.notifier).dismiss(alert.id),
                ),
              ),
            const SizedBox(height: 6),
          ],

          // KPI stats grid
          LayoutBuilder(builder: (context, constraints) {
            final cols = constraints.maxWidth >= 900 ? 4 : constraints.maxWidth >= 600 ? 3 : 2;
            return GridView.count(
              crossAxisCount: cols,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                TradeStatTile(
                  label: 'Verified Suppliers',
                  value: '$verifiedSuppliers',
                  icon: Icons.verified_outlined,
                  trendPercent: 8.3,
                ),
                TradeStatTile(
                  label: 'Open Purchase Orders',
                  value: '$openPOs',
                  icon: Icons.receipt_long_outlined,
                  iconColor: TradeColors.blue,
                ),
                TradeStatTile(
                  label: 'Stock Alerts',
                  value: '$stockAlerts',
                  icon: Icons.inventory_2_outlined,
                  iconColor: stockAlerts > 0 ? TradeColors.orange : TradeColors.green,
                  valueColor: stockAlerts > 0 ? TradeColors.orange : null,
                ),
                TradeStatTile(
                  label: 'Revenue MTD',
                  value: 'US\$ ${(revenueMtd / 1000).toStringAsFixed(1)}k',
                  icon: Icons.trending_up_outlined,
                  trendPercent: 12.6,
                ),
              ],
            );
          }),
          const SizedBox(height: 16),

          // Quick actions
          TradeSectionCard(
            title: 'Quick Actions',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _QuickAction(
                  icon: Icons.add_shopping_cart_outlined,
                  label: 'New Purchase Order',
                  color: TradeColors.blue,
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.inventory_outlined,
                  label: 'Log Intake',
                  color: TradeColors.green,
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.local_shipping_outlined,
                  label: 'Dispatch Stock',
                  color: TradeColors.purple,
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.fact_check_outlined,
                  label: 'Record QC',
                  color: TradeColors.orange,
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.point_of_sale_outlined,
                  label: 'Create Sale',
                  color: TradeColors.amber,
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.handshake_outlined,
                  label: 'Add Supplier',
                  color: TradeColors.muted,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Price board + audit log
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            final priceBoard = TradeSectionCard(
              title: 'Live Price Board',
              trailing: const TradeBadge(label: 'Harare • Today', color: TradeColors.green),
              child: Column(
                children: prices.map((p) {
                  final isUp = p.changePercent >= 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: TradeColors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            p.productName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        Text(
                          'US\$ ${p.pricePer100kg.toStringAsFixed(2)}/100kg',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: TradeColors.dark),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isUp ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 14,
                          color: isUp ? TradeColors.green : TradeColors.red,
                        ),
                        Text(
                          '${p.changePercent.abs().toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isUp ? TradeColors.green : TradeColors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );

            final recentActivity = TradeSectionCard(
              title: 'Recent Activity',
              child: Column(
                children: auditLog.take(6).map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: TradeColors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.history, size: 16, color: TradeColors.green),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.action} ${entry.entityType} ${entry.entityId}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: TradeColors.dark),
                              ),
                              Text(
                                '${entry.performedBy} • ${entry.timestamp}',
                                style: const TextStyle(fontSize: 11, color: TradeColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: priceBoard),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: recentActivity),
                ],
              );
            }
            return Column(children: [priceBoard, const SizedBox(height: 16), recentActivity]);
          }),

          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
