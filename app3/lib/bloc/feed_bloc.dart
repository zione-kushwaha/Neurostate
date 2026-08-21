import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/mock_api_service.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedBlocState> {
  final MockApiService _apiService;

  FeedBloc({MockApiService? apiService})
      : _apiService = apiService ?? MockApiService(),
        super(const FeedBlocState()) {
    on<LoadInitialFeedEvent>(_onLoadInitialFeed);
    on<LoadMoreFeedEvent>(_onLoadMoreFeed);
    on<FilterCategoryEvent>(_onFilterCategory);
    on<ToggleBookmarkEvent>(_onToggleBookmark);
  }

  Future<void> _onLoadInitialFeed(
    LoadInitialFeedEvent event,
    Emitter<FeedBlocState> emit,
  ) async {
    emit(state.copyWith(status: FeedStatus.loading));
    try {
      final items = await _apiService.getFeed(offset: 0, limit: 30);
      emit(state.copyWith(
        status: FeedStatus.success,
        articles: items,
      ));
    } catch (_) {
      emit(state.copyWith(status: FeedStatus.failure));
    }
  }

  Future<void> _onLoadMoreFeed(
    LoadMoreFeedEvent event,
    Emitter<FeedBlocState> emit,
  ) async {
    if (state.isLoadingMore || state.status == FeedStatus.loading) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final more = await _apiService.getFeed(offset: state.articles.length, limit: 30);
      emit(state.copyWith(
        articles: [...state.articles, ...more],
        isLoadingMore: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  void _onFilterCategory(
    FilterCategoryEvent event,
    Emitter<FeedBlocState> emit,
  ) {
    emit(state.copyWith(
      selectedCategory: event.category,
      clearCategory: event.category == null,
    ));
  }

  void _onToggleBookmark(
    ToggleBookmarkEvent event,
    Emitter<FeedBlocState> emit,
  ) {
    final updated = Set<int>.from(state.bookmarkedIds);
    if (updated.contains(event.articleId)) {
      updated.remove(event.articleId);
    } else {
      updated.add(event.articleId);
    }
    emit(state.copyWith(bookmarkedIds: updated));
  }
}
