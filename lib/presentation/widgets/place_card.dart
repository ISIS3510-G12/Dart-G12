import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../data/services/image_lru_cache.dart';
class PlaceCard extends StatefulWidget {
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
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  Uint8List? _imageBytes;
  bool _loading = true;
  final _cache = ImageCacheLRU();

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await _cache.loadImage(widget.imagePath);
      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _loading = false;
        });
      }
    } catch (_) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: _loading
                      ? const SizedBox(
                          height: 100,
                          width: 150,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : (_imageBytes != null
                          ? Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                              height: 100,
                              width: 150,
                            )
                          : Image.asset(
                              'assets/images/default_image.jpg',
                              fit: BoxFit.cover,
                              height: 100,
                              width: 150,
                            )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.block != null && widget.block!.isNotEmpty)
                        Text(
                          'Bloque: ${widget.block}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
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
