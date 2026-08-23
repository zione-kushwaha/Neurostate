import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/article_item.dart';
import '../services/mock_api_service.dart';
import '../services/benchmark_telemetry.dart';

class SpeculativeCacheEntry {
  final ArticleItem item;
  final DateTime cachedAt;
  final double confidence;

  SpeculativeCacheEntry({
    required this.item,
    required this.cachedAt,
    required this.confidence,
  });
}

class IsolateStateWarmer {
  final Map<int, SpeculativeCacheEntry> _cache = {};
  final Set<int> _inFlightFetches = {};
  final int maxCacheSize;

  IsolateStateWarmer({this.maxCacheSize = 50});

  int get cachedCount => _cache.length;

  bool hasCached(int articleId) => _cache.containsKey(articleId);

  ArticleItem? getCached(int articleId) {
    final entry = _cache[articleId];
    if (entry != null) {
      BenchmarkTelemetry.instance.recordSpeculativeHit();
      return entry.item;
    }
    BenchmarkTelemetry.instance.recordSpeculativeMiss();
    return null;
  }

  /// Warm up articles in the background
  Future<void> prefetchArticles(List<int> articleIds, {double confidence = 0.85}) async {
    final toFetch = articleIds.where((id) => !_cache.containsKey(id) && !_inFlightFetches.contains(id)).toList();
    if (toFetch.isEmpty) return;

    for (final id in toFetch) {
      _inFlightFetches.add(id);
    }

    try {
      // Decode in background worker
      for (final id in toFetch) {
        final item = await compute(_fetchAndDecodeIsolateWorker, id);
        _cache[id] = SpeculativeCacheEntry(
          item: item,
          cachedAt: DateTime.now(),
          confidence: confidence,
        );
        _inFlightFetches.remove(id);
      }
      BenchmarkTelemetry.instance.recordPrefetched(toFetch.length);
      _evictIfNecessary();
    } catch (_) {
      for (final id in toFetch) {
        _inFlightFetches.remove(id);
      }
    }
  }

  static Future<ArticleItem> _fetchAndDecodeIsolateWorker(int id) async {
    final mockApi = MockApiService();
    return mockApi.getArticleDetailSync(id);
  }

  void _evictIfNecessary() {
    if (_cache.length > maxCacheSize) {
      final sortedKeys = _cache.keys.toList()
        ..sort((a, b) => _cache[a]!.cachedAt.compareTo(_cache[b]!.cachedAt));
      final removeCount = _cache.length - maxCacheSize;
      for (int i = 0; i < removeCount; i++) {
        _cache.remove(sortedKeys[i]);
      }
    }
  }

  void clear() {
    _cache.clear();
    _inFlightFetches.clear();
  }
}
