import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/dates.dart';
import '../../domain/food/stock.dart';
import '../../state/app_controller.dart';

class BagPage extends StatelessWidget {
  const BagPage({required this.pantryId, super.key});

  final int pantryId;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final entry = app.pantryById(pantryId);
    if (entry == null) {
      return Scaffold(
        appBar: zhuajiBar('这袋粮'),
        body: const Center(child: Text('这袋已经不在了')),
      );
    }
    final opened = entry.item.openedAt;
    final useBy = opened == null || entry.openWindowDays <= 0
        ? null
        : dateOnly(opened).add(Duration(days: entry.openWindowDays));
    final estimate = estimateStock(
      spec: entry.product.spec,
      dailyGrams: entry.item.dailyGrams,
      openedAt: opened,
      today: dateOnly(app.now),
    );
    final storage = entry.product.storageMethod.trim();
    final sentence = storage.isEmpty
        ? '阴凉干燥，封好袋口。'
        : (storage.split('。').first.endsWith('。')
              ? storage.split('。').first
              : '${storage.split('。').first}。');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: zhuajiBar('这袋粮'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            entry.product.name,
            style: zhuaji.copyWith(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            entry.product.brand,
            style: zhuaji.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          _line(
            '生产',
            entry.item.productionDate == null
                ? '没填'
                : formatDate(entry.item.productionDate!),
          ),
          _line(
            '到期',
            entry.item.expiryDate == null
                ? '没填'
                : formatDate(entry.item.expiryDate!),
          ),
          _line('开封', opened == null ? '没开' : formatDate(opened)),
          _line('还能吃', useBy == null ? '看包装' : '到 ${formatDate(useBy)}'),
          _line('余量', stockHint(estimate)),
          const SizedBox(height: 8),
          Text(
            '每天喂多少',
            style: zhuaji.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final grams in dailyGramChoices)
                ChoiceChip(
                  label: Text('$grams 克'),
                  selected: entry.item.dailyGrams == grams.toDouble(),
                  selectedColor: AppColors.tintCoral,
                  onSelected: (_) => app.setDailyGrams(entry, grams.toDouble()),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(sentence, style: zhuaji.copyWith(height: 1.4)),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () async {
              await app.removePantry(entry.item.id);
              if (!context.mounted) return;
              showMessage(context, '吃完了');
              context.pop();
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: const Text('已吃完'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
              if (!await confirmDelete(context, '删掉这袋？')) return;
              await app.removePantry(entry.item.id);
              if (!context.mounted) return;
              context.pop();
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: zhuaji.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value, style: zhuaji)),
        ],
      ),
    );
  }
}
