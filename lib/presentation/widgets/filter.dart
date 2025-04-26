import 'package:dart_g12/presentation/view_models/see_all_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ovals_painter.dart';

class FilterScreen extends StatefulWidget {
  final String contentType;

  const FilterScreen({super.key, required this.contentType});

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SeeAllViewModel>();

    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: OvalsPainter())),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Filters',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), // Espacio debajo del título

                  // Campo de búsqueda
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by Name',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: viewModel.filterItems,
                  ),
                  const SizedBox(height: 16),

                  // Filtros específicos
                  if (widget.contentType == 'building') _buildBlockFilter(viewModel),
                  //if (widget.contentType == 'event') _buildEventFilters(viewModel),
                  //if (widget.contentType == 'laboratory' ||
                      //widget.contentType == 'access' ||
                      //widget.contentType == 'auditorium' ||
                      //widget.contentType == 'library')
                    //_buildLocationFilter(viewModel),

                  const Spacer(),

                  // Botón "Show All Results"
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {

                        if (_searchController.text.trim().isEmpty && viewModel.selectedBlock != null) {
                          viewModel.filterByBlock(viewModel.selectedBlock!);
                        } else {

                          viewModel.filterItems(_searchController.text);
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Show All Results',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF2E1F54),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlockFilter(SeeAllViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Filter by Block', style: TextStyle(color: Colors.black)),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Block name (ML)',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
          onChanged: vm.setSelectedBlock,
        ),
      ],
    );
  }


  Widget _buildEventFilters(SeeAllViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Filter by Date', style: TextStyle(color: Colors.black)),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _selectDate(context, vm, true),
              child: Text(
                vm.startDate != null
                    ? 'From: ${vm.formatDate(vm.startDate!)}'
                    : 'Start Date',
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _selectDate(context, vm, false),
              child: Text(
                vm.endDate != null
                    ? 'To: ${vm.formatDate(vm.endDate!)}'
                    : 'End Date',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Filter by Event ID', style: TextStyle(color: Colors.black)),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search by Event ID',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
          onChanged: vm.filterItems,
        ),
      ],
    );
  }

  Widget _buildLocationFilter(SeeAllViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Filter by Location', style: TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: vm.selectedLocation,
          hint: const Text('Select Location'),
          isExpanded: true,
          onChanged: vm.setSelectedLocation,
          dropdownColor: Colors.white,
          items: <String>['Location 1', 'Location 2', 'Location 3']
              .map((l) => DropdownMenuItem(value: l, child: Text(l)))
              .toList(),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, SeeAllViewModel vm, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      if (isStart) {
        vm.setStartDate(picked);
      } else {
        vm.setEndDate(picked);
      }
    }
  }
}
