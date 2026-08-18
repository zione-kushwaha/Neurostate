import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article_item.dart';
import '../services/mock_api_service.dart';
import '../services/benchmark_telemetry.dart';

final apiServiceProvider = Provider<MockApiService>((ref) => MockApiService());

class FeedState {
  final List<ArticleItem> articles;
  final bool isLoading;
  final bool isLoadingMore;
  final Set<int> bookmarkedIds;
  final String? selectedCategory;

  FeedState({
    this.articles = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.bookmarkedIds = const {},
    this.selectedCategory,
  });

  FeedState copyWith({
    List<ArticleItem>? articles,
    bool? isLoading,
    bool? isLoadingMore,
    Set<int>? bookmarkedIds,
    String? selectedCategory,
    bool clearCategory = false,
  }) {
    return FeedState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
    );
  }

  List<ArticleItem> get filteredArticles {
    if (selectedCategory == null || selectedCategory!.isEmpty) {
      return articles;
    }
    return articles.where((a) => a.category == selectedCategory).toList();
  }
}

class FeedNotifier extends Notifier<FeedState> {
  @override
  FeedState build() {
    return FeedState();
  }

  MockApiService get _apiService => ref.read(apiServiceProvider);

  Future<void> loadInitialFeed() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _apiService.getFeed(offset: 0, limit: 30);
      state = state.copyWith(articles: items, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final more = await _apiService.getFeed(offset: state.articles.length, limit: 30);
      state = state.copyWith(
        articles: [...state.articles, ...more],
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void toggleBookmark(int id) {
    final updated = Set<int>.from(state.bookmarkedIds);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = state.copyWith(bookmarkedIds: updated);
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category, clearCategory: category == null);
  }
}

final feedNotifierProvider = NotifierProvider<FeedNotifier, FeedState>(FeedNotifier.new);

final articleDetailProvider = FutureProvider.family<ArticleItem, int>((ref, id) async {
  final sw = BenchmarkTelemetry.instance.startTransitionTimer();
  final api = ref.watch(apiServiceProvider);
  try {
    return await api.getArticleDetail(id);
  } finally {
    BenchmarkTelemetry.instance.recordTransitionLatency(sw);
  }
});
