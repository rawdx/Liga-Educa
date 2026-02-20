class CompetitionSummary {
  final String id;
  final String category;
  final String seasonLabel;
  final String groupLabel;
  final int groupsCount;

  const CompetitionSummary({
    required this.id,
    required this.category,
    required this.seasonLabel,
    required this.groupLabel,
    required this.groupsCount,
  });

  factory CompetitionSummary.fromJson(Map<String, dynamic> json) =>
      CompetitionSummary(
        id: (json['id'] ?? '').toString(),
        category: (json['category'] ?? '').toString(),
        seasonLabel: (json['seasonLabel'] ?? '').toString(),
        groupLabel: (json['groupLabel'] ?? '').toString(),
        groupsCount: (json['groupsCount'] ?? 0) as int,
      );
}

class MatchTeam {
  final String name;
  final String short;
  final String? image;
  const MatchTeam({required this.name, required this.short, this.image});
}

class MatchResult {
  final int matchday;
  final MatchTeam home;
  final MatchTeam away;
  final int homeGoals;
  final int awayGoals;
  final String status;
  final int statusValue; // 0: Pending, 1: Finished, 2: Suspended, 3: Postponed
  final DateTime dateTime;
  final String? stadium;
  final String? referee;

  const MatchResult({
    required this.matchday,
    required this.home,
    required this.away,
    required this.homeGoals,
    required this.awayGoals,
    required this.status,
    required this.statusValue,
    required this.dateTime,
    this.stadium,
    this.referee,
  });
}

class StandingRow {
  final int position;
  final String team;
  final int played;
  final int points;
  final int won;
  final int drawn;
  final int lost;
  final int gf;
  final int ga;
  final String? image;

  // Detailed stats for Casa/Fuera
  final int wonHome;
  final int drawnHome;
  final int lostHome;
  final int gfHome;
  final int gaHome;
  final int wonAway;
  final int drawnAway;
  final int lostAway;
  final int gfAway;
  final int gaAway;

  const StandingRow({
    required this.position,
    required this.team,
    required this.played,
    required this.points,
    this.won = 0,
    this.drawn = 0,
    this.lost = 0,
    this.gf = 0,
    this.ga = 0,
    this.image,
    this.wonHome = 0,
    this.drawnHome = 0,
    this.lostHome = 0,
    this.gfHome = 0,
    this.gaHome = 0,
    this.wonAway = 0,
    this.drawnAway = 0,
    this.lostAway = 0,
    this.gfAway = 0,
    this.gaAway = 0,
  });

  int get playedHome => wonHome + drawnHome + lostHome;
  int get playedAway => wonAway + drawnAway + lostAway;
}

class CompetitionDetailData {
  final String id;
  final String title;
  final String subtitle;
  final String groupTitle;
  final int currentMatchday;
  final List<MatchResult> results;
  final List<StandingRow> standings;
  final List<MatchResult> nextMatchday;
  final Map<String, List<String>> streak; // team -> last outcomes (W/D/L)

  const CompetitionDetailData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.groupTitle,
    required this.currentMatchday,
    required this.results,
    required this.standings,
    required this.nextMatchday,
    required this.streak,
  });
}

class FavoriteTeam {
  final String teamName;
  final String competitionId;
  final String? competitionTitle;
  final String? image;

  const FavoriteTeam({
    required this.teamName,
    required this.competitionId,
    this.competitionTitle,
    this.image,
  });

  Map<String, dynamic> toJson() => {
        'teamName': teamName,
        'competitionId': competitionId,
        'competitionTitle': competitionTitle,
        'image': image,
      };

  factory FavoriteTeam.fromJson(Map<String, dynamic> json) => FavoriteTeam(
        teamName: json['teamName'],
        competitionId: json['competitionId'],
        competitionTitle: json['competitionTitle'],
        image: json['image'],
      );
}

class Coach {
  final String name;
  final String role;
  final String? image;

  const Coach({
    required this.name,
    required this.role,
    this.image,
  });
}

class Player {
  final String name;
  final String? number;
  final String? position;
  final String? image;

  const Player({
    required this.name,
    this.number,
    this.position,
    this.image,
  });
}

