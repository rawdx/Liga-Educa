import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/models/competition_models.dart';
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/team_logo.dart';

/// Widget reutilizable para mostrar la tabla de clasificación.
/// Soporta highlight de equipo y navegación a detalle de equipo.
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

    // Helper to calculate required width based on content
    double calculateWidth(Iterable<String> values, String header) {
      int maxChars = header.length;
      for (final v in values) {
        if (v.length > maxChars) maxChars = v.length;
      }
      
      if (maxChars <= 2) return 36.0;
      if (maxChars == 3) return 42.0;
      return 48.0; // For 4+ chars like "-105"
    }

    // Dynamic widths for each column
    final double ptsW = calculateWidth(widget.standings.map((r) => '${r.points}'), 'PTS');
    final double pjW = calculateWidth(widget.standings.map((r) => '${r.played}'), 'PJ');
    final double wonW = calculateWidth(widget.standings.map((r) => '${r.won}'), 'G');
    final double drawnW = calculateWidth(widget.standings.map((r) => '${r.drawn}'), 'E');
    final double lostW = calculateWidth(widget.standings.map((r) => '${r.lost}'), 'P');
    final double gfW = calculateWidth(widget.standings.map((r) => '${r.gf}'), 'GF');
    final double gaW = calculateWidth(widget.standings.map((r) => '${r.ga}'), 'GC');
    final double dgW = calculateWidth(widget.standings.map((r) => '${r.gf - r.ga}'), 'DG');

    Widget buildCell(String text, double width,
        {bool bold = false, bool isHighlighted = false}) {
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
                fontWeight:
                    (bold || isHighlighted) ? FontWeight.bold : FontWeight.normal)),
      );
    }

    Widget buildHeader(String text, double width, {bool alignRight = true}) {
      return Container(
        width: width,
        height: headerHeight,
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                fontWeight: FontWeight.bold)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final targetLeftWidth = totalWidth * (_expandTeamNames ? 0.85 : 0.55);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT SIDE (Pos + Team)
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
                        // Header
                        GestureDetector(
                          onTap: () =>
                              setState(() => _expandTeamNames = !_expandTeamNames),
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            height: headerHeight,
                            child: Row(
                              children: [
                                if (widget.highlightedTeam != null)
                                  const SizedBox(width: 4),
                                SizedBox(
                                    width: 32,
                                    child: Center(
                                        child: Text('POS',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                    color: cs.onSurfaceVariant,
                                                    fontWeight: FontWeight.bold)))),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Row(
                                  children: [
                                    Text('EQUIPO',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                                color: cs.onSurfaceVariant,
                                                fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 4),
                                    Icon(
                                        _expandTeamNames
                                            ? Icons.compress_rounded
                                            : Icons.expand_rounded,
                                        size: 14,
                                        color: cs.onSurfaceVariant),
                                  ],
                                )),
                              ],
                            ),
                          ),
                        ),
                        // Data rows
                        ...widget.standings.asMap().entries.map((entry) {
                          final index = entry.key;
                          final r = entry.value;
                          final bool isHighlighted =
                              widget.highlightedTeam == r.team;
                          final bool isEven = index % 2 == 0;
                          final rowColor = isEven
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
                                        left: Radius.circular(AppRadius.sm))),
                            child: Row(
                              children: [
                                // Highlight indicator
                                if (widget.highlightedTeam != null)
                                  Container(
                                    width: 4,
                                    height: rowHeight * 0.6,
                                    decoration: BoxDecoration(
                                      color: isHighlighted
                                          ? AppBrandColors.green
                                          : Colors.transparent,
                                      borderRadius: const BorderRadius.horizontal(
                                          right: Radius.circular(2)),
                                    ),
                                  ),
                                GestureDetector(
                                  onTap: () => setState(
                                      () => _expandTeamNames = !_expandTeamNames),
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
                                                      fontWeight: isHighlighted
                                                          ? FontWeight.bold
                                                          : FontWeight.normal)))),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: InkWell(
                                    onTap: isHighlighted
                                        ? null
                                        : () {
                                            context.push(
                                              '${AppRoutes.teamDetail}?teamName=${Uri.encodeComponent(r.team)}&competitionId=${widget.competitionId}${widget.competitionTitle != null ? '&competitionTitle=${Uri.encodeComponent(widget.competitionTitle!)}' : ''}',
                                            );
                                          },
                                    borderRadius: BorderRadius.circular(4),
                                    child: Row(
                                      children: [
                                        TeamLogo(
                                          image: r.image,
                                          size: 24,
                                          padding: 2,
                                          borderRadius: 4,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                            child: Text(r.team,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: isHighlighted
                                                          ? AppBrandColors.green
                                                          : cs.onSurface,
                                                      fontWeight: isHighlighted
                                                          ? FontWeight.bold
                                                          : FontWeight.w600,
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
                  // Shadow overlay
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
            // RIGHT SIDE (Stats)
            Expanded(
              child: Stack(
                children: [
                  // Background layer
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: headerHeight),
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
                            borderRadius: isEven
                                ? null
                                : const BorderRadius.horizontal(
                                    right: Radius.circular(AppRadius.sm)),
                          ),
                        );
                      }),
                    ],
                  ),
                  // Scrollable content
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            buildHeader('PTS', ptsW),
                            buildHeader('PJ', pjW),
                            buildHeader('G', wonW),
                            buildHeader('E', drawnW),
                            buildHeader('P', lostW),
                            buildHeader('GF', gfW),
                            buildHeader('GC', gaW),
                            buildHeader('DG', dgW),
                          ],
                        ),
                        ...widget.standings.asMap().entries.map((entry) {
                          final r = entry.value;
                          final isHighlighted = widget.highlightedTeam == r.team;
                          return Container(
                            height: rowHeight,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                buildCell('${r.points}', ptsW,
                                    bold: true, isHighlighted: isHighlighted),
                                buildCell('${r.played}', pjW,
                                    isHighlighted: isHighlighted),
                                buildCell('${r.won}', wonW,
                                    isHighlighted: isHighlighted),
                                buildCell('${r.drawn}', drawnW,
                                    isHighlighted: isHighlighted),
                                buildCell('${r.lost}', lostW,
                                    isHighlighted: isHighlighted),
                                buildCell('${r.gf}', gfW,
                                    isHighlighted: isHighlighted),
                                buildCell('${r.ga}', gaW,
                                    isHighlighted: isHighlighted),
                                buildCell('${r.gf - r.ga}', dgW,
                                    isHighlighted: isHighlighted),
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
      },
    );
  }
}
