import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../view_models/map_view_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/dropdown_container.dart';
import '../widgets/location_dropdown.dart';
import '../widgets/map_view.dart';
import '../widgets/distance_card.dart';
import '../widgets/steps_card.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapViewModel viewModel;
  bool _isInitialized = false; // Para evitar múltiples inicializaciones

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      viewModel = MapViewModel();
      viewModel.getCurrentLocation();
      _isInitialized = true; // Evita múltiples llamadas
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapViewModel>.value(
      value: viewModel,
      child: Consumer<MapViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: CustomAppBar(
              dropdownFrom: DropdownContainer(
                child: LocationDropdown(
                  value: viewModel.fromLocationName,
                  hint: "Your Location",
                  locations: viewModel.locations,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      viewModel.updateLocation(true, newValue);
                    }
                  },
                ),
              ),
              dropdownTo: DropdownContainer(
                child: LocationDropdown(
                  value: viewModel.toLocationName,
                  hint: "Destination",
                  locations: viewModel.locations,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      viewModel.updateLocation(false, newValue);
                    }
                  },
                ),
              ),
              onSwap: viewModel.swapLocations,
              onMoreOptions: () {},
            ),
            body: Stack(
              children: [
                if (_isInitialized) // Solo carga el mapa si ya se inicializó
                  MapView(
                    initialCameraPosition: CameraPosition(
                      target: const LatLng(4.602196, -74.065816),
                      zoom: 17,
                    ),
                    polylines: viewModel.polylines,
                    circles: viewModel.circles,
                    onMapCreated: (controller) {
                      viewModel.mapController = controller;
                    },
                  ),
                if (viewModel.fromLocation != null &&
                    viewModel.toLocation != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: viewModel.showSteps
                        ? StepsCard(
                            onClose: viewModel.toggleSteps,
                            nodes: viewModel.stepNodes,
                          )
                        : DistanceCard(
                            distance: viewModel.distance ?? 0,
                            onStepsPressed: viewModel.toggleSteps,
                          ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
