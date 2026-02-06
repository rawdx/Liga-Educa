import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/models/competition_models.dart';
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/pages/calendar_page.dart';
import 'package:liga_educa/services/competitions_service.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_app_bar.dart';
import 'package:liga_educa/widgets/league_card.dart';
import 'package:liga_educa/widgets/match_item.dart';
import 'package:liga_educa/widgets/sponsor_footer.dart';

class CompetitionDetailPage extends StatefulWidget {
  final String competitionId;
  final String? title;
  final String? subtitle;

  const CompetitionDetailPage(
      {super.key, required this.competitionId, this.title, this.subtitle});

  @override
  State<CompetitionDetailPage> createState() => _CompetitionDetailPageState();
}

class _CompetitionDetailPageState extends State<CompetitionDetailPage> {
  late CompetitionDetailData _data;
  late int _currentMatchday;
  // Simple loading state if needed, though service is synchronous for cached data
  // but getMatches is synchronous.

  @override
  void initState() {
    super.initState();
    _data = CompetitionsService.instance.getDetail(widget.competitionId,
        titleOverride: widget.title, subtitleOverride: widget.subtitle);
    _currentMatchday = _data.currentMatchday;
  }

  void _changeMatchday(int delta) {
    setState(() {
      _currentMatchday += delta;
      // Simple bound check simulation (e.g. 1 to 30)
      if (_currentMatchday < 1) _currentMatchday = 1;
      // In a real app we would know the max matchday
    });
  }

