import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/models/competition_models.dart';
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class MatchItem extends StatelessWidget {
  final MatchResult match;
  final bool showScore;
  const MatchItem({super.key, required this.match, this.showScore = true});

  void _navigateToTeam(BuildContext context, String teamName) {
    // In a real app, we would have the competitionId available here
    // For now, we'll try to find it from the context or a parent widget
    // but since MatchItem is used in many places, we'll use a default if not provided.
    context.push(
      '${AppRoutes.teamDetail}?teamName=${Uri.encodeComponent(teamName)}&competitionId=minis-grupo-1',
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final date = formatEs(match.dateTime);

    // Logic for Status Label and Color
    final (String statusLabel, Color statusColor) = switch (match.statusValue) {
      1 => ('FINAL', AppBrandColors.green),
      2 => ('SUSP.', const Color(0xFFEF4444)), // Red
      3 => ('APLAZ.', const Color(0xFFF59E0B)), // Amber
      _ => (match.status.isNotEmpty ? match.status : '—:—', cs.onSurfaceVariant),
    };

    // Only show score if the match is finished (statusValue == 1)
    final actuallyShowScore = showScore && match.statusValue == 1;

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
                        ?.copyWith(color: cs.onSurfaceVariant),
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
          InkWell(
            onTap: () => _navigateToTeam(context, match.home.name),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                TeamAvatar(label: match.home.short, image: match.home.image),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(match.home.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: cs.onSurface),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis)),
                if (actuallyShowScore) ...[
                  const SizedBox(width: 12),
                  ScorePill(text: '${match.homeGoals}'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _navigateToTeam(context, match.away.name),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                TeamAvatar(label: match.away.short, accent: false, image: match.away.image),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(match.away.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: cs.onSurface),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis)),
                if (actuallyShowScore) ...[
                  const SizedBox(width: 12),
                  ScorePill(text: '${match.awayGoals}'),
                ],
              ],
            ),
          ),
          
          if (match.stadium != null || match.referee != null) ...[
            const SizedBox(height: 14),
            Divider(
                height: 1, color: AppBrandColors.gray600.withValues(alpha: 0.4)),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: match.stadium != null
                        ? () {
                            final query = Uri.encodeComponent(match.stadium!);
                            launchUrl(Uri.parse(
                                'https://www.google.com/maps/search/?api=1&query=$query'));
                          }
                        : null,
                    borderRadius: BorderRadius.circular(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(match.stadium ?? 'Por definir',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                      color: match.stadium != null
                                          ? AppBrandColors.green
                                          : cs.onSurfaceVariant)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(match.referee ?? 'Por designar',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: cs.onSurfaceVariant),
                            textAlign: TextAlign.right),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.sports, size: 16, color: cs.onSurfaceVariant),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class TeamAvatar extends StatelessWidget {
  final String label;
  final bool accent;
  final String? image;
  const TeamAvatar({super.key, required this.label, this.accent = true, this.image});

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

class ScorePill extends StatelessWidget {
  final String text;
  const ScorePill({super.key, required this.text});

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

String capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

String formatEs(DateTime dt) {
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
