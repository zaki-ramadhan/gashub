import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../customers/data/customers_repository.dart';
import '../../customers/domain/customer_model.dart';
import '../../dashboard/data/dashboard_repository.dart';
import '../../inventory/data/inventory_repository.dart';
import '../../receivables/data/receivables_repository.dart';
import '../../reports/data/reports_repository.dart';
import '../data/distribution_repository.dart';
import 'widgets/distribution_customer_selector.dart';
import 'widgets/distribution_payment_section.dart';
import 'widgets/distribution_quantity_stepper.dart';
import 'widgets/distribution_summary_section.dart';

/// Bottom sheet form for recording LPG sales with senior-friendly ergonomic controls.
class DistributionFormSheet extends StatefulWidget {
  const DistributionFormSheet({super.key, this.onBack});

  final VoidCallback? onBack;

  static Future<void> show(BuildContext context, {VoidCallback? onBack}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DistributionFormSheet(onBack: onBack),
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
  final _paidAmountController = TextEditingController(text: '0');

  int get _unitPrice => InventoryRepository.instance.sellingPrice;
  int get _availableStock => InventoryRepository.instance.stockSummaryNotifier.value.filled;

  bool _isPaid = true;
  bool _isLoading = false;
  String? _customerError;
  String? _qtyError;
  String? _paymentError;

  int get _qty => AppInputFormatters.parseQuantity(_qtyController.text, min: 1, defaultValue: 0);
  int get _subtotal => _qty * _unitPrice;
  int get _paidAmount => _isPaid ? _subtotal : AppInputFormatters.parseNumber(_paidAmountController.text, defaultValue: 0);
  int get _remainingDebt => (_subtotal - _paidAmount).clamp(0, _subtotal);

  @override
  void initState() {
    super.initState();
    if (CustomersRepository.instance.customersNotifier.value.isEmpty) {
      CustomersRepository.instance.fetchCustomers().then((_) {
        if (mounted && _selectedCustomer == null && _masterCustomers.isNotEmpty) {
          setState(() {
            _selectedCustomer = _masterCustomers.first;
            _customerController.text = _selectedCustomer?.name ?? '';
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
    _paidAmountController.dispose();
    super.dispose();
  }

  Future<CustomerModel> _createNewCustomer(String name) async {
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
    final created = await CustomersRepository.instance.addCustomer(newModel);
    if (mounted) {
      setState(() {
        _selectedCustomer = created;
        _customerController.text = clean;
      });
    }
    return created;
  }

  Future<void> _save() async {
    final customerName = AppInputFormatters.trim(_customerController.text);
    final parsedQty = AppInputFormatters.parseNumber(_qtyController.text);

    String? custErr;
    String? qtyErr;
    String? payErr;

    if (customerName.isEmpty) {
      custErr = 'Nama pelanggan wajib diisi';
    }
    if (parsedQty < 1) {
      qtyErr = 'Jumlah tabung minimal 1';
    }
    if (!_isPaid && _paidAmount > _subtotal) {
      payErr = 'Uang muka melebihi total tagihan';
    }

    if (custErr != null || qtyErr != null || payErr != null) {
      setState(() {
        _customerError = custErr;
        _qtyError = qtyErr;
        _paymentError = payErr;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      var customer = _selectedCustomer;
      if (customer == null || customer.name.toLowerCase() != customerName.toLowerCase()) {
        customer = _masterCustomers.cast<CustomerModel?>().firstWhere(
          (c) => c?.name.toLowerCase() == customerName.toLowerCase(),
          orElse: () => null,
        );
      }

      customer ??= await _createNewCustomer(customerName);

      await DistributionRepository.instance.createDistribution(
        customerId: customer.id,
        items: [
          {
            'product_id': InventoryRepository.instance.defaultProductId,
            'quantity': _qty,
            'unit_price': _unitPrice,
          }
        ],
        amountPaid: _paidAmount,
        notes: '',
      );

      await Future.wait([
        InventoryRepository.instance.fetchInventory(),
        ReportsRepository.instance.fetchLiveReport(),
        DashboardRepository.instance.fetchDashboardMetrics(),
        DashboardRepository.instance.fetchCashflowEntries(),
        ReceivablesRepository.instance.fetchReceivables(),
        CustomersRepository.instance.fetchCustomers(),
      ]);

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      AppToast.success(title: 'Penjualan gas berhasil dicatat');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.error(title: 'Gagal mencatat penjualan: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Catat Penjualan Gas',
      onBack: widget.onBack,
      bottomAction: AppButton(
        text: 'Simpan Penjualan',
        isLoading: _isLoading,
        onPressed: _save,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DistributionCustomerSelector(
            controller: _customerController,
            masterCustomers: _masterCustomers,
            selectedCustomer: _selectedCustomer,
            errorText: _customerError,
            onSelectCustomer: (cust) {
              setState(() {
                _selectedCustomer = cust;
                if (_customerError != null) _customerError = null;
              });
            },
          ),
          const SizedBox(height: AppDimensions.space16),
          DistributionQuantityStepper(
            controller: _qtyController,
            unitPrice: _unitPrice,
            availableStock: _availableStock,
            errorText: _qtyError,
            onChanged: () {
              if (_qtyError != null) setState(() => _qtyError = null);
              setState(() {});
            },
          ),
          const SizedBox(height: AppDimensions.space16),
          DistributionPaymentSection(
            isPaid: _isPaid,
            onPaidChanged: (val) {
              setState(() {
                _isPaid = val;
                if (_paymentError != null) _paymentError = null;
              });
            },
            paidAmountController: _paidAmountController,
            remainingDebt: _remainingDebt,
            errorText: _paymentError,
            onAmountChanged: () {
              if (_paymentError != null) setState(() => _paymentError = null);
              setState(() {});
            },
          ),
          const SizedBox(height: AppDimensions.space16),
          DistributionSummarySection(
            subtotal: _subtotal,
            qty: _qty,
            isPaid: _isPaid,
            remainingDebt: _remainingDebt,
          ),
        ],
      ),
    );
  }
}
