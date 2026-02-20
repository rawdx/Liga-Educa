import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/models/competition_models.dart';
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/pages/calendar_page.dart';
import 'package:liga_educa/services/competitions_service.dart';
import 'package:liga_educa/services/favorites_service.dart';
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
  late CompetitionDetailData _competitionDetail;
  late List<Coach> _coaches;
  late List<Player> _players;

  @override
  void initState() {
    super.initState();
    _competitionDetail = CompetitionsService.instance.getDetail(widget.competitionId);
    
    // Find team stats in standings
    try {
      _stats = _competitionDetail.standings.firstWhere((s) => s.team == widget.teamName);
    } catch (_) {
      _stats = null;
    }

    _allMatches = CompetitionsService.instance.getTeamMatches(widget.competitionId, widget.teamName);
    _coaches = CompetitionsService.instance.getTeamCoaches(widget.teamName);
    _players = CompetitionsService.instance.getTeamPlayers(widget.teamName);
  }

    @override

    Widget build(BuildContext context) {

      final pastMatches = _allMatches.where((m) => m.statusValue == 1).toList().reversed.toList();

  

      // Format competition title for AppBar subtitle

      final compParts = _competitionDetail.groupTitle.split('\n');

      final compDisplay = compParts.length > 1 

          ? '${compParts.first} - ${compParts.last}' 

          : compParts.first;

  

      return Scaffold(

        appBar: LeagueAppBar(

          title: widget.teamName,

          subtitle: compDisplay,

          showBack: true,

          actions: [

            ListenableBuilder(

              listenable: FavoritesService.instance,

              builder: (context, _) {

                final isFav = FavoritesService.instance.isFavorite(widget.teamName, widget.competitionId);

                return Center(

                  child: Padding(

                    padding: const EdgeInsets.only(right: 12, left: 12),

                    child: Material(

                        color: isFav ? Colors.redAccent.withValues(alpha: 0.15) : AppBrandColors.green.withValues(alpha: 0.15),

                        borderRadius: BorderRadius.circular(12),

                        child: InkWell(

                                                    onTap: () {
                                                      FavoritesService.instance.toggleFavorite(FavoriteTeam(
                                                        teamName: widget.teamName,
                                                        competitionId: widget.competitionId,
                                                        competitionTitle: compDisplay,
                                                        image: _stats?.image,
                                                      ));
                                                    },

                          borderRadius: BorderRadius.circular(12),

                          child: Container(

                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

                            decoration: BoxDecoration(

                              borderRadius: BorderRadius.circular(12),

                              border: Border.all(

                                color: isFav ? Colors.redAccent.withValues(alpha: 0.4) : AppBrandColors.green.withValues(alpha: 0.4),

                                width: 1.2,

                              ),

                            ),

                            child: Row(

                              mainAxisSize: MainAxisSize.min,

                              children: [

                                Icon(

                                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,

                                  size: 14,

                                  color: isFav ? Colors.redAccent : AppBrandColors.green,

                                ),

                                const SizedBox(width: 6),

                                Text(

                                  isFav ? 'SIGUIENDO' : 'SEGUIR',

                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(

                                        color: isFav ? Colors.redAccent : AppBrandColors.green,

                                        fontWeight: FontWeight.w900,

                                        letterSpacing: 0.2,

                                      ),

                                ),

                              ],

                            ),

                          ),

                        ),

                      ),

                    ),

                  );

                },

              ),

            ],

          ),

          endDrawer: const LeagueMenuDrawer(),

          body: SafeArea(

            child: ListView(

              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),

              children: [

                                                                // 1. Header Card with Logo
                                                                LeagueCard(
                                                                  background: LeagueCardBackground.navy,
                                                                  padding: EdgeInsets.zero,
                                                                  child: Stack(
                                                                    children: [
                                                                      // Radial glow behind logo
                                                                      Positioned.fill(
                                                                        child: DecoratedBox(
                                                                          decoration: BoxDecoration(
                                                                            gradient: RadialGradient(
                                                                              center: const Alignment(0, -0.45),
                                                                              radius: 0.7,
                                                                              colors: [
                                                                                AppBrandColors.green.withValues(alpha: 0.08),
                                                                                Colors.transparent,
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                                                                  // Subtle football field motif
                                                                                                                  Positioned.fill(
                                                                                                                    child: CustomPaint(
                                                                                                                      painter: _FootballFieldPainter(
                                                                                                                        color: Colors.white.withValues(alpha: 0.04),
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),                                                                      // Decorative corner markers
                                                                      for (var alignment in [
                                                                        Alignment.topLeft,
                                                                        Alignment.topRight,
                                                                        Alignment.bottomLeft,
                                                                        Alignment.bottomRight
                                                                      ])
                                                                        Positioned.fill(
                                                                          child: Align(
                                                                            alignment: alignment,
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.all(12),
                                                                              child: Icon(
                                                                                Icons.add,
                                                                                size: 8,
                                                                                color: Colors.white.withValues(alpha: 0.1),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      // Accent notch at the top
                                                                      Positioned(
                                                                        top: 0,
                                                                        left: 0,
                                                                        right: 0,
                                                                        child: Center(
                                                                          child: Container(
                                                                            width: 40,
                                                                            height: 3,
                                                                            decoration: const BoxDecoration(
                                                                              color: AppBrandColors.green,
                                                                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(3)),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),                                                        child: Center(
                                                          child: Column(
                                                            children: [
                                                              // Logo with brand ring and position badge
                                                              Stack(
                                                                alignment: Alignment.bottomRight,
                                                                children: [
                                                                  Container(
                                                                    padding: const EdgeInsets.all(3),
                                                                    decoration: BoxDecoration(
                                                                      shape: BoxShape.circle,
                                                                      border: Border.all(
                                                                        color: AppBrandColors.green.withValues(alpha: 0.4),
                                                                        width: 2,
                                                                      ),
                                                                    ),
                                                                    child: Container(
                                                                      padding: const EdgeInsets.all(4),
                                                                      decoration: const BoxDecoration(
                                                                        color: Colors.white,
                                                                        shape: BoxShape.circle,
                                                                      ),
                                                                      child: ClipOval(
                                                                        child: _stats?.image != null
                                                                            ? Image.asset(_stats!.image!, width: 90, height: 90, fit: BoxFit.contain)
                                                                            : const CircleAvatar(
                                                                                radius: 45,
                                                                                backgroundColor: AppBrandColors.white,
                                                                                child: Icon(Icons.shield, size: 45, color: AppBrandColors.navy900),
                                                                              ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  if (_stats != null)
                                                                    Positioned(
                                                                      right: 0,
                                                                      bottom: 0,
                                                                      child: Container(
                                                                        padding: const EdgeInsets.all(8),
                                                                        decoration: BoxDecoration(
                                                                          color: AppBrandColors.green,
                                                                          shape: BoxShape.circle,
                                                                          border: Border.all(color: AppBrandColors.navy800, width: 3),
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.black.withValues(alpha: 0.3),
                                                                              blurRadius: 4,
                                                                              offset: const Offset(0, 2),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child: Text(
                                                                          '${_stats!.position}º',
                                                                          style: const TextStyle(
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 14,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                              const SizedBox(height: 20),
                                                              // Info Section
                                                              Text(
                                                                widget.teamName,
                                                                textAlign: TextAlign.center,
                                                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                                      color: AppBrandColors.white,
                                                                      fontWeight: FontWeight.w900,
                                                                      letterSpacing: -0.5,
                                                                    ),
                                                              ),
                                                              const SizedBox(height: 14),
                                                              Builder(
                                                                builder: (context) {
                                                                  final parts = _competitionDetail.groupTitle.split('\n');
                                                                  final display = parts.length > 1 
                                                                      ? '${parts.first} - ${parts.last}' 
                                                                      : parts.first;
                                                                  return Material(
                                                                    color: AppBrandColors.green.withValues(alpha: 0.15),
                                                                    borderRadius: BorderRadius.circular(12),
                                                                    child: InkWell(
                                                                      onTap: () {
                                                                        context.go(
                                                                          '${AppRoutes.competition}/${widget.competitionId}?title=${Uri.encodeComponent(_competitionDetail.title)}&subtitle=${Uri.encodeComponent(_competitionDetail.subtitle)}',
                                                                        );
                                                                      },
                                                                      borderRadius: BorderRadius.circular(12),
                                                                      child: Container(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(12),
                                                                          border: Border.all(
                                                                            color: AppBrandColors.green.withValues(alpha: 0.4),
                                                                            width: 1.2,
                                                                          ),
                                                                        ),
                                                                        child: Row(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: [
                                                                            const Icon(Icons.emoji_events, size: 16, color: AppBrandColors.green),
                                                                            const SizedBox(width: 10),
                                                                            Text(
                                                                              display.toUpperCase(),
                                                                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                                                    color: AppBrandColors.green,
                                                                                    fontWeight: FontWeight.w900,
                                                                                    letterSpacing: 0.6,
                                                                                    fontSize: 11,
                                                                                  ),
                                                                            ),
                                                                            const SizedBox(width: 8),
                                                                            const Icon(Icons.chevron_right_rounded, size: 16, color: AppBrandColors.green),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),            const SizedBox(height: 16),

            // 2. Stats Section
            if (_stats != null)
              _SectionBlock(
                title: 'Estadísticas',
                icon: Icons.bar_chart_rounded,
                child: Column(
                  children: [
                    _StatsTableHeader(),
                    const SizedBox(height: 12),
                    _StatsTableRow(
                      label: 'Jugados', 
                      gen: _stats!.played, 
                      casa: _stats!.playedHome, 
                      fuera: _stats!.playedAway,
                      icon: Icons.sports_soccer_rounded,
                    ),
                    _StatsTableRow(
                      label: 'Ganados', 
                      gen: _stats!.won, 
                      casa: _stats!.wonHome, 
                      fuera: _stats!.wonAway, 
                      color: AppBrandColors.green,
                      icon: Icons.check_circle_outline_rounded,
                    ),
                    _StatsTableRow(
                      label: 'Empatados', 
                      gen: _stats!.drawn, 
                      casa: _stats!.drawnHome, 
                      fuera: _stats!.drawnAway,
                      color: const Color(0xFFF59E0B),
                      icon: Icons.pause_circle_outline_rounded,
                    ),
                    _StatsTableRow(
                      label: 'Perdidos', 
                      gen: _stats!.lost, 
                      casa: _stats!.lostHome, 
                      fuera: _stats!.lostAway, 
                      color: Colors.redAccent,
                      icon: Icons.error_outline_rounded,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                      child: Divider(height: 1, color: AppBrandColors.gray600, thickness: 0.5),
                    ),
                    _StatsTableRow(
                      label: 'Goles Favor', 
                      gen: _stats!.gf, 
                      casa: _stats!.gfHome, 
                      fuera: _stats!.gfAway,
                      icon: Icons.add_circle_outline_rounded,
                    ),
                    _StatsTableRow(
                      label: 'Goles Contra', 
                      gen: _stats!.ga, 
                      casa: _stats!.gaHome, 
                      fuera: _stats!.gaAway,
                      icon: Icons.remove_circle_outline_rounded,
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),

            // 3. Last Results (Streak)
            _SectionBlock(
              title: 'Últimos resultados',
              icon: Icons.history_rounded,
              child: Column(
                children: [
                  if (pastMatches.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No hay resultados recientes',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppBrandColors.gray400,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    )
                  else
                    ...pastMatches.take(3).map((m) {
                      // Custom status for this section based on team result
                      String statusLabel = 'FINAL';
                      Color statusColor = AppBrandColors.green;

                      if (m.statusValue == 1) {
                        final isHome = m.home.name == widget.teamName;
                        final teamGoals = isHome ? m.homeGoals : m.awayGoals;
                        final opponentGoals = isHome ? m.awayGoals : m.homeGoals;

                        if (teamGoals > opponentGoals) {
                          statusLabel = 'GANA';
                          statusColor = AppBrandColors.green;
                        } else if (teamGoals < opponentGoals) {
                          statusLabel = 'PIERDE';
                          statusColor = Colors.redAccent;
                        } else {
                          statusLabel = 'EMPATE';
                          statusColor = Colors.orange;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10, left: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 3,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: AppBrandColors.green,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'JORNADA ${m.matchday}',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppBrandColors.white,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                          fontSize: 11,
                                        ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: AppBrandColors.white.withValues(alpha: 0.08),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _TeamMatchItem(
                              match: m,
                              statusLabel: statusLabel,
                              statusColor: statusColor,
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 4),
                  Material(
                    color: AppBrandColors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CalendarPage(
                              competitionId: widget.competitionId,
                              title: widget.competitionTitle,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppBrandColors.green.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_month, 
                                size: 18, color: AppBrandColors.green),
                            const SizedBox(width: 10),
                            Text(
                              'VER TODOS LOS PARTIDOS',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppBrandColors.green,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),


            const SizedBox(height: 16),

            // 4. Standings Section
            _SectionBlock(
              title: 'Clasificación',
              icon: Icons.leaderboard_rounded,
              child: StandingsView(
                standings: _competitionDetail.standings,
                competitionId: widget.competitionId,
                competitionTitle: widget.competitionTitle,
                highlightedTeam: widget.teamName,
              ),
            ),

            const SizedBox(height: 16),

            // 5. Coaches Section
            if (_coaches.isNotEmpty)
              _SectionBlock(
                title: 'Técnicos',
                icon: Icons.assignment_ind_rounded,
                child: Column(
                  children: _coaches.asMap().entries.map((entry) {
                    final index = entry.key;
                    final coach = entry.value;
                    return Column(
                      children: [
                        _PersonListTile(
                          name: coach.name,
                          subtitle: coach.role,
                          image: coach.image,
                          icon: Icons.person,
                        ),
                        if (index < _coaches.length - 1)
                          Divider(height: 1, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
                      ],
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 16),

            // 6. Players Section
            if (_players.isNotEmpty)
              _SectionBlock(
                title: 'Plantilla',
                icon: Icons.groups_rounded,
                child: Column(
                  children: _players.asMap().entries.map((entry) {
                    final index = entry.key;
                    final player = entry.value;
                    return Column(
                      children: [
                        _PersonListTile(
                          name: player.name,
                          subtitle: player.position ?? 'Jugador',
                          trailingText: player.number != null ? '#${player.number}' : null,
                          image: player.image,
                          icon: Icons.directions_run,
                        ),
                        if (index < _players.length - 1)
                          Divider(height: 1, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
                      ],
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 16),
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
    final cs = Theme.of(context).colorScheme;
    return LeagueCard(
      background: LeagueCardBackground.navy,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: AppBrandColors.green),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1, 
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 30),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _StatsTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        );
        
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3, 
            child: Text(
              'DATOS', 
              style: baseStyle?.copyWith(color: AppBrandColors.white.withValues(alpha: 0.9))
            )
          ),
          Expanded(
            child: Center(
              child: Text(
                'GEN', 
                style: baseStyle?.copyWith(color: AppBrandColors.white)
              )
            )
          ),
          Expanded(
            child: Center(
              child: Text(
                'CASA', 
                style: baseStyle?.copyWith(color: AppBrandColors.white.withValues(alpha: 0.6))
              )
            )
          ),
          Expanded(
            child: Center(
              child: Text(
                'FUERA', 
                style: baseStyle?.copyWith(color: AppBrandColors.white.withValues(alpha: 0.6))
              )
            )
          ),
        ],
      ),
    );
  }
}

class _StatsTableRow extends StatelessWidget {
  final String label;
  final int gen;
  final int casa;
  final int fuera;
  final Color? color;
  final IconData? icon;

  const _StatsTableRow({
    required this.label,
    required this.gen,
    required this.casa,
    required this.fuera,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: color ?? AppBrandColors.white.withValues(alpha: 0.9),
          fontWeight: color != null ? FontWeight.bold : FontWeight.w600,
        );
    final valueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: color ?? AppBrandColors.white,
          fontWeight: FontWeight.bold,
        );
    final normalValueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppBrandColors.white.withValues(alpha: 0.6),
          fontWeight: FontWeight.w500,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3, 
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: (color ?? AppBrandColors.gray400).withValues(alpha: 0.6)),
                  const SizedBox(width: 8),
                ],
                Text(label, style: labelStyle),
              ],
            ),
          ),
          Expanded(
            child: Center(child: Text('$gen', style: valueStyle)),
          ),
          Expanded(child: Center(child: Text('$casa', style: normalValueStyle))),
          Expanded(child: Center(child: Text('$fuera', style: normalValueStyle))),
        ],
      ),
    );
  }
}

class StandingsView extends StatefulWidget {
  final List<StandingRow> standings;
  final String competitionId;
  final String? competitionTitle;
  final String? highlightedTeam;

  const StandingsView({
    super.key,
    required this.standings,
    required this.competitionId,
    this.competitionTitle,
    this.highlightedTeam,
  });

  @override
  State<StandingsView> createState() => _StandingsViewState();
}

class _StandingsViewState extends State<StandingsView> {
  bool _expandTeamNames = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const double rowHeight = 44.0;
    const double headerHeight = 32.0;

    Widget buildCell(String text, double width, {bool bold = false, bool isHighlighted = false}) {
      return Container(
        width: width,
        height: rowHeight,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isHighlighted 
                    ? AppBrandColors.green 
                    : (bold ? cs.onSurface : cs.onSurfaceVariant),
                fontWeight: (bold || isHighlighted) ? FontWeight.bold : FontWeight.normal)),
      );
    }

    Widget buildHeader(String text, double width, {bool alignRight = true}) {
      return Container(
        width: width,
        height: headerHeight,
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final targetLeftWidth = totalWidth * (_expandTeamNames ? 0.85 : 0.55);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              width: targetLeftWidth,
              child: Stack(
                children: [
                  Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _expandTeamNames = !_expandTeamNames),
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            height: headerHeight,
                            child: Row(
                              children: [
                                const SizedBox(width: 4), // Space for indicator
                                SizedBox(
                                    width: 32,
                                    child: Center(
                                        child: Text('POS',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.bold)))),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Row(
                                      children: [
                                        Text('EQUIPO',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 4),
                                        Icon(
                                          _expandTeamNames ? Icons.compress_rounded : Icons.expand_rounded, 
                                          size: 14, 
                                          color: cs.onSurfaceVariant
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                        ),
                        ...widget.standings.asMap().entries.map((entry) {
                          final index = entry.key;
                          final r = entry.value;
                          final bool isHighlighted = widget.highlightedTeam == r.team;
                          final bool isEven = index % 2 == 0;
                          
                          final Color rowColor = isEven ? Colors.transparent : cs.surfaceContainerHighest.withValues(alpha: 0.3);

                          return Container(
                              height: rowHeight,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(
                                  color: rowColor,
                                  borderRadius: isEven
                                      ? null 
                                      : const BorderRadius.horizontal(left: Radius.circular(AppRadius.sm))),
                              child: Row(
                                children: [
                                  // Highlight indicator bar
                                  Container(
                                    width: 4,
                                    height: rowHeight * 0.6,
                                    decoration: BoxDecoration(
                                      color: isHighlighted ? AppBrandColors.green : Colors.transparent,
                                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(2)),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(() => _expandTeamNames = !_expandTeamNames),
                                    behavior: HitTestBehavior.opaque,
                                    child: SizedBox(
                                        width: 32,
                                        child: Center(
                                            child: Text('${r.position}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                        color: cs.onSurface,
                                                        fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal)))),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        if (isHighlighted) return;
                                        context.push(
                                          '${AppRoutes.teamDetail}?teamName=${Uri.encodeComponent(r.team)}&competitionId=${widget.competitionId}${widget.competitionTitle != null ? '&competitionTitle=${Uri.encodeComponent(widget.competitionTitle!)}' : ''}',
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(4),
                                      child: Row(
                                        children: [
                                          if (r.image != null) ...[
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: Image.asset(r.image!,
                                                  width: 20,
                                                  height: 20,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      const SizedBox.shrink()),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          Expanded(
                                              child: Text(r.team,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: isHighlighted ? AppBrandColors.green : cs.onSurface,
                                                        fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                                                      ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                        })
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    width: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.08),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: headerHeight),
                                                                    ...widget.standings.asMap().entries.map((entry) {
                                                                      final index = entry.key;
                                                                      final bool isEven = index % 2 == 0;                                                
                                                final Color rowColor = isEven
                                                    ? Colors.transparent
                                                    : cs.surfaceContainerHighest.withValues(alpha: 0.3);
                      
                                                return Container(
                                                  height: rowHeight,
                                                  margin: const EdgeInsets.symmetric(vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: rowColor,
                                                    borderRadius: isEven
                                                        ? null
                                                        : const BorderRadius.horizontal(
                                                            right: Radius.circular(AppRadius.sm)),
                                                  ),
                                                );
                                              }),                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            buildHeader('PTS', 40),
                            buildHeader('PJ', 36),
                            buildHeader('G', 36),
                            buildHeader('E', 36),
                            buildHeader('P', 36),
                            buildHeader('GF', 36),
                            buildHeader('GC', 36),
                            buildHeader('DG', 36),
                          ],
                        ),
                        ...widget.standings.asMap().entries.map((entry) {
                          final r = entry.value;
                          return Container(
                            height: rowHeight,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
        buildCell('${r.points}', 40, bold: true),                                                                            
     buildCell('${r.played}', 36),                                                                                        
   buildCell('${r.won}', 36),                                                                                          
        buildCell('${r.drawn}', 36),                                                                                         
    buildCell('${r.lost}', 36),                                                                                          
       buildCell('${r.gf}', 36),                                                                                            
        buildCell('${r.ga}', 36),                                                                                            
         buildCell('${r.gf - r.ga}', 36),   
                              ],
                            ),
                          );
                        })
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }
}

/// A specialized version of MatchItem for the Team Detail page
/// that allows overriding the status label and color.
class _TeamMatchItem extends StatelessWidget {
  final MatchResult match;
  final String statusLabel;
  final Color statusColor;

  const _TeamMatchItem({
    required this.match,
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final date = formatEs(match.dateTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppBrandColors.gray700.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(capitalize(date),
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Text(statusLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: statusColor, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right),
            ],
          ),
          const SizedBox(height: 14),
                    Row(
          
                      children: [
          
                        InkWell(
          
                          onTap: () {
          
                            if (match.home.name == (context.findAncestorWidgetOfExactType<TeamDetailPage>()?.teamName)) return;
          
                            context.push(
          
                              '${AppRoutes.teamDetail}?teamName=${Uri.encodeComponent(match.home.name)}&competitionId=${(context.findAncestorStateOfType<_TeamDetailPageState>()?.widget.competitionId) ?? ''}',
          
                            );
          
                          },
          
                          borderRadius: BorderRadius.circular(4),
          
                          child: Row(
          
                            mainAxisSize: MainAxisSize.min,
          
                            children: [
          
                              TeamAvatar(label: match.home.short, image: match.home.image),
          
                              const SizedBox(width: 10),
          
                            ],
          
                          ),
          
                        ),
          
                        Expanded(
          
                          child: InkWell(
          
                            onTap: () {
          
                              if (match.home.name == (context.findAncestorWidgetOfExactType<TeamDetailPage>()?.teamName)) return;
          
                              context.push(
          
                                '${AppRoutes.teamDetail}?teamName=${Uri.encodeComponent(match.home.name)}&competitionId=${(context.findAncestorStateOfType<_TeamDetailPageState>()?.widget.competitionId) ?? ''}',
          
                              );
          
                            },
          
                            borderRadius: BorderRadius.circular(4),
          
                            child: Text(match.home.name,
          
                                style: Theme.of(context)
          
                                    .textTheme
          
                                    .bodyMedium
          
                                    ?.copyWith(
          
                                      color: cs.onSurface,
          
                                      fontWeight: match.home.name == (context.findAncestorWidgetOfExactType<TeamDetailPage>()?.teamName) ? FontWeight.bold : FontWeight.w600,
          
                                    ),
          
                                maxLines: 2,
          
                                overflow: TextOverflow.ellipsis),
          
                          ),
          
                        ),
          
                        const SizedBox(width: 12),
          
                        ScorePill(text: '${match.homeGoals}'),
          
                      ],
          
                    ),
          
                    const SizedBox(height: 10),
          
                    Row(
          
                      children: [
          
                        InkWell(
          
                          onTap: () {
          
                            if (match.away.name == (context.findAncestorWidgetOfExactType<TeamDetailPage>()?.teamName)) return;
          
                            context.push(
          
                              '${AppRoutes.teamDetail}?teamName=${Uri.encodeComponent(match.away.name)}&competitionId=${(context.findAncestorStateOfType<_TeamDetailPageState>()?.widget.competitionId) ?? ''}',
          
                            );
          
                          },
          
                          borderRadius: BorderRadius.circular(4),
          
                          child: Row(
          
                            mainAxisSize: MainAxisSize.min,
          
                            children: [
          
                              TeamAvatar(label: match.away.short, accent: false, image: match.away.image),
          
                              const SizedBox(width: 10),
          
                            ],
          
                          ),
          
                        ),
          
                        Expanded(
          
                          child: InkWell(
          
                            onTap: () {
          
                              if (match.away.name == (context.findAncestorWidgetOfExactType<TeamDetailPage>()?.teamName)) return;
          
                              context.push(
          
                                '${AppRoutes.teamDetail}?teamName=${Uri.encodeComponent(match.away.name)}&competitionId=${(context.findAncestorStateOfType<_TeamDetailPageState>()?.widget.competitionId) ?? ''}',
          
                              );
          
                            },
          
                            borderRadius: BorderRadius.circular(4),
          
                            child: Text(match.away.name,
          
                                style: Theme.of(context)
          
                                    .textTheme
          
                                    .bodyMedium
          
                                    ?.copyWith(
          
                                      color: cs.onSurface,
          
                                      fontWeight: match.away.name == (context.findAncestorWidgetOfExactType<TeamDetailPage>()?.teamName) ? FontWeight.bold : FontWeight.w600,
          
                                    ),
          
                                maxLines: 2,
          
                                overflow: TextOverflow.ellipsis),
          
                          ),
          
                        ),
          
                        const SizedBox(width: 12),
          
                        ScorePill(text: '${match.awayGoals}'),
          
                      ],
          
                    ),
        ],
      ),
    );
  }
}

class _PersonListTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? trailingText;
  final String? image;
  final IconData icon;

  const _PersonListTile({
    required this.name,
    required this.subtitle,
    this.trailingText,
    this.image,
    required this.icon,
  });

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return '?';
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppBrandColors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppBrandColors.green.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: image != null
                  ? Image.asset(image!, fit: BoxFit.cover)
                  : Center(
                      child: Text(
                        _getInitials(name),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppBrandColors.green,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              fontSize: 15,
                            ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppBrandColors.gray400,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          if (trailingText != null)
            _JerseyNumber(number: trailingText!.replaceAll('#', '')),
        ],
      ),
    );
  }
}

class _JerseyNumber extends StatelessWidget {
  final String number;
  const _JerseyNumber({required this.number});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Solid background shield
          Icon(
            Icons.shield,
            size: 38,
            color: AppBrandColors.green.withValues(alpha: 0.12),
          ),
          // Outlined shield for definition
          Icon(
            Icons.shield_outlined,
            size: 38,
            color: AppBrandColors.green.withValues(alpha: 0.35),
          ),
          Text(
            number,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppBrandColors.green,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
          ),
        ],
      ),
    );
  }
}

class _FootballFieldPainter extends CustomPainter {
  final Color color;
  _FootballFieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Outer border (with padding)
    final rect = Rect.fromLTWH(10, 10, size.width - 20, size.height - 20);
    canvas.drawRect(rect, paint);

    // Midline
    canvas.drawLine(
      Offset(size.width / 2, 10),
      Offset(size.width / 2, size.height - 10),
      paint,
    );

    // Center Circle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 40, paint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 2, paint..style = PaintingStyle.fill);
    paint.style = PaintingStyle.stroke; // Reset style

    // Penalty Areas (stylized as we only see sides)
    // Left side
    canvas.drawRect(
      Rect.fromLTWH(10, size.height / 2 - 50, 40, 100),
      paint,
    );
    // Right side
    canvas.drawRect(
      Rect.fromLTWH(size.width - 50, size.height / 2 - 50, 40, 100),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


