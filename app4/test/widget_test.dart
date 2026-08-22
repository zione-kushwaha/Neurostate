import 'package:flutter_test/flutter_test.dart';
import 'package:app4/main.dart';
import 'package:app4/state/predictive_state_container.dart';

void main() {
  testWidgets('App4 smoke test and launches successfully', (WidgetTester tester) async {
    final container = PredictiveStateContainer();
    await tester.pumpWidget(BenchmarkApp4(stateContainer: container));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('App 4: NeuroState'), findsWidgets);
  });
}
