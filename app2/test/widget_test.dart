import 'package:flutter_test/flutter_test.dart';
import 'package:app2/main.dart';

void main() {
  testWidgets('App2 smoke test and launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const BenchmarkApp2());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('App 2: Riverpod'), findsWidgets);
  });
}
