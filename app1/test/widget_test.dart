import 'package:flutter_test/flutter_test.dart';
import 'package:app1/main.dart';

void main() {
  testWidgets('App1 smoke test and launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const BenchmarkApp1());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('App 1: Provider'), findsWidgets);
  });
}
