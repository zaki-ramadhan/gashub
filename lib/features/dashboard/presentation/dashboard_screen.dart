import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';
import '../../distribution/presentation/distribution_form_sheet.dart';
import '../../inventory/presentation/restock_form_sheet.dart';
import '../../reports/presentation/expense_form_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Gradient ends roughly at the vertical middle of MetricHeroCard.
  static const double _headerGradientHeight = 180;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: AppColors.brandPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        automaticallyImplyLeading: false,
        titleSpacing: AppDimensions.space16,
        title: Builder(
          builder: (context) {
            final now = DateTime.now();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppFormatters.dayOfWeek(now),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppFormatters.fullDate(now),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withValues(alpha: 0.82),
                    height: 1.15,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.space16),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.notifications_none,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  AppToast.info(title: 'Tidak ada notifikasi baru');
                },
                tooltip: 'Notifikasi',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _headerGradientHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.brandPrimary, AppColors.canvas],
                    stops: [0.2, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
                vertical: AppDimensions.space12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Focal Hero Balance Card (Sesuai Referensi)
                  MetricHeroCard(
                    netCashflow: 2400000,
                    cashIn: 4500000,
                    cashOut: 2100000,
                    onDistribute: () => DistributionFormSheet.show(context),
                    onRestock: () => RestockFormSheet.show(context),
                    onExpense: () => ExpenseFormSheet.show(context),
                  ),
                  const SizedBox(height: AppDimensions.space12),

                  // 2. Secondary Quick Tools Card (Sesuai Referensi Card 2)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border, width: 1.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.space16,
                      horizontal: AppDimensions.space8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSecondaryAction(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Utang Warung',
                          onTap: () => context.push('/piutang'),
                        ),
                        _buildSecondaryAction(
                          icon: Icons.propane_tank_outlined,
                          label: 'Stok Tabung',
                          onTap: () => context.go('/stok'),
                        ),
                        _buildSecondaryAction(
                          icon: Icons.pie_chart_outline,
                          label: 'Kuota 3kg',
                          onTap: () => context.go('/laporan'),
                        ),
                        _buildSecondaryAction(
                          icon: Icons.bar_chart_outlined,
                          label: 'Untung Rugi',
                          onTap: () => context.go('/laporan'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // 3. Recent Transaction Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Distribusi Terkini',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      InkWell(
                        onTap: () => context.go('/distribusi'),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusPill,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusPill,
                            ),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text(
                            'Lihat semua',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.brandPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space10),

                  // 4. Standalone Pill-Shaped Transaction Cards (Tanpa Divider Tempel)
                  FlatTransactionRow(
                    title: 'Warung Madura Pak Joko',
                    subtitle: '15 tabung • 14:30 WIB',
                    amount: AppFormatters.currency(285000),
                    statusLabel: 'Lunas',
                    statusType: BadgeType.success,
                    icon: Icons.arrow_upward,
                    iconColor: AppColors.brandPrimary,
                    iconBg: AppColors.brandAccent,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppDimensions.space8),

                  FlatTransactionRow(
                    title: 'Toko Berkah Ibu',
                    subtitle: '20 tabung • 13:15 WIB',
                    amount: AppFormatters.currency(380000),
                    statusLabel: 'Sebagian',
                    statusType: BadgeType.warning,
                    icon: Icons.schedule,
                    iconColor: AppColors.warningText,
                    iconBg: const Color(0xFFFEF3C7),
                    onTap: () {},
                  ),
                  const SizedBox(height: AppDimensions.space8),

                  FlatTransactionRow(
                    title: 'Pangkalan Barokah H. Slamet',
                    subtitle: '30 tabung • 11:00 WIB',
                    amount: AppFormatters.currency(570000),
                    statusLabel: 'Belum Bayar',
                    statusType: BadgeType.danger,
                    icon: Icons.priority_high,
                    iconColor: AppColors.dangerText,
                    iconBg: const Color(0xFFFEE2E2),
                    onTap: () {},
                  ),
                  const SizedBox(height: 96),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.canvas,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, size: 20, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
