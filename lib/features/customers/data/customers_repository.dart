import 'package:flutter/foundation.dart';
import '../../../core/core.dart';
import '../domain/customer_model.dart';

/// In-memory repository managing partner store directory & per-customer ledger.
class CustomersRepository {
  CustomersRepository._();
  static final CustomersRepository instance = CustomersRepository._();

  final ValueNotifier<List<CustomerModel>> customersNotifier =
      ValueNotifier<List<CustomerModel>>(_initialCustomers);

  static final List<CustomerModel> _initialCustomers = [
    CustomerModel(
      id: 'c2222222-2222-2222-2222-222222222222',
      name: 'Toko Berkah Ibu',
      owner: 'Ibu Ratna',
      phone: '0813-9876-5432',
      address: 'Jl. Mawar No. 45',
      activeDebt: 380000,
      totalCylinders: 40,
      lastOrderDate: DateTime.now().subtract(const Duration(hours: 3)),
      transactions: [
        CustomerTransaction(
          id: 't-1',
          invoice: '#DST-202610-002',
          date: DateTime.now().subtract(const Duration(hours: 3)),
          items: '20 tabung',
          qty: 20,
          totalAmount: 380000,
          paidAmount: 0,
          statusLabel: 'Belum Bayar',
          statusType: BadgeType.warning,
        ),
        CustomerTransaction(
          id: 't-2',
          invoice: '#DST-202609-088',
          date: DateTime.now().subtract(const Duration(days: 4)),
          items: '20 tabung',
          qty: 20,
          totalAmount: 380000,
          paidAmount: 380000,
          statusLabel: 'Lunas',
          statusType: BadgeType.success,
        ),
        CustomerTransaction(
          id: 't-2b',
          invoice: '#DST-202609-065',
          date: DateTime.now().subtract(const Duration(days: 8)),
          items: '15 tabung',
          qty: 15,
          totalAmount: 285000,
          paidAmount: 285000,
          statusLabel: 'Lunas',
          statusType: BadgeType.success,
        ),
        CustomerTransaction(
          id: 't-2c',
          invoice: '#DST-202609-040',
          date: DateTime.now().subtract(const Duration(days: 12)),
          items: '20 tabung',
          qty: 20,
          totalAmount: 380000,
          paidAmount: 380000,
          statusLabel: 'Lunas',
          statusType: BadgeType.success,
        ),
        CustomerTransaction(
          id: 't-2d',
          invoice: '#DST-202609-012',
          date: DateTime.now().subtract(const Duration(days: 16)),
          items: '25 tabung',
          qty: 25,
          totalAmount: 475000,
          paidAmount: 475000,
          statusLabel: 'Lunas',
          statusType: BadgeType.success,
        ),
      ],
    ),
    CustomerModel(
      id: 'c1111111-1111-1111-1111-111111111111',
      name: 'Warung Madura Pak Joko',
      owner: 'Pak Joko',
      phone: '0812-3456-7890',
      address: 'Jl. Melati Raya No. 12',
      activeDebt: 0,
      totalCylinders: 15,
      lastOrderDate: DateTime.now().subtract(const Duration(hours: 2)),
      transactions: [
        CustomerTransaction(
          id: 't-3',
          invoice: '#DST-202610-001',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          items: '15 tabung',
          qty: 15,
          totalAmount: 285000,
          paidAmount: 285000,
          statusLabel: 'Lunas',
          statusType: BadgeType.success,
        ),
      ],
    ),
    CustomerModel(
      id: 'c4444444-4444-4444-4444-444444444444',
      name: 'Warung Kelontong Bu Siti',
      owner: 'Bu Siti',
      phone: '0857-1122-3344',
      address: 'Jl. Anggrek No. 3',
      activeDebt: 190000,
      totalCylinders: 10,
      lastOrderDate: DateTime.now().subtract(const Duration(days: 1)),
      transactions: [
        CustomerTransaction(
          id: 't-4',
          invoice: '#DST-202610-004',
          date: DateTime.now().subtract(const Duration(days: 1)),
          items: '10 tabung',
          qty: 10,
          totalAmount: 190000,
          paidAmount: 0,
          statusLabel: 'Belum Bayar',
          statusType: BadgeType.danger,
        ),
      ],
    ),
    CustomerModel(
      id: 'c5555555-5555-5555-5555-555555555555',
      name: 'RM Padang Sederhana',
      owner: 'Bpk. Rizal',
      phone: '0821-4455-6677',
      address: 'Jl. Raya Pasar Minggu No. 99',
      activeDebt: 860000,
      totalCylinders: 25,
      lastOrderDate: DateTime.now().subtract(const Duration(days: 1)),
      transactions: [
        CustomerTransaction(
          id: 't-5',
          invoice: '#DST-202610-005',
          date: DateTime.now().subtract(const Duration(days: 1)),
          items: '25 tabung',
          qty: 25,
          totalAmount: 860000,
          paidAmount: 0,
          statusLabel: 'Belum Bayar',
          statusType: BadgeType.danger,
        ),
      ],
    ),
    CustomerModel(
      id: 'c3333333-3333-3333-3333-333333333333',
      name: 'Pangkalan Barokah H. Slamet',
      owner: 'H. Slamet',
      phone: '0811-2233-4455',
      address: 'Jl. Kenanga No. 8',
      activeDebt: 0,
      totalCylinders: 30,
      lastOrderDate: DateTime.now().subtract(const Duration(hours: 4)),
      transactions: [
        CustomerTransaction(
          id: 't-6',
          invoice: '#DST-202610-003',
          date: DateTime.now().subtract(const Duration(hours: 4)),
          items: '30 tabung',
          qty: 30,
          totalAmount: 570000,
          paidAmount: 570000,
          statusLabel: 'Lunas',
          statusType: BadgeType.success,
        ),
      ],
    ),
    CustomerModel(
      id: 'c6666666-6666-6666-6666-666666666666',
      name: 'Warung Nasi Bu Nur',
      owner: 'Bu Nur',
      phone: '0819-3322-1100',
      address: 'Gang Kancil No. 5',
      activeDebt: 0,
      totalCylinders: 8,
      lastOrderDate: DateTime.now().subtract(const Duration(days: 2)),
      transactions: [
        CustomerTransaction(
          id: 't-7',
          invoice: '#DST-202610-006',
          date: DateTime.now().subtract(const Duration(days: 2)),
          items: '8 tabung',
          qty: 8,
          totalAmount: 152000,
          paidAmount: 152000,
          statusLabel: 'Lunas',
          statusType: BadgeType.success,
        ),
      ],
    ),
    CustomerModel(
      id: 'c7777777-7777-7777-7777-777777777777',
      name: 'Toko Kelontong Berkat',
      owner: 'Ko Asun',
      phone: '0852-9988-7766',
      address: 'Jl. Dahlia Timur No. 14',
      activeDebt: 0,
      totalCylinders: 12,
      lastOrderDate: DateTime.now().subtract(const Duration(days: 3)),
      transactions: [
        CustomerTransaction(
          id: 't-8',
          invoice: '#DST-202610-007',
          date: DateTime.now().subtract(const Duration(days: 3)),
          items: '12 tabung',
          qty: 12,
          totalAmount: 228000,
          paidAmount: 228000,
          statusLabel: 'Lunas',
          statusType: BadgeType.success,
        ),
      ],
    ),
  ];

