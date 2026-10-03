import 'package:flutter/material.dart';
import '../../../core/core.dart';
import 'distribution_form_sheet.dart';

class DistributionScreen extends StatefulWidget {
  const DistributionScreen({super.key});

  @override
  State<DistributionScreen> createState() => _DistributionScreenState();
}

class _DistributionScreenState extends State<DistributionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'Semua';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const List<Map<String, dynamic>> _allTransactions = [
    {
      'title': 'Warung Madura Pak Joko',
      'items': '15 tabung',
      'time': '14:30 WIB',
      'amount': 285000,
      'statusType': BadgeType.success,
      'statusLabel': 'Lunas',
      'icon': Icons.check,
      'iconColor': AppColors.brandSuccess,
      'iconBg': AppColors.brandAccent,
    },
    {
      'title': 'Toko Berkah Ibu',
      'items': '20 tabung',
      'time': '13:15 WIB',
      'amount': 380000,
      'statusType': BadgeType.warning,
      'statusLabel': 'Belum Lunas',
      'icon': Icons.schedule,
      'iconColor': AppColors.warningText,
      'iconBg': Color(0xFFFEF3C7),
    },
    {
      'title': 'Pangkalan Barokah H. Slamet',
      'items': '30 tabung',
      'time': '11:00 WIB',
      'amount': 570000,
      'statusType': BadgeType.danger,
      'statusLabel': 'Belum Bayar',
      'icon': Icons.priority_high,
      'iconColor': AppColors.dangerText,
      'iconBg': Color(0xFFFEE2E2),
    },
    {
      'title': 'Warung Kelontong Bu Siti',
      'items': '10 tabung',
      'time': '09:45 WIB',
      'amount': 190000,
      'statusType': BadgeType.success,
      'statusLabel': 'Lunas',
      'icon': Icons.check,
      'iconColor': AppColors.brandSuccess,
      'iconBg': AppColors.brandAccent,
    },
    {
      'title': 'RM Padang Sederhana',
      'items': '25 tabung',
      'time': '08:30 WIB',
      'amount': 475000,
      'statusType': BadgeType.success,
      'statusLabel': 'Lunas',
      'icon': Icons.check,
      'iconColor': AppColors.brandSuccess,
      'iconBg': AppColors.brandAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _allTransactions.where((tx) {
      // 1. Filter Chip Matching
      if (_activeFilter == 'Lunas' && tx['statusLabel'] != 'Lunas') {
        return false;
      }
      if (_activeFilter == 'Sebagian (Tempo)' && tx['statusLabel'] != 'Sebagian (Tempo)') {
        return false;
      }
      if (_activeFilter == 'Belum Bayar' && tx['statusLabel'] != 'Belum Bayar') {
        return false;
      }

      // 2. Search Query Matching
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = (tx['title'] as String).toLowerCase();
        final items = (tx['items'] as String).toLowerCase();
        if (!title.contains(query) && !items.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribusi Gas'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.space16),
            child: ElevatedButton.icon(
              onPressed: () => DistributionFormSheet.show(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Catat Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: AppDimensions.space4),

          // Filter Bar & Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 14),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari nama warung...',
                    hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 12, right: 8),
                      child: Icon(Icons.search, size: 20, color: AppColors.textMuted),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    isDense: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: AppDimensions.space10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua'),
                      const SizedBox(width: AppDimensions.space8),
                      _buildFilterChip('Lunas'),
                      const SizedBox(width: AppDimensions.space8),
                      _buildFilterChip('Belum Lunas'),
                      const SizedBox(width: AppDimensions.space8),
                      _buildFilterChip('Belum Bayar'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space8),

          // Daftar Transaksi Dipisah Per Item
          Expanded(
            child: filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(AppDimensions.space24),
                    child: Center(
                      child: Text(
                        'Tidak ada data distribusi yang cocok dengan pencarian / filter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(
                      left: AppDimensions.space16,
                      right: AppDimensions.space16,
                      top: AppDimensions.space8,
                      bottom: 96,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.space8),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return FlatTransactionRow(
                        title: item['title'] as String,
                        subtitle: item['items'] as String,
                        amount: AppFormatters.currency(item['amount'] as int),
                        statusLabel: item['statusLabel'] as String,
                        statusType: item['statusType'] as BadgeType,
                        time: item['time'] as String?,
                        icon: item['icon'] as IconData?,
                        iconColor: item['iconColor'] as Color?,
                        iconBg: item['iconBg'] as Color?,
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
      onTap: () {
        setState(() {
          _activeFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary : Colors.transparent,
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
}
