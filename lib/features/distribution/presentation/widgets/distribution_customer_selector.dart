import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../customers/domain/customer_model.dart';

/// Customer selector with pinned 1-tap "Pelanggan Umum (Eceran)" option for elderly users.
class DistributionCustomerSelector extends StatelessWidget {
  const DistributionCustomerSelector({
    super.key,
    required this.controller,
    required this.masterCustomers,
    required this.selectedCustomer,
    required this.onSelectCustomer,
    this.errorText,
  });

  final TextEditingController controller;
  final List<CustomerModel> masterCustomers;
  final CustomerModel? selectedCustomer;
  final ValueChanged<CustomerModel?> onSelectCustomer;
  final String? errorText;

  static const String generalCustomerName = 'Pelanggan Umum (Eceran)';

  @override
  Widget build(BuildContext context) {
    final currentQuery = controller.text.trim();
    final cleanQuery = currentQuery.toLowerCase();

    final filteredCustomers = cleanQuery.isEmpty
        ? masterCustomers.take(6).toList()
        : masterCustomers
            .where((c) => c.name.toLowerCase().contains(cleanQuery))
            .take(6)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const InputLabel(
          label: 'Nama Pelanggan',
          isRequired: true,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          inputFormatters: [AppInputFormatters.cleanText],
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Ketik nama pelanggan / warung...',
            prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppColors.textMuted),
            errorText: errorText,
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 16, color: AppColors.textMuted),
                    onPressed: () {
                      controller.clear();
                      onSelectCustomer(null);
                    },
                  )
                : null,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          onChanged: (val) {
            final clean = val.trim().toLowerCase();
            final match = masterCustomers.cast<CustomerModel?>().firstWhere(
              (c) => c?.name.toLowerCase() == clean,
              orElse: () => null,
            );
            onSelectCustomer(match);
          },
        ),
        const SizedBox(height: 8),

        // Pinned General Customer + Customer Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Pinned 1-Tap "Pelanggan Umum (Eceran)"
              _buildChip(
                label: generalCustomerName,
                isSelected: controller.text == generalCustomerName,
                isPinned: true,
                onTap: () {
                  controller.text = generalCustomerName;
                  controller.selection = TextSelection.collapsed(offset: generalCustomerName.length);
                  final match = masterCustomers.cast<CustomerModel?>().firstWhere(
                    (c) => c?.name.toLowerCase() == generalCustomerName.toLowerCase(),
                    orElse: () => null,
                  );
                  onSelectCustomer(match);
                },
              ),
              const SizedBox(width: 6),

              // Registered Customer Chips
              ...filteredCustomers.map((cust) {
                final isSelected = selectedCustomer?.id == cust.id || controller.text == cust.name;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _buildChip(
                    label: cust.name,
                    isSelected: isSelected,
                    isPinned: false,
                    onTap: () {
                      controller.text = cust.name;
                      controller.selection = TextSelection.collapsed(offset: cust.name.length);
                      onSelectCustomer(cust);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required bool isPinned,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.lime
              : (isPinned ? AppColors.lime.withValues(alpha: 0.3) : Colors.white),
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          border: Border.all(
            color: isSelected ? AppColors.forestGreen.withValues(alpha: 0.5) : AppColors.border,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : (isPinned ? FontWeight.w500 : FontWeight.w400),
            color: isSelected ? AppColors.brandPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

