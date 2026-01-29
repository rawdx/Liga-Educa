import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:liga_educa/models/phrase.dart';

class PhrasesService {
  // Singleton instance
  static final PhrasesService instance = PhrasesService._();
  PhrasesService._();
  static const String _assetPath = 'assets/data/phrases.json';

  List<Phrase>? _cache;
  final Random _rng = Random();

  Future<List<Phrase>> loadAll() async {
    if (_cache != null) return _cache!;
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! List) return _cache = const [];
      _cache = decoded
          .whereType<Map<String, dynamic>>()
          .map(Phrase.fromJson)
          .toList(growable: false);
      return _cache!;
    } catch (e) {
      debugPrint('Failed to load phrases JSON: $e');
      return _cache = const [];
    }
  }

  Future<Phrase?> randomPhrase({Phrase? notThisOne}) async {
    final all = await loadAll();
    if (all.isEmpty) return null;
    if (all.length == 1) return all.first;

    var newPhrase = all[_rng.nextInt(all.length)];
    while (newPhrase == notThisOne) {
      newPhrase = all[_rng.nextInt(all.length)];
    }
    return newPhrase;
  }
}
