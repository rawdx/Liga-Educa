import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/drawer_manager.dart';
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_app_bar.dart';
import 'package:liga_educa/widgets/league_card.dart';
import 'package:liga_educa/widgets/news_card.dart';
import 'package:liga_educa/widgets/sponsor_footer.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _selectedCategory;

  static const _allItems = [
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

  List<String> get _categories => _allItems.map((e) => e.tag).toSet().toList();

  List<NewsItemData> get _filteredItems => _selectedCategory == null
      ? _allItems
      : _allItems.where((e) => e.tag == _selectedCategory).toList();

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
    final items = _filteredItems;

    return Scaffold(
      key: _scaffoldKey,
      appBar: const LeagueAppBar(title: 'Liga Educa', subtitle: 'Noticias'),
      endDrawer: const LeagueMenuDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          children: [
            // Bloque de Actualidad Estilo Premium (Dashboad Style)
            LeagueCard(
              background: LeagueCardBackground.navy,
              padding: EdgeInsets.zero,
              child: Stack(
                children: [
                  // Icono decorativo de fondo (Consistente con Home/Competiciones)
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Icon(
                      Icons.newspaper_rounded,
                      size: 100,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Actualidad',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: cs.onSurface,
                                        ),
                                  ),
                                  Text(
                                    'Noticias y formación',
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Filtros integrados
                      Container(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              _CategoryChip(
                                label: 'Todas',
                                isSelected: _selectedCategory == null,
                                onSelected: (selected) => setState(() => _selectedCategory = null),
                              ),
                              const SizedBox(width: 8),
                              ..._categories.map((category) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: _CategoryChip(
                                  label: category,
                                  isSelected: _selectedCategory == category,
                                  onSelected: (selected) => setState(() => _selectedCategory = selected ? category : null),
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Lista de Noticias
            if (items.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'No hay noticias en esta categoría',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              )
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: NewsCard(
                    item: item,
                    onTap: () => context.go(AppRoutes.newsDetail, extra: item),
                  ),
                ),
              ),
            
            const SizedBox(height: 10),
            const SponsorFooter(),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppBrandColors.green,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : cs.onSurface,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
      checkmarkColor: Colors.white,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}