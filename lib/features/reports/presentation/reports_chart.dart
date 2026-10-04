import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../domain/report_models.dart';

/// Clean, focused, high-contrast bar chart for depot operational reporting.
/// Features:
/// - Real calculated data from [dataPoints]
/// - Interactive toggle between Omset (Rupiah) and Volume (Tabung)
/// - Highlighted peak performance bar
/// - Interactive touch tooltips with formatted currency / quantities
/// - Minimalist horizontal grid and readable axis labels
class ReportsChartCard extends StatefulWidget {
  const ReportsChartCard({
    super.key,
    required this.dataPoints,
    required this.periodTitle,
  });

  final List<ReportDataPoint> dataPoints;
  final String periodTitle;

  @override
  State<ReportsChartCard> createState() => _ReportsChartCardState();
}

class _ReportsChartCardState extends State<ReportsChartCard> {
  // true = Omset (Rp), false = Volume (Tabung)
  bool _isOmsetMetric = true;

  @override
  Widget build(BuildContext context) {
    final points = widget.dataPoints;
    if (points.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: const Text(
          'Tidak ada data untuk periode ini',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      );
    }

    final values = points
        .map((p) => _isOmsetMetric ? p.omset.toDouble() : p.quantity.toDouble())
        .toList();
    final double maxVal = values.fold(0.0, (prev, e) => e > prev ? e : prev);
    final double maxY = maxVal > 0 ? maxVal * 1.25 : 100.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title & Interactive Metric Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isOmsetMetric ? 'Grafik Penjualan (Omset)' : 'Grafik Volume (Tabung)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isOmsetMetric ? 'Total omset per interval' : 'Jumlah tabung fisik terjual',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              // Segmented Metric Toggle
              Container(
                height: 32,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleItem(label: 'Rp Omset', isSelected: _isOmsetMetric, onTap: () {
                      if (!_isOmsetMetric) setState(() => _isOmsetMetric = true);
                    }),
                    _buildToggleItem(label: 'Tabung', isSelected: !_isOmsetMetric, onTap: () {
                      if (_isOmsetMetric) setState(() => _isOmsetMetric = false);
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space20),

          // Chart Display
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.textPrimary,
                    tooltipBorderRadius: BorderRadius.circular(8),
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final point = points[groupIndex];
                      final metricStr = _isOmsetMetric
                          ? AppFormatters.currency(point.omset)
                          : '${AppFormatters.number(point.quantity)} tabung';

                      return BarTooltipItem(
                        '${point.label}\n',
                        const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: metricStr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      interval: maxY > 0 ? maxY / 3 : 1,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) {
                          return const Text('0', style: TextStyle(fontSize: 10, color: AppColors.textMuted));
                        }
                        if (value >= maxY * 0.95) {
                          return const SizedBox.shrink();
                        }
                        String text;
                        if (_isOmsetMetric) {
                          if (value >= 1000000) {
                            text = '${(value / 1000000).toInt()}jt';
                          } else {
                            text = '${(value / 1000).toInt()}rb';
                          }
                        } else {
                          if (value >= 1000) {
                            text = '${(value / 1000).toStringAsFixed(1)}k';
                          } else {
                            text = value.toInt().toString();
                          }
                        }
                        return Text(
                          text,
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < points.length) {
                          final point = points[idx];
                          final isPeak = values[idx] == maxVal;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              point.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isPeak ? FontWeight.w600 : FontWeight.w400,
                                color: isPeak ? AppColors.textPrimary : AppColors.textMuted,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 3 : 1,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFF1F5F9),
                    strokeWidth: 1.0,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(points, values, maxVal, maxY),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.brandPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    List<ReportDataPoint> points,
    List<double> values,
    double maxVal,
    double maxY,
  ) {
    final count = points.length;
    final double rodWidth;
    if (count > 8) {
      rodWidth = 11.0;
    } else if (count > 4) {
      rodWidth = 18.0;
    } else {
      rodWidth = 26.0;
    }

    return List.generate(count, (i) {
      final val = values[i];
      final isPeak = val == maxVal;

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: val,
            width: rodWidth,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            color: isPeak ? AppColors.brandSuccess : AppColors.brandPrimary,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY,
              color: const Color(0xFFF8FAFC),
            ),
          ),
        ],
      );
    });
  }
}
