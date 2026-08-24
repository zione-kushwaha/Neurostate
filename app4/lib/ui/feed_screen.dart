import 'package:flutter/material.dart';
import '../state/predictive_state_container.dart';
import '../services/benchmark_telemetry.dart';
import 'detail_screen.dart';
import 'widgets/telemetry_hud.dart';

class FeedScreen extends StatefulWidget {
  final PredictiveStateContainer stateContainer;

  const FeedScreen({super.key, required this.stateContainer});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _categories = ['All', 'AI & ML', 'Systems', 'Mobile Computing', 'Cloud', 'Cybersecurity', 'Algorithms'];
  bool _isBenchmarking = false;

  @override
  void initState() {
    super.initState();
    BenchmarkTelemetry.instance.startRecording();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.stateContainer.loadInitialFeed();
    });

    _scrollController.addListener(() {
      final offset = _scrollController.position.pixels;
      final approxIndex = (offset / 120.0).floor();
      
      // Update predictive viewport tracker and trigger background pre-warming
      widget.stateContainer.onViewportScroll(offset, approxIndex);

      if (offset >= _scrollController.position.maxScrollExtent - 400) {
        widget.stateContainer.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _runAutomatedStressBenchmark() async {
    if (_isBenchmarking) return;
    setState(() => _isBenchmarking = true);

    BenchmarkTelemetry.instance.startRecording();

    try {
      for (int i = 0; i < 6; i++) {
        if (!_scrollController.hasClients) break;
        await _scrollController.animateTo(
          _scrollController.offset + 800.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
        await Future.delayed(const Duration(milliseconds: 50));
      }

      for (final cat in ['Systems', 'AI & ML', 'Cloud', 'All']) {
        widget.stateContainer.setCategory(cat == 'All' ? null : cat);
        await Future.delayed(const Duration(milliseconds: 150));
      }

      for (int i = 1; i <= 5; i++) {
        if (!mounted) break;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(
              articleId: i,
              stateContainer: widget.stateContainer,
            ),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 150));
      }

      final report = BenchmarkTelemetry.instance.generateReport(
        architectureName: "App 4: NeuroState",
      );

      if (!mounted) return;
      _showBenchmarkResults(report);
    } finally {
      if (mounted) setState(() => _isBenchmarking = false);
    }
  }

  void _showBenchmarkResults(Map<String, dynamic> report) {
    final spec = (report['speculative_cache'] as Map<String, dynamic>?) ?? {};

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151D2A),
        title: const Row(
          children: [
            Icon(Icons.bolt, color: Color(0xFF00E5FF)),
            SizedBox(width: 8),
            Text("NeuroState Benchmark", style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Architecture: ${report['architecture']}", style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
              const Divider(color: Colors.white24),
              _statRow("Speculative Cache Hits", "${spec['hits'] ?? 0}"),
              _statRow("Speculative Hit Rate", "${((spec['hit_rate_pct'] ?? 0.0) as double).toStringAsFixed(1)}%"),
              _statRow("Pre-warmed Items", "${spec['total_prefetched'] ?? 0}"),
              const SizedBox(height: 8),
              const Text("Frame Build Times:", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12)),
              _statRow("  Mean Build Time", "${(report['frame_build_time_ms']['mean'] as double).toStringAsFixed(2)} ms"),
              _statRow("  P95 Build Time", "${(report['frame_build_time_ms']['p95'] as double).toStringAsFixed(2)} ms"),
              _statRow("  P99 Build Time", "${(report['frame_build_time_ms']['p99'] as double).toStringAsFixed(2)} ms"),
              const SizedBox(height: 8),
              const Text("Navigation Latency (TTI):", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12)),
              _statRow("  Mean TTI", "${(report['transition_latency_tti_ms']['mean'] as double).toStringAsFixed(2)} ms"),
              _statRow("  P95 TTI", "${(report['transition_latency_tti_ms']['p95'] as double).toStringAsFixed(2)} ms"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CLOSE", style: TextStyle(color: Color(0xFF00E5FF))),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.stateContainer,
      builder: (context, _) {
        final articles = widget.stateContainer.filteredArticles;

        return Scaffold(
          backgroundColor: const Color(0xFF0F0F1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF151D2A),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("NexusFeed • Research Benchmark", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text("App 4: NeuroState (Predictive Prefetch)", style: TextStyle(fontSize: 11, color: Color(0xFF00E5FF))),
              ],
            ),
            actions: [
              IconButton(
                tooltip: "Run Stress Benchmark Suite",
                icon: _isBenchmarking
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber))
                    : const Icon(Icons.speed, color: Colors.amberAccent),
                onPressed: _isBenchmarking ? null : _runAutomatedStressBenchmark,
              ),
            ],
          ),
          body: Column(
            children: [
              const TelemetryHUD(architectureName: "App 4: NeuroState"),
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = (cat == 'All' && widget.stateContainer.selectedCategory == null) || widget.stateContainer.selectedCategory == cat;
                    return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat, style: TextStyle(fontSize: 11, color: isSelected ? Colors.black : Colors.white60)),
                    selected: isSelected,
                    selectedColor: const Color(0xFF00E5FF),
                    backgroundColor: const Color(0xFF1E1E2C),
                    checkmarkColor: Colors.black,
                    onSelected: (_) => widget.stateContainer.setCategory(cat == 'All' ? null : cat),
                  ),
                );
                  },
                ),
              ),
              Expanded(
                child: widget.stateContainer.isLoading && articles.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: articles.length + (widget.stateContainer.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == articles.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00E5FF)),
                              ),
                            );
                          }

                          final item = articles[index];
                          final isBookmarked = widget.stateContainer.bookmarkedIds.contains(item.id);

                          return Card(
                            color: const Color(0xFF151D2A),
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFF24334A), width: 1),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailScreen(
                                      articleId: item.id,
                                      stateContainer: widget.stateContainer,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00E5FF).withAlpha(35),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item.category,
                                            style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                            color: isBookmarked ? Colors.amberAccent : Colors.white38,
                                            size: 18,
                                          ),
                                          onPressed: () => widget.stateContainer.toggleBookmark(item.id),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.summary,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(item.author, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                                        const Spacer(),
                                        const Icon(Icons.thumb_up_alt_outlined, size: 12, color: Colors.white38),
                                        const SizedBox(width: 4),
                                        Text("${item.likes}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
