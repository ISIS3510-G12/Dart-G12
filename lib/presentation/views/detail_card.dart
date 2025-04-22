import 'package:flutter/material.dart';
import 'package:dart_g12/presentation/view_models/card_detail_view_model.dart';
import 'package:dart_g12/presentation/widgets/transparent_ovals_painter.dart';
import 'package:dart_g12/presentation/widgets/bottom_navbar.dart';
import 'package:dart_g12/presentation/widgets/place_card.dart';

enum CardType {
  event,
  building,
}

class DetailCard extends StatefulWidget {
  final int id;
  final CardType type;

  const DetailCard({super.key, required this.id, required this.type});

  @override
  _DetailCardState createState() => _DetailCardState();
}

class _DetailCardState extends State<DetailCard> {
  late CombinedViewModel viewModel;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    viewModel = CombinedViewModel();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    switch (widget.type) {
      case CardType.event:
        await viewModel.fetchEventDetails(widget.id);
        break;
      case CardType.building:
        await viewModel.fetchBuildingDetails(widget.id);
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isEvent = widget.type == CardType.event;
    final imageUrl = isEvent
        ? (viewModel.event != null ? viewModel.event!['image_url'] : null)
        : (viewModel.building != null
            ? viewModel.building!['image_url']
            : null);

    final title = isEvent
        ? (viewModel.event != null ? viewModel.event!['title'] ?? '' : '')
        : (viewModel.building != null ? viewModel.building!['name'] ?? '' : '');

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: isEvent ? 280 : 260,
              decoration: BoxDecoration(
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey[300],
              ),
            ),
          ),

          // Fondo con óvalos
          Positioned.fill(
            child: CustomPaint(painter: TransparentOvalsPainter()),
          ),

          Positioned(
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
          ),

          Positioned(
            top: isEvent ? 220 : 200,
            left: 16,
            child: _buildActionButtons(),
          ),

          Positioned.fill(
            top: isEvent ? 300 : 280,
            child: _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: viewModel.selectedIndex,
        onTap: (index) => viewModel.onItemTapped(context, index),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.type == CardType.event) {
      return _buildEventContent();
    }
    if (widget.type == CardType.building) {
      return _buildBuildingContent();
    }
    return const SizedBox();
  }

  Widget _buildEventContent() {
    if (viewModel.event == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            if (viewModel.event?['start_time'] != null &&
                viewModel.event?['end_time'] != null)
              _buildEventDates(),
            const SizedBox(height: 16),
            if (viewModel.event?['description']?.isNotEmpty ?? false)
              _buildDescription(viewModel.event?['description'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingContent() {
    if (viewModel.building == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            if (viewModel.building?['address']?.isNotEmpty ?? false)
              _buildAddress(viewModel.building?['address'] ?? ''),
            const SizedBox(height: 16),
            if (viewModel.building?['description']?.isNotEmpty ?? false)
              _buildDescription(viewModel.building?['description'] ?? ''),
            const SizedBox(height: 16),
            if (viewModel.building?['opening_hours']?.isNotEmpty ?? false)
              _buildOpeningHours(viewModel.building?['opening_hours'] ?? ''),
            const SizedBox(height: 24),

            // Sección de lugares populares
            if (viewModel.places.isNotEmpty) ...[

              TextField(
                decoration: InputDecoration(
                  hintText: "Where to go?",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Popular Places',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 165,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: viewModel.places.length,
                  itemBuilder: (context, index) {
                    final place = viewModel.places[index];
                    return PlaceCard(
                      imagePath: place['url_image'] ?? '',
                      title: place['name'],
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () => viewModel.goToMapPage(context),
          label: const Text(
            'Indications',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          icon: const Icon(Icons.directions, size: 20, color: Colors.white),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEA1D5D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {
                if (viewModel.isFavorite) {
                   viewModel.removeFromFavorites();
                } else {
                  viewModel.addToFavorites();
                }

                setState(() {}); 
          },
          icon:
              const Icon(Icons.favorite_border, size: 20, color: Colors.white),
          label: const Text(
            'Favorites',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEA1D5D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildEventDates() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event Dates:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            '🕒 Start: ${formatDateTime(viewModel.event?['start_time'] ?? '')}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            '⏳ End: ${formatDateTime(viewModel.event?['end_time'] ?? '')}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildAddress(String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          address,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildOpeningHours(String openingHours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Opening Hours:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          openingHours,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  String formatDateTime(String dateTime) {
    try {
      final DateTime parsedDate = DateTime.parse(dateTime);
      return '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}'
          ' ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
