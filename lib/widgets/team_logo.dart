import 'package:flutter/material.dart';
import 'package:liga_educa/theme.dart';

class TeamLogo extends StatelessWidget {
  final String? image;
  final double size;
  final double padding;
  final double borderRadius;
  final Color? backgroundColor;
  final IconData fallbackIcon;

  const TeamLogo({
    super.key,
    this.image,
    this.size = 44,
    this.padding = 4,
    this.borderRadius = 8,
    this.backgroundColor = Colors.white,
    this.fallbackIcon = Icons.shield,
  });

  @override
  Widget build(BuildContext context) {
    if (image == null || image!.isEmpty) {
      return _buildFallback();
    }

    final isNetwork = image!.startsWith('http');

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 1),
        child: isNetwork
            ? Image.network(
                image!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: size * 0.4,
                      height: size * 0.4,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              )
            : Image.asset(
                image!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
              ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppBrandColors.navy800,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        fallbackIcon,
        size: size * 0.6,
        color: AppBrandColors.white.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildErrorIcon() {
    return Center(
      child: Icon(
        fallbackIcon,
        size: size * 0.5,
        color: AppBrandColors.navy900.withValues(alpha: 0.3),
      ),
    );
  }
}
