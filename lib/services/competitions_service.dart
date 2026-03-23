import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liga_educa/models/competition_models.dart';

/// Real data service connecting to Education League API.
class CompetitionsService {
  // Singleton instance
  static final CompetitionsService instance = CompetitionsService._();
  CompetitionsService._();

  static const String _baseUrl = 'https://www.educationleague.es/apis/education_league/';
  static const Map<String, String> _headers = {
    'X-Auth-Token': '#!t4//l1g43duc4@260310',
    'Content-Type': 'application/json',
  };

  static const String _prefCompetitions = 'cache_competitions';
  static const String _prefTeams = 'cache_teams';
  static const String _prefMatches = 'cache_matches';

  List<CompetitionSummary>? _cache;
  Map<String, Map<String, String?>>? _teamImagesCache; // competitionId -> {teamName -> image}
  Map<String, Map<String, List<MatchResult>>>? _matchesCache;

  Future<void> _loadTeams() async {
    if (_teamImagesCache != null) return;
    
    // 1. Try to load from memory/cache
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_prefTeams);
    if (cachedData != null) {
      _parseTeamsData(jsonDecode(cachedData));
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?section=teams'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == 200 && decoded['data'] is Map<String, dynamic>) {
          await prefs.setString(_prefTeams, jsonEncode(decoded['data']));
          _parseTeamsData(decoded['data']);
        }
      }
    } catch (e) {
      debugPrint('Failed to load teams from API (offline?): $e');
    }
  }

  void _parseTeamsData(Map<String, dynamic> data) {
    _teamImagesCache = {};
    data.forEach((compId, teams) {
      if (teams is List) {
        _teamImagesCache![compId] = {};
        for (final t in teams) {
          final name = t['name'] as String? ?? '';
          final image = t['image'] as String?;
          if (name.isNotEmpty) {
            _teamImagesCache![compId]![name] = image;
          }
        }
      }
    });
  }

  Future<void> _loadMatches() async {
    if (_matchesCache != null) return;

    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_prefMatches);
    if (cachedData != null) {
      _parseMatchesData(jsonDecode(cachedData));
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?section=matches'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == 200 && decoded['data'] is Map<String, dynamic>) {
          await prefs.setString(_prefMatches, jsonEncode(decoded['data']));
          _parseMatchesData(decoded['data']);
        }
      }
    } catch (e) {
      debugPrint('Failed to load matches from API (offline?): $e');
    }
  }

  void _parseMatchesData(Map<String, dynamic> data) {
    _matchesCache = {};
    data.forEach((compId, matchdays) {
      if (matchdays is Map<String, dynamic>) {
        final dayMap = <String, List<MatchResult>>{};
        matchdays.forEach((day, matches) {
          if (matches is List) {
            dayMap[day] = matches.map<MatchResult>((m) {
              final map = m as Map<String, dynamic>;
              final statusStr = map['status'] as String? ?? '';
              
              int statusValue = 0;
              if (statusStr == 'Finalizado') {
                statusValue = 1;
              } else if (statusStr == 'Suspendido') {
                statusValue = 2;
              } else if (statusStr == 'Aplazado') {
                statusValue = 3;
              }

              return MatchResult(
                matchday: int.tryParse(day) ?? 0,
                home: MatchTeam(
                    name: map['home'],
                    short: _getShortName(map['home']),
                    image: _getTeamImage(map['home'], compId)),
                away: MatchTeam(
                    name: map['away'],
                    short: _getShortName(map['away']),
                    image: _getTeamImage(map['away'], compId)),
                homeGoals: (map['homeGoals'] as num?)?.toInt() ?? 0,
                awayGoals: (map['awayGoals'] as num?)?.toInt() ?? 0,
                status: statusStr,
                statusValue: statusValue,
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
    if (fullName.length >= 3) return fullName.substring(0, 3).toUpperCase();
    return fullName.toUpperCase();
  }

  String? _getTeamImage(String fullName, [String? competitionId]) {
    if (_teamImagesCache == null) return null;

    // Si se especifica competitionId, buscar primero ahí
    if (competitionId != null && _teamImagesCache!.containsKey(competitionId)) {
      final compImages = _teamImagesCache![competitionId]!;
      if (compImages.containsKey(fullName)) {
        return compImages[fullName];
      }
    }

    // Buscar en todas las competiciones
    for (final compImages in _teamImagesCache!.values) {
      if (compImages.containsKey(fullName)) {
        return compImages[fullName];
      }
    }
    return null;
  }

  /// Calcula la clasificación dinámicamente desde los partidos finalizados
  List<StandingRow> _calculateStandings(String competitionId) {
    final matchDays = _matchesCache?[competitionId] ?? {};
    if (matchDays.isEmpty) return [];

    // Acumulador de estadísticas por equipo
    final Map<String, _TeamStats> stats = {};

    // Recorrer todos los partidos finalizados
    for (final matches in matchDays.values) {
      for (final match in matches) {
        // Solo contar partidos finalizados
        if (match.status != 'Finalizado') continue;

        final homeName = match.home.name;
        final awayName = match.away.name;
        final homeGoals = match.homeGoals;
        final awayGoals = match.awayGoals;

        // Inicializar equipos si no existen
        stats.putIfAbsent(homeName, () => _TeamStats());
        stats.putIfAbsent(awayName, () => _TeamStats());

        final homeStats = stats[homeName]!;
        final awayStats = stats[awayName]!;

        // Actualizar partidos jugados
        homeStats.playedHome++;
        awayStats.playedAway++;

        // Actualizar goles
        homeStats.gfHome += homeGoals;
        homeStats.gaHome += awayGoals;
        awayStats.gfAway += awayGoals;
        awayStats.gaAway += homeGoals;

        // Determinar resultado y actualizar victorias/empates/derrotas
        if (homeGoals > awayGoals) {
          // Victoria local
          homeStats.wonHome++;
          awayStats.lostAway++;
        } else if (homeGoals < awayGoals) {
          // Victoria visitante
          homeStats.lostHome++;
          awayStats.wonAway++;
        } else {
          // Empate
          homeStats.drawnHome++;
          awayStats.drawnAway++;
        }
      }
    }

    // Convertir a lista de StandingRow
    final List<StandingRow> standings = stats.entries.map((entry) {
      final name = entry.key;
      final s = entry.value;

      // Totales
      final played = s.playedHome + s.playedAway;
      final won = s.wonHome + s.wonAway;
      final drawn = s.drawnHome + s.drawnAway;
      final lost = s.lostHome + s.lostAway;
      final gf = s.gfHome + s.gfAway;
      final ga = s.gaHome + s.gaAway;
      final points = (won * 3) + drawn;

      return StandingRow(
        position: 0, // Se asignará después de ordenar
        team: name,
        played: played,
        points: points,
        won: won,
        drawn: drawn,
        lost: lost,
        gf: gf,
        ga: ga,
        image: _getTeamImage(name, competitionId),
        wonHome: s.wonHome,
        drawnHome: s.drawnHome,
        lostHome: s.lostHome,
        gfHome: s.gfHome,
        gaHome: s.gaHome,
        wonAway: s.wonAway,
        drawnAway: s.drawnAway,
        lostAway: s.lostAway,
        gfAway: s.gfAway,
        gaAway: s.gaAway,
      );
    }).toList();

    // Ordenar por: puntos (desc), diferencia de goles (desc), goles a favor (desc)
    standings.sort((a, b) {
      final pointsDiff = b.points.compareTo(a.points);
      if (pointsDiff != 0) return pointsDiff;

      final gdDiff = (b.gf - b.ga).compareTo(a.gf - a.ga);
      if (gdDiff != 0) return gdDiff;

      return b.gf.compareTo(a.gf);
    });

    // Asignar posiciones
    final List<StandingRow> result = [];
    for (int i = 0; i < standings.length; i++) {
      final s = standings[i];
      result.add(StandingRow(
        position: i + 1,
        team: s.team,
        played: s.played,
        points: s.points,
        won: s.won,
        drawn: s.drawn,
        lost: s.lost,
        gf: s.gf,
        ga: s.ga,
        image: s.image,
        wonHome: s.wonHome,
        drawnHome: s.drawnHome,
        lostHome: s.lostHome,
        gfHome: s.gfHome,
        gaHome: s.gaHome,
        wonAway: s.wonAway,
        drawnAway: s.drawnAway,
        lostAway: s.lostAway,
        gfAway: s.gfAway,
        gaAway: s.gaAway,
      ));
    }

    return result;
  }

  Future<List<CompetitionSummary>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Load competitions from cache first if memory is empty
    if (_cache == null) {
      final cachedComp = prefs.getString(_prefCompetitions);
      if (cachedComp != null) {
        try {
          final List<dynamic> decoded = jsonDecode(cachedComp);
          _cache = decoded
              .whereType<Map<String, dynamic>>()
              .map(CompetitionSummary.fromJson)
              .toList(growable: false);
        } catch (e) {
          debugPrint('Error parsing cached competitions: $e');
        }
      }
    }

    // 2. Load teams and matches (they already have internal cache logic)
    await _loadTeams();
    await _loadMatches();

    // 3. Try to update competitions from API
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?section=competitions'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == 200 && decoded['data'] is List) {
          final list = decoded['data'] as List;
          
          // Update cache in SharedPreferences
          await prefs.setString(_prefCompetitions, jsonEncode(list));
          
          _cache = list
              .whereType<Map<String, dynamic>>()
              .map(CompetitionSummary.fromJson)
              .toList(growable: false);
          
          return _cache!;
        }
      }
    } catch (e) {
      debugPrint('Failed to update competitions from API (using cache): $e');
    }

    return _cache ?? const [];
  }

  List<CompetitionSummary> listCompetitions() {
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

    // Calculate current matchday dynamically
    int currentMatchday = 1;
    int maxMatchday = 1;

    // Get matches for current matchday from cache
    List<MatchResult> currentMatches = [];
    List<MatchResult> nextMatches = [];

    if (_matchesCache != null && _matchesCache!.containsKey(id)) {
      final days = _matchesCache![id]!;

      // Find max matchday and current matchday (last with finished matches)
      final matchdayNumbers = days.keys
          .map((k) => int.tryParse(k) ?? 0)
          .where((d) => d > 0)
          .toList()
        ..sort();

      if (matchdayNumbers.isNotEmpty) {
        maxMatchday = matchdayNumbers.last;

        // Find the last matchday with at least one finished match
        for (final dayNum in matchdayNumbers.reversed) {
          final matches = days[dayNum.toString()] ?? [];
          final hasFinished = matches.any((m) => m.status == 'Finalizado');
          if (hasFinished) {
            currentMatchday = dayNum;
            break;
          }
        }

        // If no finished matches found, use the first matchday
        if (currentMatchday == 1 && matchdayNumbers.isNotEmpty) {
          currentMatchday = matchdayNumbers.first;
        }
      }

      if (days.containsKey(currentMatchday.toString())) {
        currentMatches = days[currentMatchday.toString()]!;
      }
      if (days.containsKey((currentMatchday + 1).toString())) {
        nextMatches = days[(currentMatchday + 1).toString()]!;
      }
    }

    // Calculate standings dynamically from matches
    final currentStandings = _calculateStandings(id);

    // Calculate streak dynamically from match data
    final streakData = _calculateStreak(id, currentStandings);

    // Generate a descriptive title if not provided
    String defaultTitle = 'Competición';
    if (competition != null) {
      if (competition.groupLabel.isNotEmpty && competition.groupLabel != 'General') {
        defaultTitle = '${competition.category} - ${competition.groupLabel}';
      } else {
        defaultTitle = competition.category;
      }
    }

    return CompetitionDetailData(
      id: id,
      title: titleOverride ?? defaultTitle,
      subtitle: subtitleOverride ?? '',
      groupTitle: groupTitle,
      seasonLabel: competition?.seasonLabel ?? '',
      currentMatchday: currentMatchday,
      maxMatchday: maxMatchday,
      results: currentMatches,
      standings: currentStandings,
      nextMatchday: nextMatches,
      streak: streakData,
    );
  }

  Map<String, List<String>> _calculateStreak(String competitionId, List<StandingRow> standings) {
    final Map<String, List<String>> result = {};
    final matchDays = _matchesCache?[competitionId] ?? {};
    if (matchDays.isEmpty || standings.isEmpty) return result;

    final teamNames = standings.map((s) => s.team).toSet();
    final sortedMatchdays = matchDays.keys
        .map((k) => int.tryParse(k) ?? 0)
        .where((d) => d > 0)
        .toList()
      ..sort((a, b) => b.compareTo(a));

    for (final teamName in teamNames) {
      final List<String> teamStreak = [];
      for (final matchday in sortedMatchdays) {
        if (teamStreak.length >= 5) break;
        final matches = matchDays[matchday.toString()] ?? [];
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
          final hasFinishedMatches = matches.any((m) => 
            m.statusValue == 1 || m.statusValue == 2 || m.statusValue == 3);
          if (hasFinishedMatches) {
            teamStreak.add('R');
          }
        } else {
          if (teamMatch.statusValue == 1) {
            final teamGoals = isHome ? teamMatch.homeGoals : teamMatch.awayGoals;
            final opponentGoals = isHome ? teamMatch.awayGoals : teamMatch.homeGoals;
            if (teamGoals > opponentGoals) {
              teamStreak.add('W');
            } else if (teamGoals < opponentGoals) {
              teamStreak.add('L');
            } else {
              teamStreak.add('D');
            }
          } else if (teamMatch.statusValue == 2) {
            teamStreak.add('S'); // Suspended
          } else if (teamMatch.statusValue == 3) {
            teamStreak.add('A'); // Postponed
          }
        }
      }
      result[teamName] = teamStreak.reversed.toList();
    }
    return result;
  }

  List<MatchResult> getMatches(String competitionId, int matchday) {
    if (_matchesCache == null) return [];
    if (_matchesCache!.containsKey(competitionId)) {
      final days = _matchesCache![competitionId];
      if (days != null) {
        return days[matchday.toString()] ?? [];
      }
    }
    return [];
  }

  Map<String, List<MatchResult>> getAllMatchesGrouped(String competitionId) {
    if (_matchesCache == null) return {};
    if (_matchesCache!.containsKey(competitionId)) {
      return _matchesCache![competitionId] ?? {};
    }
    return {};
  }

  List<MatchResult> getTeamMatches(String competitionId, String teamName) {
    final List<MatchResult> teamMatches = [];
    final matchDays = _matchesCache?[competitionId] ?? {};
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

  List<Coach> getTeamCoaches(String teamName) {
    return [
      Coach(name: 'Francisco Javier Ruiz', role: 'Primer Entrenador'),
      Coach(name: 'Manuel García López', role: 'Segundo Entrenador'),
    ];
  }

  List<Player> getTeamPlayers(String teamName) {
    return [
      Player(name: 'Adrián González', number: '1', position: 'Portero'),
      Player(name: 'Daniel Sánchez', number: '4', position: 'Defensa'),
      Player(name: 'Alejandro Ramos', number: '5', position: 'Defensa'),
      Player(name: 'Marcos Benítez', number: '8', position: 'Centrocampista'),
      Player(name: 'Hugo Martínez', number: '10', position: 'Delantero'),
      Player(name: 'Álvaro López', number: '11', position: 'Delantero'),
      Player(name: 'Pau Ferré', number: '14', position: 'Centrocampista'),
      Player(name: 'Lucas Romero', number: '21', position: 'Defensa'),
    ];
  }
}

class _TeamStats {
  int playedHome = 0;
  int playedAway = 0;
  int wonHome = 0;
  int wonAway = 0;
  int drawnHome = 0;
  int drawnAway = 0;
  int lostHome = 0;
  int lostAway = 0;
  int gfHome = 0;
  int gfAway = 0;
  int gaHome = 0;
  int gaAway = 0;
}
