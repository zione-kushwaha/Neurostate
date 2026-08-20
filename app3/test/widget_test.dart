import 'package:flutter_test/flutter_test.dart';
import 'package:app3/main.dart';

void main() {
  testWidgets('App3 smoke test and launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const BenchmarkApp3());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('App 3: BLoC'), findsWidgets);
  });
}
