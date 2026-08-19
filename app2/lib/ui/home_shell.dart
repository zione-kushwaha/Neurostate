import 'package:flutter/material.dart';
import 'feed_screen.dart';
import 'explore_screen.dart';
import 'bookmarks_screen.dart';
import 'telemetry_lab_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FeedScreen(),
    ExploreScreen(),
    BookmarksScreen(),
    TelemetryLabScreen(architectureName: "App 2: Riverpod"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF151522),
          indicatorColor: const Color(0xFF00C896).withAlpha(40),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Color(0xFF00E6AC), fontSize: 11, fontWeight: FontWeight.bold);
            }
            return const TextStyle(color: Colors.white38, fontSize: 11);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF00C896));
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
            NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: "Telemetry Lab"),
          ],
        ),
      ),
    );
  }
}
