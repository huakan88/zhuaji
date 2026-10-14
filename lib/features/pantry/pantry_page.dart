import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/dates.dart';
import '../../domain/food/stock.dart';
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
            QuietCard(
              onTap: () => context.push('/catalog'),
              child: Row(
                children: [
                  const IconWell(icon: Icons.menu_book_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '图鉴',
                          style: zhuaji.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '搜已有的，也能看自己加的',
                          style: zhuaji.copyWith(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionLabel('先到期的排在上面'),
            const SizedBox(height: 8),
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
    return QuietCard(
      onTap: () => context.push('/bag?id=${entry.item.id}'),
      child: Row(
        children: [
          const IconWell(icon: Icons.inventory_2_outlined),
          const SizedBox(width: 12),
          Expanded(
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
                  _stockLine(entry, app.now),
                  style: zhuaji.copyWith(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _when(entry, app.now),
            style: zhuaji.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  String _stockLine(PantryEntry entry, DateTime now) {
    final estimate = estimateStock(
      spec: entry.product.spec,
      dailyGrams: entry.item.dailyGrams,
      openedAt: entry.item.openedAt,
      today: now,
    );
    if (estimate.daysLeft != null) return stockHint(estimate);
    return entry.item.openedAt == null ? '没开封' : '已开封';
  }

  String _when(PantryEntry entry, DateTime now) {
    final sooner = _sooner(entry);
    if (sooner == null) return '日期没填';
    return countdownOf(sooner, now);
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
