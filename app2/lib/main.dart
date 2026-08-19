import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BenchmarkApp2());
}

class BenchmarkApp2 extends StatelessWidget {
  const BenchmarkApp2({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'App 2: Riverpod Benchmark',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0F0F1A),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00C896),
            secondary: Color(0xFF00E6AC),
            surface: Color(0xFF181829),
          ),
        ),
        home: const HomeShell(),
      ),
    );
  }
}
