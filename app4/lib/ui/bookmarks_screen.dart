import 'package:flutter/material.dart';
import '../state/predictive_state_container.dart';
import 'detail_screen.dart';
import 'widgets/telemetry_hud.dart';

class BookmarksScreen extends StatelessWidget {
  final PredictiveStateContainer stateContainer;

  const BookmarksScreen({super.key, required this.stateContainer});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: stateContainer,
      builder: (context, _) {
        final bookmarkedArticles = stateContainer.articles.where((a) => stateContainer.bookmarkedIds.contains(a.id)).toList();

        return Scaffold(
          backgroundColor: const Color(0xFF0F0F1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF151D2A),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Saved Research Library", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text("NeuroState Speculative Synchronization", style: TextStyle(fontSize: 11, color: Color(0xFF00E5FF))),
              ],
            ),
            actions: [
              if (bookmarkedArticles.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.clear_all, size: 16, color: Colors.redAccent),
                  label: const Text("Clear All", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                  onPressed: () {
                    for (final a in bookmarkedArticles) {
                      stateContainer.toggleBookmark(a.id);
                    }
                  },
                ),
            ],
          ),
          body: Column(
            children: [
              const TelemetryHUD(architectureName: "App 4: NeuroState"),
              Expanded(
                child: bookmarkedArticles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF151D2A),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF24334A)),
                              ),
                              child: const Icon(Icons.bookmark_outline, size: 40, color: Colors.white24),
                            ),
                            const SizedBox(height: 16),
                            const Text("No Bookmarked Papers Yet", style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            const Text("Tap bookmark icons on feed items to test state synchronization", style: TextStyle(color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: bookmarkedArticles.length,
                        itemBuilder: (context, index) {
                          final item = bookmarkedArticles[index];
                          return Card(
                            color: const Color(0xFF151D2A),
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFF24334A)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              title: Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: [
                                    Text(item.category, style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 11)),
                                    const SizedBox(width: 8),
                                    const Text("•", style: TextStyle(color: Colors.white24)),
                                    const SizedBox(width: 8),
                                    Text(item.author, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                                  ],
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.bookmark_remove, color: Colors.amberAccent, size: 20),
                                onPressed: () => stateContainer.toggleBookmark(item.id),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailScreen(
                                      articleId: item.id,
                                      stateContainer: stateContainer,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
