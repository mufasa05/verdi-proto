import 'package:flutter_test/flutter_test.dart';
import 'package:verdi/app/verdi_app.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const VerdiApp());
    await tester.pumpAndSettle();
    expect(find.text('Farm Operations'), findsOneWidget);
  });
}
