import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/home_view_model.dart';
import '../widgets/ovals_painter_home.dart';
import '../widgets/section_header.dart';
import '../widgets/place_card.dart';
import '../widgets/category_list.dart';
import '../widgets/chat_widget.dart';
import 'main_screen.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(painter: OvalsPainterHome()),
                ),
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
                    Expanded(child: _buildContent()),
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
      builder: (context, vm, _) {
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
                  MaterialPageRoute(
                    builder: (_) => const MainScreen(initialIndex: 4),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 24,
                backgroundImage: vm.avatarUrl != null
                    ? FileImage(File(vm.avatarUrl!))
                    : const AssetImage('assets/profile.jpg') as ImageProvider,
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
            title: "Most Popular",
            destinationScreen: SeeAllScreen(contentType: "popular"),
            builder: (vm) => _buildHorizontalList(vm.mostSearchedLocations),
            showSeeAll: false,
          ),
          _buildSection(
            title: "Buildings",
            destinationScreen: SeeAllScreen(contentType: "building"),
            builder: (vm) => _buildHorizontalList(vm.locations),
          ),
          _buildSection(
            title: "Events",
            destinationScreen: SeeAllScreen(contentType: "event"),
            builder: (vm) => _buildHorizontalList(vm.events),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget destinationScreen,
    required Widget Function(HomeViewModel) builder,
    bool showSeeAll = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          destinationScreen: destinationScreen,
          showSeeAll: showSeeAll,
        ),
        Consumer<HomeViewModel>(builder: (_, vm, __) => builder(vm)),
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
          final location = item['locations'];
          final subtitle = location != null ? location['name'] ?? '' : '';
          final block = location?['block'] ?? item['block'];

          return PlaceCard(
            imagePath: item['image_url'] ?? 'assets/images/default_image.jpg',
            title: item['name'] ?? 'Unknown Location',
            subtitle: subtitle,
            block: block,
            onTap: () => _navigateToDetail(item),
          );
        }).toList(),
      ),
    );
  }

  void _navigateToDetail(Map<String, dynamic> item) {
    final typeMap = {
      'building': CardType.building,
      'laboratory': CardType.laboratories,
      'access': CardType.access,
      'event': CardType.event,
      'library': CardType.library,
      'auditorium': CardType.auditorium,
    };

    for (final entry in typeMap.entries) {
      if (item['type'] == entry.key) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailCard(
              id: item['information_id'],
              type: entry.value,
            ),
          ),
        );
        return;
      }
    }

    final idFields = {
      'location_id': CardType.building,
      'event_id': CardType.event,
      'laboratories_id': CardType.laboratories,
      'access_id': CardType.access,
    };

    for (final entry in idFields.entries) {
      if (item[entry.key] != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailCard(
              id: item[entry.key],
              type: entry.value,
            ),
          ),
        );
        return;
      }
    }
  }
}
