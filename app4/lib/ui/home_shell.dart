import 'package:flutter/material.dart';
import '../state/predictive_state_container.dart';
import 'feed_screen.dart';
import 'explore_screen.dart';
import 'bookmarks_screen.dart';
import 'telemetry_lab_screen.dart';

class HomeShell extends StatefulWidget {
  final PredictiveStateContainer stateContainer;

  const HomeShell({super.key, required this.stateContainer});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      FeedScreen(stateContainer: widget.stateContainer),
      ExploreScreen(stateContainer: widget.stateContainer),
      BookmarksScreen(stateContainer: widget.stateContainer),
      TelemetryLabScreen(
        architectureName: "App 4: NeuroState",
        stateContainer: widget.stateContainer,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF101622),
          indicatorColor: const Color(0xFF00E5FF).withAlpha(40),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.bold);
            }
            return const TextStyle(color: Colors.white38, fontSize: 11);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF00E5FF));
            }
            return const IconThemeData(color: Colors.white38);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.feed_outlined), selectedIcon: Icon(Icons.feed), label: "Feed"),
            NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: "Explore"),
            NavigationDestination(icon: Icon(Icons.bookmark_outline), selectedIcon: Icon(Icons.bookmark), label: "Saved"),
            NavigationDestination(icon: Icon(Icons.bolt_outlined), selectedIcon: Icon(Icons.bolt), label: "Neuro Lab"),
          ],
        ),
      ),
    );
  }
}
