import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/OvalsPainter.dart';
import '../view_models/home_view_model.dart';
import '../widgets/place_card.dart'; // Asegúrate de que el widget PlaceCard esté importado
import '../widgets/section_header.dart'; // Asegúrate de que el widget SectionHeader esté importado
import '../widgets/category_icon.dart'; // Asegúrate de que el widget CategoryIcon esté importado

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
                    SizedBox(
                      height: 60,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          CategoryIcon(icon: Icons.business, label: "Buildings"),
                          CategoryIcon(icon: Icons.event, label: "Events"),
                          CategoryIcon(icon: Icons.restaurant, label: "Food & Rest"),
                          CategoryIcon(icon: Icons.school, label: "Study Spaces"),
                          CategoryIcon(icon: Icons.build, label: "Services"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16), // Espacio entre categorías y la sección "Buildings"

                    // Sección de "Buildings"
                    const SectionHeader(title: "Buildings"),
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
                                imagePath: location['image_url'], // Asegúrate de que `image_url` esté correcto
                                title: location['name'],
                                subtitle: location['description'],
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16), // Espacio entre las secciones

                    // Sección de "Recommendations"
                    const SectionHeader(title: "Recommendations"),
                    SizedBox(
                      height: 180, // Evitar el desbordamiento
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
                                imagePath: recommendation['image_url'], // Asegúrate de que `image_url` esté correcto
                                title: recommendation['title'],
                                subtitle: recommendation['description'],
                                onTap: () {
                                  // Agrega la acción al tocar la tarjeta
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
