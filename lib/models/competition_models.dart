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
  });
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
