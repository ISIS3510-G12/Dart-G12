import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlaceCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback? onTap; // Agregamos el callback opcional

  const PlaceCard({
    required this.imagePath,
    required this.title,
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
                // Imagen
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: imagePath, // URL de la imagen
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()), // Indicador de carga mientras se descarga
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/default_image.jpg', // Imagen por defecto si falla la carga
                      fit: BoxFit.cover,
                    ),
                    fit: BoxFit.cover,
                    height: 100,
                    width: 150,
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
                      // Subtítulo (puedes agregar un subtítulo si lo deseas)
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
