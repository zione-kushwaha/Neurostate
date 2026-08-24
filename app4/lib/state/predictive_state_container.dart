import 'dart:async';
import 'package:flutter/material.dart';
import '../models/article_item.dart';
import '../services/mock_api_service.dart';
import '../services/benchmark_telemetry.dart';
import '../predictor/markov_navigation_matrix.dart';
import '../predictor/viewport_velocity_tracker.dart';
import '../predictor/prediction_models.dart';
import '../prefetcher/isolate_state_warmer.dart';

class PredictiveStateContainer extends ChangeNotifier {
  final MockApiService _apiService;
  final MarkovNavigationMatrix _markovMatrix;
  final ViewportVelocityTracker _velocityTracker;
  final IsolateStateWarmer _stateWarmer;
  final PredictionModel _predictionModel;

  List<ArticleItem> _articles = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;

  ArticleItem? _currentDetail;
  bool _isLoadingDetail = false;
  bool _isSpeculativeHit = false;

  final Set<int> _bookmarkedIds = {};
  String? _selectedCategory;
  int? _lastVisitedArticleId;

  PredictiveStateContainer({
    MockApiService? apiService,
    MarkovNavigationMatrix? markovMatrix,
    ViewportVelocityTracker? velocityTracker,
    IsolateStateWarmer? stateWarmer,
    PredictionModel? predictionModel,
  })  : _apiService = apiService ?? MockApiService(),
        _markovMatrix = markovMatrix ?? MarkovNavigationMatrix(),
        _velocityTracker = velocityTracker ?? ViewportVelocityTracker(),
        _stateWarmer = stateWarmer ?? IsolateStateWarmer(),
        _predictionModel = predictionModel ?? ContextualBanditModel();

  List<ArticleItem> get articles => _articles;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  ArticleItem? get currentDetail => _currentDetail;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isSpeculativeHit => _isSpeculativeHit;
  Set<int> get bookmarkedIds => _bookmarkedIds;
  String? get selectedCategory => _selectedCategory;
  int get prewarmedCount => _stateWarmer.cachedCount;

  List<ArticleItem> get filteredArticles {
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      return _articles;
    }
    return _articles.where((a) => a.category == _selectedCategory).toList();
  }

  Future<void> loadInitialFeed() async {
    _isLoading = true;
    notifyListeners();

    try {
      _articles = await _apiService.getFeed(offset: 0, limit: 30);
      // Immediately prewarm the first 6 candidate items
      final initialCandidateIds = _articles.take(6).map((e) => e.id).toList();
      _stateWarmer.prefetchArticles(initialCandidateIds, confidence: 0.95);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || _isLoading) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final more = await _apiService.getFeed(offset: _articles.length, limit: 30);
      _articles.addAll(more);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Hook called during scroll interaction: computes velocity lookahead and pre-warms states
  void onViewportScroll(double offset, int approxFirstIndex) {
    _velocityTracker.updateScroll(offset);
    final lookahead = _velocityTracker.computeLookaheadCount();

    final startIndex = (approxFirstIndex + 1).clamp(0, _articles.length);
    final endIndex = (startIndex + lookahead).clamp(0, _articles.length);

    if (endIndex > startIndex) {
      final candidateIds = _articles.sublist(startIndex, endIndex).map((a) => a.id).toList();
      _stateWarmer.prefetchArticles(candidateIds, confidence: 0.80);
    }
  }

  /// Load detail with Speculative Execution & Markov prefetching
  Future<void> loadDetail(int id) async {
    final sw = BenchmarkTelemetry.instance.startTransitionTimer();
    _currentDetail = null;

    // 1. Record transition in prediction models
    if (_lastVisitedArticleId != null && _lastVisitedArticleId != id) {
      _markovMatrix.recordTransition("article_$_lastVisitedArticleId", "article_$id");
      _predictionModel.recordTransition("article_$_lastVisitedArticleId", "article_$id");
    }
    _lastVisitedArticleId = id;

    // 2. Check if state was pre-warmed speculatively (Instant TTI!)
    final cached = _stateWarmer.getCached(id);
    if (cached != null) {
      _isSpeculativeHit = true;
      _currentDetail = cached;
      _isLoadingDetail = false;
      BenchmarkTelemetry.instance.recordTransitionLatency(sw);
      notifyListeners();

      // Trigger predictive lookahead for next sequence jumps based on prediction model
      _speculativelyPrefetchMarkovSuccessors(id);
      return;
    }

    // 3. Fallback: Reactive fetch if speculative miss
    _isSpeculativeHit = false;
    _isLoadingDetail = true;
    notifyListeners();

    try {
      _currentDetail = await _apiService.getArticleDetail(id);
    } finally {
      _isLoadingDetail = false;
      BenchmarkTelemetry.instance.recordTransitionLatency(sw);
      notifyListeners();
      _speculativelyPrefetchMarkovSuccessors(id);
    }
  }

  void _speculativelyPrefetchMarkovSuccessors(int currentArticleId) {
    final dynamicPredictions = _predictionModel.predictNextRoutes("article_$currentArticleId");
    final nextIds = <int>[];
    for (final p in dynamicPredictions) {
      final parsedId = int.tryParse(p.replaceFirst("article_", ""));
      if (parsedId != null) nextIds.add(parsedId);
    }

    // Fallback: also consult standard markov matrix
    if (nextIds.isEmpty) {
      final predictions = _markovMatrix.predictNextStates("article_$currentArticleId", topK: 3);
      for (final p in predictions) {
        final parsedId = int.tryParse(p.state.replaceFirst("article_", ""));
        if (parsedId != null) nextIds.add(parsedId);
      }
    }

    // Also include natural sequential neighbors (id+1, id+2)
    nextIds.addAll([currentArticleId + 1, currentArticleId + 2]);
    _stateWarmer.prefetchArticles(nextIds.toSet().toList(), confidence: 0.85);
  }

  void toggleBookmark(int id) {
    if (_bookmarkedIds.contains(id)) {
      _bookmarkedIds.remove(id);
    } else {
      _bookmarkedIds.add(id);
    }
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
