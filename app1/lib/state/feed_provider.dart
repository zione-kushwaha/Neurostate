import 'package:flutter/foundation.dart';
import '../models/article_item.dart';
import '../services/mock_api_service.dart';
import '../services/benchmark_telemetry.dart';

class FeedProvider extends ChangeNotifier {
  final MockApiService _apiService;
  
  List<ArticleItem> _articles = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  
  ArticleItem? _currentDetail;
  bool _isLoadingDetail = false;

  final Set<int> _bookmarkedIds = {};
  String? _selectedCategory;

  FeedProvider({MockApiService? apiService}) : _apiService = apiService ?? MockApiService();

  List<ArticleItem> get articles => _articles;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  ArticleItem? get currentDetail => _currentDetail;
  bool get isLoadingDetail => _isLoadingDetail;
  Set<int> get bookmarkedIds => _bookmarkedIds;
  String? get selectedCategory => _selectedCategory;

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

  Future<void> loadDetail(int id) async {
    final sw = BenchmarkTelemetry.instance.startTransitionTimer();
    _isLoadingDetail = true;
    _currentDetail = null;
    notifyListeners();

    try {
      _currentDetail = await _apiService.getArticleDetail(id);
    } finally {
      _isLoadingDetail = false;
      BenchmarkTelemetry.instance.recordTransitionLatency(sw);
      notifyListeners();
    }
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
