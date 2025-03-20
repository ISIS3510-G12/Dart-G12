import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/OvalsPainter.dart';
import '../widgets/card.dart';
import '../view_models/see_all_view_model.dart';
import '../widgets/place_card.dart';

class SeeAllScreen extends StatefulWidget {
  const SeeAllScreen({super.key});

  @override
  _SeeAllScreenState createState() => _SeeAllScreenState();
}

class _SeeAllScreenState extends State<SeeAllScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<SeeAllViewModel>(context, listen: false).fetchBuildings());
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SeeAllViewModel>(context);

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
                    child: // Barra de búsqueda
                    TextField(
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
                    child: viewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : viewModel.error != null
                        ? Center(child: Text(viewModel.error!))
                        : viewModel.buildings.isEmpty
                        ? const Center(child: Text("No hay edificios disponibles"))
                        : GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                      ),
                      itemCount: viewModel.buildings.length,
                      itemBuilder: (context, index) {
                        final building = viewModel.buildings[index];

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
                            imagePath: building['image_url'] ?? '', // URL de la imagen o vacío si no tiene
                            title: building['name'],
                            subtitle: building['description'] ?? 'Sin descripción',
                          ),

                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
