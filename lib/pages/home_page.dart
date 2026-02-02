import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/drawer_manager.dart'; // Added import
import 'package:liga_educa/models/phrase.dart';
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/services/phrases_service.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_app_bar.dart';
import 'package:liga_educa/widgets/league_card.dart';
import 'package:liga_educa/widgets/news_card.dart';
import 'package:liga_educa/widgets/sponsor_footer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(); // Added GlobalKey
  final _phrases = PhrasesService.instance;
  Phrase? _phrase;
  bool _loadingPhrase = true;

  @override
  void initState() {
    super.initState();
    _loadPhrase();
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

  Future<void> _loadPhrase() async {
    if (_phrase == null) {
      setState(() => _loadingPhrase = true);
    }
    final phrase = await _phrases.randomPhrase(notThisOne: _phrase);
    if (!mounted) return;
    setState(() {
      _phrase = phrase;
      _loadingPhrase = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Featured news data
    const featuredNews = NewsItemData(
      imagePath: 'assets/images/teams/betis.jpg',
      tag: 'Destacado',
      timeAgo: 'Hace 2 horas',
      title: 'FC Barcelona B se proclama campeón de la temporada 2024',
      description:
          'El equipo azulgrana consigue el título tras una emocionante final contra Real Betis Féminas con un resultado de 3-2.',
      author: 'Juan Pérez',
    );

    return Scaffold(
      key: _scaffoldKey, // Assigned key
      appBar: const LeagueAppBar(title: 'Liga Educa', subtitle: 'Inicio'),
      endDrawer: const LeagueMenuDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: SvgPicture.asset(
                'assets/images/logos/LOGO LIGA EDUCA HORIZONTAL BLANCO.svg',
                height: 70,
              ),
            ),
            LeagueCard(
              padding: const EdgeInsets.all(24),
              background: LeagueCardBackground.accent,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Decorative background icon
                  Positioned(
                    right: -20,
                    bottom: -30,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        Icons.handshake_rounded,
                        size: 140,
                        color: AppBrandColors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  // Main Content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite,
                          color: AppBrandColors.white, size: 32),
                      const SizedBox(height: 12),
                      Text('Valores que nos unen',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  color: AppBrandColors.white,
                                  fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                                position: Tween(
                                        begin: const Offset(0, 0.03),
                                        end: Offset.zero)
                                    .animate(anim),
                                child: child)),
                        child: _loadingPhrase
                            ? Padding(
                                key: const ValueKey('loading'),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          valueColor: AlwaysStoppedAnimation(
                                              AppBrandColors.white)),
                                    ),
                                    const SizedBox(width: 10),
                                    Text('Cargando frase…',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: AppBrandColors.white
                                                    .withValues(alpha: 0.9))),
                                  ],
                                ),
                              )
                            : Column(
                                key: ValueKey(_phrase?.text ?? ''),
                                children: [
                                  SizedBox(
                                    height: 90,
                                    width: double.infinity,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.center,
                                          child: SizedBox(
                                            width: constraints.maxWidth,
                                            child: Text(
                                              '“${_phrase?.text ?? 'El deporte nos enseña a crecer.'}”',
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                      fontSize: 20,
                                                      color:
                                                          AppBrandColors.white,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      height: 1.3,
                                                      fontWeight:
                                                          FontWeight.w500),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                      _phrase?.author.isNotEmpty == true
                                          ? _phrase!.author
                                          : 'Liga Educa',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                              color: AppBrandColors.white
                                                  .withValues(alpha: 0.8),
                                              letterSpacing: 1.2,
                                              fontWeight: FontWeight.bold)),
                                ],
                              ),
                      ),
                    ],
                  ),
                  // Refresh button adjusted to avoid overlap
                  Positioned(
                    bottom: -10,
                    right: -10,
                    child: IconButton(
                      onPressed: _loadPhrase,
                      icon: Icon(Icons.refresh,
                          size: 20,
                          color: AppBrandColors.white.withValues(alpha: 0.7)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // New Competitions CTA
            LeagueCard(
              onTap: () => context.go(AppRoutes.competitions),
              background: LeagueCardBackground.normal,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [AppBrandColors.greenDark, AppBrandColors.green],
                      ),
                    ),
                    child: const Icon(Icons.emoji_events_rounded,
                        color: AppBrandColors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Competiciones',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          'Consulta resultados, calendarios y clasificaciones.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // News Section
            NewsCard(
              item: featuredNews,
              onTap: () => context.go(AppRoutes.homeNewsDetail, extra: featuredNews),
            ),

            const SizedBox(height: AppSpacing.lg),
            const SponsorFooter(),
          ],
        ),
      ),
    );
  }
}

