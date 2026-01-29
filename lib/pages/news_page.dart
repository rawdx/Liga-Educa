import 'package:flutter/material.dart';
import 'package:liga_educa/drawer_manager.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_app_bar.dart';
import 'package:liga_educa/widgets/league_card.dart';

class _NewsItem {
  final String imagePath;
  final String tag;
  final String timeAgo;
  final String title;
  final String description;
  final String author;

  const _NewsItem({
    required this.imagePath,
    required this.tag,
    required this.timeAgo,
    required this.title,
    required this.description,
    required this.author,
  });
}

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    drawerManager.addListener(_closeDrawerListener);
  }

  @override
  void dispose() {
    drawerManager.removeListener(_closeDrawerListener);
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
    final items = const [
      _NewsItem(
        imagePath: 'assets/images/teams/betis.jpg',
        tag: 'Destacado',
        timeAgo: 'Hace 2 horas',
        title: 'FC Barcelona B se proclama campeón de la temporada 2024',
        description: 'El equipo azulgrana consigue el título tras una emocionante final contra Real Betis Féminas con un resultado de 3-2.',
        author: 'Juan Pérez',
      ),
      _NewsItem(
        imagePath: 'assets/images/teams/adlosmares.jpg',
        tag: 'Formación',
        timeAgo: 'Hace 5 horas',
        title: 'Jornada educativa: respeto en el campo',
        description: 'Cómo el juego limpio mejora la convivencia y fortalece los valores deportivos en las nuevas generaciones.',
        author: 'María García',
      ),
      _NewsItem(
        imagePath: 'assets/images/teams/huevarcf.jpg',
        tag: 'Entrenamiento',
        timeAgo: 'Hace 1 día',
        title: 'Entrenamiento de valores y trabajo en equipo',
        description: '3 dinámicas esenciales para reforzar la cohesión del grupo y el compañerismo dentro y fuera del campo.',
        author: 'Carlos Ruiz',
      ),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: const LeagueAppBar(title: 'Liga Educa', subtitle: 'Noticias'),
      endDrawer: const LeagueMenuDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          children: [
            Text('Actualidad', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurface)),
            const SizedBox(height: 10),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: LeagueCard(
                  background: LeagueCardBackground.navy,
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                        child: Image.asset(
                          item.imagePath,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 180,
                            color: AppBrandColors.navy900,
                            child: const Center(child: Icon(Icons.image_not_supported, color: AppBrandColors.gray600)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppBrandColors.greenDark,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.tag,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  item.timeAgo,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppBrandColors.gray400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.description,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppBrandColors.gray400,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppBrandColors.gray600,
                                  child: Icon(Icons.person, size: 16, color: Colors.white),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.author,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppBrandColors.gray400,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Leer más',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppBrandColors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward, size: 16, color: AppBrandColors.green),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
