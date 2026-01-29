import 'package:flutter/material.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_card.dart';

class SponsorsPage extends StatelessWidget {
  const SponsorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sponsors = const [
      ('Soccer Factory', 'Sponsor técnico'),
      ('Academia Educa', 'Formación en valores'),
      ('NutriKids', 'Hábitos saludables'),
      ('Deporte Seguro', 'Prevención y bienestar'),
    ];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            Text('Liga Educa', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurface)),
            const SizedBox(height: 2),
            Text('Patrocinadores', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          children: [
            LeagueCard(
              background: LeagueCardBackground.accent,
              child: Row(
                children: [
                  const Icon(Icons.handshake, color: AppBrandColors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Gracias por hacerlo posible', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppBrandColors.white))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...sponsors.map((s) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: LeagueCard(
                  background: LeagueCardBackground.navy,
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: AppBrandColors.greenDark.withValues(alpha: 0.22),
                          border: Border.all(color: AppBrandColors.gray600.withValues(alpha: 0.55)),
                        ),
                        child: const Icon(Icons.workspace_premium, color: AppBrandColors.green),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.$1, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: cs.onSurface)),
                            const SizedBox(height: 2),
                            Text(s.$2, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
