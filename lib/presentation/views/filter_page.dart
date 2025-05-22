import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/see_all_view_model.dart';
import '../widgets/ovals_painter_home.dart';

class FilterScreen extends StatefulWidget {
  final String contentType;

  const FilterScreen({super.key, required this.contentType});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  final Map<String, bool> _expandedSections = {
    'favorites': false,
    'date': false,
    'places': false,
  };

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SeeAllViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: OvalsPainterHome())),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Header
                  Center(
                    child: Text(
                      'Filters for ${widget.contentType}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Search
                  TextField(
                    controller: _searchCtrl,
                    onChanged: vm.filterItems,
                    maxLength: 20,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: const Icon(Icons.filter_alt_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),

                  // Filters header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filters",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          vm.clearAllFilters(); // Debes implementar este método en tu ViewModel
                          setState(() {}); // Para refrescar la UI si es necesario
                        },
                        child: const Text(
                          "Clear All",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Dynamic Filters
                  Expanded(child: _buildFilters(vm)),

                  const SizedBox(height: 12),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        vm.applyAllFilters(_searchCtrl.text); // Aplica todos los filtros
                        vm.clearAllFilters();
                        _searchCtrl.clear();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E1F54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Show All Results',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(SeeAllViewModel vm) {
    return ListView(
      children: [
        if (widget.contentType == 'favorite') _buildDropdown("Filter Favorites", _buildFavoriteFilter(vm), "favorites"),
        if (widget.contentType == 'event') _buildDropdown("Date", _buildDateFilter(vm), "date"),
        if (widget.contentType != 'favorite') _buildDropdown("Places", _buildLocationFilter(vm), "places"),
      ],
    );
  }

  Widget _buildDropdown(String title, Widget content, String key) {
    final expanded = _expandedSections[key] ?? false;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
        onExpansionChanged: (val) {
          setState(() => _expandedSections[key] = val);
        },
        children: [Padding(padding: const EdgeInsets.all(12), child: content)],
      ),
    );
  }

  Widget _buildFavoriteFilter(SeeAllViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Filter by type"),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: vm.tempFavoriteType,
          items: ['building', 'event', 'library', 'laboratory', 'access', 'auditorium']
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: vm.setFavoriteType,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateFilter(SeeAllViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _selectDate(context, vm, true),
            child: Text(vm.tempStartDate != null
                ? 'From: ${vm.formatDate(vm.tempStartDate!)}'
                : 'Start Date'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _selectDate(context, vm, false),
            child: Text(vm.tempEndDate != null
                ? 'To: ${vm.formatDate(vm.tempEndDate!)}'
                : 'End Date'),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationFilter(SeeAllViewModel vm) {
    return TextField(
      onChanged: vm.setSelectedLocation,
      maxLength: 20,
      decoration: const InputDecoration(
        hintText: 'Location Name',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, SeeAllViewModel vm, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
