import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/drawer_manager.dart'; // Added import
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_app_bar.dart';
import 'package:liga_educa/widgets/league_card.dart';
import 'package:liga_educa/widgets/sponsor_footer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: const LeagueAppBar(title: 'Liga Educa', subtitle: 'Perfil'),
      endDrawer: const LeagueMenuDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          children: [
            // Bloque de Usuario Estilo Premium
            LeagueCard(
              background: LeagueCardBackground.navy,
              padding: EdgeInsets.zero,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [AppBrandColors.greenDark, AppBrandColors.green],
                            ),
                          ),
                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mi Perfil',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: cs.onSurface,
                                    ),
                              ),
                              Text(
                                'Usuario Invitado',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: cs.onSurface.withValues(alpha: 0.7),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Secciones
            LeagueCard(
              background: LeagueCardBackground.navy,
              onTap: () => context.go(AppRoutes.team),
              child: Row(
                children: [
                  const Icon(Icons.groups_rounded, color: AppBrandColors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mi Equipo',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                ],
              ),
            ),
            const SizedBox(height: 12),
            LeagueCard(
              background: LeagueCardBackground.navy,
              onTap: () => context.go(AppRoutes.sponsors),
              child: Row(
                children: [
                  const Icon(Icons.handshake_rounded, color: AppBrandColors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Patrocinadores',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SponsorFooter(),
          ],
        ),
      ),
    );
  }
}
