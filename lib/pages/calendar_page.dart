import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/models/competition_models.dart';
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/services/competitions_service.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_app_bar.dart';
import 'package:liga_educa/widgets/league_card.dart';
import 'package:liga_educa/widgets/match_item.dart';
import 'package:liga_educa/widgets/sponsor_footer.dart';

class CalendarPage extends StatefulWidget {
  final String competitionId;
  final String? title;
  final String? subtitle;

  const CalendarPage({
    super.key,
    required this.competitionId,
    this.title,
    this.subtitle,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late CompetitionDetailData _data;
  final Set<String> _expandedMatchdays = {};

  @override
  void initState() {
    super.initState();
    _data = CompetitionsService.instance.getDetail(
      widget.competitionId,
      titleOverride: widget.title,
      subtitleOverride: widget.subtitle,
    );
  }

  void _toggleMatchday(String day) {
    setState(() {
      if (_expandedMatchdays.contains(day)) {
        _expandedMatchdays.remove(day);
      } else {
        _expandedMatchdays.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<MatchResult>> matchdays =
        CompetitionsService.instance.getAllMatchesGrouped(widget.competitionId);

    // Sort matchdays by number
    final sortedKeys = matchdays.keys.toList()
      ..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));

    final currentMatchdayStr = _data.currentMatchday.toString();

    return Scaffold(
      appBar: LeagueAppBar(
        title: widget.title ?? 'Calendario',
        subtitle: widget.subtitle,
        showBack: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          itemCount: sortedKeys.length + 2, // +1 for Headers, +1 for SponsorFooter
          itemBuilder: (context, index) {
            // Header: Competition Title & Calendario title
            if (index == 0) {
              return Column(
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
                            child: Icon(Icons.emoji_events,
                                color: AppBrandColors.white),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child:
                                _CompetitionHeader(groupTitle: _data.groupTitle),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  LeagueCard(
                    padding: EdgeInsets.zero,
                    backgroundColorOverride: AppBrandColors.navy800,
                    child: Stack(
                      children: [
                        // Decorative background icon
                        Positioned(
                          right: -15,
                          bottom: -15,
                          child: Icon(
                            Icons.calendar_month,
                            size: 80,
                            color: AppBrandColors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 20),
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  'Calendario',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: AppBrandColors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppBrandColors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Temporada 2024 - 2025',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: AppBrandColors.gray400,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }

            // Sponsor Footer
            if (index == sortedKeys.length + 1) {
              return const Padding(
                padding: EdgeInsets.only(top: AppSpacing.md),
                child: SponsorFooter(),
              );
            }

            // Matchday Card
            final day = sortedKeys[index - 1];
            final matches = matchdays[day]!;
            final isExpanded = _expandedMatchdays.contains(day);
            final isCurrent = day == currentMatchdayStr;

            // Determine matchday status
            final bool allFinished = matches.isNotEmpty && matches.every((m) => m.statusValue == 1);
            
            Widget statusBadge;
            if (allFinished) {
              statusBadge = _StatusBadge(
                text: 'FINALIZADA',
                color: AppBrandColors.green,
              );
            } else if (isCurrent) {
              statusBadge = _StatusBadge(
                text: 'PRÓXIMA',
                color: const Color(0xFFFFB300), // Amber/Yellow
              );
            } else {
              statusBadge = _StatusBadge(
                text: 'PENDIENTE',
                color: AppBrandColors.gray600,
              );
            }

            // Get date label for the subtitle
            String subtitleDate = '';
            if (matches.isNotEmpty) {
              final firstDate = matches.first.dateTime;
              subtitleDate = _formatShortDate(firstDate);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LeagueCard(
                padding: EdgeInsets.zero,
                backgroundColorOverride: AppBrandColors.navy800,
                borderAlpha: 0.32,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => _toggleMatchday(day),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Jornada $day',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  if (subtitleDate.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitleDate,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: AppBrandColors.gray400,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            statusBadge,
                            const SizedBox(width: 8),
                            AnimatedRotation(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              turns: isExpanded ? 0.5 : 0,
                              child: Icon(Icons.expand_more,
                                  color: AppBrandColors.gray400),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: isExpanded
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(
                                  height: 1,
                                  color: AppBrandColors.gray600.withValues(alpha: 60),
                                ),
                                // Match list grouping by date
                                _MatchListByDate(matches: matches),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatShortDate(DateTime dt) {
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${dt.day} de ${months[dt.month - 1]} de ${dt.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _MatchListByDate extends StatelessWidget {
  final List<MatchResult> matches;
  const _MatchListByDate({required this.matches});

  @override
  Widget build(BuildContext context) {
    // Group matches by date and time for the sub-headers
    final groups = <String, List<MatchResult>>{};
    for (var m in matches) {
      final dateKey = _formatDateTimeHeader(m.dateTime);
      groups.putIfAbsent(dateKey, () => []).add(m);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var entry in groups.entries) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppBrandColors.green,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppBrandColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            for (var i = 0; i < entry.value.length; i++) ...[
              _CalendarMatchItem(match: entry.value[i]),
              if (i < entry.value.length - 1) const SizedBox(height: 10),
            ],
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  String _formatDateTimeHeader(DateTime dt) {
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} \u00b7 $hh:$mm';
  }
}

class _CalendarMatchItem extends StatelessWidget {
  final MatchResult match;
  const _CalendarMatchItem({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppBrandColors.gray700.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppBrandColors.gray600.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _TeamRow(
            name: match.home.name,
            logo: match.home.image,
            score: match.statusValue == 1 ? match.homeGoals.toString() : null,
            shortName: match.home.short,
          ),
          const SizedBox(height: 10),
          _TeamRow(
            name: match.away.name,
            logo: match.away.image,
            score: match.statusValue == 1 ? match.awayGoals.toString() : null,
            shortName: match.away.short,
            isHome: false,
          ),
        ],
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  final String name;
  final String? logo;
  final String? score;
  final String shortName;
  final bool isHome;

  const _TeamRow({
    required this.name,
    this.logo,
    this.score,
    required this.shortName,
    this.isHome = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        final calendarState = context.findAncestorStateOfType<_CalendarPageState>();
        final competitionId = calendarState?.widget.competitionId ?? 'minis-grupo-1';
        final competitionTitle = calendarState?.widget.title;
        
        context.push(
          '${AppRoutes.teamDetail}?teamName=${Uri.encodeComponent(name)}&competitionId=$competitionId${competitionTitle != null ? '&competitionTitle=${Uri.encodeComponent(competitionTitle)}' : ''}',
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          TeamAvatar(label: shortName, image: logo, accent: isHome),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (score != null) ScorePill(text: score!),
        ],
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