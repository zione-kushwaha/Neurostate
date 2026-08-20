import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_item.dart';

class MockApiService {
  static const int totalItems = 2000;
  static final List<ArticleItem> _cachedDatabase = _generateMockDatabase();
  
  final String baseUrl;
  final http.Client _client;

  MockApiService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? _getDefaultBaseUrl(),
        _client = client ?? http.Client();

  static String _getDefaultBaseUrl() {
    const fromDefine = String.fromEnvironment('API_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    return 'http://127.0.0.1:8080';
  }

  /// Fetches paginated feed from live HTTP mock server with automatic fallback
  Future<List<ArticleItem>> getFeed({int offset = 0, int limit = 30, int simulatedDelayMs = 40}) async {
    for (final host in [baseUrl, 'http://10.0.2.2:8080', 'http://127.0.0.1:8080']) {
      try {
        final page = (offset / limit).floor();
        final uri = Uri.parse('$host/api/feed?page=$page&limit=$limit');
        final res = await _client.get(uri).timeout(const Duration(milliseconds: 600));
        if (res.statusCode == 200) {
          final decoded = jsonDecode(res.body);
          final List items = decoded['items'] ?? [];
          return items.map((m) => ArticleItem.fromMap(m)).toList();
        }
      } catch (_) {}
    }

    if (simulatedDelayMs > 0) {
      await Future.delayed(Duration(milliseconds: simulatedDelayMs));
    }
    final end = (offset + limit).clamp(0, _cachedDatabase.length);
    if (offset >= _cachedDatabase.length) return [];
    
    final rawJson = jsonEncode(_cachedDatabase.sublist(offset, end).map((e) => e.toMap()).toList());
    final List decoded = jsonDecode(rawJson);
    return decoded.map((m) => ArticleItem.fromMap(m)).toList();
  }

  /// Fetches article detail from live HTTP mock server with automatic fallback
  Future<ArticleItem> getArticleDetail(int id, {int simulatedDelayMs = 120}) async {
    for (final host in [baseUrl, 'http://10.0.2.2:8080', 'http://127.0.0.1:8080']) {
      try {
        final formattedId = 'item_${(id - 1).toString().padLeft(6, '0')}';
        final uri = Uri.parse('$host/api/items/$formattedId');
        final res = await _client.get(uri).timeout(const Duration(milliseconds: 600));
        if (res.statusCode == 200) {
          final decoded = jsonDecode(res.body);
          return ArticleItem.fromMap(decoded['item'] ?? decoded);
        }
      } catch (_) {}
    }

    if (simulatedDelayMs > 0) {
      await Future.delayed(Duration(milliseconds: simulatedDelayMs));
    }
    return getArticleDetailSync(id);
  }

  ArticleItem getArticleDetailSync(int id) {
    final target = _cachedDatabase.firstWhere((a) => a.id == id, orElse: () => _cachedDatabase.first);
    final rawJson = jsonEncode(target.toMap());
    return ArticleItem.fromMap(jsonDecode(rawJson));
  }

  static List<ArticleItem> _generateMockDatabase() {
    final categories = ['AI & ML', 'Systems', 'Mobile Computing', 'Cloud', 'Cybersecurity', 'Algorithms'];
    final authors = ['Dr. Aris Thorne', 'Elena Rostova', 'Kenji Sato', 'Prof. Maya Lin', 'Liam Vance'];

    return List.generate(totalItems, (i) {
      final id = i + 1;
      final category = categories[i % categories.length];
      final author = authors[i % authors.length];

      return ArticleItem(
        id: id,
        title: 'Research Paper #$id: Empirical Evaluation of $category Architectures',
        summary: 'A deep comparative study on reactive state management, asynchronous data flows, and predictive latency mitigation in mobile runtime environments #$id.',
        content: '''
# Empirical Evaluation of $category Architectures (Paper #$id)

## Abstract
This paper explores novel paradigms in modern client application architectures, contrasting reactive state management frameworks with speculative execution models. We analyze throughput, heap churn, garbage collection frequency, and frame jitter under sustained load conditions.

## Methodology
Using an automated test harness, we subject $category pipelines to 10,000 synthetic operations across multi-tiered navigation graphs. All metrics are captured via low-overhead runtime hooks.

## Results & Discussion
Our empirical findings demonstrate a substantial reduction in frame drop rates (>16.6ms) and total latency when predictive prefetching is deployed over traditional reactive listener trees.
''',
        category: category,
        author: author,
        readTimeMinutes: 4 + (i % 6),
        likes: (i * 17) % 400,
        isBookmarked: false,
        publishedAt: DateTime.now().subtract(Duration(days: i % 365)),
      );
    });
  }
}
