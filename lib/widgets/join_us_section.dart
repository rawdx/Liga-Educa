import 'package:flutter/material.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_card.dart';

class JoinUsSection extends StatelessWidget {
  const JoinUsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LeagueCard(
      background: LeagueCardBackground.navy,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            '¡Únete a nuestra familia!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppBrandColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Forma parte de una liga que valora tanto el juego como la persona',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppBrandColors.white.withValues(alpha: 0.8),
                ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppBrandColors.greenDark,
                foregroundColor: AppBrandColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.person_add, size: 20),
              label: const Text(
                'Inscribirse Ahora',
                style: TextStyle(
                  fontSize: 16,
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
