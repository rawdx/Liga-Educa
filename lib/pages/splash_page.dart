import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liga_educa/nav.dart';
import 'package:liga_educa/services/competitions_service.dart';
import 'package:liga_educa/theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  Future<void> _startLoading() async {
    final stopwatch = Stopwatch()..start();
    
    // Load all data from API
    await CompetitionsService.instance.loadAll();
    
    stopwatch.stop();
    
    // Ensure splash is visible for at least 4 seconds
    final remaining = 4000 - stopwatch.elapsedMilliseconds;
    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }

    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 28, right: 28, bottom: 60, top: 22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LoadingText(),
                const SizedBox(height: 16),
                _SplashProgressBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingText extends StatefulWidget {
  @override
  State<_LoadingText> createState() => _LoadingTextState();
}

class _LoadingTextState extends State<_LoadingText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
      child: Text(
        'CARGANDO...',
        textAlign: TextAlign.center,
        style: TextStyle(
         color: Colors.white.withValues(alpha: 0.9),                                                                          
       fontSize: 10,                                                                                                        
       fontWeight: FontWeight.w800,                                                                                         
          letterSpacing: 2.5,   
        ),
      ),
    );
  }
}

class _SplashProgressBar extends StatefulWidget {
  @override
  State<_SplashProgressBar> createState() => _SplashProgressBarState();
}

class _SplashProgressBarState extends State<_SplashProgressBar> with TickerProviderStateMixin {
  late final AnimationController _progressController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..forward();

  late final AnimationController _shimmerController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _progressController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressController, _shimmerController]),
      builder: (context, _) {
        final progress = CurvedAnimation(
          parent: _progressController,
          curve: Curves.easeInOutCubic,
        ).value;

        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            height: 6,
            child: Stack(
              children: [
                // Background Glass track
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                // Progress Fill
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppBrandColors.greenDark,
                          AppBrandColors.green,
                          Color(0xFF86EFAC), // A lighter green for the tip
                        ],
                        stops: [0.0, 0.7, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppBrandColors.green.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          // Shimmer overlay
                          Transform.translate(
                            offset: Offset(
                              MediaQuery.of(context).size.width * 0.8 * (_shimmerController.value * 2 - 1),
                              0,
                            ),
                            child: Container(
                              width: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.0),
                                    Colors.white.withValues(alpha: 0.3),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
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
      },
    );
  }
}