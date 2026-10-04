import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/customers_repository.dart';
import '../domain/customer_model.dart';

/// Modal bottom sheet for registering a new customer / partner store.
class CustomerFormSheet extends StatefulWidget {
  const CustomerFormSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CustomerFormSheet(),
    );
  }

  @override
  State<CustomerFormSheet> createState() => _CustomerFormSheetState();
}

class _CustomerFormSheetState extends State<CustomerFormSheet> {
  final _nameController = TextEditingController();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = AppInputFormatters.trim(_nameController.text);
    final owner = AppInputFormatters.trim(_ownerController.text);
    final phone = AppInputFormatters.trim(_phoneController.text);
    final address = AppInputFormatters.trim(_addressController.text);

    if (name.isEmpty) {
      AppToast.warning(title: 'Nama pelanggan wajib diisi');
      return;
    }
    if (phone.isEmpty) {
      AppToast.warning(title: 'Nomor WhatsApp wajib diisi');
      return;
    }

    setState(() => _isLoading = true);

    final newCustomer = CustomerModel(
      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      owner: owner,
      phone: phone,
      address: address.isEmpty ? 'Alamat belum diatur' : address,
      activeDebt: 0,
      totalCylinders: 0,
      lastOrderDate: null,
      transactions: const [],
    );

    CustomersRepository.instance.addCustomer(newCustomer);

    Navigator.of(context, rootNavigator: true).pop();
    AppToast.success(title: 'Pelanggan $name berhasil ditambahkan');
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Tambah Pelanggan',
      bottomAction: AppButton(
        text: 'Simpan Pelanggan',
        isLoading: _isLoading,
        onPressed: _submit,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Pelanggan
          const Text(
            'Nama Pelanggan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Contoh: Toko Berkah / RM Padang',
            ),
          ),
          const SizedBox(height: AppDimensions.space12),

          // Nama Pemilik
          const Text(
            'Nama Pemilik (Opsional)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _ownerController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Contoh: Pak Joko / Bu Siti',
            ),
          ),
          const SizedBox(height: AppDimensions.space12),

          // No WhatsApp / HP
          const Text(
            'Nomor WhatsApp / HP',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'Contoh: 0812-3456-7890',
            ),
          ),
          const SizedBox(height: AppDimensions.space12),

          // Alamat
          const Text(
            'Alamat / Patokan Toko',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _addressController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Contoh: Jl. Melati No. 12 (depan masjid)',
            ),
          ),
        ],
      ),
    );
  }
}
