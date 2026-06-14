import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'features/ai_assistant/presentation/ai_assistant_page.dart';
import 'features/alerts/presentation/alerts_page.dart';
import 'features/analytics/presentation/analytics_page.dart';
import 'features/home/presentation/home_page.dart';
import 'features/logistics/presentation/logistics_page.dart';
import 'features/marketplace/presentation/marketplace_page.dart';
import 'features/orders/presentation/orders_page.dart';
import 'features/payments/presentation/payments_page.dart';
import 'features/settings/presentation/settings_page.dart';
import 'state/app_state.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    final pages = const [
      HomePage(), // index 0: Home
      MarketplacePage(), // index 1: Marketplace
      AssistantPage(), // index 2: Chats (AI Assistant)
      AnalyticsPage(), // index 3: Analytics
      OrdersPage(), // index 4: Orders
      LogisticsPage(), // index 5: Transport
      PaymentsPage(), // index 6: Finance/Payments
      AlertsPage(), // index 7: Notifications
      SettingsPage(), // index 8: Settings
    ];

    final sidebar = Sidebar(
      selectedIndex: state.navIndex,
      onSelect: (index) {
        notifier.setNavIndex(index);
        if (!isDesktop) {
          Navigator.pop(context); // Close drawer on mobile
        }
      },
    );

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            sidebar,
            const VerticalDivider(width: 1, color: Colors.black12),
            Expanded(
              child: IndexedStack(
                index: state.navIndex,
                children: pages,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verdi'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              notifier.setNavIndex(7); // Go to notifications/alerts
            },
            icon: const Icon(Icons.notifications_none_outlined),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF16A34A),
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: sidebar,
      ),
      body: IndexedStack(
        index: state.navIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: state.navIndex < 4 ? state.navIndex : 0,
        onDestinationSelected: (idx) {
          notifier.setNavIndex(idx);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            label: 'Marketplace',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.leaf, color: Color(0xFF16A34A), size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Verdi',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Smart Agriculture. Real Results.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF0F172A).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(context, index: 0, label: 'Home', icon: LucideIcons.home),
                _buildMenuItem(context, index: 1, label: 'Marketplace', icon: LucideIcons.store),
                _buildMenuItem(context, index: 2, label: 'Chats', icon: LucideIcons.messageCircle, badge: '3'),
                _buildMenuItem(context, index: 3, label: 'Analytics', icon: LucideIcons.barChart3),
                _buildMenuItem(context, index: 4, label: 'Orders', icon: LucideIcons.shoppingCart),
                _buildMenuItem(context, index: 5, label: 'Transport', icon: LucideIcons.truck),
                _buildMenuItem(context, index: 6, label: 'Finance', icon: LucideIcons.dollarSign),
                _buildMenuItem(context, index: 7, label: 'Notifications', icon: LucideIcons.bell),
                _buildMenuItem(context, index: 8, label: 'Settings', icon: LucideIcons.settings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required int index,
    required String label,
    required IconData icon,
    String? badge,
  }) {
    final isSelected = selectedIndex == index;
    final activeBgColor = const Color(0xFF16A34A).withOpacity(0.15);

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? activeBgColor : Colors.transparent,
        border: isSelected
            ? const Border(
                left: BorderSide(color: Color(0xFF16A34A), width: 3),
              )
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        onTap: () => onSelect(index),
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF64748B),
          size: 20,
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}