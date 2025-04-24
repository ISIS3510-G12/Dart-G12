import 'package:dart_g12/presentation/views/detail_card.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String location;
  final String time;
  final String imageUrl;
  final int id;  // Agregamos el id del evento

  const NotificationCard({
    Key? key,
    required this.title,
    required this.location,
    required this.time,
    required this.imageUrl,
    required this.id,  // Recibimos el id del evento
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
        builder: (context) => DetailCard(
              id: id,  
              type: CardType.event, 
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl, // URL de la imagen
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()), // Indicador de carga
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/default_image.jpg', // Imagen por defecto
                  fit: BoxFit.cover,
                ),
                fit: BoxFit.cover,
                height: 120,
                width: 120,
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.black54),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
