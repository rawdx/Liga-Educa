import 'package:flutter/material.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_card.dart';

class NewsItemData {
  final String imagePath;
  final String tag;
  final String timeAgo;
  final String title;
  final String description;
  final String author;
  final String? content;

  const NewsItemData({
    required this.imagePath,
    required this.tag,
    required this.timeAgo,
    required this.title,
    required this.description,
    required this.author,
    this.content,
  });
}

class NewsCard extends StatelessWidget {
  final NewsItemData item;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LeagueCard(
      background: LeagueCardBackground.navy,
      padding: EdgeInsets.zero,
      onTap: onTap,
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
    );
  }
}
