import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/article_item.dart';
import '../services/mock_api_service.dart';
import '../services/benchmark_telemetry.dart';

abstract class DetailEvent extends Equatable {
  const DetailEvent();
  @override
  List<Object?> get props => [];
}

class LoadArticleDetailEvent extends DetailEvent {
  final int articleId;
  const LoadArticleDetailEvent(this.articleId);

  @override
  List<Object?> get props => [articleId];
}

abstract class DetailState extends Equatable {
  const DetailState();
  @override
  List<Object?> get props => [];
}

class DetailInitial extends DetailState {}

class DetailLoading extends DetailState {}

class DetailLoaded extends DetailState {
  final ArticleItem article;
  const DetailLoaded(this.article);

  @override
  List<Object?> get props => [article];
}

class DetailError extends DetailState {
  final String message;
  const DetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  final MockApiService _apiService;

  DetailBloc({MockApiService? apiService})
      : _apiService = apiService ?? MockApiService(),
        super(DetailInitial()) {
    on<LoadArticleDetailEvent>(_onLoadDetail);
  }

  Future<void> _onLoadDetail(
    LoadArticleDetailEvent event,
    Emitter<DetailState> emit,
  ) async {
    final sw = BenchmarkTelemetry.instance.startTransitionTimer();
    emit(DetailLoading());
    try {
      final article = await _apiService.getArticleDetail(event.articleId);
      emit(DetailLoaded(article));
    } catch (e) {
      emit(DetailError(e.toString()));
    } finally {
      BenchmarkTelemetry.instance.recordTransitionLatency(sw);
    }
  }
}
