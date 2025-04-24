import 'package:dart_g12/presentation/views/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';
import '../widgets/ovals_painter_home.dart';
import '../widgets/section_header.dart';
import '../widgets/place_card.dart';
import '../widgets/category_list.dart';
import '../widgets/chat_widget.dart';
import 'see_all_screen.dart';
import 'detail_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = HomeViewModel();
    viewModel.loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeViewModel>.value(
      value: viewModel,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: OvalsPainterHome()),
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
                    const SizedBox(height: 25),
                    const CategoryList(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildContent(),
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
    return Consumer<HomeViewModel>(
      builder: (context, vm, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hi, ${vm.userName}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen(initialIndex: 4)),
              );
            },
            child: CircleAvatar(
              radius: 24,
              backgroundImage: vm.avatarUrl != null
                  ? NetworkImage(vm.avatarUrl!)
                  : const AssetImage('assets/images/profile.jpg') as ImageProvider,
            ),
          ),
          ],
        );
      },
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            "Most Popular",
            SeeAllScreen(contentType: "building"),
            (vm) => _buildHorizontalList(vm.mostSearchedLocations),
          ),
          _buildSection(
            "Buildings",
            SeeAllScreen(contentType: "building"),
            (vm) => _buildHorizontalList(vm.locations),
          ),
          _buildSection(
            "Laboratories",
            SeeAllScreen(contentType: "laboratory"),
            (vm) => _buildHorizontalList(vm.laboratories),
          ),
          _buildSection(
            "Access points",
            SeeAllScreen(contentType: "access"),
            (vm) => _buildHorizontalList(vm.access),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    Widget destinationScreen,
    Widget Function(HomeViewModel) builder,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, destinationScreen: destinationScreen),
        Consumer<HomeViewModel>(
          builder: (context, vm, child) {
            return builder(vm);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHorizontalList(List<dynamic> items) {
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
            subtitle = item['locations']['name'];
            block = item['locations']['block'];
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
              if (item['location_id'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailCard(
                      id: item['location_id'],
                      type: CardType.building,
                    ),
                  ),
                );
              } else if (item['laboratories_id'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailCard(
                      id: item['laboratories_id'],
                      type: CardType.laboratories,
                    ),
                  ),
                );
              } else if (item['access_id'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailCard(
                      id: item['access_id'],
                      type: CardType.access,
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
