import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/competition_models.dart';

class FavoritesService extends ChangeNotifier {
  static final FavoritesService instance = FavoritesService._internal();
  FavoritesService._internal();

  static const String _storageKey = 'favorite_teams';
  List<FavoriteTeam> _favorites = [];

  List<FavoriteTeam> get favorites => List.unmodifiable(_favorites);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        _favorites = decoded.map((item) => FavoriteTeam.fromJson(item)).toList();
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading favorites: $e');
      }
    }
  }

  bool isFavorite(String teamName, String competitionId) {
    return _favorites.any((f) => f.teamName == teamName && f.competitionId == competitionId);
  }

  Future<void> toggleFavorite(FavoriteTeam team) async {
    final index = _favorites.indexWhere(
      (f) => f.teamName == team.teamName && f.competitionId == team.competitionId
    );

    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(team);
    }

    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_favorites.map((f) => f.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
