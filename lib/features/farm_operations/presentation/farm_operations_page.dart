import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:verdi/features/drone_inspection/presentation/drone_inspection_view.dart';
import 'package:verdi/features/irrigation/presentation/farmer_irrigation_view.dart';
import 'package:verdi/features/irrigation/presentation/government_irrigation_view.dart';

class FarmOperationsPage extends StatelessWidget {
  const FarmOperationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: const [
              _Header(),
              _TopSummary(),
              SizedBox(height: 12),
              _TabStrip(),
              SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    GovernmentIrrigationView(),
                    FarmerIrrigationView(),
                    DroneInspectionView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farm Operations',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Government schemes, farmer irrigation, and drone inspection in one control center.',
                  style: GoogleFonts.inter(color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Colors.black12),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopSummary extends StatelessWidget {
  const _TopSummary();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Schemes', '4', Icons.water_outlined),
      ('Fields', '3', Icons.grass_outlined),
      ('Flights', '4', Icons.flight_outlined),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 900;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: desktop ? 3 : 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: desktop ? 4.5 : 2.7,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.$3, color: const Color(0xFF16A34A)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.$1,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.$2,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
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
        },
      ),
    );
  }
}

class _TabStrip extends StatelessWidget {
  const _TabStrip();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black12),
        ),
        child: const TabBar(
          isScrollable: true,
          labelColor: Color(0xFF16A34A),
          unselectedLabelColor: Color(0xFF64748B),
          indicatorColor: Color(0xFF16A34A),
          tabs: [
            Tab(text: 'Government'),
            Tab(text: 'Farmer Control'),
            Tab(text: 'Drone Inspection'),
          ],
        ),
      ),
    );
  }
}
