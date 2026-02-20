import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/models/competition_models.dart';
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/services/favorites_service.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_app_bar.dart';
import 'package:liga_educa/widgets/league_card.dart';
import 'package:liga_educa/widgets/sponsor_footer.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LeagueAppBar(title: 'Liga Educa', subtitle: 'Favoritos'),
      endDrawer: const LeagueMenuDrawer(),
      body: ListenableBuilder(
        listenable: FavoritesService.instance,
        builder: (context, _) {
          final favorites = FavoritesService.instance.favorites;

          if (favorites.isEmpty) {
            return _buildEmptyState(context);
          }

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
              children: [
                _buildHeaderCard(context, favorites.length),
                const SizedBox(height: 20),
                ...favorites.map((team) => _FavoriteTeamCard(team: team)),
                const SizedBox(height: 20),
                const SponsorFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, int count) {
    return LeagueCard(
      background: LeagueCardBackground.accent,
      padding: const EdgeInsets.all(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative background icon
          Positioned(
            right: -20,
            bottom: -25,
            child: Transform.rotate(
              angle: -0.2,
              child: Icon(
                Icons.star_rounded,
                size: 110,
                color: AppBrandColors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppBrandColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.stars_outlined, color: AppBrandColors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mis Equipos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppBrandColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppBrandColors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        count == 1 ? '1 SEGUIDO' : '$count SEGUIDOS',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppBrandColors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppBrandColors.green.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_rounded,
              size: 64,
              color: AppBrandColors.green.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aún no tienes favoritos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Guarda tus equipos favoritos para acceder rápidamente a sus resultados y clasificación.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 40, 158, 40), Color.fromARGB(255, 43, 176, 43)],
                begin: Alignment.topLeft,
                end: Alignment.center,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.competitions),
              icon: const Icon(Icons.search, size: 18),
              label: const Text('EXPLORAR COMPETICIONES',
                  style: TextStyle(
                    fontWeight: FontWeight.w700, 
                    letterSpacing: 0.2,
                    fontSize: 13,
                  )),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                minimumSize: const Size(200, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteTeamCard extends StatelessWidget {
  final FavoriteTeam team;

  const _FavoriteTeamCard({required this.team});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LeagueCard(
        onTap: () {
          context.push(
            '${AppRoutes.teamDetail}?teamName=${Uri.encodeComponent(team.teamName)}&competitionId=${team.competitionId}${team.competitionTitle != null ? '&competitionTitle=${Uri.encodeComponent(team.competitionTitle!)}' : ''}',
          );
        },
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (team.image != null)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.asset(team.image!, fit: BoxFit.cover),
                ),
              )
            else
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
                ),
                child: Icon(Icons.shield, color: cs.onSurfaceVariant, size: 24),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.teamName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                  ),
                  Text(
                    team.competitionTitle ?? 'Liga Educa',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}