  List<CustomerModel> getCustomers() => customersNotifier.value;

  List<CustomerModel> searchCustomers({
    required String query,
    required String filter, // 'Semua', 'Ada Utang', 'Lunas'
  }) {
    final cleanQuery = query.toLowerCase().trim();
    return customersNotifier.value.where((customer) {
      final matchesQuery = cleanQuery.isEmpty ||
          customer.name.toLowerCase().contains(cleanQuery) ||
          customer.owner.toLowerCase().contains(cleanQuery) ||
          customer.address.toLowerCase().contains(cleanQuery) ||
          customer.phone.contains(cleanQuery);

      if (!matchesQuery) return false;

      if (filter == 'Ada Utang') {
        return customer.hasDebt;
      } else if (filter == 'Lunas') {
        return !customer.hasDebt;
      }
      return true;
    }).toList();
  }

  void addCustomer(CustomerModel newCustomer) {
    final updated = List<CustomerModel>.from(customersNotifier.value)
      ..insert(0, newCustomer);
    customersNotifier.value = updated;
  }

  void payDebt(String customerId, int paidAmount) {
    final list = List<CustomerModel>.from(customersNotifier.value);
    final idx = list.indexWhere((c) => c.id == customerId);
    if (idx != -1) {
      final current = list[idx];
      final newDebt = (current.activeDebt - paidAmount).clamp(0, double.infinity).toInt();
      list[idx] = current.copyWith(activeDebt: newDebt);
      customersNotifier.value = list;
    }
  }
}
