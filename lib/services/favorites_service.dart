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

  /// Refreshes favorite team names and images using current standings data.
  /// This ensures that if a name was corrected in the API, the favorite is updated
  /// instead of being broken.
  void refreshWithLatestData(List<StandingRow> standings, String competitionId) {
    bool changed = false;
    for (int i = 0; i < _favorites.length; i++) {
      final fav = _favorites[i];
      if (fav.competitionId == competitionId) {
        // Try to find the team in latest standings (maybe the name changed slightly)
        // Since we don't have teamId, we can only do this if we are SURE it's the same team.
        // For now, we update the image if it's the same name.
        try {
          final latest = standings.firstWhere((s) => s.team == fav.teamName);
          if (latest.image != fav.image) {
            _favorites[i] = FavoriteTeam(
              teamName: fav.teamName,
              competitionId: fav.competitionId,
              competitionTitle: fav.competitionTitle,
              image: latest.image,
              teamId: latest.teamId ?? fav.teamId,
            );
            changed = true;
          }
        } catch (_) {
          // Team name might have changed in API, but without a stable teamId 
          // we cannot automatically migrate the name safely yet.
        }
      }
    }
    if (changed) {
      _save();
      notifyListeners();
    }
  }

  bool isFavorite(String teamName, String competitionId, [String? teamId]) {
    return _favorites.any((f) =>
        (teamId != null && f.teamId == teamId) ||
        (f.teamName == teamName && f.competitionId == competitionId));
  }

  void toggleFavorite(FavoriteTeam team) {
    final index = _favorites.indexWhere((f) =>
        (team.teamId != null && f.teamId == team.teamId) ||
        (f.teamName == team.teamName && f.competitionId == team.competitionId));

    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(team);
    }
    _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_favorites.map((f) => f.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
