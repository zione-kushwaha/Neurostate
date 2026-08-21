import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/detail_bloc.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../bloc/feed_state.dart';
import 'widgets/telemetry_hud.dart';

class DetailScreen extends StatelessWidget {
  final int articleId;

  const DetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DetailBloc()..add(LoadArticleDetailEvent(articleId)),
      child: _DetailView(articleId: articleId),
    );
  }
}

class _DetailView extends StatelessWidget {
  final int articleId;

  const _DetailView({required this.articleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181829),
        title: Text("Article #$articleId", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          BlocBuilder<FeedBloc, FeedBlocState>(
            builder: (context, feedState) {
              final isBookmarked = feedState.bookmarkedIds.contains(articleId);
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Colors.amberAccent : Colors.white70,
                ),
                onPressed: () => context.read<FeedBloc>().add(ToggleBookmarkEvent(articleId)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const TelemetryHUD(architectureName: "App 3: BLoC"),
          Expanded(
            child: BlocBuilder<DetailBloc, DetailState>(
              builder: (context, state) {
                if (state is DetailLoading || state is DetailInitial) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFFF5252)),
                        SizedBox(height: 16),
                        Text(
                          "Loading state via BlocBuilder...",
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                if (state is DetailError) {
                  return Center(
                    child: Text("Error: ${state.message}", style: const TextStyle(color: Colors.redAccent)),
                  );
                }

                if (state is DetailLoaded) {
                  final article = state.article;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5252).withAlpha(40),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            article.category,
                            style: const TextStyle(color: Color(0xFFFF7A7A), fontWeight: FontWeight.bold, fontSize: 12),
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
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
