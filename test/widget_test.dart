import 'package:flutter_test/flutter_test.dart';
import 'package:verdi/app/verdi_app.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const VerdiApp());
    expect(find.text('Verdi'), findsOneWidget);
  });
}