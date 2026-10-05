import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../customers/data/customers_repository.dart';
import '../../customers/domain/customer_model.dart';
import '../../inventory/data/inventory_repository.dart';
import '../../reports/data/reports_repository.dart';
import '../data/distribution_repository.dart';

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

class _DistributionFormSheetState extends State<DistributionFormSheet> {
  List<CustomerModel> get _masterCustomers =>
      CustomersRepository.instance.customersNotifier.value;

  CustomerModel? _selectedCustomer;
  final _customerController = TextEditingController();
  final _qtyController = TextEditingController(text: '15');
  int get _unitPrice => InventoryRepository.instance.sellingPrice;
  bool _isPaid = true;
  bool _isLoading = false;

  int get _qty => AppInputFormatters.parseQuantity(_qtyController.text, min: 1, defaultValue: 0);
  int get _subtotal => _qty * _unitPrice;

  @override
  void initState() {
    super.initState();
    if (CustomersRepository.instance.customersNotifier.value.isEmpty) {
      CustomersRepository.instance.fetchCustomers().then((_) {
        if (mounted) {
          setState(() {
            if (_selectedCustomer == null && _masterCustomers.isNotEmpty) {
              _selectedCustomer = _masterCustomers.first;
              _customerController.text = _selectedCustomer?.name ?? '';
            }
          });
        }
      });
    } else {
      _selectedCustomer = _masterCustomers.firstOrNull;
      _customerController.text = _selectedCustomer?.name ?? '';
    }
  }

  @override
  void dispose() {
    _customerController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<CustomerModel> _createNewCustomer(String name, {bool silent = false}) async {
    final clean = AppInputFormatters.trim(name);
    final newModel = CustomerModel(
      id: '',
      name: clean,
      phone: '',
      address: 'Alamat belum diatur',
      owner: '',
      activeDebt: 0,
      totalCylinders: 0,
      lastOrderDate: null,
      transactions: const [],
    );
    await CustomersRepository.instance.addCustomer(newModel);
    final match = _masterCustomers.cast<CustomerModel?>().firstWhere(
      (c) => c?.name.toLowerCase() == clean.toLowerCase(),
      orElse: () => CustomerModel(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        name: clean,
        phone: '',
        address: '',
        owner: '',
        activeDebt: 0,
        totalCylinders: 0,
        lastOrderDate: null,
        transactions: const [],
      ),
    );
    if (mounted) {
      setState(() {
        _selectedCustomer = match;
        _customerController.text = clean;
        _customerController.selection = TextSelection.collapsed(offset: clean.length);
      });
    }
    if (!silent) {
      AppToast.success(title: '"$clean" ditambahkan ke daftar mitra');
    }
    return match!;
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

    setState(() => _isLoading = true);

    try {
      var customer = _selectedCustomer ??
          _masterCustomers.cast<CustomerModel?>().firstWhere(
            (c) => c?.name.toLowerCase() == customerName.toLowerCase(),
            orElse: () => null,
          );

      customer ??= await _createNewCustomer(customerName, silent: true);

      await DistributionRepository.instance.createDistribution(
        customerId: customer.id,
        items: [
          {
            'product_id': '11111111-1111-1111-1111-111111111111',
            'quantity': _qty,
            'unit_price': _unitPrice,
          }
        ],
        amountPaid: _isPaid ? _subtotal : 0,
        notes: 'Pengiriman via GasHub Mobile',
      );

      await Future.wait([
        InventoryRepository.instance.fetchInventory(),
        ReportsRepository.instance.fetchLiveReport(),
      ]);

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      AppToast.success(title: 'Penjualan ke ${customer.name} berhasil disimpan');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.error(title: 'Gagal menyimpan transaksi: $e');
      }
    }
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
              final match = _masterCustomers.cast<CustomerModel?>().firstWhere(
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
