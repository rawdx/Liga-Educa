import 'package:flutter/material.dart';
import 'package:liga_educa/drawer_manager.dart'; // Added import
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_app_bar.dart';
import 'package:liga_educa/widgets/league_card.dart';
import 'package:liga_educa/widgets/sponsor_footer.dart';

class ValuesPage extends StatefulWidget {
  const ValuesPage({super.key});

  @override
  State<ValuesPage> createState() => _ValuesPageState();
}

class _ValuesPageState extends State<ValuesPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(); // Added GlobalKey

  @override
  void initState() {
    super.initState();
    drawerManager.addListener(_closeDrawerListener); // Added listener
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
    final cs = Theme.of(context).colorScheme;
    final values = const [
      ('Respeto', 'Trata a rivales, árbitros y compañeros con consideración.'),
      ('Esfuerzo', 'Mejora cada día. Lo importante es el proceso.'),
      ('Compañerismo', 'Nadie gana solo: la unión hace equipo.'),
      ('Fair Play', 'Ganar es bonito, jugar bien es mejor.'),
      ('Inclusión', 'El fútbol es de todos: siempre hay un lugar.'),
    ];
    return Scaffold(
      key: _scaffoldKey, // Assigned key
      appBar: const LeagueAppBar(title: 'Liga Educa', subtitle: 'Valores'),
      endDrawer: const LeagueMenuDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          children: [
            LeagueCard(
              background: LeagueCardBackground.accent,
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: AppBrandColors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Valores deportivos', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppBrandColors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...values.map((v) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: LeagueCard(
                  background: LeagueCardBackground.navy,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppBrandColors.greenDark.withValues(alpha: 0.25),
                              border: Border.all(color: AppBrandColors.gray600.withValues(alpha: 0.55)),
                            ),
                            child: const Icon(Icons.check, color: AppBrandColors.green, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(v.$1, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: cs.onSurface))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(v.$2, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.55)),
                    ],
                  ),
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
