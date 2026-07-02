import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider;
import 'package:provider/provider.dart';

import 'app.dart';
import 'features/traceability/providers/traceability_provider.dart';
import 'features/traceability/models/repositories/in_memory_traceability_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => TraceabilityProvider(
              repository: InMemoryTraceabilityRepository(),
            ),
          ),
        ],
        child: const VerdiApp(),
      ),
    ),
  );
}