  @override
  Widget build(BuildContext context) {
    // Fetch matches dynamically for the selected matchday
    final matches = CompetitionsService.instance
        .getMatches(widget.competitionId, _currentMatchday);

    return Scaffold(
      appBar: LeagueAppBar(
        title: _data.title,
        subtitle: _data.subtitle.isNotEmpty ? _data.subtitle : null,
        showBack: true,
      ),
      endDrawer: const LeagueMenuDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          children: [
            LeagueCard(
              background: LeagueCardBackground.accent,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Icon(Icons.emoji_events,
                          color: AppBrandColors.white),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _CompetitionHeader(groupTitle: _data.groupTitle),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Interactive Matchday Block
            _DetailBlock(
              header: _MatchdaySelector(
                matchday: _currentMatchday,
                onPrevious: () => _changeMatchday(-1),
                onNext: () => _changeMatchday(1),
              ),
              content: matches.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No hay partidos registrados para esta jornada.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (int i = 0; i < matches.length; i++) ...[
                          if (i > 0) const SizedBox(height: 12),
                          MatchItem(match: matches[i]),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CalendarPage(
                                    competitionId: widget.competitionId,
                                    title: _data.title,
                                    subtitle: _data.subtitle,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.calendar_month, size: 18),
                            label: const Text('CALENDARIO',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppBrandColors.green,
                              side: const BorderSide(
                                  color: AppBrandColors.green, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            
            const SizedBox(height: 16),
            _DetailBlock(
              header: const _SectionTitle(
                  title: 'Clasificación', icon: Icons.leaderboard),
              content: StandingsView(standings: _data.standings),
            ),
            const SizedBox(height: 16),
            _DetailBlock(
              header: const _SectionTitle(title: 'Racha', icon: Icons.whatshot),
              content: StreakView(streak: _data.streak, standings: _data.standings),
            ),
            const SizedBox(height: AppSpacing.md),
            const SponsorFooter(),
          ],
        ),
      ),
    );
  }
}

class _CompetitionHeader extends StatelessWidget {
  final String groupTitle;
  const _CompetitionHeader({required this.groupTitle});

  @override
  Widget build(BuildContext context) {
    final parts = groupTitle
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    final String? a = parts.isNotEmpty ? parts[0] : null;
    final String? b = parts.length > 1 ? parts[1] : null;
    final extra = parts.length > 2 ? parts.sublist(2) : const <String>[];

    final showDash = extra.isNotEmpty;
    final topText = showDash
        ? <String>[
            if (a != null) a,
            if (b != null) b,
          ].join(' - ')
        : (a ?? '');

    final bottomText = showDash
        ? (extra.isNotEmpty ? extra.join(' \u00b7 ') : null)
        : (b?.trim().isNotEmpty ?? false)
            ? b
            : null;

    final topStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppBrandColors.white,
          fontWeight: FontWeight.w700,
          height: 1.1,
        );

    final bottomStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppBrandColors.white.withValues(alpha: 0.92),
          fontWeight: FontWeight.w500,
          height: 1.1,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          topText,
          style: topStyle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (bottomText != null) ...[
          const SizedBox(height: 4),
          Text(
            bottomText,
            style: bottomStyle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _DetailBlock extends StatelessWidget {
  final Widget header;
  final Widget content;

  const _DetailBlock({required this.header, required this.content});

  @override
  Widget build(BuildContext context) {
    return LeagueCard(
      background: LeagueCardBackground.navy,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: header,
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 30),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  const _SectionTitle({required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: AppBrandColors.green),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _MatchdaySelector extends StatelessWidget {
  final int matchday;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MatchdaySelector({
    required this.matchday,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: onPrevious,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(Icons.chevron_left, color: cs.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 16),
        Text('Jornada $matchday',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w700)),
        const SizedBox(width: 16),
        InkWell(
          onTap: onNext,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class StandingsView extends StatefulWidget {
  final List<StandingRow> standings;
  const StandingsView({super.key, required this.standings});

  @override
  State<StandingsView> createState() => _StandingsViewState();
}

class _StandingsViewState extends State<StandingsView> {
  bool _expandTeamNames = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const double rowHeight = 44.0; // Standard height
    const double headerHeight = 32.0;

    // Helper to build a cell
    Widget buildCell(String text, double width, {bool bold = false, bool alignRight = true}) {
      return Container(
        width: width,
        height: rowHeight,
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: bold ? cs.onSurface : cs.onSurfaceVariant,
                fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
      );
    }

    // Helper for header cell
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
        // Expanded: 85% / 15%, Collapsed: 55% / 45%
        final targetLeftWidth = totalWidth * (_expandTeamNames ? 0.85 : 0.55);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ANIMATED LEFT SIDE (Pos + Team)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              width: targetLeftWidth,
              child: GestureDetector(
                onTap: () => setState(() => _expandTeamNames = !_expandTeamNames),
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  children: [
                    // Content
                    Container(
                      color: Theme.of(context).colorScheme.surface, // Opaque background
                      child: Column(
                        children: [
                          // Header
                          SizedBox(
                            height: headerHeight,
                            child: Row(
                              children: [
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
                                        // Visual cue
                                        Icon(
                                          _expandTeamNames ? Icons.compress : Icons.expand, 
                                          size: 14, 
                                          color: cs.onSurfaceVariant
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          // Data
                          ...widget.standings.asMap().entries.map((entry) {
                            final index = entry.key;
                            final r = entry.value;
                            final bool isEven = index % 2 == 0;
                            final rowColor = isEven ? Colors.transparent : cs.surfaceContainerHighest.withValues(alpha: 0.3);

                            return Container(
                                height: rowHeight,
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                decoration: BoxDecoration(
                                    color: rowColor,
                                    // Only round the left side to merge with the scroll area
                                    borderRadius: isEven 
                                        ? null 
                                        : const BorderRadius.horizontal(left: Radius.circular(AppRadius.sm))),
                                child: Row(
                                  children: [
                                    SizedBox(
                                        width: 32,
                                        child: Center(
                                            child: Text('${r.position}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                        color: cs.onSurface,
                                                        fontWeight: FontWeight.bold)))),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          final competitionId = (context.findAncestorStateOfType<_CompetitionDetailPageState>()?.widget.competitionId) ?? 'minis-grupo-1';
                                          final competitionTitle = (context.findAncestorStateOfType<_CompetitionDetailPageState>()?.widget.title);
                                          context.push(
                                            '${AppRoutes.teamDetail}?teamName=${Uri.encodeComponent(r.team)}&competitionId=$competitionId${competitionTitle != null ? '&competitionTitle=${Uri.encodeComponent(competitionTitle)}' : ''}',
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
                                                        ?.copyWith(color: cs.onSurface),
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
                    
                    // Shadow Overlay (Right Edge)
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 0,
                      width: 6, // Width of the shadow gradient
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.08), // Very subtle shadow
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // RIGHT SIDE (Stats) - Fills remaining space
            Expanded(
              child: Stack(
                children: [
                  // Background Layer (Fixed to viewport)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: headerHeight), // Spacer for header
                      ...widget.standings.asMap().entries.map((entry) {
                        final index = entry.key;
                        final bool isEven = index % 2 == 0;
                        final rowColor = isEven
                            ? Colors.transparent
                            : cs.surfaceContainerHighest.withValues(alpha: 0.3);

                        return Container(
                          height: rowHeight,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: rowColor,
                            // Round the right side to match the viewport edge
                            borderRadius: isEven
                                ? null
                                : const BorderRadius.horizontal(
                                    right: Radius.circular(AppRadius.sm)),
                          ),
                        );
                      }),
                    ],
                  ),
                  // Content Layer (Scrollable)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            buildHeader('PTS', 40),
                            buildHeader('PJ', 36),
                            buildHeader('G', 36),
                            buildHeader('E', 36),
                            buildHeader('P', 36),
                            buildHeader('GF', 36),
                            buildHeader('GC', 36),
                            buildHeader('DG', 36), // Goal Difference
                          ],
                        ),
                        // Data
                        ...widget.standings.asMap().entries.map((entry) {
                          final r = entry.value;
                          return Container(
                            height: rowHeight,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            // No decoration here, background is handled by the layer below
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

class StreakView extends StatelessWidget {
  final Map<String, List<String>> streak;
  final List<StandingRow>? standings;
  const StreakView({super.key, required this.streak, this.standings});

  String? _getTeamImage(String teamName) {
    if (standings == null) return null;
    for (final s in standings!) {
      if (s.team == teamName) return s.image;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const double rowHeight = 44.0;
    const double headerHeight = 32.0;

    if (streak.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No hay datos de racha disponibles.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final entries = streak.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table-like header to match Standings
        SizedBox(
          height: headerHeight,
          child: Row(
            children: [
              const SizedBox(width: 4),
              Text(
                'EQUIPO',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  'RACHA',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
        
        // Team streaks with alternating backgrounds
        ...entries.asMap().entries.map((entry) {
          final e = entry.value;
          final teamImage = _getTeamImage(e.key);
          return InkWell(
            onTap: () {
              final competitionId = (context.findAncestorStateOfType<_CompetitionDetailPageState>()?.widget.competitionId) ?? 'minis-grupo-1';
              final competitionTitle = (context.findAncestorStateOfType<_CompetitionDetailPageState>()?.widget.title);
              context.push(
                '${AppRoutes.teamDetail}?teamName=${Uri.encodeComponent(e.key)}&competitionId=$competitionId${competitionTitle != null ? '&competitionTitle=${Uri.encodeComponent(competitionTitle)}' : ''}',
              );
            },
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Container(
              height: rowHeight,
              margin: const EdgeInsets.symmetric(vertical: 1),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
              _TeamBadge(teamName: e.key, image: teamImage, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  e.key,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: e.value.isEmpty
                    ? [
                        Text(
                          '—',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                        ),
                      ]
                    : e.value
                        .take(5)
                        .map((x) => Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: _StreakDot(value: x)))
                        .toList(growable: false),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      );
    }),
    const SizedBox(height: 20),
    Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: const [
              _StreakLegendItem(code: 'G', label: 'Ganado'),
              _StreakLegendItem(code: 'E', label: 'Empate'),
              _StreakLegendItem(code: 'P', label: 'Perdido'),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: const [
              _StreakLegendItem(code: 'D', label: 'Descansa'),
              _StreakLegendItem(code: 'S', label: 'Suspendido'),
              _StreakLegendItem(code: 'A', label: 'Aplazado'),
            ],
          ),
        ],
      ),
    ),
  ],
);
}
}

class _TeamBadge extends StatelessWidget {
  final String teamName;
  final String? image;
  final double size;
  const _TeamBadge({required this.teamName, this.image, this.size = 30});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (image != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.asset(
            image!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallback(context, cs),
          ),
        ),
      );
    }
    return _buildFallback(context, cs);
  }

  Widget _buildFallback(BuildContext context, ColorScheme cs) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      alignment: Alignment.center,
      child: Text(
        teamName.isNotEmpty ? teamName[0].toUpperCase() : '?',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}

class _StreakLegendItem extends StatelessWidget {
  final String code;
  final String label;
  const _StreakLegendItem({required this.code, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    String dotCode = code;
    if (code == 'G') dotCode = 'W';
    if (code == 'E') dotCode = 'D';
    if (code == 'P') dotCode = 'L';
    if (code == 'D') dotCode = 'R';
    // 'A' maps directly to 'A' in _StreakDot for Aplazado

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StreakDot(value: dotCode, small: true),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _StreakDot extends StatelessWidget {
  final String value;
  final bool small;
  const _StreakDot({required this.value, this.small = false});

  @override
  Widget build(BuildContext context) {
    // Balanced color palette with glass style
    final (String label, Color color) = switch (value) {
      'W' => ('G', const Color.fromARGB(255, 7, 226, 87)), // G for Ganado (Green)
      'D' => ('E', const Color(0xFFF59E0B)), // E for Empate (Amber)
      'L' => ('P', const Color.fromARGB(255, 242, 63, 63)), // P for Perdido (Red)
      'R' => ('D', const Color.fromARGB(255, 193, 193, 193)), // D for Descansa (Grey)
      'S' => ('S', const Color(0xFF334155)), // S for Suspendido (Dark)
      'A' => ('A', Colors.indigoAccent), // A for Aplazado (Indigo)
      _ => ('-', const Color(0xFF64748B)),
    };

    final double size = small ? 18 : 26;
    final double fontSize = small ? 9 : 11;
    final bool isSuspended = value == 'S';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isSuspended ? 0.35 : 0.2),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: isSuspended 
            ? Colors.white.withValues(alpha: 0.35) 
            : color.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isSuspended && Theme.of(context).brightness == Brightness.dark 
            ? Colors.white.withValues(alpha: 0.8) 
            : color,
          fontWeight: FontWeight.w900,
          fontSize: fontSize,
          height: 1,
        ),
      ),
    );
  }
}
