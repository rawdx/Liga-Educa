import 'package:flutter/material.dart';
import 'package:liga_educa/models/competition_models.dart';
import 'package:liga_educa/services/competitions_service.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_app_bar.dart';
import 'package:liga_educa/widgets/league_card.dart';
import 'package:liga_educa/widgets/match_item.dart';
import 'package:liga_educa/widgets/sponsor_footer.dart';

class TeamDetailPage extends StatefulWidget {
  final String teamName;
  final String competitionId;
  final String? competitionTitle;

  const TeamDetailPage({
    super.key,
    required this.teamName,
    required this.competitionId,
    this.competitionTitle,
  });

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  late List<MatchResult> _allMatches;
  late StandingRow? _stats;
  late List<String> _streak;

  @override
  void initState() {
    super.initState();
    final detail = CompetitionsService.instance.getDetail(widget.competitionId);
    
    // Find team stats in standings
    try {
      _stats = detail.standings.firstWhere((s) => s.team == widget.teamName);
    } catch (_) {
      _stats = null;
    }

    _allMatches = CompetitionsService.instance.getTeamMatches(widget.competitionId, widget.teamName);
    _streak = detail.streak[widget.teamName] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    final pastMatches = _allMatches.where((m) => m.statusValue == 1).toList().reversed.toList();
    final futureMatches = _allMatches.where((m) => m.statusValue == 0 || m.statusValue == 3).toList();

    return Scaffold(
      appBar: LeagueAppBar(
        title: widget.teamName,
        subtitle: widget.competitionTitle ?? 'Detalle de Equipo',
        showBack: true,
      ),
      endDrawer: const LeagueMenuDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          children: [
            // 1. Header Card with Logo
            LeagueCard(
              background: LeagueCardBackground.accent,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (_stats?.image != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(_stats!.image!, width: 80, height: 80, fit: BoxFit.contain),
                    )
                  else
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppBrandColors.white,
                      child: Icon(Icons.shield, size: 40, color: AppBrandColors.navy900),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    widget.teamName.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppBrandColors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (_stats != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppBrandColors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Posición: ${_stats!.position}º',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppBrandColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Stats Summary
            if (_stats != null)
              _SectionBlock(
                title: 'Estadísticas',
                icon: Icons.bar_chart_rounded,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(label: 'PJ', value: '${_stats!.played}'),
                    _StatItem(label: 'G', value: '${_stats!.won}', color: AppBrandColors.green),
                    _StatItem(label: 'E', value: '${_stats!.drawn}', color: Colors.orange),
                    _StatItem(label: 'P', value: '${_stats!.lost}', color: Colors.redAccent),
                    _StatItem(label: 'PTS', value: '${_stats!.points}', isPrimary: true),
                  ],
                ),
              ),
            
            const SizedBox(height: 20),

            // 3. Last Results (Streak)
            _SectionBlock(
              title: 'Últimos resultados',
              icon: Icons.history_rounded,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _streak.map((s) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _StreakBadge(result: s),
                    )).toList(),
                  ),
                  if (pastMatches.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...pastMatches.take(3).map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: MatchItem(match: m),
                    )),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 4. Upcoming Matches
            if (futureMatches.isNotEmpty)
              _SectionBlock(
                title: 'Próximos encuentros',
                icon: Icons.calendar_today_rounded,
                child: Column(
                  children: futureMatches.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: MatchItem(match: m),
                  )).toList(),
                ),
              ),

            const SizedBox(height: 20),
            const SponsorFooter(),
          ],
        ),
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionBlock({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return LeagueCard(
      background: LeagueCardBackground.navy,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppBrandColors.green),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isPrimary;

  const _StatItem({
    required this.label,
    required this.value,
    this.color,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isPrimary ? AppBrandColors.green : (color ?? Theme.of(context).colorScheme.onSurface),
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final String result;
  const _StreakBadge({required this.result});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (result) {
      'W' => ('G', AppBrandColors.green),
      'D' => ('E', Colors.orange),
      'L' => ('P', Colors.redAccent),
      'S' => ('S', Colors.blueGrey),
      'A' => ('A', Colors.indigoAccent),
      _ => ('-', Colors.grey),
    };

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
