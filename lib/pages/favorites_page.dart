import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/models/competition_models.dart';
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/services/favorites_service.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_app_bar.dart';
import 'package:liga_educa/widgets/league_card.dart';
import 'package:liga_educa/widgets/sponsor_footer.dart';
import 'package:liga_educa/widgets/team_logo.dart';

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
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppBrandColors.green.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppBrandColors.greenDark, AppBrandColors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppBrandColors.green.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 52,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
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
          const SizedBox(height: 36),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppBrandColors.greenDark, AppBrandColors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: AppBrandColors.green.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.competitions),
              icon: const Icon(Icons.search, size: 18),
              label: const Text('EXPLORAR COMPETICIONES',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
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
        backgroundColorOverride: AppBrandColors.navy800,
        borderAlpha: 0.32,
        onTap: () {
          context.push(
            '${AppRoutes.teamDetail}?teamName=${Uri.encodeComponent(team.teamName)}&competitionId=${team.competitionId}${team.competitionTitle != null ? '&competitionTitle=${Uri.encodeComponent(team.competitionTitle!)}' : ''}',
          );
        },
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            TeamLogo(image: team.image, size: 44),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.teamName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700
                        ),
                  ),
                  Text(
                    team.competitionTitle ?? 'Liga Educa',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
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