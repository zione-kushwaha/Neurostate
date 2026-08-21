import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../bloc/feed_state.dart';
import 'detail_screen.dart';
import 'widgets/telemetry_hud.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181829),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Saved Research Library", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text("BLoC Stream State Synchronization", style: TextStyle(fontSize: 11, color: Color(0xFFFF7A7A))),
          ],
        ),
        actions: [
          BlocBuilder<FeedBloc, FeedBlocState>(
            builder: (context, state) {
              final bookmarkedArticles = state.articles.where((a) => state.bookmarkedIds.contains(a.id)).toList();
              if (bookmarkedArticles.isEmpty) return const SizedBox.shrink();
              return TextButton.icon(
                icon: const Icon(Icons.clear_all, size: 16, color: Colors.redAccent),
                label: const Text("Clear All", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                onPressed: () {
                  for (final a in bookmarkedArticles) {
                    context.read<FeedBloc>().add(ToggleBookmarkEvent(a.id));
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const TelemetryHUD(architectureName: "App 3: BLoC"),
          Expanded(
            child: BlocBuilder<FeedBloc, FeedBlocState>(
              builder: (context, state) {
                final bookmarkedArticles = state.articles.where((a) => state.bookmarkedIds.contains(a.id)).toList();

                if (bookmarkedArticles.isEmpty) {
                  return Center(
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
                  );
                }

                return ListView.builder(
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
                              Text(item.category, style: const TextStyle(color: Color(0xFFFF7A7A), fontSize: 11)),
                              const SizedBox(width: 8),
                              const Text("•", style: TextStyle(color: Colors.white24)),
                              const SizedBox(width: 8),
                              Text(item.author, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.bookmark_remove, color: Colors.amberAccent, size: 20),
                          onPressed: () => context.read<FeedBloc>().add(ToggleBookmarkEvent(item.id)),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
