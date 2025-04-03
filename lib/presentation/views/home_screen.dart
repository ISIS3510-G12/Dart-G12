import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';
import '../widgets/ovals_painter.dart';
import '../widgets/section_header.dart';
import '../widgets/place_card.dart';
import '../widgets/category_list.dart';
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
        viewModel.loadLocations();
        viewModel.loadRecommendations();
        viewModel.loadMostSearchedLocations();
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
                                  : const AssetImage(
                                          'assets/images/profile.jpg')
                                      as ImageProvider,
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
                    const CategoryList(),
                    const SizedBox(height: 16),

                    // ScrollView
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sección Most Popular
                            const SectionHeader(
                              title: "Most Popular",
                              destinationScreen: SeeAllScreen(),
                            ),
                            SizedBox(
                              height: 180,
                              child: Consumer<HomeViewModel>(
                                builder: (context, viewModel, child) {
                                  if (viewModel.mostSearchedLocations.isEmpty) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: viewModel.mostSearchedLocations
                                        .map((location) {
                                      return PlaceCard(
                                        imagePath: location['image_url'] ??
                                            'assets/default_image.png',
                                        title: location['location_name'] ??
                                            'Unknown Location',
                                        subtitle: location['description'] ??
                                            'No description available',
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Sección Buildings
                            const SectionHeader(
                                title: "Buildings",
                                destinationScreen: SeeAllScreen()),
                            SizedBox(
                              height: 180,
                              child: Consumer<HomeViewModel>(
                                builder: (context, viewModel, child) {
                                  if (viewModel.locations.isEmpty) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return ListView(
                                    scrollDirection: Axis.horizontal,
                                    children:
                                        viewModel.locations.map((location) {
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

                            // Sección Recommendations
                            const SectionHeader(
                                title: "Events",
                                destinationScreen: SeeAllScreen()),
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
                                    children: viewModel.recommendations
                                        .map((recommendation) {
                                      return PlaceCard(
                                        imagePath: recommendation['image_url'],
                                        title: recommendation['title'],
                                        subtitle: recommendation['description'],
                                        onTap: () {
                                          viewModel.onRecommendationTap(
                                              recommendation);
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
            ),
          ],
        ),
      ),
    );
  }
}
