import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/core.dart';
import '../../dashboard/data/dashboard_repository.dart';
import '../../distribution/data/distribution_repository.dart';
import '../../receivables/data/receivables_repository.dart';
import '../domain/customer_model.dart';

/// Repository managing partner store directory & per-customer ledger via Supabase PostgreSQL.
class CustomersRepository {
  CustomersRepository._();
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
    final list = customersNotifier.value.where((customer) {
      final matchesQuery = cleanQuery.isEmpty ||
          customer.name.toLowerCase().contains(cleanQuery) ||
          customer.owner.toLowerCase().contains(cleanQuery) ||
          customer.address.toLowerCase().contains(cleanQuery) ||
          customer.phone.contains(cleanQuery);

      if (!matchesQuery) return false;

      if (filter == 'Ada Utang') {
        return customer.hasDebt;
      }
      return true;
    }).toList();

    if (filter == 'Ada Utang') {
      list.sort((a, b) => b.activeDebt.compareTo(a.activeDebt));
    } else if (filter == 'Paling Banyak Order') {
      list.sort((a, b) {
        final cmp = b.totalCylinders.compareTo(a.totalCylinders);
        if (cmp != 0) return cmp;
        return b.totalSpending.compareTo(a.totalSpending);
      });
    } else {
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    return list;
  }

  Future<CustomerModel> addCustomer(CustomerModel newCustomer) async {
    try {
      final client = Supabase.instance.client;
      final res = await client.from('customers').insert({
        'name': newCustomer.name,
        'phone': newCustomer.phone,
        'address': newCustomer.address,
        'type': 'warung',
        'notes': newCustomer.owner,
        'active': true,
      }).select().single();
      final created = CustomerModel.fromMap(res);
      await fetchCustomers();
      return created;
    } catch (e) {
      debugPrint('Error adding customer to Supabase: $e');
      final fallback = newCustomer.id.isEmpty
          ? newCustomer.copyWith(id: 'temp_${DateTime.now().millisecondsSinceEpoch}')
          : newCustomer;
      final updated = List<CustomerModel>.from(customersNotifier.value)
        ..insert(0, fallback);
      customersNotifier.value = updated;
      return fallback;
    }
  }

  Future<void> payDebt(String customerId, int paidAmount) async {
    try {
      final client = Supabase.instance.client;
      final recs = await client
          .from('receivables')
          .select('id, remaining_amount, paid_amount, source_distribution_id')
          .eq('customer_id', customerId)
          .neq('status', 'paid')
          .order('created_at', ascending: true);

      int remainingToPay = paidAmount;
      final today = DateTime.now().toIso8601String().split('T')[0];

      for (final r in recs as List<dynamic>) {
        if (remainingToPay <= 0) break;
        final row = r as Map<String, dynamic>;
        final recId = row['id'] as String;
        final currentRemaining = (row['remaining_amount'] as num).toInt();
        final currentPaid = (row['paid_amount'] as num).toInt();
        final sourceDistId = row['source_distribution_id'] as String?;

        final payThis = remainingToPay >= currentRemaining ? currentRemaining : remainingToPay;
        final newRemaining = currentRemaining - payThis;
        final newPaid = currentPaid + payThis;
        final newStatus = newRemaining == 0 ? 'paid' : 'partial';

        // 1. Update receivable
        await client.from('receivables').update({
          'remaining_amount': newRemaining,
          'paid_amount': newPaid,
          'status': newStatus,
        }).eq('id', recId);

        final paymentNumber = 'PAY-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

        // 2. Record payment audit
        await client.from('payments').insert({
          'payment_number': paymentNumber,
          'receivable_id': recId,
          'customer_id': customerId,
          'business_date': today,
          'amount': payThis,
          'method': 'cash',
          'notes': 'Pelunasan piutang pelanggan',
        });

        // 3. Record cashflow entry
        await client.from('cashflow_entries').insert({
          'direction': 'in',
          'category': 'debt_payment',
          'source_type': 'receivable',
          'source_id': recId,
          'business_date': today,
          'amount': payThis,
          'method': 'cash',
          'notes': 'Pelunasan piutang pelanggan',
        });

        // 4. Synchronize source distribution
        if (sourceDistId != null) {
          final dist = await client
              .from('distributions')
              .select('id, total, amount_paid')
              .eq('id', sourceDistId)
              .maybeSingle();
          if (dist != null) {
            final distTotal = (dist['total'] as num).toInt();
            final distPaid = (dist['amount_paid'] as num).toInt() + payThis;
            final distStatus = distPaid >= distTotal ? 'paid' : (distPaid > 0 ? 'partial' : 'unpaid');
            await client.from('distributions').update({
              'amount_paid': distPaid,
              'payment_status': distStatus,
            }).eq('id', sourceDistId);
          }
        }

        remainingToPay -= payThis;
      }

      await Future.wait([
        fetchCustomers(),
        ReceivablesRepository.instance.fetchReceivables(),
        DistributionRepository.instance.fetchDistributions(),
        DashboardRepository.instance.fetchDashboardMetrics(),
        DashboardRepository.instance.fetchCashflowEntries(),
      ]);
    } catch (e) {
      debugPrint('Error updating customer debt: $e');
      final list = List<CustomerModel>.from(customersNotifier.value);
      final idx = list.indexWhere((c) => c.id == customerId);
      if (idx != -1) {
        final current = list[idx];
        final newDebt = (current.activeDebt - paidAmount).clamp(0, double.infinity).toInt();
        final updatedTxs = current.transactions.map((tx) {
          if (tx.isUnpaid) {
            return tx.copyWith(
              paidAmount: tx.totalAmount,
              statusLabel: 'Lunas',
              statusType: BadgeType.success,
            );
          }
          return tx;
        }).toList();
        list[idx] = current.copyWith(
          activeDebt: newDebt,
          transactions: updatedTxs,
        );
        customersNotifier.value = list;
      }
    }
  }
}
