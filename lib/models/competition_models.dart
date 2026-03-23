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

  factory CompetitionSummary.fromJson(Map<String, dynamic> json) {
    return CompetitionSummary(
      id: json['id']?.toString() ?? '',
      category: json['category'] ?? '',
      seasonLabel: json['seasonLabel'] ?? '',
      groupLabel: json['groupLabel'] ?? '',
      groupsCount: json['groupsCount'] ?? 0,
    );
  }
}

class CompetitionDetailData {
  final String id;
  final String title;
  final String subtitle;
  final String groupTitle;
  final String seasonLabel;
  final int currentMatchday;
  final int maxMatchday;
  final List<MatchResult> results;
  final List<StandingRow> standings;
  final List<MatchResult> nextMatchday;
  final Map<String, List<String>> streak;

  const CompetitionDetailData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.groupTitle,
    required this.seasonLabel,
    required this.currentMatchday,
    required this.maxMatchday,
    required this.results,
    required this.standings,
    required this.nextMatchday,
    required this.streak,
  });
}

class StandingRow {
  final int position;
  final String team;
  final String? teamId;
  final int played;
  final int points;
  final int won;
  final int drawn;
  final int lost;
  final int gf;
  final int ga;
  final String? image;

  // Detailed stats
  final int playedHome; // Added
  final int playedAway; // Added
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
    this.teamId,
    required this.played,
    required this.points,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.gf,
    required this.ga,
    this.image,
    this.playedHome = 0,
    this.playedAway = 0,
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
}

class MatchResult {
  final int matchday;
  final MatchTeam home;
  final MatchTeam away;
  final int homeGoals;
  final int awayGoals;
  final String status;
  final int statusValue; // 1: Finished, 0: Pending, 2: Suspended, 3: Postponed
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

class MatchTeam {
  final String name;
  final String? id;
  final String short;
  final String? image;

  const MatchTeam({
    required this.name,
    this.id,
    required this.short,
    this.image,
  });
}

class FavoriteTeam {
  final String teamName;
  final String? teamId;
  final String competitionId;
  final String? competitionTitle;
  final String? image;

  const FavoriteTeam({
    required this.teamName,
    this.teamId,
    required this.competitionId,
    this.competitionTitle,
    this.image,
  });

  Map<String, dynamic> toJson() => {
        'teamName': teamName,
        'teamId': teamId,
        'competitionId': competitionId,
        'competitionTitle': competitionTitle,
        'image': image,
      };

  factory FavoriteTeam.fromJson(Map<String, dynamic> json) {
    return FavoriteTeam(
      teamName: json['teamName'] ?? '',
      teamId: json['teamId'],
      competitionId: json['competitionId'] ?? '',
      competitionTitle: json['competitionTitle'],
      image: json['image'],
    );
  }
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
