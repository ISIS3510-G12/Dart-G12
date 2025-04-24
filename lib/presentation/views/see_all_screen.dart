import 'package:flutter/material.dart';
import '../view_models/see_all_view_model.dart';
import '../widgets/ovals_painter_home.dart';
import '../widgets/place_card.dart';
import '../widgets/bottom_navbar.dart';
import 'detail_card.dart';

class SeeAllScreen extends StatefulWidget {
  final int initialIndex;
  final String contentType;

  const SeeAllScreen(
      {super.key, this.initialIndex = 0, required this.contentType});

  @override
  SeeAllScreenState createState() => SeeAllScreenState();
}

class SeeAllScreenState extends State<SeeAllScreen> {
  late SeeAllViewModel _viewModel;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = SeeAllViewModel();
    _viewModel.contentType = widget.contentType;
    _viewModel.addListener(_updateState);

    if (widget.contentType == "building") {
      _viewModel.fetchBuildings();
    } else if (widget.contentType == "event") {
      _viewModel.fetchEvents();
    } else if (widget.contentType == "laboratory") {
      _viewModel.fetchLaboratories();
    } else if (widget.contentType == "access") {
      _viewModel.fetchAccess();
    } else if (widget.contentType == "favorite") {
      _viewModel.fetchFavorites();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateState);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: OvalsPainterHome())),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      widget.contentType == "building"
                          ? "Buildings"
                          : widget.contentType == "event"
                              ? "Events"
                              : widget.contentType == "laboratory"
                                  ? "Laboratories"
                                  : widget.contentType == "access"
                                      ? "Access Points"
                                      : widget.contentType == "favorite"
                                          ? "Favorites"
                                          : "Unknown",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: _viewModel.filterItems,
                    decoration: InputDecoration(
                      hintText: "Where to go?",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchCtrl.text.isEmpty
                          ? const Icon(Icons.filter_list)
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                _viewModel.filterItems('');
                              },
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _viewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _viewModel.error != null
                            ? Center(child: Text(_viewModel.error!))
                            : _viewModel.items.isEmpty
                                ? Center(
                                    child: Text(
                                        "No hay ${widget.contentType}s disponibles"))
                                : SingleChildScrollView(
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 600),
                                        child: Wrap(
                                          alignment: WrapAlignment.start,
                                          spacing: 16,
                                          runSpacing: 16,
                                          children:
                                              _viewModel.items.map((item) {
                                            String? subtitle;
                                            String? block;

                                            // Eventos o laboratorios: toman datos desde la relación con locations
                                            if (item['locations'] != null) {
                                              if (item['locations']['name'] !=
                                                  null) {
                                                subtitle =
                                                    item['locations']['name'];
                                              }
                                              if (item['locations']['block'] !=
                                                  null) {
                                                block =
                                                    item['locations']['block'];
                                              }
                                            }

                                            // Si es un building/location directo
                                            if (widget.contentType ==
                                                "building") {
                                              subtitle = null;
                                              if (item['block'] != null) {
                                                block = item['block'];
                                              }
                                            }

                                            return PlaceCard(
                                              imagePath: item['image_url'] ??
                                                  'assets/images/default_image.jpg',
                                              title: item['title'] ??
                                                  item['name'] ??
                                                  'Unknown ${widget.contentType}',
                                              subtitle: subtitle ?? '',
                                              block: block,
                                              onTap: () {
                                                if (widget.contentType ==
                                                    "building" || (widget.contentType ==
                                                    "favorite" && (item['type'] ?? '') == 'building') ) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailCard(
                                                        id: item['location_id'],
                                                        type: CardType.building,
                                                      ),
                                                    ),
                                                  );
                                                } else if (widget.contentType ==
                                                    "laboratory" || (widget.contentType ==
                                                    "favorite" && (item['type'] ?? '') == 'laboratories')) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailCard(
                                                        id: item[
                                                            'laboratories_id'],
                                                        type: CardType
                                                            .laboratories,
                                                      ),
                                                    ),
                                                  );
                                                } else if (widget.contentType ==
                                                    "access" ||(widget.contentType ==
                                                    "favorite" && (item['type'] ?? '') == 'access') ) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailCard(
                                                        id: item['access_id'],
                                                        type: CardType.access,
                                                      ),
                                                    ),
                                                  );
                                                } else if (widget.contentType ==
                                                    "event" || (widget.contentType ==
                                                    "favorite" && (item['type'] ?? '') == 'event') ) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailCard(
                                                        id: item['event_id'],
                                                        type: CardType.event,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.contentType == "favorite"
          ? null
          : BottomNavbar(
              currentIndex: _viewModel.selectedIndex,
              onTap: (index) => _viewModel.onItemTapped(context, index),
            ),
    );
  }
}
