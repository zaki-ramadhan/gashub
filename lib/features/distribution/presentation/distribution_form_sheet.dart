import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// Bottom sheet form for recording LPG 3kg sales / distribution to warung.
class DistributionFormSheet extends StatefulWidget {
  const DistributionFormSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const DistributionFormSheet(),
    );
  }

  @override
  State<DistributionFormSheet> createState() => _DistributionFormSheetState();
}

/// Customer entity representing registered store or buyer.
class CustomerEntity {
  final String id;
  final String name;
  final String phone;

  const CustomerEntity({
    required this.id,
    required this.name,
    this.phone = '',
  });
}

class _DistributionFormSheetState extends State<DistributionFormSheet> {
  static final List<CustomerEntity> _masterCustomers = [
    const CustomerEntity(
      id: 'c1111111-1111-1111-1111-111111111111',
      name: 'Warung Madura Pak Joko',
      phone: '0812-3456-7890',
    ),
    const CustomerEntity(
      id: 'c2222222-2222-2222-2222-222222222222',
      name: 'Toko Berkah Ibu',
      phone: '0813-9876-5432',
    ),
    const CustomerEntity(
      id: 'c3333333-3333-3333-3333-333333333333',
      name: 'Pangkalan Barokah H. Slamet',
      phone: '0811-2233-4455',
    ),
    const CustomerEntity(
      id: 'c4444444-4444-4444-4444-444444444444',
      name: 'Warung Kelontong Bu Siti',
      phone: '0857-1122-3344',
    ),
    const CustomerEntity(
      id: 'c5555555-5555-5555-5555-555555555555',
      name: 'RM Padang Sederhana',
      phone: '0821-4455-6677',
    ),
    const CustomerEntity(
      id: 'c6666666-6666-6666-6666-666666666666',
      name: 'Warung Nasi Bu Nur',
      phone: '0819-3322-1100',
    ),
    const CustomerEntity(
      id: 'c7777777-7777-7777-7777-777777777777',
      name: 'Toko Kelontong Berkat',
      phone: '0852-9988-7766',
    ),
  ];

  CustomerEntity? _selectedCustomer = _masterCustomers.first;
  final _customerController = TextEditingController();
  final _qtyController = TextEditingController(text: '15');
  final int _unitPrice = 19000;
  bool _isPaid = true;
  bool _isLoading = false;

  int get _qty => AppInputFormatters.parseQuantity(_qtyController.text, min: 1, defaultValue: 0);
  int get _subtotal => _qty * _unitPrice;

  @override
  void initState() {
    super.initState();
    _customerController.text = _selectedCustomer?.name ?? '';
  }

