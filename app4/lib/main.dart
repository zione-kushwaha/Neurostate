import 'package:flutter/material.dart';
import 'state/predictive_state_container.dart';
import 'ui/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final stateContainer = PredictiveStateContainer();

  runApp(
    BenchmarkApp4(stateContainer: stateContainer),
  );
}

class BenchmarkApp4 extends StatelessWidget {
  final PredictiveStateContainer stateContainer;

  const BenchmarkApp4({super.key, required this.stateContainer});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App 4: NeuroState Benchmark',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFF00B0FF),
          surface: Color(0xFF151D2A),
        ),
      ),
      home: HomeShell(stateContainer: stateContainer),
    );
  }
}
