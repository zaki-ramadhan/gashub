import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/customer_model.dart';

/// Repository managing partner store directory & per-customer ledger via Supabase PostgreSQL.
class CustomersRepository {
  CustomersRepository._() {
    fetchCustomers();
  }
  static final CustomersRepository instance = CustomersRepository._();

  final ValueNotifier<List<CustomerModel>> customersNotifier =
      ValueNotifier<List<CustomerModel>>([]);

  Future<List<CustomerModel>> fetchCustomers() async {
    try {
      final client = Supabase.instance.client;
      final res = await client.from('customers').select('''
        id, name, phone, address, type, notes, active,
        receivables(id, remaining_amount, status),
        distributions(
          id, transaction_number, business_date, total, amount_paid, payment_status,
          distribution_items(quantity, unit_price, subtotal, product_id)
        )
      ''').order('name', ascending: true);

      final list = (res as List<dynamic>)
          .map((m) => CustomerModel.fromMap(m as Map<String, dynamic>))
          .toList();

      customersNotifier.value = list;
      return list;
    } catch (e) {
      debugPrint('Error fetching customers from Supabase: $e');
      return customersNotifier.value;
    }
  }

  List<CustomerModel> getCustomers() => customersNotifier.value;

  List<CustomerModel> searchCustomers({
    required String query,
    required String filter,
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

  Future<void> addCustomer(CustomerModel newCustomer) async {
    try {
      final client = Supabase.instance.client;
      await client.from('customers').insert({
        'name': newCustomer.name,
        'phone': newCustomer.phone,
        'address': newCustomer.address,
        'type': 'warung',
        'notes': newCustomer.owner,
        'active': true,
      });
      await fetchCustomers();
    } catch (e) {
      debugPrint('Error adding customer to Supabase: $e');
      final updated = List<CustomerModel>.from(customersNotifier.value)
        ..insert(0, newCustomer);
      customersNotifier.value = updated;
    }
  }

  Future<void> payDebt(String customerId, int paidAmount) async {
    try {
      final client = Supabase.instance.client;
      final recs = await client
          .from('receivables')
          .select('id, remaining_amount, paid_amount')
          .eq('customer_id', customerId)
          .neq('status', 'paid');

      if (recs.isNotEmpty) {
        final rec = recs.first;
        final recId = rec['id'] as String;
        final currentRemaining = (rec['remaining_amount'] as num).toInt();
        final currentPaid = (rec['paid_amount'] as num).toInt();

        final newRemaining = (currentRemaining - paidAmount).clamp(0, double.infinity).toInt();
        final newPaid = currentPaid + paidAmount;
        final newStatus = newRemaining == 0 ? 'paid' : 'partial';

        await client.from('receivables').update({
          'remaining_amount': newRemaining,
          'paid_amount': newPaid,
          'status': newStatus,
        }).eq('id', recId);

        final today = DateTime.now().toIso8601String().split('T')[0];
        await client.from('cashflow_entries').insert({
          'direction': 'in',
          'category': 'debt_payment',
          'source_type': 'receivable',
          'source_id': recId,
          'business_date': today,
          'amount': paidAmount,
          'method': 'cash',
          'notes': 'Pelunasan piutang pelanggan',
        });
      }
      await fetchCustomers();
    } catch (e) {
      debugPrint('Error updating customer debt: $e');
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
}
