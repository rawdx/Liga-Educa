import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:liga_educa/models/competition_models.dart';

/// Local sample data service (loads from JSON, will connect to database in the future).
class CompetitionsService {
  // Singleton instance
  static final CompetitionsService instance = CompetitionsService._();
  CompetitionsService._();
  static const String _assetPath = 'assets/data/competitions.json';
  static const String _teamsAssetPath = 'assets/data/teams.json';

  List<CompetitionSummary>? _cache;
  Map<String, List<StandingRow>>? _teamsCache;

  Future<List<CompetitionSummary>> loadAll() async {
    // Load teams data if not already loaded
    if (_teamsCache == null) {
      try {
        final rawTeams = await rootBundle.loadString(_teamsAssetPath);
        final decodedTeams = jsonDecode(rawTeams);
        if (decodedTeams is Map<String, dynamic>) {
          _teamsCache = {};
          decodedTeams.forEach((key, value) {
            if (value is List) {
              _teamsCache![key] = value.map<StandingRow>((t) {
                return StandingRow(
                  position: 0, // Will be calculated
                  team: t['name'] ?? '',
                  played: (t['played'] as num?)?.toInt() ?? 0,
                  points: (t['points'] as num?)?.toInt() ?? 0,
                  image: t['image'],
                );
              }).toList();
            }
          });
        }
      } catch (e) {
        debugPrint('Failed to load teams JSON: $e');
        _teamsCache = {};
      }
    }

    if (_cache != null) return _cache!;
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! List) return _cache = const [];
      _cache = decoded
          .whereType<Map<String, dynamic>>()
          .map(CompetitionSummary.fromJson)
          .toList(growable: false);
      return _cache!;
    } catch (e) {
      debugPrint('Failed to load competitions JSON: $e');
      return _cache = const [];
    }
  }

  List<CompetitionSummary> listCompetitions() {
    // Return cached data if available, otherwise return empty list
    // Call loadAll() first to ensure data is loaded
    return _cache ?? const [];
  }

  CompetitionDetailData getDetail(String id,
      {String? titleOverride, String? subtitleOverride}) {
    // Find the competition by ID
    CompetitionSummary? competition;
    if (_cache != null) {
      try {
        competition = _cache!.firstWhere((c) => c.id == id);
      } catch (e) {
        competition = null;
      }
    }

    // Build groupTitle with category and subcategories
    final parts = <String>[];
    if (competition != null) {
      if (competition.category.isNotEmpty) {
        parts.add(competition.category);
      }
      if (competition.seasonLabel.isNotEmpty &&
          competition.seasonLabel != 'Temporada') {
        parts.add(competition.seasonLabel);
      }
      if (competition.groupLabel.isNotEmpty &&
          competition.groupLabel != 'General') {
        parts.add(competition.groupLabel);
      }
    }
    final groupTitle = parts.isEmpty ? 'Competición' : parts.join('\n');

    final now = DateTime.now();
    final home =
        MatchTeam(name: 'Real Betis Balompié - Marc Roca', short: 'BET', image: 'assets/images/teams/betis.jpg');
    final away = MatchTeam(name: 'Camino Viejo C.F.', short: 'CV', image: 'assets/images/teams/caminoviejocf.jpg');
    final altHome = MatchTeam(name: 'Atlético Verde', short: 'AV');
    final altAway = MatchTeam(name: 'Sporting Azul', short: 'SA');

    // Get standings from cache and sort
    List<StandingRow> currentStandings = [];
    if (_teamsCache != null && _teamsCache!.containsKey(id)) {
      // Create a copy to sort
      final teams = List<StandingRow>.from(_teamsCache![id]!);
      // Sort desc by points
      teams.sort((a, b) => b.points.compareTo(a.points));
      // Assign positions
      for (int i = 0; i < teams.length; i++) {
        currentStandings.add(StandingRow(
          position: i + 1,
          team: teams[i].team,
          played: teams[i].played,
          points: teams[i].points,
          image: teams[i].image,
        ));
      }
    } else {
      // Fallback empty if no data found
      currentStandings = [];
    }

    return CompetitionDetailData(
      id: id,
      title: titleOverride ?? 'Liga Educa',
      subtitle: subtitleOverride ?? '',
      groupTitle: groupTitle,
      currentMatchday: 15,
      results: [
        MatchResult(
            home: home,
            away: away,
            homeGoals: 1,
            awayGoals: 7,
            status: 'FINAL',
            dateTime: now.subtract(const Duration(days: 4, hours: 2))),
        MatchResult(
            home: altHome,
            away: altAway,
            homeGoals: 4,
            awayGoals: 4,
            status: 'FINAL',
            dateTime: now.subtract(const Duration(days: 4, hours: 2))),
      ],
      standings: currentStandings,
      nextMatchday: [
        MatchResult(
            home: home,
            away: altAway,
            homeGoals: 0,
            awayGoals: 0,
            status: '16:00',
            dateTime: now.add(const Duration(days: 3, hours: 16))),
        MatchResult(
            home: away,
            away: altHome,
            homeGoals: 0,
            awayGoals: 0,
            status: '18:00',
            dateTime: now.add(const Duration(days: 3, hours: 18))),
      ],
      streak: const {
        'Real Betis Balompié - Marc Roca': ['W', 'W', 'D', 'W', 'L'],
        'Camino Viejo C.F.': ['W', 'D', 'W', 'D', 'W'],
        'Atlético Verde': ['L', 'W', 'W', 'W', 'D'],
      },
    );
  }
}
