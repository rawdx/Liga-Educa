import 'package:flutter/material.dart';
import 'package:liga_educa/theme.dart';

enum LeagueCardBackground { normal, accent, highlight, navy }

class LeagueCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final LeagueCardBackground background;
  final Color? backgroundColorOverride;
  final double borderAlpha;

  const LeagueCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.onTap,
    this.background = LeagueCardBackground.normal,
    this.backgroundColorOverride,
    this.borderAlpha = 0.22,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Gradient? base;
    switch (background) {
      case LeagueCardBackground.accent:
        base = const LinearGradient(
          colors: [AppBrandColors.greenDark, AppBrandColors.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      default:
        base = null;
        break;
    }
    
    final Color? backgroundColor;
    if (base != null) {
      backgroundColor = null;
    } else if (backgroundColorOverride != null) {
      backgroundColor = backgroundColorOverride;
    } else if (background == LeagueCardBackground.highlight) {
      backgroundColor = cs.secondary.withValues(alpha: 0.65);
    } else if (background == LeagueCardBackground.navy) {
      backgroundColor = AppBrandColors.navy800;
    } else {
      backgroundColor = cs.surfaceContainerHighest.withValues(alpha: 0.45);
    }

    final content = Padding(padding: padding, child: child);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: base,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: content,
        ),
      ),
    );
  }
}