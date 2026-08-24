import 'package:flutter/material.dart';
import '../state/predictive_state_container.dart';
import 'widgets/telemetry_hud.dart';

class DetailScreen extends StatefulWidget {
  final int articleId;
  final PredictiveStateContainer stateContainer;

  const DetailScreen({
    super.key,
    required this.articleId,
    required this.stateContainer,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.stateContainer.loadDetail(widget.articleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.stateContainer,
      builder: (context, _) {
        final article = widget.stateContainer.currentDetail;
        final isLoading = widget.stateContainer.isLoadingDetail;
        final isHit = widget.stateContainer.isSpeculativeHit;
        final isBookmarked = widget.stateContainer.bookmarkedIds.contains(widget.articleId);

        return Scaffold(
          backgroundColor: const Color(0xFF0F0F1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF151D2A),
            title: Text("Article #${widget.articleId}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Colors.amberAccent : Colors.white70,
                ),
                onPressed: () => widget.stateContainer.toggleBookmark(widget.articleId),
              ),
            ],
          ),
          body: Column(
            children: [
              const TelemetryHUD(architectureName: "App 4: NeuroState"),
              Expanded(
                child: isLoading || article == null
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF00E5FF)),
                            SizedBox(height: 16),
                            Text(
                              "Reactive fallback fetch...",
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
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E5FF).withAlpha(40),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    article.category,
                                    style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isHit ? Colors.green.withAlpha(40) : Colors.orange.withAlpha(40),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: isHit ? Colors.greenAccent : Colors.orangeAccent),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isHit ? Icons.flash_on : Icons.sync,
                                        size: 12,
                                        color: isHit ? Colors.greenAccent : Colors.orangeAccent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isHit ? "Speculative Hit (~0ms)" : "Reactive Fallback",
                                        style: TextStyle(
                                          color: isHit ? Colors.greenAccent : Colors.orangeAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
      },
    );
  }
}
