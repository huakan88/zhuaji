import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/dates.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';

class PantryPage extends StatelessWidget {
  const PantryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final bags = [...app.pantry]
      ..sort((a, b) {
        final left = _sooner(a) ?? DateTime(2100);
        final right = _sooner(b) ?? DateTime(2100);
        return left.compareTo(right);
      });
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: zhuajiBar('粮仓'),
      body: FadeIn(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            Text(
              '点一袋看日期，可以标已吃完或删掉。',
              style: zhuaji.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            if (bags.isEmpty)
              EmptyHint(
                title: '还没有',
                body: '扫一袋就会出现在这里',
                action: '扫粮',
                onAction: () => context.push('/scan'),
              )
            else
              for (final entry in bags) ...[
                _BagRow(entry: entry),
                const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }
}

class _BagRow extends StatelessWidget {
  const _BagRow({required this.entry});

  final PantryEntry entry;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final sooner = _sooner(entry);
    final urgent =
        sooner != null &&
        !sooner.isAfter(dateOnly(app.now).add(const Duration(days: 14)));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => context.push('/bag?id=${entry.item.id}'),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 6,
                  color: urgent ? AppColors.coralDeep : AppColors.sage,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: zhuaji.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _status(entry, app.now),
                          style: zhuaji.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.muted,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _status(PantryEntry entry, DateTime now) {
    final sooner = _sooner(entry);
    final when = sooner == null ? '日期没填' : countdownOf(sooner, now);
    final open = entry.item.openedAt == null ? '没开封' : '已开封';
    return '$when · $open';
  }
}

DateTime? _sooner(PantryEntry entry) {
  final expiry = entry.item.expiryDate;
  final opened = entry.item.openedAt;
  DateTime? useBy;
  if (opened != null && entry.openWindowDays > 0) {
    useBy = dateOnly(opened).add(Duration(days: entry.openWindowDays));
  }
  DateTime? sooner;
  for (final date in [expiry, useBy]) {
    if (date == null) continue;
    final day = dateOnly(date);
    if (sooner == null || day.isBefore(sooner)) sooner = day;
  }
  return sooner;
}
