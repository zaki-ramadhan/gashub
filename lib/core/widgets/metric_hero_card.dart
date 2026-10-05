import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../formatters/app_formatters.dart';

/// Focal Hero Balance Card matching the reference design layout:
/// - Centered balance with eye toggle
/// - 3 circular quick action buttons directly under the balance
/// - Split Inflow / Outflow summary at the bottom with vertical separator
class MetricHeroCard extends StatefulWidget {
  const MetricHeroCard({
    super.key,
    required this.netCashflow,
    required this.cashIn,
    required this.cashOut,
    this.onDistribute,
    this.onRestock,
    this.onExpense,
  });

  final int netCashflow;
  final int cashIn;
  final int cashOut;
  final VoidCallback? onDistribute;
  final VoidCallback? onRestock;
  final VoidCallback? onExpense;

  @override
  State<MetricHeroCard> createState() => _MetricHeroCardState();
}

class _MetricHeroCardState extends State<MetricHeroCard> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.netCashflow >= 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space20,
        vertical: AppDimensions.space20,
      ),
      child: Column(
        children: [
          // 1. Centered "Available balance" + Eye Icon Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Skeleton.keep(
                child: const Text(
                  'Arus kas bersih hari ini',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Skeleton.ignore(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isVisible = !_isVisible;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      _isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 17,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 2. Large Centered Net Balance
          Text(
            _isVisible
                ? AppFormatters.currency(widget.netCashflow)
                : 'Rp ••••••••',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: isPositive ? AppColors.textPrimary : AppColors.dangerText,
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // 3. Three Circular Action Buttons (Fund / Deposit / Send style)
          Skeleton.ignore(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCircularAction(
                  icon: Icons.add,
                  label: 'Kirim Gas',
                  onTap: widget.onDistribute,
                ),
                const SizedBox(width: 32),
                _buildCircularAction(
                  icon: Icons.arrow_downward,
                  label: 'Tukar Truk',
                  onTap: widget.onRestock,
                ),
                const SizedBox(width: 32),
                _buildCircularAction(
                  icon: Icons.arrow_upward,
                  label: 'Bensin/Upah',
                  onTap: widget.onExpense,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space20),

          // 4. Subtle Inflow / Outflow Split Row
          Container(
            padding: const EdgeInsets.only(top: AppDimensions.space16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                // Inflow
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Skeleton.keep(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppColors.brandAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_downward,
                                size: 11,
                                color: AppColors.brandPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Kas Masuk',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isVisible ? AppFormatters.currency(widget.cashIn) : 'Rp ••••••',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Vertical Divider
                Container(
                  height: 36,
                  width: 1,
                  color: AppColors.border,
                ),

                // Outflow
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Skeleton.keep(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFEE2E2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_upward,
                                size: 11,
                                color: AppColors.dangerText,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Kas Keluar',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isVisible ? AppFormatters.currency(widget.cashOut) : 'Rp ••••••',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularAction({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        children: [
          Skeleton.replace(
            replacement: const Bone.circle(size: 48),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.canvas,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.0),
              ),
              child: Icon(icon, size: 22, color: AppColors.brandPrimary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
