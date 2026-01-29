import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/drawer_manager.dart'; // Added import
import 'package:liga_educa/models/competition_models.dart';
import 'package:liga_educa/models/phrase.dart';
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/services/competitions_service.dart';
import 'package:liga_educa/services/phrases_service.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_app_bar.dart';
import 'package:liga_educa/widgets/league_card.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(); // Added GlobalKey
  final _phrases = PhrasesService.instance;
  final _competitions = CompetitionsService.instance;
  Phrase? _phrase;
  bool _loadingPhrase = true;

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
  List<CompetitionSummary>? _allCompetitions;

  @override
  void initState() {
    super.initState();
    _loadPhrase();
    _initializeCompetitions();
    drawerManager.addListener(_closeDrawerListener); // Added listener
  }

  Future<void> _initializeCompetitions() async {
    await _competitions.loadAll();
    _allCompetitions = _competitions.listCompetitions();
    _groupedCompetitions = <String, List<CompetitionSummary>>{};
    for (final c in _allCompetitions!) {
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

  Future<void> _loadPhrase() async {
    if (_phrase == null) {
      setState(() => _loadingPhrase = true);
    }
    final phrase = await _phrases.randomPhrase(notThisOne: _phrase);
    if (!mounted) return;
    setState(() {
      _phrase = phrase;
      _loadingPhrase = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use memoized data instead of recalculating on every build
    final grouped =
        _groupedCompetitions ?? <String, List<CompetitionSummary>>{};
    return Scaffold(
      key: _scaffoldKey, // Assigned key
      appBar: const LeagueAppBar(title: 'Liga Educa', subtitle: 'Inicio'),
      endDrawer: const LeagueMenuDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Image.asset(
                'assets/images/logos/logo_horizontal_white.png',
                height: 70,
              ),
            ),
            LeagueCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              background: LeagueCardBackground.accent,
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite,
                          color: AppBrandColors.white, size: 30),
                      const SizedBox(height: 10),
                      Text('Valores que nos unen',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppBrandColors.white)),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                                position: Tween(
                                        begin: const Offset(0, 0.03),
                                        end: Offset.zero)
                                    .animate(anim),
                                child: child)),
                        child: _loadingPhrase
                            ? Padding(
                                key: const ValueKey('loading'),
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          valueColor:
                                              const AlwaysStoppedAnimation(
                                                  AppBrandColors.white)),
                                    ),
                                    const SizedBox(width: 10),
                                    Text('Cargando frase…',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: AppBrandColors.white
                                                    .withValues(alpha: 0.9))),
                                  ],
                                ),
                              )
                            : Column(
                                key: ValueKey(_phrase?.text ?? ''),
                                children: [
                                  SizedBox(
                                    height: 80,
                                    child: Center(
                                      child: Text(
                                        '“${_phrase?.text ?? 'El deporte nos enseña a crecer.'}”',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                color: AppBrandColors.white,
                                                height: 1.5),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                      _phrase?.author.isNotEmpty == true
                                          ? _phrase!.author
                                          : 'Liga Educa',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                              color: AppBrandColors.white
                                                  .withValues(alpha: 0.9))),
                                ],
                              ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: -12,
                    right: -12,
                    child: IconButton(
                      onPressed: _loadPhrase,
                      icon: const Icon(Icons.refresh,
                          color: AppBrandColors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Text('Competiciones',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: AppSpacing.lg),
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
                  expanded: _expandedCategories[category] ?? false,
                  onToggle: (v) =>
                      setState(() => _expandedCategories[category] = v),
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
                                    context.go(
                                        '${AppRoutes.competition}/${c.id}?title=$title&subtitle=$subtitle');
                                  },
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                  child: Row(
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
                                  context.go(
                                      '${AppRoutes.competition}/${c.id}?title=$title&subtitle=$subtitle');
                                },
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                child: Row(
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
                                          context.go(
                                              '${AppRoutes.competition}/${c.id}?title=$title&subtitle=$subtitle');
                                        },
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 14),
                                        child: Row(
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
            const SizedBox(height: AppSpacing.md),
            LeagueCard(
              padding: const EdgeInsets.all(AppSpacing.sm),
              backgroundColorOverride: AppBrandColors.navy900,
              child: Column(
                children: [
                  InkWell(
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
                  const SizedBox(height: AppSpacing.xxl),
                  Image.asset(
                    'assets/images/logos/logo_vertical_white.png',
                    height: 160,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  InkWell(
                    onTap: () {
                      launchUrl(Uri.parse('https://www.educationleague.es'));
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: Text(
                        'www.educationleague.es',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppBrandColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
