import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/pages/competition_detail_page.dart';
import 'package:liga_educa/pages/competitions_page.dart';
import 'package:liga_educa/pages/home_page.dart';
import 'package:liga_educa/pages/news_detail_page.dart';
import 'package:liga_educa/pages/news_page.dart';
import 'package:liga_educa/pages/profile_page.dart';
import 'package:liga_educa/pages/splash_page.dart';
import 'package:liga_educa/pages/sponsors_page.dart';
import 'package:liga_educa/pages/team_page.dart';
import 'package:liga_educa/pages/values_page.dart';
import 'package:liga_educa/widgets/app_shell.dart';
import 'package:liga_educa/widgets/news_card.dart';

/// GoRouter configuration for Liga Educa.
///
/// IMPORTANT: use go_router navigation helpers:
/// - context.go('/route')
/// - context.push('/route')
/// - context.pop()
class AppRouter {
  // Navigator keys
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  // Key specifically for competitions to preserve its state (detail view)
  static final _competitionsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'competitions');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => const NoTransitionPage(child: SplashPage()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                pageBuilder: (context, state) => const NoTransitionPage(child: HomePage()),
                routes: [
                  GoRoute(
                    path: 'news-detail',
                    name: 'homeNewsDetail',
                    pageBuilder: (context, state) {
                      final newsItem = state.extra as NewsItemData;
                      return CustomTransitionPage(
                        child: NewsDetailPage(newsItem: newsItem),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
                          return FadeTransition(
                            opacity: curved,
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(0.03, 0.02), end: Offset.zero).animate(curved),
                              child: child,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _competitionsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.competitions,
                name: 'competitions',
                pageBuilder: (context, state) => const NoTransitionPage(child: CompetitionsPage()),
                routes: [
                  GoRoute(
                    path: 'detail/:competitionId',
                    name: 'competitionDetail',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['competitionId'] ?? '';
                      final title = state.uri.queryParameters['title'];
                      final subtitle = state.uri.queryParameters['subtitle'];
                      return CustomTransitionPage(
                        child: CompetitionDetailPage(competitionId: id, title: title, subtitle: subtitle),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
                          return FadeTransition(
                            opacity: curved,
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(0.03, 0.02), end: Offset.zero).animate(curved),
                              child: child,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.news,
                name: 'news',
                pageBuilder: (context, state) => const NoTransitionPage(child: NewsPage()),
                routes: [
                  GoRoute(
                    path: 'detail',
                    name: 'newsDetail',
                    pageBuilder: (context, state) {
                      final newsItem = state.extra as NewsItemData;
                      return CustomTransitionPage(
                        child: NewsDetailPage(newsItem: newsItem),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
                          return FadeTransition(
                            opacity: curved,
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(0.03, 0.02), end: Offset.zero).animate(curved),
                              child: child,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.values,
                name: 'values',
                pageBuilder: (context, state) => const NoTransitionPage(child: ValuesPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage()),
                routes: [
                  GoRoute(
                    path: 'equipo',
                    name: 'team',
                    pageBuilder: (context, state) => MaterialPage(child: TeamPage()),
                  ),
                  GoRoute(
                    path: 'patrocinadores',
                    name: 'sponsors',
                    pageBuilder: (context, state) => MaterialPage(child: SponsorsPage()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String homeNewsDetail = '/home/news-detail';
  static const String competitions = '/competitions';
  static const String competition = '/competitions/detail';
  static const String news = '/news';
  static const String newsDetail = '/news/detail';
  static const String values = '/values';
  static const String profile = '/profile';
}
