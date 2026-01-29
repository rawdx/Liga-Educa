import 'package:flutter/material.dart';
import 'package:liga_educa/models/competition_models.dart';
import 'package:liga_educa/services/competitions_service.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_app_bar.dart';
import 'package:liga_educa/widgets/league_card.dart';
import 'package:url_launcher/url_launcher.dart';

class CompetitionDetailPage extends StatelessWidget {
  final String competitionId;
  final String? title;
  final String? subtitle;

  const CompetitionDetailPage(
      {super.key, required this.competitionId, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final data = CompetitionsService.instance.getDetail(competitionId,
        titleOverride: title, subtitleOverride: subtitle);
    return Scaffold(
      appBar: LeagueAppBar(
        title: data.title,
        subtitle: data.subtitle.isNotEmpty ? data.subtitle : null,
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
                      child: _CompetitionHeader(groupTitle: data.groupTitle),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _DetailBlock(
              header: _MatchdaySelector(matchday: data.currentMatchday),
              content: Column(
                children: [
                  for (int i = 0; i < data.results.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    MatchItem(match: data.results[i]),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 16),
            _DetailBlock(
              header: const _SectionTitle(title: 'Clasificación'),
              content: StandingsView(standings: data.standings),
            ),
            const SizedBox(height: 16),
            _DetailBlock(
              header: _MatchdaySelector(matchday: data.currentMatchday + 1),
              content: Column(
                children: [
                  for (int i = 0; i < data.nextMatchday.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    MatchItem(match: data.nextMatchday[i], showScore: false),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 16),
            _DetailBlock(
              header: const _SectionTitle(title: 'Racha'),
              content: StreakView(streak: data.streak),
            ),
            const SizedBox(height: AppSpacing.md),
            LeagueCard(
              padding: const EdgeInsets.all(AppSpacing.sm),
              backgroundColorOverride: AppBrandColors.navy900,
              child: InkWell(
                onTap: () {
                  launchUrl(Uri.parse('https://www.soccerfactory.es/'));
                },
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Image.asset(
                    'assets/images/sponsor.gif',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
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
    // The "Block" wrapper is Navy 800
    // The content is a slightly different shade to simulate "lighter" or "inset"
    return LeagueCard(
      background: LeagueCardBackground.navy,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: header,
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 30), // approx 0.12 * 255
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            child: content,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: cs.onSurface,
                ),
          ),
        ),
      ],
    );
  }
}

class _MatchdaySelector extends StatelessWidget {
  final int matchday;
  const _MatchdaySelector({required this.matchday});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(Icons.chevron_left, color: cs.onSurfaceVariant),
        Text('Jornada $matchday',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: cs.onSurface)),
        Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
      ],
    );
  }
}

class MatchItem extends StatelessWidget {
  final MatchResult match;
  final bool showScore;
  const MatchItem({super.key, required this.match, this.showScore = true});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final date = _formatEs(match.dateTime);
    // Removed LeagueCard wrapper, now just a Column inside a Container
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppBrandColors.gray700.withValues(alpha: 0.65), // Using #374151 with high opacity
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_capitalize(date),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 10),
          Row(
            children: [
              _TeamAvatar(label: match.home.short, image: match.home.image),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(match.home.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: cs.onSurface))),
              if (showScore) _ScorePill(text: '${match.homeGoals}'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _TeamAvatar(label: match.away.short, accent: false, image: match.away.image),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(match.away.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: cs.onSurface))),
              if (showScore) _ScorePill(text: '${match.awayGoals}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: Text('Estadio',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: cs.onSurfaceVariant))),
              Expanded(
                  child: Text('Árbitro',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                      textAlign: TextAlign.center)),
              Expanded(
                  child: Text(match.status,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: match.status == 'FINAL'
                              ? AppBrandColors.green
                              : cs.onSurfaceVariant),
                      textAlign: TextAlign.right)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamAvatar extends StatelessWidget {
  final String label;
  final bool accent;
  final String? image;
  const _TeamAvatar({required this.label, this.accent = true, this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: accent
            ? AppBrandColors.greenDark.withValues(alpha: 0.35)
            : AppBrandColors.gray700.withValues(alpha: 0.55),
        border:
            Border.all(color: AppBrandColors.gray600.withValues(alpha: 0.55)),
      ),
      alignment: Alignment.center,
      child: (image != null && image!.isNotEmpty)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.asset(image!,
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover, errorBuilder: (c, e, s) {
                return Text(label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface));
              }))
          : Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String text;
  const _ScorePill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppBrandColors.navy800,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppBrandColors.gray600.withValues(alpha: 0.6)),
      ),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
    );
  }
}

class StandingsView extends StatelessWidget {
  final List<StandingRow> standings;
  const StandingsView({super.key, required this.standings});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
                width: 36,
                child: Text('POS',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant))),
            Expanded(
                child: Text('EQUIPO',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant))),
            SizedBox(
                width: 46,
                child: Text('PJ',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.right)),
            SizedBox(
                width: 54,
                child: Text('PTS',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                        textAlign: TextAlign.right)),
          ],
        ),
        const SizedBox(height: 10),
        ...standings.map((r) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                    width: 36,
                    child: Text('${r.position}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: cs.onSurface))),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color:
                              AppBrandColors.gray700.withValues(alpha: 0.55),
                          border: Border.all(
                              color: AppBrandColors.gray600
                                  .withValues(alpha: 0.55)),
                        ),
                        child: (r.image != null && r.image!.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.asset(r.image!,
                                    width: 28,
                                    height: 28,
                                    fit: BoxFit.cover, errorBuilder: (c, e, s) {
                                  return const Icon(Icons.shield,
                                      size: 16, color: AppBrandColors.white);
                                }))
                            : const Icon(Icons.shield,
                                size: 16, color: AppBrandColors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(r.team,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: cs.onSurface),
                              overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
                SizedBox(
                    width: 46,
                    child: Text('${r.played}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: cs.onSurface),
                        textAlign: TextAlign.right)),
                SizedBox(
                    width: 54,
                    child: Text('${r.points}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: cs.onSurface),
                        textAlign: TextAlign.right)),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class StreakView extends StatelessWidget {
  final Map<String, List<String>> streak;
  const StreakView({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: streak.entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(
                  child: Text(e.key,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: cs.onSurface),
                      overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: e.value
                    .map((x) => Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: _StreakDot(value: x)))
                    .toList(growable: false),
              ),
            ],
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _StreakDot extends StatelessWidget {
  final String value;
  const _StreakDot({required this.value});

  @override
  Widget build(BuildContext context) {
    final Color c = switch (value) {
      'W' => AppBrandColors.green,
      'D' => AppBrandColors.gray400,
      'L' => const Color(0xFFEF4444),
      _ => AppBrandColors.gray600,
    };
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
          color: c.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: c.withValues(alpha: 0.75))),
      alignment: Alignment.center,
      child: Text(value,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
    );
  }
}

String _capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

String _formatEs(DateTime dt) {
  const weekdays = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo'
  ];
  const months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre'
  ];

  // Dart weekday: 1=Mon ... 7=Sun
  final wd = weekdays[(dt.weekday - 1).clamp(0, 6)];
  final mo = months[(dt.month - 1).clamp(0, 11)];
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$wd ${dt.day} de $mo \u00b7 $hh:$mm';
}