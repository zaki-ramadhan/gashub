import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Search bar and date filter chips header for Distribution screen.
class DistributionFilterHeader extends StatelessWidget {
  const DistributionFilterHeader({
    super.key,
    required this.searchController,
    required this.hasQuery,
    required this.activeFilter,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.onFilterSelected,
  });

  final TextEditingController searchController;
  final bool hasQuery;
  final String activeFilter;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSearchBar(
            controller: searchController,
            hintText: 'Cari nama pelanggan / pembeli...',
            hasQuery: hasQuery,
            onChanged: onSearchChanged,
            onClear: onSearchClear,
          ),
          const SizedBox(height: AppDimensions.space10),
          AppFilterChips<String>(
            options: const ['Semua', 'Hari Ini', 'Minggu Ini', 'Bulan Ini'],
            selected: activeFilter,
            onSelected: onFilterSelected,
          ),
          const SizedBox(height: AppDimensions.space8),
        ],
      ),
    );
  }
}

