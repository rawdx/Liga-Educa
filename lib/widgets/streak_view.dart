import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/models/competition_models.dart';
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/team_logo.dart';

/// Widget para mostrar la racha de resultados de los equipos.
class StreakView extends StatelessWidget {
  final Map<String, List<String>> streak;
  final List<StandingRow>? standings;
  final String competitionId;
  final String? competitionTitle;

  const StreakView({
    super.key,
    required this.streak,
    required this.competitionId,
    this.standings,
    this.competitionTitle,
  });

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
        // Header
        SizedBox(
          height: headerHeight,
          child: Row(
            children: [
              const SizedBox(width: 4),
              Text(
                'EQUIPO',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  'ÚLTIMOS PARTIDOS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
        // Team rows
        ...entries.asMap().entries.map((entry) {
          final e = entry.value;
          final teamImage = _getTeamImage(e.key);
          return InkWell(
            onTap: () {
              context.push(
                '${AppRoutes.teamDetail}?teamName=${Uri.encodeComponent(e.key)}&competitionId=$competitionId${competitionTitle != null ? '&competitionTitle=${Uri.encodeComponent(competitionTitle!)}' : ''}',
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
                  TeamLogo(image: teamImage, size: 24, padding: 2, borderRadius: 6),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.key,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
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
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                            ),
                          ]
                        : e.value
                            .take(5)
                            .map((x) => Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: StreakDot(value: x)))
                            .toList(growable: false),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
        // Legend
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
                  StreakLegendItem(code: 'G', label: 'Ganado'),
                  StreakLegendItem(code: 'E', label: 'Empate'),
                  StreakLegendItem(code: 'P', label: 'Perdido'),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 16,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: const [
                  StreakLegendItem(code: 'D', label: 'Descansa'),
                  StreakLegendItem(code: 'S', label: 'Suspendido'),
                  StreakLegendItem(code: 'A', label: 'Aplazado'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Item de leyenda para la racha.
class StreakLegendItem extends StatelessWidget {
  final String code;
  final String label;

  const StreakLegendItem({super.key, required this.code, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    String dotCode = code;
    if (code == 'G') dotCode = 'W';
    if (code == 'E') dotCode = 'D';
    if (code == 'P') dotCode = 'L';
    if (code == 'D') dotCode = 'R';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreakDot(value: dotCode, small: true),
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

/// Indicador visual de resultado (G/E/P/D/S/A).
class StreakDot extends StatelessWidget {
  final String value;
  final bool small;

  const StreakDot({super.key, required this.value, this.small = false});

  @override
  Widget build(BuildContext context) {
    final (String label, Color color) = switch (value) {
      'W' => ('G', const Color.fromARGB(255, 7, 226, 87)),
      'D' => ('E', const Color(0xFFF59E0B)),
      'L' => ('P', const Color.fromARGB(255, 242, 63, 63)),
      'R' => ('D', const Color.fromARGB(255, 193, 193, 193)),
      'S' => ('S', const Color(0xFF334155)),
      'A' => ('A', Colors.indigoAccent),
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
