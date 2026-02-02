import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_card.dart';
import 'package:url_launcher/url_launcher.dart';

class SponsorFooter extends StatelessWidget {
  const SponsorFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return LeagueCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      backgroundColorOverride: AppBrandColors.navy900,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              launchUrl(Uri.parse('https://www.soccerfactory.es/'));
            },
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Image.asset(
                'assets/images/sponsor.gif',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SvgPicture.asset(
            'assets/images/logos/LOGO LIGA EDUCA VERTICAL BLANCO.svg',
            height: 160,
          ),
          const SizedBox(height: AppSpacing.lg),
          InkWell(
            onTap: () {
              launchUrl(Uri.parse('https://www.educationleague.es'));
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 4.0),
              child: Text(
                'www.educationleague.es',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppBrandColors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
