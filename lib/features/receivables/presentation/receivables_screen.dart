import 'package:flutter/material.dart';
import '../../../core/core.dart';

class ReceivablesScreen extends StatefulWidget {
  const ReceivablesScreen({super.key});

  @override
  State<ReceivablesScreen> createState() => _ReceivablesScreenState();
}

class _ReceivablesScreenState extends State<ReceivablesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeFilter = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static final List<Map<String, dynamic>> _receivablesData = [
    {
      'customer': 'Warung Barokah (Pak Slamet)',
      'phone': '0812-3456-7890',
      'remaining': 1250000,
      'dueDate': DateTime.now().subtract(const Duration(days: 4)),
      'invoice': '#DST-202610-001',
      'statusLabel': 'Lewat Tempo',
      'statusType': BadgeType.danger,
    },
    {
      'customer': 'Toko Berkah Ibu',
      'phone': '0813-9876-5432',
      'remaining': 380000,
      'dueDate': DateTime.now().add(const Duration(days: 3)),
      'invoice': '#DST-202610-002',
      'statusLabel': 'Mendekati',
      'statusType': BadgeType.warning,
    },
    {
      'customer': 'Warung Kelontong Bu Siti',
      'phone': '0857-1122-3344',
      'remaining': 190000,
      'dueDate': DateTime.now().add(const Duration(days: 1)),
      'invoice': '#DST-202610-004',
      'statusLabel': 'Mendekati',
      'statusType': BadgeType.warning,
    },
    {
      'customer': 'RM Padang Sederhana',
      'phone': '0821-4455-6677',
      'remaining': 860000,
      'dueDate': DateTime.now().add(const Duration(days: 7)),
      'invoice': '#DST-202610-005',
      'statusLabel': 'Lancar',
      'statusType': BadgeType.info,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _receivablesData.where((item) {
      if (_activeFilter == 'Lewat Tempo' && item['statusLabel'] != 'Lewat Tempo') {
        return false;
      }
      if (_activeFilter == 'Mendekati' && item['statusLabel'] != 'Mendekati') {
        return false;
      }
      if (_activeFilter == 'Lancar' && item['statusLabel'] != 'Lancar') {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = (item['customer'] as String).toLowerCase();
        final inv = (item['invoice'] as String).toLowerCase();
        if (!name.contains(query) && !inv.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

    final totalOutstanding = filtered.fold<int>(0, (sum, i) => sum + (i['remaining'] as int));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Piutang Warung'),
      ),
      body: Column(
        children: [
          // 1. Total Piutang Highlight Card (Clean surface, no harsh green block)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.space16,
              AppDimensions.space4,
              AppDimensions.space16,
              AppDimensions.space12,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.space16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total tagihan piutang beredar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
                        ),
                      ),
                      StatusBadge(label: 'Perlu Ditagih', type: BadgeType.warning),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  Text(
                    AppFormatters.currency(totalOutstanding),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dangerText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dari ${filtered.length} transaksi warung mitra aktif',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),

          // 2. Search & Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Cari nama warung / no faktur...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space12,
                      vertical: AppDimensions.space8,
                    ),
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: AppDimensions.space10),
                Row(
                  children: [
                    _buildFilterChip('Semua'),
                    const SizedBox(width: AppDimensions.space8),
                    _buildFilterChip('Lewat Tempo'),
                    const SizedBox(width: AppDimensions.space8),
                    _buildFilterChip('Mendekati'),
                    const SizedBox(width: AppDimensions.space8),
                    _buildFilterChip('Lancar'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space12),

          // 3. Daftar Pelanggan Berhutang
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada data piutang yang cocok.',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.space8),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final dueDate = item['dueDate'] as DateTime;
                      final diffDays = dueDate.difference(DateTime.now()).inDays;
                      final dueString = diffDays < 0
                          ? 'Telat ${diffDays.abs()} hari (Jatuh tempo: ${AppFormatters.date(dueDate)})'
                          : 'Sisa $diffDays hari (Jatuh tempo: ${AppFormatters.date(dueDate)})';

                      return FlatTransactionRow(
                        title: item['customer'] as String,
                        subtitle: '${item['invoice']} • $dueString',
                        subtitleColor: diffDays < 0 ? AppColors.dangerText : AppColors.textMuted,
                        amount: AppFormatters.currency(item['remaining'] as int),
                        amountColor: AppColors.dangerText,
                        statusLabel: item['statusLabel'] as String,
                        statusType: item['statusType'] as BadgeType,
                        trailingAction: InkWell(
                          onTap: () => _showPaymentSheet(context, item),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Text(
                              'Bayar',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.brandPrimary,
                              ),
                            ),
                          ),
                        ),
                        onTap: () => _showPaymentSheet(context, item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, Map<String, dynamic> item) {
    final payController = TextEditingController(text: item['remaining'].toString());
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return AppBottomSheet(
              title: 'Pelunasan Piutang Warung',
              bottomAction: AppButton(
                text: 'Simpan Pembayaran',
                isLoading: isSaving,
                onPressed: () async {
                  final amount = int.tryParse(payController.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
                  if (amount <= 0) {
                    AppToast.warning(title: 'Nominal belum valid');
                    return;
                  }

                  setSheetState(() => isSaving = true);
                  await Future.delayed(const Duration(milliseconds: 350));
                  if (!ctx.mounted) return;

                  Navigator.of(ctx, rootNavigator: true).pop();
                  AppToast.success(title: 'Pembayaran berhasil disimpan');
                },
              ),
              child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Warung Card
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['customer'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Invoice: ${item['invoice']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Sisa Piutang',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    Text(
                      AppFormatters.currency(item['remaining'] as int),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dangerText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // Nominal Pembayaran Input
          const Text(
            'Nominal Pembayaran (Rp)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: payController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              prefixText: 'Rp ',
              hintText: '0',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pastikan nominal uang tunai atau transfer sesuai sebelum menyimpan.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
              ),
            );
          },
        );
      },
    );
  }
}
