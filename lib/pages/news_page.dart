import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/drawer_manager.dart';
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_app_bar.dart';
import 'package:liga_educa/widgets/news_card.dart';
import 'package:liga_educa/widgets/sponsor_footer.dart';

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
      NewsItemData(
        imagePath: 'assets/images/teams/betis.jpg',
        tag: 'Destacado',
        timeAgo: 'Hace 2 horas',
        title: 'FC Barcelona B se proclama campeón de la temporada 2024',
        description: 'El equipo azulgrana consigue el título tras una emocionante final contra Real Betis Féminas con un resultado de 3-2.',
        author: 'Juan Pérez',
      ),
      NewsItemData(
        imagePath: 'assets/images/teams/adlosmares.jpg',
        tag: 'Formación',
        timeAgo: 'Hace 5 horas',
        title: 'Jornada educativa: respeto en el campo',
        description: 'Cómo el juego limpio mejora la convivencia y fortalece los valores deportivos en las nuevas generaciones.',
        author: 'María García',
      ),
      NewsItemData(
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
                child: NewsCard(
                  item: item,
                  onTap: () => context.go(AppRoutes.newsDetail, extra: item),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SponsorFooter(),
          ],
        ),
      ),
    );
  }
}
