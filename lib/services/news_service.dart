import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:liga_educa/models/news.dart';

class NewsService {
  static final NewsService instance = NewsService._();
  NewsService._();

  static const String _assetPath = 'assets/data/news.json';
  List<NewsItem>? _cache;

  Future<List<NewsItem>> getAllNews() async {
    if (_cache != null) return _cache!;
    
    try {
      final String response = await rootBundle.loadString(_assetPath);
      final decoded = json.decode(response);
      
      if (decoded is List) {
        _cache = decoded
            .whereType<Map<String, dynamic>>()
            .map(NewsItem.fromJson)
            .toList();
        return _cache!;
      }
      return [];
    } catch (e) {
      debugPrint('Error loading news from $_assetPath: $e');
      return [];
    }
  }

  Future<NewsItem?> getNewsById(String id) async {
    final news = await getAllNews();
    try {
      return news.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> getCategories() async {
    final news = await getAllNews();
    return news.map((item) => item.tag).toSet().toList();
  }
}
