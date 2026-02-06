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
  static const String _matchesAssetPath = 'assets/data/matches.json';

  List<CompetitionSummary>? _cache;
  Map<String, List<StandingRow>>? _teamsCache;
  Map<String, Map<String, List<MatchResult>>>? _matchesCache;

  Future<void> _loadMatches() async {
    if (_matchesCache != null) return;
    try {
      final raw = await rootBundle.loadString(_matchesAssetPath);
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _matchesCache = {};
        decoded.forEach((compId, matchdays) {
          if (matchdays is Map<String, dynamic>) {
            final dayMap = <String, List<MatchResult>>{};
            matchdays.forEach((day, matches) {
              if (matches is List) {
                dayMap[day] = matches.map<MatchResult>((m) {
                  final map = m as Map<String, dynamic>;
                  return MatchResult(
                    home: MatchTeam(
                        name: map['home'],
                        short: _getShortName(map['home']),
                        image: _getTeamImage(map['home'])),
                    away: MatchTeam(
                        name: map['away'],
                        short: _getShortName(map['away']),
                        image: _getTeamImage(map['away'])),
                    homeGoals: (map['homeGoals'] as num?)?.toInt() ?? 0,
                    awayGoals: (map['awayGoals'] as num?)?.toInt() ?? 0,
                    status: map['status'] ?? '',
                    statusValue: (map['statusValue'] as num?)?.toInt() ?? 0,
                    dateTime: DateTime.tryParse(map['dateTime'] ?? '') ??
                        DateTime.now(),
                    stadium: map['stadium'],
                    referee: map['referee'],
                  );
                }).toList();
              }
            });
            _matchesCache![compId] = dayMap;
          }
        });
      }
    } catch (e) {
      debugPrint('Failed to load matches JSON: $e');
      _matchesCache = {};
    }
  }

  String _getShortName(String fullName) {
    if (fullName.contains('Betis')) return 'BET';
    if (fullName.contains('Sevilla')) return 'SEV';
    if (fullName.contains('Camino')) return 'CV';
    if (fullName.contains('Loreto')) return 'LOR';
    if (fullName.contains('Triana')) return 'TRI';
    if (fullName.contains('Mares')) return 'MAR';
    if (fullName.contains('Roque')) return 'SRQ';
    if (fullName.contains('Esfubasa')) return 'ESF';
    if (fullName.contains('Huévar')) return 'HUE';
    return fullName.substring(0, 3).toUpperCase();
  }

  String? _getTeamImage(String fullName) {
    if (_teamsCache == null) return null;
    for (final list in _teamsCache!.values) {
      for (final t in list) {
        if (t.team == fullName) return t.image;
      }
    }
    return null;
  }

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
                final played = (t['played'] as num?)?.toInt() ?? 0;
                final points = (t['points'] as num?)?.toInt() ?? 0;
                
                // Simulate Stats
                int won = points ~/ 3;
                if (won > played) won = played;
                
                int remainingPoints = points - (won * 3);
                int drawn = remainingPoints; // 1 pt per draw
                if (won + drawn > played) drawn = played - won;
                
                int lost = played - won - drawn;
                if (lost < 0) lost = 0;

                // Simulate goals (pseudo-random based on name hash to be consistent)
                final nameHash = (t['name'] ?? '').hashCode;
                final gf = played > 0 ? (played * 1.5 + (nameHash % 10)).toInt() : 0;
                final ga = played > 0 ? (played * 1.0 + (nameHash % 8)).toInt() : 0;

                return StandingRow(
                  position: 0,
                  team: t['name'] ?? '',
                  played: played,
                  points: points,
                  won: won,
                  drawn: drawn,
                  lost: lost,
                  gf: gf,
                  ga: ga,
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
    
    // Load matches
    await _loadMatches();

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

    // Default current matchday
    const currentMatchday = 2;

    // Get matches for current matchday from cache
    List<MatchResult> currentMatches = [];
    List<MatchResult> nextMatches = [];
    
    if (_matchesCache != null && _matchesCache!.containsKey(id)) {
      final days = _matchesCache![id]!;
      if (days.containsKey(currentMatchday.toString())) {
        currentMatches = days[currentMatchday.toString()]!;
      }
      if (days.containsKey((currentMatchday + 1).toString())) {
        nextMatches = days[(currentMatchday + 1).toString()]!;
      }
    } else {
      // If no data found for this ID, try 'minis-grupo-1' as fallback for demo
      if (_matchesCache != null && _matchesCache!.containsKey('minis-grupo-1')) {
         final days = _matchesCache!['minis-grupo-1']!;
         if (days.containsKey(currentMatchday.toString())) {
           currentMatches = days[currentMatchday.toString()]!;
         }
         if (days.containsKey((currentMatchday + 1).toString())) {
           nextMatches = days[(currentMatchday + 1).toString()]!;
         }
      }
    }

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
          won: teams[i].won,
          drawn: teams[i].drawn,
          lost: teams[i].lost,
          gf: teams[i].gf,
          ga: teams[i].ga,
          image: teams[i].image,
        ));
      }
    } else {
      // Fallback empty if no data found
      currentStandings = [];
    }

    // Calculate streak dynamically from match data
    final streakData = _calculateStreak(id, currentStandings);

    return CompetitionDetailData(
      id: id,
      title: titleOverride ?? 'Liga Educa',
      subtitle: subtitleOverride ?? '',
      groupTitle: groupTitle,
      currentMatchday: currentMatchday,
      results: currentMatches,
      standings: currentStandings,
      nextMatchday: nextMatches,
      streak: streakData,
    );
  }

  /// Calculates streak for all teams in a competition based on match history.
  /// Returns a map of team name -> list of last 5 results.
  /// Result codes: W (win), D (draw), L (loss), S (suspended), R (rest/bye)
  Map<String, List<String>> _calculateStreak(String competitionId, List<StandingRow> standings) {
    final Map<String, List<String>> result = {};

    // Get all matches for this competition
    final matchDays = _matchesCache?[competitionId] ?? _matchesCache?['minis-grupo-1'] ?? {};
    if (matchDays.isEmpty || standings.isEmpty) return result;

    // Get all team names from standings
    final teamNames = standings.map((s) => s.team).toSet();

    // Collect all matchdays sorted in descending order (most recent first)
    final sortedMatchdays = matchDays.keys
        .map((k) => int.tryParse(k) ?? 0)
        .where((d) => d > 0)
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Descending

    // For each team, calculate their streak
    for (final teamName in teamNames) {
      final List<String> teamStreak = [];

      for (final matchday in sortedMatchdays) {
        if (teamStreak.length >= 5) break; // Only last 5

        final matches = matchDays[matchday.toString()] ?? [];

        // Find if this team played in this matchday
        MatchResult? teamMatch;
        bool isHome = false;

        for (final match in matches) {
          if (match.home.name == teamName) {
            teamMatch = match;
            isHome = true;
            break;
          } else if (match.away.name == teamName) {
            teamMatch = match;
            isHome = false;
            break;
          }
        }

        if (teamMatch == null) {
          // Team didn't play in this matchday - check if it's a rest/bye
          // Only count as rest if at least one match was played that day
          final hasFinishedMatches = matches.any((m) => m.statusValue == 1);
          if (hasFinishedMatches) {
            teamStreak.add('R'); // Rest/Bye
          }
        } else {
          // Team had a match in this matchday
          switch (teamMatch.statusValue) {
            case 1: // Finished
              final teamGoals = isHome ? teamMatch.homeGoals : teamMatch.awayGoals;
              final opponentGoals = isHome ? teamMatch.awayGoals : teamMatch.homeGoals;
              if (teamGoals > opponentGoals) {
                teamStreak.add('W'); // Win
              } else if (teamGoals < opponentGoals) {
                teamStreak.add('L'); // Loss
              } else {
                teamStreak.add('D'); // Draw
              }
              break;
            case 2: // Suspended
              teamStreak.add('S'); // Suspended
              break;
            case 3: // Postponed
              teamStreak.add('A'); // Postponed/Aplazado
              break;
            case 0: // Pending - don't count
            default:
              // Skip pending matches
              break;
          }
        }
      }

      // Reverse to show oldest to newest (left to right)
      result[teamName] = teamStreak.reversed.toList();
    }

    return result;
  }

  List<MatchResult> getMatches(String competitionId, int matchday) {
    if (_matchesCache == null) return [];
    
    // Try exact ID
    if (_matchesCache!.containsKey(competitionId)) {
      final days = _matchesCache![competitionId];
      if (days != null) {
        return days[matchday.toString()] ?? [];
      }
    }
    
    // Fallback for demo
    if (_matchesCache!.containsKey('minis-grupo-1')) {
      final days = _matchesCache!['minis-grupo-1'];
      if (days != null) {
        return days[matchday.toString()] ?? [];
      }
    }

    return [];
  }

  Map<String, List<MatchResult>> getAllMatchesGrouped(String competitionId) {
    if (_matchesCache == null) return {};

    // Try exact ID
    if (_matchesCache!.containsKey(competitionId)) {
      return _matchesCache![competitionId] ?? {};
    }

    // Fallback for demo
    if (_matchesCache!.containsKey('minis-grupo-1')) {
      return _matchesCache!['minis-grupo-1'] ?? {};
    }

    return {};
  }

  /// Retrieves all matches (past and future) for a specific team in a competition.
  List<MatchResult> getTeamMatches(String competitionId, String teamName) {
    final List<MatchResult> teamMatches = [];
    final matchDays = _matchesCache?[competitionId] ?? _matchesCache?['minis-grupo-1'] ?? {};
    
    // Sort matchday keys numerically
    final sortedKeys = matchDays.keys.toList()
      ..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));

    for (final dayKey in sortedKeys) {
      final matches = matchDays[dayKey] ?? [];
      for (final match in matches) {
        if (match.home.name == teamName || match.away.name == teamName) {
          teamMatches.add(match);
        }
      }
    }
    
    return teamMatches;
  }
}
