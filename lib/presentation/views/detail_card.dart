import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dart_g12/presentation/view_models/card_detail_view_model.dart';
import 'package:dart_g12/presentation/widgets/transparent_ovals_painter.dart';
import 'package:dart_g12/presentation/widgets/bottom_navbar.dart';
import 'package:dart_g12/presentation/widgets/place_card.dart';

enum CardType { event, building, laboratories, access, auditorium, library}

class DetailCard extends StatefulWidget {
  final int id;
  final CardType type;

  const DetailCard({super.key, required this.id, required this.type});

  @override
  State<DetailCard> createState() => _DetailCardState();
}

class _DetailCardState extends State<DetailCard> {
  late final CardDetailViewModel viewModel;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    viewModel = CardDetailViewModel();
    _loadData();
  }


  Future<void> _loadData() async {
    switch (widget.type) {
      case CardType.event:
        await viewModel.fetchEventDetails(widget.id);
        break;
      case CardType.building:
        await viewModel.fetchBuildingDetails(widget.id);
        break;
      case CardType.laboratories:
        await viewModel.fetchLaboratoryDetails(widget.id);
        break;
      case CardType.access:
        await viewModel.fetchAccessDetails(widget.id);
        break;
      case CardType.auditorium:
        await viewModel.fetchAuditoriumDetails(widget.id); 
        break;
      case CardType.library:
        await viewModel.fetchLibraryDetails(widget.id); 
        break;
    }
    isFavorite = await viewModel.isFavorite(widget.id.toString());
    setState(() {});
  }

 Map<String, dynamic> _prepareFavoriteItem() {
    switch (widget.type) {
      case CardType.event:
        final e = viewModel.event ?? {};
        return {
          ...e,
          'type': 'event',
          'event_id': widget.id,
          'title': e['name'] ?? '',
          'image': e['image_url'],
          'start_time': e['start_time'],
        };
      case CardType.building:
        final b = viewModel.building ?? {};
        return {
          ...b,
          'type': 'building',
          'location_id': widget.id,
          'name': b['name'] ?? '',
          'image': b['image_url'],
          'block': b['block'],
        };
      case CardType.laboratories:
        final l = viewModel.laboratories.isNotEmpty
            ? viewModel.laboratories[0]
            : {};
        return {
          ...l,
          'type': 'laboratories',
          'laboratories_id': widget.id,
          'name': l['name'] ?? '',
          'image': l['image_url'],
          'block': l['locations']?['block'],
        };
      case CardType.access:
        final a = viewModel.access.isNotEmpty
            ? viewModel.access[0]
            : {};
        return {
          ...a,
          'type': 'access',
          'access_id': widget.id,
          'name': a['name'] ?? '',
          'image': a['image_url'],
          'block': a['locations']?['block'],
        };
      case CardType.auditorium:
        final au = viewModel.autorium.isNotEmpty
            ? viewModel.autorium[0]
            : {};
        return {
          ...au,
          'type': 'auditorium',
          'auditorium_id': widget.id,
          'name': au['name'] ?? '',
          'image': au['image_url'],
        };
      case CardType.library:
        final lib = viewModel.library.isNotEmpty
            ? viewModel.library[0]
            : {};
        return {
          ...lib,
          'type': 'library',
          'library_id': widget.id,
          'name': lib['name'] ?? '',
          'image': lib['image_url'],
        };
    }
  }

  void _toggleFavorite() async {
    final item = _prepareFavoriteItem();
    item['id'] = widget.id;
    final result = await viewModel.toggleFavorite(
      widget.id.toString(),
      item,
    );

    setState(() {
      isFavorite = result;
      log('Favorito: $isFavorite');
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _getData();
    final imageUrl = data['image'];
    final title = data['title'];
    final isEvent = widget.type == CardType.event;

    return Scaffold(
      body: Stack(
        children: [
          _buildHeaderImage(imageUrl, isEvent),
          Positioned.fill(child: CustomPaint(painter: TransparentOvalsPainter())),
          _buildTitle(title),
          Positioned(
              top: isEvent ? 220 : 200, left: 16, child: _buildActionButtons()),
          Positioned.fill(
              top: isEvent ? 300 : 280,
              child: ContentSection(viewModel: viewModel, type: widget.type)),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: viewModel.selectedIndex,
        onTap: (index) => viewModel.onItemTapped(context, index),
      ),
    );
  }

  Map<String, dynamic> _getData() {
    switch (widget.type) {
      case CardType.event:
        final e = viewModel.event;
        return {
          'image': e?['image_url'],
          'title': e?['name'] ?? '',
        };
      case CardType.building:
        final b = viewModel.building;
        return {
          'image': b?['image_url'],
          'title': b?['name'] ?? '',
        };
      case CardType.laboratories:
        final l = viewModel.laboratories.isNotEmpty
            ? viewModel.laboratories[0]
            : null;
        return {
          'image': l?['image_url'],
          'title': l?['name'] ?? '',
        };
      case CardType.access:
        final a = viewModel.access.isNotEmpty ? viewModel.access[0] : null;
        return {
          'image': a?['image_url'],
          'title': a?['name'] ?? '',
        };
      case CardType.auditorium:
        final au = viewModel.autorium.isNotEmpty ? viewModel.autorium[0] : null;
        return {
          'image': au?['image_url'],
          'title': au?['name'] ?? '',

        };
      case CardType.library:
        final lib = viewModel.library.isNotEmpty ? viewModel.library[0] : null;
        return {
          'image': lib?['image_url'],
          'title': lib?['name'] ?? '',
        };
    }
  }

  Widget _buildHeaderImage(String? imageUrl, bool isEvent) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: isEvent ? 280 : 260,
        decoration: BoxDecoration(
          color: Colors.grey[300],
        ),
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
            : null,
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Positioned(
      top: 48,
      left: 16,
      right: 16,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 6, color: Colors.black)],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _ActionButton(
          icon: Icons.directions,
          label: 'Indications',
          onTap: () => viewModel.goToMapPage(context),
        ),
        const SizedBox(width: 12),
        _ActionButton(
          icon: isFavorite ? Icons.favorite : Icons.favorite_border,
          label: isFavorite ? 'Favorited' : 'Favorites',
          onTap: _toggleFavorite
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: Colors.white),
      label: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEA1D5D),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

class ContentSection extends StatelessWidget {
  final CardDetailViewModel viewModel;
  final CardType type;

  const ContentSection({required this.viewModel, required this.type});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _searchCtrl = TextEditingController();
    final event = viewModel.event;
    final building = viewModel.building;
    final labs = viewModel.laboratories;
    final access = viewModel.access;
    final auditorium = viewModel.autorium;
    final library = viewModel.library;

    if ((type == CardType.event && event == null) ||
        (type == CardType.building && building == null) ||
        (type == CardType.laboratories && labs.isEmpty) ||
        (type == CardType.access && access.isEmpty) ||
        (type == CardType.auditorium && auditorium.isEmpty) ||
        (type == CardType.library && library.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    final Map<String, dynamic>? data = type == CardType.event
        ? event
        : type == CardType.building
            ? building
            : type == CardType.laboratories
                ? labs.first
                : type == CardType.access
                    ? access.first
                    : type == CardType.auditorium
                        ? auditorium.first
                        : library.first;
                        

    final Map<String, dynamic>? location = data?['locations'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (type == CardType.event &&
            event?['start_time'] != null &&
            event?['end_time'] != null)
          _buildTextBlock('Event Dates:',
              '🕒 Start: ${_formatDate(event!['start_time'])}\n⏳ End: ${_formatDate(event['end_time'])}'),
        if (data?['description'] != null)
          _buildTextBlock('Description:', data!['description']),
        if (data?['address'] != null)
          _buildTextBlock('Address:', data!['address']),
        if (data?['opening_hours'] != null)
          _buildTextBlock('Opening Hours:', data!['opening_hours']),
        if(location?['name'] != null)
          _buildTextBlock('Location:', location!['name']),
        if (location?['block'] != null)
          _buildTextBlock('Block:', location!['block']),
        if(data?["location"] !=null)
          _buildTextBlock('Location:', data!['location']),
        // Mostrar Laboratorios si existen
        if (labs.isNotEmpty && type != CardType.laboratories) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _searchCtrl,
            readOnly: true,
            decoration: InputDecoration(
              hintText: "Where to go?",
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: const Icon(Icons.filter_list),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextBlock('Laboratories:', ''),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: labs.length,
              itemBuilder: (context, index) {
                final lab = labs[index];
                final loc = lab['locations'] ?? {};
                return GestureDetector(
                  onTap: () {
                    if (lab['laboratories_id'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailCard(
                            id: lab['laboratories_id'],
                            type: CardType.laboratories,
                          ),
                        ),
                      );
                    }
                  },
                  child: PlaceCard(
                    imagePath:
                        lab['url_image'] ?? 'assets/images/default_image.jpg',
                    title: lab['name'] ?? 'Unknown Lab',
                    subtitle: loc['name'] ?? '',
                    block: loc['block'],
                  ),
                );
              },
            ),
          ),
        ],
        // Mostrar Access Points si existen
        if (access.isNotEmpty && type != CardType.access) ...[
          const SizedBox(height: 16),
          _buildTextBlock('Access Points:', ''),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: access.length,
              itemBuilder: (context, index) {
                final acc = access[index];
                final loc = acc['locations'] ?? {};
                return GestureDetector(
                  onTap: () {
                    if (acc['access_id'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailCard(
                            id: acc['access_id'],
                            type: CardType.access,
                          ),
                        ),
                      );
                    }
                  },
                  child: PlaceCard(
                    imagePath:
                        acc['url_image'] ?? 'assets/images/default_image.jpg',
                    title: acc['name'] ?? 'Unknown Access Point',
                    subtitle: loc['name'] ?? '',
                    block: loc['block'],
                  ),
                );
              },
            ),
          ),
        ],
      ]), // End of Column
    );
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
          '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'Invalid date';
    }
  }

  Widget _buildTextBlock(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(content, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 16),
      ],
    );
  }
}
