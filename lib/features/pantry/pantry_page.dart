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
      appBar: AppBar(title: const Text('粮仓')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
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
          if (bags.isNotEmpty) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.push('/scan'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text('扫粮'),
            ),
          ],
        ],
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
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/bag?id=${entry.item.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
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
                      _status(entry, app.now),
                      style: zhuaji.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted, size: 20),
            ],
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
