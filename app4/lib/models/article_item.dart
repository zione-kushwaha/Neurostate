import 'dart:convert';

class ArticleItem {
  final int id;
  final String title;
  final String category;
  final String author;
  final String summary;
  final String content;
  final int readTimeMinutes;
  final int likes;
  final bool isBookmarked;
  final DateTime publishedAt;

  ArticleItem({
    required this.id,
    required this.title,
    required this.category,
    required this.author,
    required this.summary,
    required this.content,
    required this.readTimeMinutes,
    required this.likes,
    this.isBookmarked = false,
    required this.publishedAt,
  });

  ArticleItem copyWith({
    int? id,
    String? title,
    String? category,
    String? author,
    String? summary,
    String? content,
    int? readTimeMinutes,
    int? likes,
    bool? isBookmarked,
    DateTime? publishedAt,
  }) {
    return ArticleItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      author: author ?? this.author,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      readTimeMinutes: readTimeMinutes ?? this.readTimeMinutes,
      likes: likes ?? this.likes,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'author': author,
      'summary': summary,
      'content': content,
      'readTimeMinutes': readTimeMinutes,
      'likes': likes,
      'isBookmarked': isBookmarked,
      'publishedAt': publishedAt.toIso8601String(),
    };
  }

  factory ArticleItem.fromMap(Map<String, dynamic> map) {
    int parsedId = 0;
    if (map['id'] is int) {
      parsedId = map['id'];
    } else if (map['id'] is String) {
      parsedId = int.tryParse((map['id'] as String).replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    return ArticleItem(
      id: parsedId,
      title: map['title'] ?? '',
      category: map['category'] ?? 'Systems',
      author: map['author'] ?? 'Researcher',
      summary: map['summary'] ?? '',
      content: map['content'] ?? map['contentMarkdown'] ?? '',
      readTimeMinutes: (map['readTimeMinutes'] is num) ? (map['readTimeMinutes'] as num).toInt() : 5,
      likes: (map['likes'] is num) ? (map['likes'] as num).toInt() : 0,
      isBookmarked: map['isBookmarked'] ?? false,
      publishedAt: DateTime.tryParse(map['publishedAt'] ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ArticleItem.fromJson(String source) => ArticleItem.fromMap(json.decode(source));
}
