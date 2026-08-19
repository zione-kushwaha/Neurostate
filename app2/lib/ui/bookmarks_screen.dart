import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/feed_state.dart';
import 'detail_screen.dart';
import 'widgets/telemetry_hud.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedNotifierProvider);
    final bookmarkedArticles = state.articles.where((a) => state.bookmarkedIds.contains(a.id)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181829),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Saved Research Library", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text("Riverpod State Synchronization", style: TextStyle(fontSize: 11, color: Color(0xFF00E6AC))),
          ],
        ),
        actions: [
          if (bookmarkedArticles.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.clear_all, size: 16, color: Colors.redAccent),
              label: const Text("Clear All", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
              onPressed: () {
                for (final a in bookmarkedArticles) {
                  ref.read(feedNotifierProvider.notifier).toggleBookmark(a.id);
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          const TelemetryHUD(architectureName: "App 2: Riverpod"),
          Expanded(
            child: bookmarkedArticles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF181829),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF282840)),
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
                        color: const Color(0xFF181829),
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFF282840)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          title: Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Text(item.category, style: const TextStyle(color: Color(0xFF00E6AC), fontSize: 11)),
                                const SizedBox(width: 8),
                                const Text("•", style: TextStyle(color: Colors.white24)),
                                const SizedBox(width: 8),
                                Text(item.author, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.bookmark_remove, color: Colors.amberAccent, size: 20),
                            onPressed: () => ref.read(feedNotifierProvider.notifier).toggleBookmark(item.id),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => DetailScreen(articleId: item.id)),
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
  }
}
