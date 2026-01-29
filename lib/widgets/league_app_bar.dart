import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/theme.dart';

class LeagueAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBack;

  const LeagueAppBar({super.key, required this.title, this.subtitle, this.showBack = false});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      leading: showBack
          ? IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back, color: cs.onSurface),
            )
          : null,
      centerTitle: true,
      title: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurface)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ],
      ),
      actions: [
        Builder(
          builder: (ctx) => IconButton(
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            icon: Icon(Icons.menu, color: cs.onSurface),
          ),
        ),
        const SizedBox(width: 6),
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
                icon: Icons.groups,
                label: 'Equipo',
                onTap: () {
                  context.pop();
                  context.go('${AppRoutes.profile}/equipo');
                },
              ),
              _DrawerItem(
                icon: Icons.handshake,
                label: 'Patrocinadores',
                onTap: () {
                  context.pop();
                  context.go('${AppRoutes.profile}/patrocinadores');
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