import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlaceCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String? block;
  final VoidCallback? onTap;

  const PlaceCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.block,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 150;
    const double imageHeight = 100;
    const BorderRadius cardRadius = BorderRadius.all(Radius.circular(12));

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: cardRadius),
          child: SizedBox(
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen con carga remota y fallback local
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: imagePath,
                    height: imageHeight,
                    width: cardWidth,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const SizedBox(
                      height: imageHeight,
                      width: cardWidth,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, __, ___) => Image.asset(
                      'assets/images/default_image.jpg',
                      height: imageHeight,
                      width: cardWidth,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Texto
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _CardText(title: title, subtitle: subtitle, block: block),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardText extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? block;

  const _CardText({
    required this.title,
    required this.subtitle,
    this.block,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle subtitleStyle = TextStyle(
      color: Colors.grey[700],
      fontSize: 12,
    );
    final TextStyle blockStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: 12,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          subtitle,
          style: subtitleStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (block case final b? when b.trim().isNotEmpty)
          Text(
            'Bloque: $b',
            style: blockStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}
