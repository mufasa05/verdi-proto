import 'package:flutter/material.dart';
import 'package:verdi/widgets/stub_page.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const StubPage(
      title: 'Alerts',
      subtitle: 'Weather and operations alerts will appear here.',
    );
  }
}