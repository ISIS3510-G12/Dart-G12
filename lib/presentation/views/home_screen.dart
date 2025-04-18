import 'package:dart_g12/presentation/widgets/card.dart';
import 'package:dart_g12/presentation/widgets/chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';
import '../widgets/ovals_painter.dart';
import '../widgets/section_header.dart';
import '../widgets/place_card.dart';
import '../widgets/category_list.dart';
import 'see_all_screen.dart';
import '../widgets/card_event.dart';

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
                    const ChatWidget(),
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
                            SectionHeader(
                              title: "Buildings",
                              destinationScreen: () =>
                                  SeeAllScreen(contentType: "building"),
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
                                            'assets/images/default_image.jpg',
                                        title: location['title_or_name'] ??
                                            'Unknown Location',
                                        onTap: () {
                                          if (location['location_id'] != null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CardScreen(
                                                        buildingId: location[
                                                            'location_id']),
                                              ),
                                            );
                                          } else if (location['event_id'] !=
                                              null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => CardEvent(
                                                    eventId:
                                                        location['event_id']),
                                              ),
                                            );
                                          } else {
                                            // Manejo opcional si no hay ningún ID válido
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "No se puede abrir esta tarjeta")),
                                            );
                                          }
                                        },
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Sección Buildings
                            SectionHeader(
                              title: "Buildings",
                              destinationScreen: () =>
                                  SeeAllScreen(contentType: "building"),
                            ),

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
                                        imagePath: location['image_url'] ??
                                            'assets/images/default_image.jpg',
                                        title: location['name'] ??
                                            'Unknown Location',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CardScreen(
                                                  buildingId: location['id']),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Sección Events
                            SectionHeader(
                              title: "Buildings",
                              destinationScreen: () =>
                                  SeeAllScreen(contentType: "event"),
                            ),

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
                                        imagePath: recommendation[
                                                'image_url'] ??
                                            'assets/images/default_image.jpg',
                                        title: recommendation['title'] ??
                                            'Unknown Event',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CardEvent(
                                                  eventId:
                                                      recommendation['id']),
                                            ),
                                          );
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
