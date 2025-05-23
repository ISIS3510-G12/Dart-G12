import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../view_models/see_all_view_model.dart';
import '../widgets/ovals_painter_home.dart';
import '../widgets/place_card.dart';
import '../widgets/bottom_navbar.dart';
import '../../data/services/analytics_service.dart';
import 'detail_card.dart';
import 'filter_page.dart';

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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _viewModel = SeeAllViewModel();
    _viewModel.contentType = widget.contentType;
    _viewModel.addListener(_updateState);

    AnalyticsService.logConsultSeeAll(content_Type: widget.contentType);

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
    } else if (widget.contentType == "auditorium") {
      _viewModel.fetchAuditoriums();
    } else if (widget.contentType == "library") {
      _viewModel.fetchLibraries();
    } else if (widget.contentType == "services") {
      _viewModel.fetchServices();
    } else if (widget.contentType == "faculty") {
      _viewModel.fetchFaculties();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _viewModel.removeListener(_updateState);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _viewModel.filterItems(value);
    });
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
                                          : widget.contentType == "auditorium"
                                              ? "Auditoriums"
                                              : widget.contentType == "library"
                                                  ? "Libraries"
                                                : widget.contentType == "services"
                                                    ? "Services"
                                                    : widget.contentType == "faculty"
                                                        ? "Faculties"
                                                        : "Unknown",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.contentType != "favorite")
                    TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearchChanged,
                    maxLength: 20,
                    decoration: InputDecoration(
                      hintText: "Where to go?",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchCtrl.text.isEmpty
                          ? IconButton(
                            icon: const Icon(Icons.filter_alt_outlined),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => ChangeNotifierProvider.value(
                                value: _viewModel,
                                child: FilterScreen(contentType: widget.contentType),
                                ),
                                );
                              },
                          )
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
                                                } else if (widget.contentType ==
                                                    "auditorium" || (widget.contentType ==
                                                    "favorite" && (item['type'] ?? '') == 'auditorium') ) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailCard(
                                                        id: item['auditorium_id'],
                                                        type: CardType.auditorium,
                                                      ),
                                                    ),
                                                  );
                                                } else if (widget.contentType ==
                                                    "library" || (widget.contentType ==
                                                    "favorite" && (item['type'] ?? '') == 'library') ) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailCard(
                                                        id: item['library_id'],
                                                        type: CardType.library,
                                                      ),
                                                    ),
                                                  );
                                                } else if (widget.contentType ==
                                                    "services" || (widget.contentType ==
                                                    "favorite" && (item['type'] ?? '') == 'services') ) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailCard(
                                                        id: item['service_id'],
                                                        type: CardType.services,
                                                      ),
                                                    ),
                                                  );
                                                } else if (widget.contentType ==
                                                    "faculty" || (widget.contentType ==
                                                    "favorite" && (item['type'] ?? '') == 'faculty') ) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailCard(
                                                        id: item['faculty_id'],
                                                        type: CardType.faculty,
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
