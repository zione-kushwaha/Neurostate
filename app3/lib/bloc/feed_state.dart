import 'package:equatable/equatable.dart';
import '../models/article_item.dart';

enum FeedStatus { initial, loading, success, failure }

class FeedBlocState extends Equatable {
  final FeedStatus status;
  final List<ArticleItem> articles;
  final bool isLoadingMore;
  final Set<int> bookmarkedIds;
  final String? selectedCategory;

  const FeedBlocState({
    this.status = FeedStatus.initial,
    this.articles = const [],
    this.isLoadingMore = false,
    this.bookmarkedIds = const {},
    this.selectedCategory,
  });

  FeedBlocState copyWith({
    FeedStatus? status,
    List<ArticleItem>? articles,
    bool? isLoadingMore,
    Set<int>? bookmarkedIds,
    String? selectedCategory,
    bool clearCategory = false,
  }) {
    return FeedBlocState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
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

  @override
  List<Object?> get props => [status, articles, isLoadingMore, bookmarkedIds, selectedCategory];
}
