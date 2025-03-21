import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';
import '../widgets/ovals_painter.dart';
import '../widgets/section_header.dart';
import '../widgets/place_card.dart'; 
import '../widgets/category_list.dart'; // Asegúrate de importar el nuevo widget
import 'see_all_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = HomeViewModel();
        viewModel.loadUserName();  
        viewModel.loadUserAvatar(); 
        viewModel.loadLocations(); // Cargar ubicaciones
        viewModel.loadRecommendations(); // Cargar recomendaciones
        viewModel.loadMostSearchedLocation(); // Cargar el lugar más buscado
        return viewModel;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: OvalsPainter(),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Saludo y foto de perfil
                    Consumer<HomeViewModel>(
                      builder: (context, viewModel, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hi, ${viewModel.userName}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: viewModel.avatarUrl != null
                                  ? NetworkImage(viewModel.avatarUrl!)
                                  : const AssetImage('assets/profile.jpg') as ImageProvider,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Barra de búsqueda
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
                    const SizedBox(height: 16),

                    // Categorías
                    const CategoryList(),  // Usando el widget CategoryList

                    const SizedBox(height: 16),

                    // Sección del lugar más buscado
                    Consumer<HomeViewModel>(
                      builder: (context, viewModel, child) {
                        final location = viewModel.mostSearchedLocation;
                        if (location == null) {
                          return const SizedBox(); // No mostrar nada si no hay datos
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PlaceCard(
                              imagePath: location['image_url'],
                              title: location['name'],
                              subtitle: location['description'],
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Sección de "Buildings"
                    const SectionHeader(title: "Buildings", destinationScreen: SeeAllScreen()),
                    SizedBox(
                      height: 180, // Evitar el desbordamiento
                      child: Consumer<HomeViewModel>(
                        builder: (context, viewModel, child) {
                          if (viewModel.locations.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return ListView(
                            scrollDirection: Axis.horizontal,
                            children: viewModel.locations.map((location) {
                              return PlaceCard(
                                imagePath: location['image_url'],
                                title: location['name'],
                                subtitle: location['description'],
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sección de "Recommendations"
                    const SectionHeader(title: "Recommendations", destinationScreen: SeeAllScreen()),
                    SizedBox(
                      height: 180,
                      child: Consumer<HomeViewModel>(
                        builder: (context, viewModel, child) {
                          if (viewModel.recommendations.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return ListView(
                            scrollDirection: Axis.horizontal,
                            children: viewModel.recommendations.map((recommendation) {
                              return PlaceCard(
                                imagePath: recommendation['image_url'],
                                title: recommendation['title'],
                                subtitle: recommendation['description'],
                                onTap: () {
                                  viewModel.onRecommendationTap(recommendation);
                                },
                              );
                            }).toList(),
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
      ),
    );
  }
}
