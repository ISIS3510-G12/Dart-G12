import 'package:flutter/material.dart';
import 'package:dart_g12/presentation/view_models/card_detail_view_model.dart';
import 'package:dart_g12/presentation/widgets/transparent_ovals_painter.dart';
import 'package:dart_g12/presentation/widgets/bottom_navbar.dart';
import 'package:dart_g12/presentation/widgets/place_card.dart';

enum CardType { event, building, laboratories }

class DetailCard extends StatefulWidget {
  final int id;
  final CardType type;

  const DetailCard({super.key, required this.id, required this.type});

  @override
  State<DetailCard> createState() => _DetailCardState();
}

class _DetailCardState extends State<DetailCard> {
  late final CardDetailViewModel viewModel;

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
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final data = _getDataForType();
    final imageUrl = data['image'];
    final title = data['title'];
    final isEvent = widget.type == CardType.event;

    return Scaffold(
      body: Stack(
        children: [
          _buildHeaderImage(imageUrl, isEvent),
          Positioned.fill(
              child: CustomPaint(painter: TransparentOvalsPainter())),
          _buildTitle(title),
          Positioned(
              top: isEvent ? 220 : 200, left: 16, child: _buildActionButtons()),
          Positioned.fill(top: isEvent ? 300 : 280, child: _buildContent()),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: viewModel.selectedIndex,
        onTap: (index) => viewModel.onItemTapped(context, index),
      ),
    );
  }

  Map<String, dynamic> _getDataForType() {
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
        final lab = viewModel.laboratories.isNotEmpty
            ? viewModel.laboratories[0]
            : null;
        return {
          'image': lab?['url_image'],
          'title': lab?['name'] ?? '',
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
          image: imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(imageUrl), fit: BoxFit.cover)
              : null,
          color: Colors.grey[300],
        ),
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

  Widget _buildContent() {
    switch (widget.type) {
      case CardType.event:
        return _EventContent(viewModel: viewModel);
      case CardType.building:
        return _BuildingContent(viewModel: viewModel);
      case CardType.laboratories:
        return _LabContent(viewModel: viewModel);
    }
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
          icon: Icons.favorite_border,
          label: 'Favorites',
          onTap: () => print('Favorite pressed'),
        ),
      ],
    );
  }
}

// ========================
// COMPONENTES REUTILIZABLES
// ========================

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
      label: Text(
        label,
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEA1D5D),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

// ========================
// CONTENIDO PARA CADA TIPO
// ========================

class _EventContent extends StatelessWidget {
  final CardDetailViewModel viewModel;

  const _EventContent({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final event = viewModel.event;
    if (event == null) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event['start_time'] != null && event['end_time'] != null)
            _buildEventDates(event),
          const SizedBox(height: 16),
          if ((event['description'] ?? '').isNotEmpty)
            _buildTextBlock('Description:', event['description']),
        ],
      ),
    );
  }

  Widget _buildEventDates(Map<String, dynamic> event) {
    String format(String date) {
      try {
        final d = DateTime.parse(date);
        return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
            '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
      } catch (_) {
        return 'Invalid date';
      }
    }

    return _buildTextBlock(
      'Event Dates:',
      '🕒 Start: ${format(event['start_time'])}\n⏳ End: ${format(event['end_time'])}',
    );
  }
}

class _BuildingContent extends StatefulWidget {
  final CardDetailViewModel viewModel;

  const _BuildingContent({required this.viewModel});

  @override
  State<_BuildingContent> createState() => _BuildingContentState();
}

class _BuildingContentState extends State<_BuildingContent> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final building = widget.viewModel.building;
    final laboratories = widget.viewModel.laboratories;

    if (building == null)
      return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((building['address'] ?? '').isNotEmpty)
            _buildTextBlock('Address:', building['address']),
          if ((building['description'] ?? '').isNotEmpty)
            _buildTextBlock('Description:', building['description']),
          if ((building['opening_hours'] ?? '').isNotEmpty)
            _buildTextBlock('Opening Hours:', building['opening_hours']),
          if (laboratories.isNotEmpty) ...[
            const SizedBox(height: 24),

            // BARRA DE BÚSQUEDA SOLO ESTÉTICA
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
            const SizedBox(height: 0),

            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: laboratories.length,
                itemBuilder: (context, index) {
                  final lab = laboratories[index];
                  final location = lab['locations'] ?? {};

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
                      subtitle: location['name'] ?? '',
                      block: location['block'],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LabContent extends StatelessWidget {
  final CardDetailViewModel viewModel;

  const _LabContent({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.laboratories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final lab = viewModel.laboratories.first;
    final location = lab['locations'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextBlock('Location:', location['name'] ?? 'Unknown'),
          _buildTextBlock('Block:', location['block'] ?? 'Not specified'),
          _buildTextBlock(
              'Description:', lab['description'] ?? 'No description'),
        ],
      ),
    );
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
