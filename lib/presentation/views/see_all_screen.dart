import 'package:flutter/material.dart';
import '../view_models/see_all_view_model.dart';
import '../widgets/ovals_painter.dart';
import '../widgets/place_card.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/card.dart';

class SeeAllScreen extends StatefulWidget {
  final int initialIndex;

  const SeeAllScreen({super.key, this.initialIndex = 0});

  @override
  SeeAllScreenState createState() => SeeAllScreenState();
}

class SeeAllScreenState extends State<SeeAllScreen> {
  late SeeAllViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SeeAllViewModel();
    _viewModel.fetchBuildings();
    _viewModel.addListener(_updateState);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateState);
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
          Positioned.fill(child: CustomPaint(painter: OvalsPainter())),
          Positioned(
            top: 50,
            left: MediaQuery.of(context).size.width / 2 - 65,
            child: Text(
              "Buildings",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
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
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _viewModel.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _viewModel.error != null
                                  ? Center(child: Text(_viewModel.error!))
                                  : _viewModel.buildings.isEmpty
                                      ? const Center(child: Text("No hay edificios disponibles"))
                                      : GridView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.all(16.0),
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 16.0,
                                            mainAxisSpacing: 16.0,
                                            childAspectRatio: 0.9,
                                          ),
                                          itemCount: _viewModel.buildings.length,
                                          itemBuilder: (context, index) {
                                            final building = _viewModel.buildings[index];
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => CardScreen(buildingId: building['id']),
                                                  ),
                                                );
                                              },
                                              child: PlaceCard(
                                                imagePath: building['image_url'] ?? '',
                                                title: building['name'],
                                                subtitle: building['description'] ?? 'Sin descripción',
                                              ),
                                            );
                                          },
                                        ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _viewModel.selectedIndex,
        onTap: (index) => _viewModel.onItemTapped(
          context,
          index,
        ),
      ),
    );
  }
}
