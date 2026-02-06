import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liga_educa/drawer_manager.dart';
import 'package:liga_educa/models/phrase.dart';
import 'package:liga_educa/services/phrases_service.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_app_bar.dart';
import 'package:liga_educa/widgets/league_card.dart';
import 'package:liga_educa/widgets/sponsor_footer.dart';
import 'package:liga_educa/widgets/join_us_section.dart';

class ValuesPage extends StatefulWidget {
  const ValuesPage({super.key});

  @override
  State<ValuesPage> createState() => _ValuesPageState();
}

class _ValuesPageState extends State<ValuesPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _phrases = PhrasesService.instance;
  Phrase? _phrase;
  bool _loadingPhrase = true;

  @override
  void initState() {
    super.initState();
    _loadPhrase();
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: const LeagueAppBar(title: 'Liga Educa', subtitle: 'Valores Deportivos'),
      endDrawer: const LeagueMenuDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          children: [
            // 1. Logo (Same as Home)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: SvgPicture.asset(
                'assets/images/logos/LOGO LIGA EDUCA HORIZONTAL BLANCO.svg',
                height: 70,
              ),
            ),

            // 2. Header Card (Valores que nos unen - Same logic as Home)
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
                      const Icon(Icons.favorite, color: AppBrandColors.white, size: 32),
                      const SizedBox(height: 12),
                      Text('Valores que nos unen',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppBrandColors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                                position: Tween(begin: const Offset(0, 0.03), end: Offset.zero)
                                    .animate(anim),
                                child: child)),
                        child: _loadingPhrase
                            ? Padding(
                                key: const ValueKey('loading'),
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          valueColor: AlwaysStoppedAnimation(AppBrandColors.white)),
                                    ),
                                    const SizedBox(width: 10),
                                    Text('Cargando frase…',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: AppBrandColors.white.withValues(alpha: 0.9))),
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
                                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                    fontSize: 20,
                                                    color: AppBrandColors.white,
                                                    fontStyle: FontStyle.italic,
                                                    height: 1.3,
                                                    fontWeight: FontWeight.w500,
                                                  ),
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
                                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          color: AppBrandColors.white.withValues(alpha: 0.8),
                                          letterSpacing: 1.2,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                      ),
                    ],
                  ),
                  // Refresh button
                  Positioned(
                    bottom: -10,
                    right: -10,
                    child: IconButton(
                      onPressed: _loadPhrase,
                      icon: Icon(Icons.refresh,
                          size: 20, color: AppBrandColors.white.withValues(alpha: 0.7)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // 3. Nuestros Valores List (DetailBlock style)
            LeagueCard(
              background: LeagueCardBackground.navy,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Section Header inside card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.stars_rounded, size: 18, color: AppBrandColors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Nuestros Valores',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 30),
                  ),
                  // List content
                  Column(
                    children: [
                      _ValueListItem(
                        icon: Icons.handshake,
                        title: 'Respeto',
                        description: 'Hacia compañeros, rivales, árbitros y aficionados. El respeto es la base de todo deporte.',
                      ),
                      _ValueListItem(
                        icon: Icons.groups,
                        title: 'Trabajo en Equipo',
                        description: 'Juntos somos más fuertes. El éxito individual nace del esfuerzo colectivo.',
                      ),
                      _ValueListItem(
                        icon: Icons.emoji_events,
                        title: 'Excelencia',
                        description: 'Buscamos dar lo mejor de nosotros en cada entrenamiento y cada partido.',
                      ),
                      _ValueListItem(
                        icon: Icons.balance,
                        title: 'Fair Play',
                        description: 'Jugamos limpio, ganamos con honor y perdemos con dignidad.',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 4. Testimonios Section
            LeagueCard(
              background: LeagueCardBackground.navy,
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Testimonios',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Cómo vivimos estos valores',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 10),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _TestimonialCard(
                          imagePath: 'assets/images/teams/barcelona.png', // Placeholder or generic avatar if needed
                          name: 'Carlos Martínez',
                          role: 'Entrenador',
                          roleColor: AppBrandColors.greenDark,
                          quote: 'En Liga Educa no solo formamos futbolistas, formamos personas. Cada valor que enseñamos en el campo se refleja en la vida diaria de nuestros jugadores.',
                          affiliation: 'FC Barcelona B',
                          isFemale: false, // For avatar selection logic if implemented
                        ),
                        const SizedBox(height: 12),
                        _TestimonialCard(
                          imagePath: 'assets/images/teams/betis.jpg', // Placeholder
                          name: 'María González',
                          role: 'Capitana',
                          roleColor: AppBrandColors.green,
                          quote: 'El respeto que se vive en Liga Educa es único. Aquí aprendí que ganar no lo es todo, sino cómo juegas y cómo tratas a los demás.',
                          affiliation: 'Real Betis Féminas',
                          isFemale: true,
                        ),
                        const SizedBox(height: 12),
                        _TestimonialCard(
                          imagePath: '', // No specific image, will fallback to icon
                          name: 'Roberto Silva',
                          role: 'Padre',
                          roleColor: AppBrandColors.gray600,
                          quote: 'Mi hijo ha crecido tanto como persona desde que está en Liga Educa. Los valores que aprende aquí los aplica en casa y en el colegio.',
                          affiliation: 'Familia Silva',
                          isFemale: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 5. Nuestro Compromiso Section
            LeagueCard(
              background: LeagueCardBackground.navy,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                   Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Nuestro Compromiso',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppBrandColors.greenDark.withValues(alpha: 0.34),
                          AppBrandColors.greenDark.withValues(alpha: 0.30),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppBrandColors.green.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.security, size: 40, color: AppBrandColors.green),
                        const SizedBox(height: 16),
                        Text(
                          'Liga Educa se compromete a defender y promover estos valores en cada partido, cada entrenamiento y cada decisión.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppBrandColors.white.withValues(alpha: 0.9),
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Creemos que el fútbol es una herramienta poderosa para formar mejores personas y una sociedad más justa.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppBrandColors.white.withValues(alpha: 0.9),
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '100%',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          color: AppBrandColors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Fair Play',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppBrandColors.gray400,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: AppBrandColors.gray600.withValues(alpha: 0.5),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  _AnimatedCounter(
                                    value: 500,
                                    suffix: '+',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          color: AppBrandColors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Jugadores formados',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppBrandColors.gray400,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 6. Join Us Section
            const JoinUsSection(),

            const SizedBox(height: AppSpacing.xl),
            const SponsorFooter(),
          ],
        ),
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String role;
  final Color roleColor;
  final String quote;
  final String affiliation;
  final bool isFemale;

  const _TestimonialCard({
    required this.imagePath,
    required this.name,
    required this.role,
    required this.roleColor,
    required this.quote,
    required this.affiliation,
    required this.isFemale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppBrandColors.gray700.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppBrandColors.gray700,
            backgroundImage: imagePath.isNotEmpty && !imagePath.endsWith('.png') && !imagePath.endsWith('.jpg') 
              ? null // Handle actual image loading or fallback properly
              : null, 
            child: const Icon(Icons.person, color: AppBrandColors.gray400), // Default placeholder
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppBrandColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: roleColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        role,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppBrandColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '"$quote"',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppBrandColors.white.withValues(alpha: 0.83), // Improved visibility
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (index) => const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B))), // Amber, slightly smaller for compact layout
                    ),
                    const Spacer(),
                    Text(
                      affiliation,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppBrandColors.gray400, // Lightened for visibility
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ValueListItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppBrandColors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppBrandColors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppBrandColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppBrandColors.white.withValues(alpha: 0.8), // Text color for dark background
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCounter extends StatelessWidget {
  final int value;
  final String suffix;
  final TextStyle? style;

  const _AnimatedCounter({
    required this.value,
    this.suffix = '',
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 3000),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Text(
          '$value$suffix',
          style: style,
        );
      },
    );
  }
}