  @override
  void dispose() {
    _customerController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  CustomerEntity _createNewCustomer(String name, {bool silent = false}) {
    final clean = AppInputFormatters.trim(name);
    final newEntity = CustomerEntity(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      name: clean,
    );
    _masterCustomers.insert(0, newEntity);
    setState(() {
      _selectedCustomer = newEntity;
      _customerController.text = clean;
      _customerController.selection = TextSelection.collapsed(offset: clean.length);
    });
    if (!silent) {
      AppToast.success(title: '"$clean" ditambahkan ke daftar mitra');
    }
    return newEntity;
  }

  Future<void> _save() async {
    final customerName = AppInputFormatters.trim(_customerController.text);
    if (customerName.isEmpty) {
      AppToast.warning(title: 'Nama pelanggan belum diisi');
      return;
    }
    if (_qty < 1) {
      AppToast.warning(title: 'Jumlah tabung minimal 1');
      return;
    }

    // Auto-create customer if not existing yet
    final customer = _selectedCustomer ??
        _masterCustomers.cast<CustomerEntity?>().firstWhere(
          (c) => c?.name.toLowerCase() == customerName.toLowerCase(),
          orElse: () => null,
        ) ??
        _createNewCustomer(customerName, silent: true);

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop();
    AppToast.success(title: 'Penjualan ke ${customer.name} berhasil disimpan');
  }

  @override
  Widget build(BuildContext context) {
    final currentQuery = _customerController.text.trim();
    final cleanQuery = currentQuery.toLowerCase();
    final isExactMatch = cleanQuery.isNotEmpty &&
        _masterCustomers.any((c) => c.name.toLowerCase() == cleanQuery);

    final filteredCustomers = cleanQuery.isEmpty
        ? _masterCustomers.take(7).toList()
        : _masterCustomers
            .where((c) => c.name.toLowerCase().contains(cleanQuery))
            .take(7)
            .toList();

    return AppBottomSheet(
      title: 'Catat Kirim Gas',
      bottomAction: AppButton(
        text: 'Simpan Penjualan',
        isLoading: _isLoading,
        onPressed: _save,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Nama Pelanggan (Smart Lookup)
          const Text(
            'Nama Pelanggan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          TextFormField(
            controller: _customerController,
            inputFormatters: [AppInputFormatters.cleanText],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Ketik nama pelanggan...',
              prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppColors.textMuted),
              suffixIcon: _customerController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16, color: AppColors.textMuted),
                      onPressed: () {
                        _customerController.clear();
                        setState(() => _selectedCustomer = null);
                      },
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            ),
            onChanged: (val) {
              final clean = val.trim().toLowerCase();
              final match = _masterCustomers.cast<CustomerEntity?>().firstWhere(
                (c) => c?.name.toLowerCase() == clean,
                orElse: () => null,
              );
              setState(() => _selectedCustomer = match);
            },
          ),
          const SizedBox(height: AppDimensions.space8),

          // Pilihan Cepat & Filter Chips Reaktif (Maks 7 Chip)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Tombol aksi buat baru jika nama yang diketik belum ada di daftar
                if (!isExactMatch && currentQuery.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () => _createNewCustomer(currentQuery),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, size: 14, color: AppColors.textPrimary),
                          const SizedBox(width: 4),
                          Text(
                            'Tambah "$currentQuery"',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],

                // Matching chips (Bg abu-abu lembut & teks gelap saat aktif)
                ...filteredCustomers.map((cust) {
                  final isSelected = _selectedCustomer?.id == cust.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () {
                        _customerController.text = cust.name;
                        _customerController.selection = TextSelection.collapsed(
                          offset: cust.name.length,
                        );
                        setState(() => _selectedCustomer = cust);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.brandPrimary : AppColors.canvas,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                          border: Border.all(
                            color: isSelected ? AppColors.brandPrimary : AppColors.border,
                          ),
                        ),
                        child: Text(
                          cust.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 2. Jumlah Tabung (Input manual langsung full width)
          const Text(
            'Jumlah Tabung',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          TextFormField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            inputFormatters: [AppInputFormatters.thousands],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: '1',
              prefixIcon: const Icon(Icons.propane_tank_outlined, size: 20, color: AppColors.textMuted),
              suffixText: 'tabung',
              suffixStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              helperText: 'Harga: ${AppFormatters.currency(_unitPrice)} / tabung',
              helperStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 3. Status Pembayaran
          const Text(
            'Status Pembayaran',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isPaid = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isPaid ? AppColors.brandPrimary : Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                      border: Border.all(
                        color: _isPaid ? AppColors.brandPrimary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      'Lunas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _isPaid ? FontWeight.w500 : FontWeight.w400,
                        color: _isPaid ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isPaid = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: !_isPaid ? AppColors.brandPrimary : Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                      border: Border.all(
                        color: !_isPaid ? AppColors.brandPrimary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      'Belum Bayar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: !_isPaid ? FontWeight.w500 : FontWeight.w400,
                        color: !_isPaid ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),

          // 4. Total Tagihan (Teks biasa tanpa banner / minicard)
          const SizedBox(height: AppDimensions.space4),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: AppDimensions.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Total Tagihan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                AppFormatters.currency(_subtotal),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
