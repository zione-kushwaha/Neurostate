import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/feed_bloc.dart';
import 'ui/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BenchmarkApp3());
}

class BenchmarkApp3 extends StatelessWidget {
  const BenchmarkApp3({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => FeedBloc()),
      ],
      child: MaterialApp(
        title: 'App 3: BLoC Benchmark',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0F0F1A),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF5252),
            secondary: Color(0xFFFF7A7A),
            surface: Color(0xFF181829),
          ),
        ),
        home: const HomeShell(),
      ),
    );
  }
}
