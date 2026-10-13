import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../format.dart';
import '../theme/app_tokens.dart';

class WeightChart extends StatelessWidget {
  const WeightChart({required this.weights, this.compact = false, super.key});

  final List<WeightRecord> weights;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (weights.length < 2) {
      return Text(
        compact ? '再记一次体重，曲线才会出现' : '至少记下两次体重，曲线才会出现。',
        style: const TextStyle(color: AppColors.muted, fontSize: 12),
      );
    }
    final min = weights
        .map((item) => item.weightKg)
        .reduce((a, b) => a < b ? a : b);
    final max = weights
        .map((item) => item.weightKg)
        .reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: compact ? 88 : 188,
      child: LineChart(
        LineChartData(
          minY: (min - 0.25).clamp(0, 40),
          maxY: max + 0.25,
          gridData: FlGridData(
            show: !compact,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: AppColors.line, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: compact
              ? const FlTitlesData(show: false)
              : FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: weights.length > 6 ? 2 : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.round();
                        if (index < 0 || index >= weights.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            formatMonthDay(weights[index].loggedOn),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.muted,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < weights.length; i++)
                  FlSpot(i.toDouble(), weights[i].weightKg),
              ],
              isCurved: true,
              color: AppColors.sage,
              barWidth: compact ? 2.5 : 3,
              dotData: FlDotData(show: !compact),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.green.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
        duration: Duration.zero,
      ),
    );
  }
}
