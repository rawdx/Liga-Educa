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
import 'package:liga_educa/widgets/standings_view.dart';
import 'package:liga_educa/widgets/streak_view.dart';

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
      if (_currentMatchday < 1) _currentMatchday = 1;
      if (_currentMatchday > _data.maxMatchday) {
        _currentMatchday = _data.maxMatchday;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final matches = CompetitionsService.instance
        .getMatches(widget.competitionId, _currentMatchday);

    return Scaffold(
      appBar: LeagueAppBar(
        title: 'Competiciones',
        subtitle: _data.title,
        showBack: true,
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.competitions);
          }
        },
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
                  const SizedBox(
                    width: 40,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.emoji_events_rounded,
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
                maxMatchday: _data.maxMatchday,
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
                          MatchItem(
                            match: matches[i],
                            competitionId: widget.competitionId,
                            competitionTitle: widget.title,
                          ),
                        ],
                        const SizedBox(height: 16),
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
                                    title: _data.title,
                                    subtitle: _data.subtitle,
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
                                  color:
                                      AppBrandColors.green.withValues(alpha: 0.4),
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
                                    'CALENDARIO COMPLETO',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
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
            _DetailBlock(
              header: const _SectionTitle(
                  title: 'Clasificación', icon: Icons.leaderboard_rounded),
              content: StandingsView(
                standings: _data.standings,
                competitionId: widget.competitionId,
                competitionTitle: widget.title,
              ),
            ),
            const SizedBox(height: 16),
            _DetailBlock(
              header: const _SectionTitle(title: 'Racha', icon: Icons.whatshot),
              content: StreakView(
                streak: _data.streak,
                standings: _data.standings,
                competitionId: widget.competitionId,
                competitionTitle: widget.title,
              ),
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
  final int maxMatchday;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MatchdaySelector({
    required this.matchday,
    required this.maxMatchday,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final showPrevious = matchday > 1;
    final showNext = matchday < maxMatchday;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 32,
          child: showPrevious
              ? InkWell(
                  onTap: onPrevious,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child:
                        Icon(Icons.chevron_left_rounded, color: cs.onSurfaceVariant),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text('Jornada $matchday',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        SizedBox(
          width: 32,
          child: showNext
              ? InkWell(
                  onTap: onNext,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.chevron_right_rounded,
                        color: cs.onSurfaceVariant),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}
