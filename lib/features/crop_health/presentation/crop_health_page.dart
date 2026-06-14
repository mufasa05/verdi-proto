import 'package:flutter/material.dart';
import 'package:verdi/widgets/stub_page.dart';

class CropHealthPage extends StatelessWidget {
  const CropHealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const StubPage(
      title: 'Crop Health',
      subtitle: 'Field scouting, disease signals, and crop status will appear here.',
    );
  }
}