import 'package:flutter/material.dart';
import 'package:flutter_solar_icons/linear.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../formatters/app_formatters.dart';
import 'metric_hero_actions_row.dart';
import 'metric_hero_cashflow_row.dart';

/// Focal Hero Balance Card with persistent privacy toggle via SharedPreferences.
class MetricHeroCard extends StatefulWidget {
  const MetricHeroCard({
    super.key,
    required this.netCashflow,
    required this.cashIn,
    required this.cashOut,
    this.onCheckStock,
    this.onReceivables,
    this.onCustomers,
    this.onCashInTap,
    this.onCashOutTap,
  });

  final int netCashflow;
  final int cashIn;
  final int cashOut;
  final VoidCallback? onCheckStock;
  final VoidCallback? onReceivables;
  final VoidCallback? onCustomers;
  final VoidCallback? onCashInTap;
  final VoidCallback? onCashOutTap;

  @override
  State<MetricHeroCard> createState() => _MetricHeroCardState();
}

class _MetricHeroCardState extends State<MetricHeroCard> {
  static const String _prefKey = 'is_dashboard_balance_visible';
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _loadVisibilityPreference();
  }

  Future<void> _loadVisibilityPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(_prefKey);
      if (saved != null && mounted) setState(() => _isVisible = saved);
    } catch (_) {}
  }

  Future<void> _toggleVisibility() async {
    final next = !_isVisible;
    setState(() => _isVisible = next);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, next);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.netCashflow >= 0;
    final isSkeleton = Skeletonizer.maybeOf(context)?.enabled ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      padding: const EdgeInsets.all(AppDimensions.space20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Skeleton.keep(
                child: const Text(
                  'Sisa uang hari ini',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(width: 8),
              Skeleton.ignore(
                child: InkWell(
                  onTap: _toggleVisibility,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: _isVisible
                        ? const EyeLinearIcon(size: 17, color: AppColors.textPrimary)
                        : const EyeClosedLinearIcon(size: 17, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isSkeleton ? 'Rp 2.450.000' : (_isVisible ? AppFormatters.currency(widget.netCashflow) : 'Rp ******'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
                color: isPositive ? AppColors.textPrimary : AppColors.dangerText,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          MetricHeroActionsRow(
            onCheckStock: widget.onCheckStock,
            onReceivables: widget.onReceivables,
            onCustomers: widget.onCustomers,
          ),
          const SizedBox(height: AppDimensions.space20),
          MetricHeroCashflowRow(
            cashIn: widget.cashIn,
            cashOut: widget.cashOut,
            isVisible: _isVisible,
            isSkeleton: isSkeleton,
            onCashInTap: widget.onCashInTap,
            onCashOutTap: widget.onCashOutTap,
          ),
        ],
      ),
    );
  }
}
