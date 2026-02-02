import 'package:flutter/material.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_app_bar.dart';
import 'package:liga_educa/widgets/league_card.dart';
import 'package:liga_educa/widgets/sponsor_footer.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final team = const [
      ('Coordinación', 'María López', 'Coordinadora general'),
      ('Entrenadores', 'Carlos Pérez', 'Formación y metodología'),
      ('Educación', 'Lucía García', 'Valores y convivencia'),
      ('Comunicación', 'David Ruiz', 'Noticias y difusión'),
    ];
    return Scaffold(
      appBar: const LeagueAppBar(
        title: 'Liga Educa',
        subtitle: 'Equipo',
        showBack: true,
      ),
      endDrawer: const LeagueMenuDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          children: [
            LeagueCard(
              background: LeagueCardBackground.accent,
              child: Row(
                children: [
                  const Icon(Icons.groups, color: AppBrandColors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Equipo organizador', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppBrandColors.white))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...team.map((t) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: LeagueCard(
                  background: LeagueCardBackground.navy,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppBrandColors.gray700.withValues(alpha: 0.55),
                          border: Border.all(color: AppBrandColors.gray600.withValues(alpha: 0.55)),
                        ),
                        child: const Icon(Icons.person, color: AppBrandColors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.$1, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppBrandColors.green)),
                            const SizedBox(height: 4),
                            Text(t.$2, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: cs.onSurface)),
                            const SizedBox(height: 2),
                            Text(t.$3, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
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
