import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/feed_provider.dart';
import 'ui/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BenchmarkApp1());
}

class BenchmarkApp1 extends StatelessWidget {
  const BenchmarkApp1({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FeedProvider()),
      ],
      child: MaterialApp(
        title: 'App 1: Provider Benchmark',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0F0F1A),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6C63FF),
            secondary: Color(0xFF8A84FF),
            surface: Color(0xFF181829),
          ),
        ),
        home: const HomeShell(),
      ),
    );
  }
}
