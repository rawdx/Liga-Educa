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
  final DateTime dateTime;
  const MatchResult({
    required this.home,
    required this.away,
    required this.homeGoals,
    required this.awayGoals,
    required this.status,
    required this.dateTime,
  });
}

class StandingRow {
  final int position;
  final String team;
  final int played;
  final int points;
  final String? image;
  const StandingRow(
      {required this.position,
      required this.team,
      required this.played,
      required this.points,
      this.image});
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
