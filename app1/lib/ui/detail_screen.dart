import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/feed_provider.dart';
import 'widgets/telemetry_hud.dart';

class DetailScreen extends StatefulWidget {
  final int articleId;

  const DetailScreen({super.key, required this.articleId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().loadDetail(widget.articleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeedProvider>();
    final article = provider.currentDetail;
    final isLoading = provider.isLoadingDetail;
    final isBookmarked = provider.bookmarkedIds.contains(widget.articleId);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181829),
        title: Text("Article #${widget.articleId}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.amberAccent : Colors.white70,
            ),
            onPressed: () => provider.toggleBookmark(widget.articleId),
          ),
        ],
      ),
      body: Column(
        children: [
          const TelemetryHUD(architectureName: "App 1: Provider"),
          Expanded(
            child: isLoading || article == null
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF6C63FF)),
                        SizedBox(height: 16),
                        Text(
                          "Loading state via Provider...",
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withAlpha(40),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            article.category,
                            style: const TextStyle(color: Color(0xFF8A84FF), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          article.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 14,
                              backgroundColor: Color(0xFF323250),
                              child: Icon(Icons.person, size: 16, color: Colors.white70),
                            ),
                            const SizedBox(width: 8),
                            Text(article.author, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            const Spacer(),
                            const Icon(Icons.timer_outlined, size: 14, color: Colors.white38),
                            const SizedBox(width: 4),
                            Text("${article.readTimeMinutes} min read", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                        const Divider(color: Color(0xFF282840), height: 32),
                        Text(
                          article.summary,
                          style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          article.content,
                          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
