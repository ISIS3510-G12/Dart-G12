import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlaceCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback? onTap; // Agregamos el callback opcional

  const PlaceCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.onTap, // parámetro opcional
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap, // Ejecuta el callback al tocar la tarjeta
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen con caché
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: imagePath, // Carga la imagen desde la URL
                    fit: BoxFit.cover,
                    height: 100,
                    width: 150,
                    placeholder: (context, url) => Container(), // No muestra ningún cargador
                    errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)), // Muestra un icono de error si falla la carga
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Subtítulo
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
