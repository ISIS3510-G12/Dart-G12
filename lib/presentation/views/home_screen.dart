import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';
import '../widgets/ovals_painter.dart';
import '../widgets/section_header.dart';
import '../widgets/place_card.dart';
import '../widgets/category_list.dart';
import '../widgets/chat_widget.dart';
import 'see_all_screen.dart';
import '../widgets/card_event.dart';
import '../widgets/card.dart';

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
                    Expanded(child: _buildContent(context)), // Pasamos context aquí
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
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          CircleAvatar(
            radius: 24,
            backgroundImage: viewModel.avatarUrl != null
                ? NetworkImage(viewModel.avatarUrl!)
                : const AssetImage('assets/images/profile.jpg') as ImageProvider,
          ),
        ],
      );
    });
  }

  Widget _buildContent(BuildContext context) { // context ya está definido aquí
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection("Most Popular", SeeAllScreen(contentType: "building",), context, (viewModel) {
            return _buildHorizontalList(viewModel.mostSearchedLocations, context);
          }),
          _buildSection("Buildings", SeeAllScreen(contentType: "building",), context, (viewModel) {
            return _buildHorizontalList(viewModel.locations, context);
          }),
          _buildSection("Events", SeeAllScreen(contentType: "event"), context, (viewModel) {
            return _buildHorizontalList(viewModel.recommendations, context, isEvent: true);
          }),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget destinationScreen, BuildContext context, Widget Function(HomeViewModel) builder) {
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

  Widget _buildHorizontalList(List<dynamic> items, BuildContext context, {bool isEvent = false}) {
    if (items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: items.map((item) {
          return PlaceCard(
            imagePath: item['image_url'] ?? 'assets/images/default_image.jpg',
            title: item['title_or_name'] ?? item['title'] ?? item['name'] ?? 'Unknown Location',
            onTap: () {
            if (isEvent && item['event_id'] != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CardEvent(eventId: item['event_id'])),
              );
            } else if (!isEvent && item['event_id'] != null){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CardEvent(eventId: item['event_id'])),
              );
            } else if (!isEvent && item['location_id'] != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CardScreen(buildingId: item['location_id'])),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No se puede abrir esta tarjeta")),
              );
            }
            },
          );
        }).toList(),
      ),
    );
  }
}
