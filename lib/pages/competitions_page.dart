import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/drawer_manager.dart'; // Added import
import 'package:liga_educa/models/competition_models.dart';
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/services/competitions_service.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_app_bar.dart';
import 'package:liga_educa/widgets/league_card.dart';
import 'package:liga_educa/widgets/sponsor_footer.dart';

class CompetitionsPage extends StatefulWidget {
  const CompetitionsPage({super.key});

  @override
  State<CompetitionsPage> createState() => _CompetitionsPageState();
}

class _CompetitionsPageState extends State<CompetitionsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(); // Added GlobalKey
  final _service = CompetitionsService.instance;

  final Map<String, bool> _expandedCategories = {
    'Minis': false,
    'Prebenjamines': false,
    'Benjamines': false,
    'Alevines': false,
    'Infantiles': false,
  };

  final Map<String, bool> _expandedSeasons = {};

  // Memoized grouped competitions data
  Map<String, List<CompetitionSummary>>? _groupedCompetitions;

  @override
  void initState() {
    super.initState();
    _initializeCompetitions();
    drawerManager.addListener(_closeDrawerListener); // Added listener
  }

  Future<void> _initializeCompetitions() async {
    await _service.loadAll();
    final all = _service.listCompetitions();
    _groupedCompetitions = <String, List<CompetitionSummary>>{};
    for (final c in all) {
      _groupedCompetitions!.putIfAbsent(c.category, () => []).add(c);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    drawerManager.removeListener(_closeDrawerListener); // Removed listener
    super.dispose();
  }

  void _closeDrawerListener() {
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeEndDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use memoized data instead of recalculating on every build
    final grouped =
        _groupedCompetitions ?? <String, List<CompetitionSummary>>{};

    return Scaffold(
      key: _scaffoldKey, // Assigned key
      appBar:
          const LeagueAppBar(title: 'Liga Educa', subtitle: 'Competiciones'),
      endDrawer: const LeagueMenuDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          children: [
            LeagueCard(
              background: LeagueCardBackground.accent,
              padding: const EdgeInsets.all(20),
              child: Stack(
                children: [
                  // Decorative background icon
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        Icons.emoji_events,
                        size: 100,
                        color: AppBrandColors.white.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  // Content
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppBrandColors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.calendar_month,
                            color: AppBrandColors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Temporada 2024/25',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        color: AppBrandColors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                            const SizedBox(height: 4),
                            Text(
                                '${grouped.length} Categorías \u00b7 Fase Regular',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: AppBrandColors.white
                                            .withValues(alpha: 0.9))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...grouped.keys.map((category) {
              final items = grouped[category] ?? const <CompetitionSummary>[];
              final groupedBySeason = <String, List<CompetitionSummary>>{};
              for (final c in items) {
                groupedBySeason.putIfAbsent(c.seasonLabel, () => []).add(c);
              }

              // Check if all items share the same generic seasonLabel (like "Temporada")
              // and should be shown directly without season accordion
              final shouldShowDirectly = groupedBySeason.length == 1 &&
                  (groupedBySeason.keys.first == 'Temporada' ||
                      groupedBySeason.keys.first.isEmpty);

              // Count all leaf competitions under this category (items that navigate to detail)
              final groupsCount = items.length;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CategoryAccordion(
                  category: category,
                  groupsCount: groupsCount,
                  onToggle: (v) =>
                      setState(() => _expandedCategories[category] = v),
                  expanded: _expandedCategories[category] ?? false,
                  children: shouldShowDirectly
                      ? items
                          .map((c) => Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: LeagueCard(
                                  onTap: () {
                                    final title =
                                        Uri.encodeComponent('Liga Educa');
                                    final subtitle = Uri.encodeComponent(
                                        '${c.category} - ${c.groupLabel}');
                                    context.push(
                                        '${AppRoutes.competition}/${c.id}?title=$title&subtitle=$subtitle');
                                  },
                                  padding: const EdgeInsets.all(16),                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(c.groupLabel,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface)),
                                      ),
                                      Icon(Icons.chevron_right,
                                          color: AppBrandColors.green),
                                    ],
                                  ),
                                ),
                              ))
                          .toList()
                      : groupedBySeason.keys.map((season) {
                          final seasonItems = groupedBySeason[season]!;
                          if (seasonItems.length == 1) {
                            final c = seasonItems.first;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: LeagueCard(
                                onTap: () {
                                  final title =
                                      Uri.encodeComponent('Liga Educa');
                                  final subtitle = Uri.encodeComponent(
                                      '${c.category} - ${c.seasonLabel}');
                                  context.push(
                                      '${AppRoutes.competition}/${c.id}?title=$title&subtitle=$subtitle');
                                },
                                padding: const EdgeInsets.all(16),                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(c.seasonLabel,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface)),
                                    ),
                                    Icon(Icons.chevron_right,
                                        color: AppBrandColors.green),
                                  ],
                                ),
                              ),
                            );
                          }
                          return _SeasonAccordion(
                            season: season,
                            expanded:
                                _expandedSeasons['$category-$season'] ?? false,
                            onToggle: (v) => setState(() =>
                                _expandedSeasons['$category-$season'] = v),
                            children: seasonItems
                                .map((c) => Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: LeagueCard(
                                        background: LeagueCardBackground.highlight,
                                        onTap: () {
                                          final title =
                                              Uri.encodeComponent('Liga Educa');
                                          final subtitle = Uri.encodeComponent(
                                              '${c.category} - ${c.seasonLabel}');
                                          context.push(
                                              '${AppRoutes.competition}/${c.id}?title=$title&subtitle=$subtitle');
                                        },
                                        padding: const EdgeInsets.all(16),                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(c.groupLabel,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface)),
                                            ),
                                            Icon(Icons.chevron_right,
                                                color: AppBrandColors.green),
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList(),
                          );
                        }).toList(),
                ),
              );
            }),
            const SizedBox(height: 20),
            const SponsorFooter(),
          ],
        ),
      ),
    );
  }
}

class _CategoryAccordion extends StatelessWidget {
  final String category;
  final int groupsCount;
  final bool expanded;
  final ValueChanged<bool> onToggle;
  final List<Widget> children;

  const _CategoryAccordion({
    required this.category,
    required this.groupsCount,
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LeagueCard(
      padding: EdgeInsets.zero,
      backgroundColorOverride: AppBrandColors.navy800,
      borderAlpha: 0.32,
      child: Column(
        children: [
          InkWell(
            onTap: () => onToggle(!expanded),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppBrandColors.greenDark,
                    child: Text(
                        category.characters.take(2).toString().toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: AppBrandColors.white)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: cs.onSurface)),
                        const SizedBox(height: 2),
                        Text(groupsCount > 0 ? '$groupsCount grupos' : '—',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    turns: expanded ? 0.5 : 0,
                    child: Icon(Icons.expand_more, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Column(children: children),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SeasonAccordion extends StatelessWidget {
  final String season;
  final bool expanded;
  final ValueChanged<bool> onToggle;
  final List<Widget> children;

  const _SeasonAccordion({
    required this.season,
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LeagueCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          InkWell(
            onTap: () => onToggle(!expanded),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(season,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: cs.onSurface)),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    turns: expanded ? 0.5 : 0,
                    child: Icon(Icons.expand_more, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Column(children: children),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
