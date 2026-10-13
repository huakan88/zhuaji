import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class DewormsPage extends StatelessWidget {
  const DewormsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    if (app.active == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('驱虫')),
        body: const Center(child: Text('先选择一只猫')),
      );
    }
    final items = [...app.catDeworms]
      ..sort((a, b) {
        final left = a.nextDue ?? a.givenOn;
        final right = b.nextDue ?? b.givenOn;
        return left.compareTo(right);
      });
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('驱虫')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            '体内体外分开记。完成后下次默认 90 天。',
            style: zhuaji.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const EmptyHint(title: '还没记', body: '点下面选药')
          else
            for (final item in items) ...[
              _WormCard(item: item),
              const SizedBox(height: 12),
            ],
          FilledButton(
            onPressed: () => showDewormSheet(context),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: const Text('记下'),
          ),
        ],
      ),
    );
  }
}

class _WormCard extends StatelessWidget {
  const _WormCard({required this.item});

  final DewormRecord item;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final due = item.nextDue;
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dewormLabel(item.kind),
              style: zhuaji.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(item.product, style: zhuaji.copyWith(color: AppColors.muted)),
            Text(
              due == null
                  ? '使用 ${formatDate(item.givenOn)}'
                  : '下次 ${formatDate(due)} · ${countdownOf(due, app.now)}',
              style: zhuaji.copyWith(color: AppColors.muted),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    final next = await app.completeDeworm(item);
                    if (!context.mounted) return;
                    showMessage(context, '下次 ${formatDate(next)}');
                  },
                  child: const Text('完成'),
                ),
                TextButton(
                  onPressed: () => showDewormSheet(context, existing: item),
                  child: const Text('改'),
                ),
                TextButton(
                  onPressed: () async {
                    if (!await confirmDelete(context, '删掉这次？')) return;
                    await app.removeDeworm(item.id);
                  },
                  child: const Text('删除'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
