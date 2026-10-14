import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../theme/app_fonts.dart';
import '../theme/app_tokens.dart';

/// A quiet line of the last weigh-ins, newest on the right.
class WeightTrend extends StatelessWidget {
  const WeightTrend({
    required this.weights,
    this.height = 64,
    this.limit = 8,
    super.key,
  });

  final List<WeightRecord> weights;
  final double height;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final sorted = [...weights]
      ..sort((a, b) => a.loggedOn.compareTo(b.loggedOn));
    final points = sorted.length > limit
        ? sorted.sublist(sorted.length - limit)
        : sorted;
    if (points.length < 2) {
      return Text(
        '再称一次就能看到走势',
        style: zhuaji.copyWith(fontSize: 12, color: AppColors.muted),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _TrendPainter([for (final item in points) item.weightKg]),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          trendLabel(points),
          style: zhuaji.copyWith(fontSize: 12, color: AppColors.muted),
        ),
      ],
    );
  }
}

String trendLabel(List<WeightRecord> points) {
  final sorted = [...points]..sort((a, b) => a.loggedOn.compareTo(b.loggedOn));
  final first = sorted.first;
  final last = sorted.last;
  final days =
      DateTime(last.loggedOn.year, last.loggedOn.month, last.loggedOn.day)
          .difference(
            DateTime(
              first.loggedOn.year,
              first.loggedOn.month,
              first.loggedOn.day,
            ),
          )
          .inDays;
  final span = days >= 14 ? '近 ${(days / 7).round()} 周' : '近 $days 天';
  final delta = last.weightKg - first.weightKg;
  if (delta.abs() < 0.005) return '$span 没变';
  final sign = delta > 0 ? '+' : '-';
  return '$span $sign${delta.abs().toStringAsFixed(2)} kg';
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    var low = values.reduce((a, b) => a < b ? a : b);
    var high = values.reduce((a, b) => a > b ? a : b);
    if (high - low < 0.2) {
      final mid = (high + low) / 2;
      low = mid - 0.1;
      high = mid + 0.1;
    }
    const inset = 6.0;
    final usable = size.height - inset * 2;
    Offset at(int index) {
      final x = values.length == 1
          ? size.width / 2
          : inset + (size.width - inset * 2) * index / (values.length - 1);
      final y = inset + usable * (1 - (values[index] - low) / (high - low));
      return Offset(x, y);
    }

    final guide = Paint()
      ..color = AppColors.line
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height - 0.5),
      Offset(size.width, size.height - 0.5),
      guide,
    );

    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < values.length; i++) {
      final point = at(i);
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.coralDeep
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final dot = Paint()..color = AppColors.coralDeep;
    for (var i = 0; i < values.length - 1; i++) {
      canvas.drawCircle(at(i), 2, dot);
    }
    final last = at(values.length - 1);
    canvas.drawCircle(last, 5, Paint()..color = AppColors.card);
    canvas.drawCircle(last, 4, dot);
  }

  @override
  bool shouldRepaint(_TrendPainter oldDelegate) =>
      oldDelegate.values.length != values.length ||
      [
        for (var i = 0; i < values.length; i++)
          oldDelegate.values[i] != values[i],
      ].any((changed) => changed);
}
