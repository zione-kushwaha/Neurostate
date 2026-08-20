import 'package:equatable/equatable.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadInitialFeedEvent extends FeedEvent {}

class LoadMoreFeedEvent extends FeedEvent {}

class FilterCategoryEvent extends FeedEvent {
  final String? category;
  const FilterCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class ToggleBookmarkEvent extends FeedEvent {
  final int articleId;
  const ToggleBookmarkEvent(this.articleId);

  @override
  List<Object?> get props => [articleId];
}
