import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/theme.dart';

class LeagueAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBack;

  const LeagueAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine the page title to display
    // If subtitle is provided, it's the specific page name (e.g. "Inicio", "Competiciones")
    // If not, fall back to title (e.g. "Liga Educa")
    final pageTitle = subtitle ?? title;

    return AppBar(
      leading: showBack
          ? IconButton(
              onPressed: () => context.pop(),
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
              isDark
                  ? 'assets/images/logos/LOGO LIGA EDUCA HORIZONTAL BLANCO.svg'
                  : 'assets/images/logos/LOGO LIGA EDUCA HORIZONTAL COLOR.svg',
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
            child: Text(
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(colors: [AppBrandColors.greenDark, AppBrandColors.green]),
                    ),
                    child: const Icon(Icons.sports_soccer, color: AppBrandColors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Liga Educa', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurface)),
                        const SizedBox(height: 2),
                        Text('Menú', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => context.pop(), icon: Icon(Icons.close, color: cs.onSurface)),
                ],
              ),
              const SizedBox(height: 18),
              _DrawerItem(
                icon: Icons.home,
                label: 'Inicio',
                onTap: () {
                  context.pop();
                  context.go(AppRoutes.home);
                },
              ),
              _DrawerItem(
                icon: Icons.emoji_events,
                label: 'Competiciones',
                onTap: () {
                  context.pop();
                  context.go(AppRoutes.competitions);
                },
              ),
              _DrawerItem(
                icon: Icons.article,
                label: 'Noticias',
                onTap: () {
                  context.pop();
                  context.go(AppRoutes.news);
                },
              ),
              _DrawerItem(
                icon: Icons.star,
                label: 'Favoritos',
                onTap: () {
                  context.pop();
                  context.go(AppRoutes.favorites);
                },
              ),
              _DrawerItem(
                icon: Icons.favorite,
                label: 'Valores deportivos',
                onTap: () {
                  context.pop();
                  context.go(AppRoutes.values);
                },
              ),
              const SizedBox(height: 10),
              Divider(color: cs.outline.withValues(alpha: 0.25)),
              const SizedBox(height: 10),
              _DrawerItem(
                icon: Icons.person,
                label: 'Mi Perfil',
                onTap: () {
                  context.pop();
                  context.push(AppRoutes.profile);
                },
              ),
              _DrawerItem(
                icon: Icons.groups,
                label: 'Equipo',
                onTap: () {
                  context.pop();
                  context.push(AppRoutes.team);
                },
              ),
              _DrawerItem(
                icon: Icons.handshake,
                label: 'Patrocinadores',
                onTap: () {
                  context.pop();
                  context.push(AppRoutes.sponsors);
                },
              ),
              const Spacer(),
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
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}