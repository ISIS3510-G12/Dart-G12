import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';
import '../widgets/ovals_painter.dart';
import '../widgets/section_header.dart';
import '../widgets/place_card.dart';
import '../widgets/category_list.dart';
import '../widgets/chat_widget.dart';
import 'see_all_screen.dart';
import 'detail_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeViewModel>(
      create: (_) {
        final viewModel = HomeViewModel();
        viewModel.loadAllData();
        return viewModel;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: OvalsPainter()),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    const ChatWidget(),
                    const SizedBox(height: 16),
                    const CategoryList(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildContent(context), // Pasamos context aquí
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

  Widget _buildHeader() {
    return Consumer<HomeViewModel>(builder: (context, viewModel, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hi, ${viewModel.userName}',
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          CircleAvatar(
            radius: 24,
            backgroundImage: viewModel.avatarUrl != null
                ? NetworkImage(viewModel.avatarUrl!)
                : const AssetImage('assets/images/profile.jpg')
                    as ImageProvider,
          ),
        ],
      );
    });
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            "Most Popular",
            SeeAllScreen(contentType: "building"),
            context,
            (viewModel) {
              return _buildHorizontalList(
                viewModel.mostSearchedLocations,
                context,
              );
            },
          ),
          _buildSection(
            "Buildings",
            SeeAllScreen(contentType: "building"),
            context,
            (viewModel) {
              return _buildHorizontalList(
                viewModel.locations,
                context,
              );
            },
          ),
          _buildSection(
            "Laboratories", // Nueva sección para los laboratorios
            SeeAllScreen(contentType: "laboratory"),
            context,
            (viewModel) {
              return _buildHorizontalList(
                viewModel.laboratories,
                context,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget destinationScreen,
      BuildContext context, Widget Function(HomeViewModel) builder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, destinationScreen: destinationScreen),
        Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            return builder(viewModel);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHorizontalList(List<dynamic> items, BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: items.map((item) {
          String? subtitle;
          String? block;

          if (item['locations'] != null) {
            if (item['locations']['name'] != null) {
              subtitle = item['locations']['name'];
            }
            if (item['locations']['block'] != null) {
              block = item['locations']['block'];
            }
          }

          if (item['block'] != null && subtitle == null) {
            subtitle = '';
            block = item['block'];
          }

          return PlaceCard(
            imagePath: item['image_url'] ?? 'assets/images/default_image.jpg',
            subtitle: subtitle ?? '',
            title: item['name'] ?? 'Unknown Location',
            block: block,
            onTap: () {
              // Chequeamos qué tipo de contenido es y navegamos
              if (item['location_id'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailCard(
                      id: item['location_id'],
                      type: CardType.building,
                    ),
                  ),
                );
              }  else if (item['laboratories_id'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailCard(
                      id: item['laboratories_id'],
                      type: CardType.laboratories,
                    ),
                  ),
                );
              }
            },
          );
        }).toList(),
      ),
    );
  }
}
