import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../customers/data/customers_repository.dart';
import '../domain/receivable_model.dart';

/// Repository managing outstanding customer debts and payment recording via Supabase PostgreSQL.
class ReceivablesRepository {
  ReceivablesRepository._() {
    fetchReceivables();
  }
  static final ReceivablesRepository instance = ReceivablesRepository._();

  final ValueNotifier<List<ReceivableModel>> receivablesNotifier =
      ValueNotifier<List<ReceivableModel>>([]);

  Future<List<ReceivableModel>> fetchReceivables() async {
    try {
      final client = Supabase.instance.client;
      final res = await client.from('receivables').select('''
        id, original_amount, paid_amount, remaining_amount, status, created_at,
        customers(id, name, phone, address, notes),
        distributions(id, transaction_number, business_date, total)
      ''').neq('status', 'paid').order('remaining_amount', ascending: false);

      final List<ReceivableModel> mapped = [];

      for (final row in res as List<dynamic>) {
        final r = row as Map<String, dynamic>;
        final customer = r['customers'] as Map<String, dynamic>?;
        final dist = r['distributions'] as Map<String, dynamic>?;

        final status = r['status']?.toString() ?? 'unpaid';
        final date = DateTime.tryParse(dist?['business_date']?.toString() ?? '') ?? DateTime.now();

        mapped.add(ReceivableModel(
          id: r['id'] as String,
          customerId: customer?['id'] as String? ?? '',
          customerName: customer?['name'] as String? ?? 'Pelanggan',
          phone: customer?['phone'] as String? ?? '',
          remainingAmount: (r['remaining_amount'] as num?)?.toInt() ?? 0,
          originalAmount: (r['original_amount'] as num?)?.toInt() ?? 0,
          paidAmount: (r['paid_amount'] as num?)?.toInt() ?? 0,
          date: date,
          invoiceNumber: '#${dist?['transaction_number'] ?? ''}',
          status: status,
        ));
      }

      receivablesNotifier.value = mapped;
      return mapped;
    } catch (e) {
      debugPrint('Error fetching receivables from Supabase: $e');
      return receivablesNotifier.value;
    }
  }

  Future<void> recordPayment({
    required String receivableId,
    required int amount,
    String method = 'cash',
    String? notes,
  }) async {
    try {
      final client = Supabase.instance.client;

      // 1. Fetch current receivable
      final rec = await client
          .from('receivables')
          .select('id, customer_id, remaining_amount, paid_amount')
          .eq('id', receivableId)
          .single();

      final customerId = rec['customer_id'] as String;
      final currentRemaining = (rec['remaining_amount'] as num).toInt();
      final currentPaid = (rec['paid_amount'] as num).toInt();

      final newRemaining = (currentRemaining - amount).clamp(0, double.infinity).toInt();
      final newPaid = currentPaid + amount;
      final newStatus = newRemaining == 0 ? 'paid' : 'partial';

      // 2. Update receivable
      await client.from('receivables').update({
        'remaining_amount': newRemaining,
        'paid_amount': newPaid,
        'status': newStatus,
      }).eq('id', receivableId);

      final today = DateTime.now().toIso8601String().split('T')[0];

      // 3. Record payment
      await client.from('payments').insert({
        'receivable_id': receivableId,
        'customer_id': customerId,
        'business_date': today,
        'amount': amount,
        'method': method,
        'notes': notes ?? 'Pembayaran piutang',
      });

      // 4. Record cashflow entry
      await client.from('cashflow_entries').insert({
        'direction': 'in',
        'category': 'debt_payment',
        'source_type': 'receivable',
        'source_id': receivableId,
        'business_date': today,
        'amount': amount,
        'method': method,
        'notes': notes ?? 'Pembayaran cicilan / lunas piutang',
      });

      // 5. Refresh both receivables and customers
      await fetchReceivables();
      await CustomersRepository.instance.fetchCustomers();
    } catch (e) {
      debugPrint('Error recording payment in Supabase: $e');
      rethrow;
    }
  }
}
