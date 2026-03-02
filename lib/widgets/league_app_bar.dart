import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class LeagueAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const LeagueAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Determine the page title to display
    // If subtitle is provided, it's the specific page name (e.g. "Inicio", "Competiciones")
    // If not, fall back to title (e.g. "Liga Educa")
    final pageTitle = subtitle ?? title;

    return AppBar(
      leading: showBack
          ? IconButton(
              onPressed: onBack ?? () => context.pop(),
              icon: Icon(Icons.arrow_back, color: cs.onSurface),
            )
          : null,
      // If not showing back button, we might want to adjust leading width or use title
      automaticallyImplyLeading: false, 
      titleSpacing: showBack ? 0 : AppSpacing.md,
      centerTitle: false,
      title: Row(
        children: [
          if (!showBack) ...[
            SvgPicture.asset(
              'assets/images/logos/LOGO LIGA EDUCA HORIZONTAL COLOR.svg',
              height: 28,
            ),
            Container(
              height: 24,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: cs.outline.withValues(alpha: 0.3),
            ),
          ],
          Expanded(
            child: showBack && subtitle != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle!.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                : Text(
                    pageTitle.toUpperCase(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
      actions: [
        if (actions != null) ...actions!,
        Builder(
          builder: (ctx) => IconButton(
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            icon: Icon(Icons.menu, color: cs.onSurface),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class LeagueMenuDrawer extends StatelessWidget {
  const LeagueMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Drawer(
      backgroundColor: cs.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          bottomLeft: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabecera Rediseñada: Tipografía Minimalista y Profesional
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    // Logo Vertical sin fondo
                    SizedBox(
                      height: 54,
                      width: 54,
                      child: SvgPicture.asset(
                        'assets/images/logos/LOGO LIGA EDUCA VERTICAL COLOR.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'MENÚ',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                  color: cs.onSurface,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'TEMPORADA 25/26',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  fontSize: 9,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant, size: 22),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              _DrawerItem(
                icon: Icons.home_rounded,
                label: 'Inicio',
                onTap: () {
                  context.pop();
                  context.go(AppRoutes.home);
                },
              ),
              _DrawerItem(
                icon: Icons.emoji_events_rounded,
                label: 'Competiciones',
                onTap: () {
                  context.pop();
                  context.go(AppRoutes.competitions);
                },
              ),
              _DrawerItem(
                icon: Icons.article_rounded,
                label: 'Noticias',
                onTap: () {
                  context.pop();
                  context.go(AppRoutes.news);
                },
              ),
              _DrawerItem(
                icon: Icons.star_rounded,
                label: 'Favoritos',
                onTap: () {
                  context.pop();
                  context.go(AppRoutes.favorites);
                },
              ),
              _DrawerItem(
                icon: Icons.favorite_rounded,
                label: 'Valores deportivos',
                onTap: () {
                  context.pop();
                  context.go(AppRoutes.values);
                },
              ),
              _DrawerItem(
                icon: Icons.person_rounded,
                label: 'Mi Perfil',
                onTap: () {
                  context.pop();
                  context.go(AppRoutes.profile);
                },
              ),
              const SizedBox(height: 10),
              Divider(color: cs.outline.withValues(alpha: 0.25)),
              const SizedBox(height: 10),
              _DrawerItem(
                icon: Icons.groups_rounded,
                label: 'Equipo',
                onTap: () {
                  context.pop();
                  context.push(AppRoutes.team);
                },
              ),
              _DrawerItem(
                icon: Icons.handshake_rounded,
                label: 'Patrocinadores',
                onTap: () {
                  context.pop();
                  context.push(AppRoutes.sponsors);
                },
              ),
              const Spacer(),
              Center(
                child: InkWell(
                  onTap: () => launchUrl(Uri.parse('https://www.soccerfactory.es/')),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logos/sf_logo.png',
                          height: 32,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sponsor Técnico',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                                fontSize: 8,
                                letterSpacing: 0.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('v 1.0.1', textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            color: cs.surfaceContainerHighest.withValues(alpha: 0.18),
            border: Border.all(color: cs.outline.withValues(alpha: 0.20)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppBrandColors.green),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: cs.onSurface))),
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}