import 'package:dart_g12/presentation/view_models/see_all_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilterScreen extends StatefulWidget {
  final String contentType;

  const FilterScreen({super.key, required this.contentType});

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SeeAllViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sort & Filters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              viewModel.clearFilters();
              _searchController.clear();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de búsqueda
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                viewModel.filterItems(value);
              },
            ),
            const SizedBox(height: 16),
            // Filtros específicos para contentType
            if (widget.contentType == 'building') _buildBlockFilter(viewModel),
            if (widget.contentType == 'event') _buildEventFilters(viewModel),
            if (widget.contentType == 'laboratory') _buildLocationFilter(viewModel),
            if (widget.contentType == 'access') _buildLocationFilter(viewModel),
            if (widget.contentType == 'auditorium') _buildLocationFilter(viewModel),
            if (widget.contentType == 'library') _buildLocationFilter(viewModel), // Aquí añadimos el filtro para la librería.
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                viewModel.filterItems(_searchController.text);
                Navigator.pop(context);
              },
              child: const Text('Show All Results'),
            ),
          ],
        ),
      ),
    );
  }

  // Filtro por bloque (para contenido tipo 'building')
  Widget _buildBlockFilter(SeeAllViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Filter by Block'),
        DropdownButton<String>(
          value: viewModel.selectedBlock,
          hint: const Text('Select Block'),
          isExpanded: true,
          onChanged: (newValue) {
            viewModel.setSelectedBlock(newValue);
          },
          items: <String>['Block 1', 'Block 2', 'Block 3'] // Ejemplo de bloques
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Filtros específicos para el tipo de contenido 'event'
  Widget _buildEventFilters(SeeAllViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Filter by Date'),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _selectDate(context, viewModel, true),
              child: const Text('Start Date'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _selectDate(context, viewModel, false),
              child: const Text('End Date'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Filter by Event ID'),
        TextField(
          onChanged: (value) {
            viewModel.filterItems(value);
          },
          decoration: const InputDecoration(
            labelText: 'Search by Event ID',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // Filtro por ubicación (común a varios tipos de contenido)
  Widget _buildLocationFilter(SeeAllViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Filter by Location'),
        DropdownButton<String>(
          value: viewModel.selectedLocation,
          hint: const Text('Select Location'),
          isExpanded: true,
          onChanged: (newValue) {
            viewModel.setSelectedLocation(newValue);
          },
          items: <String>['Location 1', 'Location 2', 'Location 3'] // Ejemplo de ubicaciones
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Selección de fechas (inicio o fin)
  Future<void> _selectDate(BuildContext context, SeeAllViewModel viewModel, bool isStartDate) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      if (isStartDate) {
        viewModel.setStartDate(selectedDate);
      } else {
        viewModel.setEndDate(selectedDate);
      }
    }
  }
}
