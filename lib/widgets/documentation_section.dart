import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liga_educa/theme.dart';
import 'package:liga_educa/widgets/league_card.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class DocumentationSection extends StatelessWidget {
  const DocumentationSection({super.key});

  Future<void> _openPdf(BuildContext context, String assetPath, String fileName) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');

      if (!await file.exists()) {
        final data = await rootBundle.load(assetPath);
        final bytes = data.buffer.asUint8List();
        await file.writeAsBytes(bytes, flush: true);
      }

      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo abrir el archivo: ${result.message}'),
              backgroundColor: AppBrandColors.greenDark,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar el documento'),
            backgroundColor: AppBrandColors.greenDark,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitleColor = AppBrandColors.white.withValues(alpha: 0.7);
    final dividerColor = AppBrandColors.white.withValues(alpha: 0.1);
    
    return LeagueCard(
      background: LeagueCardBackground.navy,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm + 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppBrandColors.greenDark, AppBrandColors.green],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.folder_shared_rounded,
                    color: AppBrandColors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Documentación Oficial',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppBrandColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              height: 1.2,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Consulta el reglamento y las guías oficiales.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: subtitleColor,
                              fontSize: 13,
                              height: 1.3,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Divider(
            height: 1,
            color: dividerColor,
          ),

          // Action Items
          _DocTile(
            title: 'Normativa Liga Educa',
            subtitle: 'Reglamento y bases de la temporada',
            icon: Icons.gavel_rounded,
            subtitleColor: subtitleColor,
            onTap: () => _openPdf(
              context, 
              'assets/docs/Normativa_LigaEduca.pdf', 
              'Normativa_LigaEduca.pdf'
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 1,
              color: dividerColor,
            ),
          ),

          _DocTile(
            title: 'Ubicación e Indumentaria',
            subtitle: 'Sedes y guía de equipación oficial',
            icon: Icons.stadium_rounded,
            subtitleColor: subtitleColor,
            isLast: true,
            onTap: () => _openPdf(
              context, 
              'assets/docs/UbicacionIndumentaria_LigaEduca.pdf', 
              'UbicacionIndumentaria_LigaEduca.pdf'
            ),
          ),
        ],
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color subtitleColor;
  final bool isLast;

  const _DocTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.subtitleColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppBrandColors.green;
    return InkWell(
      onTap: onTap,
      borderRadius: isLast 
        ? const BorderRadius.vertical(bottom: Radius.circular(AppRadius.lg))
        : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm + 2),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppBrandColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: subtitleColor,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.file_download_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
