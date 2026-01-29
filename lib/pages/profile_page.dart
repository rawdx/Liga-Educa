import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/drawer_manager.dart'; // Added import
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_app_bar.dart';
import 'package:liga_educa/widgets/league_card.dart';

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
      key: _scaffoldKey, // Assigned key
      appBar: const LeagueAppBar(title: 'Liga Educa', subtitle: 'Perfil'),
      endDrawer: const LeagueMenuDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          children: [
            LeagueCard(
              background: LeagueCardBackground.navy,
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(colors: [AppBrandColors.greenDark, AppBrandColors.green]),
                    ),
                    child: const Icon(Icons.person, color: AppBrandColors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Invitado', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurface)),
                        const SizedBox(height: 2),
                        Text('Sin cuenta (modo local)', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Secciones', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurface)),
            const SizedBox(height: 10),
            LeagueCard(
              background: LeagueCardBackground.navy,
              onTap: () => context.push('${AppRoutes.profile}/equipo'),
              child: Row(
                children: [
                  const Icon(Icons.groups, color: AppBrandColors.green),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Equipo', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: cs.onSurface))),
                  Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                ],
              ),
            ),
            const SizedBox(height: 10),
            LeagueCard(
              background: LeagueCardBackground.navy,
              onTap: () => context.push('${AppRoutes.profile}/patrocinadores'),
              child: Row(
                children: [
                  const Icon(Icons.handshake, color: AppBrandColors.green),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Patrocinadores', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: cs.onSurface))),
                  Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                ],
              ),
            ),
            const SizedBox(height: 18),

          ],
        ),
      ),
    );
  }
}
