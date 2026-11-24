import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../data/customers_repository.dart';
import '../domain/customer_model.dart';

/// Modal bottom sheet for registering a new customer / partner store.
class CustomerFormSheet extends StatefulWidget {
  const CustomerFormSheet({super.key, this.onBack});

  final VoidCallback? onBack;

  static Future<void> show(BuildContext context, {VoidCallback? onBack}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomerFormSheet(onBack: onBack),
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
  String? _nameError;
  String? _phoneError;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = AppInputFormatters.trim(_nameController.text);
    final owner = AppInputFormatters.trim(_ownerController.text);
    final phone = AppInputFormatters.trim(_phoneController.text);
    final address = AppInputFormatters.trim(_addressController.text);

    String? nameErr;
    String? phoneErr;

    if (name.isEmpty) {
      nameErr = 'Nama pelanggan wajib diisi';
    } else if (name.length < 2) {
      nameErr = 'Nama pelanggan minimal 2 karakter';
    }

    if (phone.isEmpty) {
      phoneErr = 'Nomor WhatsApp wajib diisi';
    } else {
      final digits = phone.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 9) {
        phoneErr = 'Nomor WhatsApp minimal 9 digit angka';
      }
    }

    if (nameErr != null || phoneErr != null) {
      setState(() {
        _nameError = nameErr;
        _phoneError = phoneErr;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newCustomer = CustomerModel(
        id: '',
        name: name,
        owner: owner,
        phone: phone,
        address: address.isEmpty ? 'Alamat belum diatur' : address,
        activeDebt: 0,
        totalCylinders: 0,
        lastOrderDate: null,
        transactions: const [],
      );

      await CustomersRepository.instance.addCustomer(newCustomer);
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();
      AppToast.success(title: 'Pelanggan berhasil ditambahkan');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.error(title: 'Gagal menambah pelanggan: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Tambah Pelanggan',
      onBack: widget.onBack,
      bottomAction: AppButton(
        text: 'Simpan Pelanggan',
        isLoading: _isLoading,
        onPressed: _submit,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Pelanggan
          const InputLabel(
            label: 'Nama Pelanggan',
            isRequired: true,
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Contoh: Berkah / RM Padang',
              errorText: _nameError,
            ),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: AppDimensions.space12),

          // Nama Pemilik
          const InputLabel(
            label: 'Nama Pemilik (Opsional)',
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
          const InputLabel(
            label: 'Nomor WhatsApp / HP',
            isRequired: true,
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Contoh: 0812-3456-7890',
              errorText: _phoneError,
            ),
            onChanged: (_) {
              if (_phoneError != null) setState(() => _phoneError = null);
            },
          ),
          const SizedBox(height: AppDimensions.space12),

          // Alamat
          const InputLabel(
            label: 'Alamat Pelanggan',
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _addressController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
