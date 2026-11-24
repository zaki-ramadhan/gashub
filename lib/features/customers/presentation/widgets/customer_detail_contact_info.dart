import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../domain/customer_model.dart';

/// Clean, raw-text contact and address details without bulky card borders or call buttons.
class CustomerDetailContactInfo extends StatelessWidget {
  const CustomerDetailContactInfo({
    super.key,
    required this.customer,
  });

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (customer.address.isNotEmpty) ...[
          Text(
            customer.address,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
        ],
        if (customer.phone.isNotEmpty)
          Text(
            customer.phone,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
      ],
    );
  }
}
