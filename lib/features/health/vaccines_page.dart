import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class VaccinesPage extends StatelessWidget {
  const VaccinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    if (app.active == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('疫苗')),
        body: const Center(child: Text('先选择一只猫')),
      );
    }
    final shots = [...app.catVaccines]
      ..sort((a, b) {
        final left = a.nextDue ?? a.givenOn;
        final right = b.nextDue ?? b.givenOn;
        return left.compareTo(right);
      });
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('疫苗')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            '点完成，下次日期会自己往后算。',
            style: zhuaji.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          if (shots.isEmpty)
            const EmptyHint(title: '还没记', body: '点下面记下这一针')
          else
            for (final shot in shots) ...[
              _ShotCard(shot: shot),
              const SizedBox(height: 12),
            ],
          FilledButton(
            onPressed: () => showVaccineSheet(context),
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

class _ShotCard extends StatelessWidget {
  const _ShotCard({required this.shot});

  final VaccineRecord shot;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final due = shot.nextDue;
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              shot.name,
              style: zhuaji.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '接种 ${formatDate(shot.givenOn)}',
              style: zhuaji.copyWith(color: AppColors.muted),
            ),
            Text(
              due == null
                  ? '下次还没定'
                  : '下次 ${formatDate(due)} · ${countdownOf(due, app.now)}',
              style: zhuaji.copyWith(color: AppColors.muted),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    final next = await app.completeVaccine(shot);
                    if (!context.mounted) return;
                    showMessage(context, '下次 ${formatDate(next)}');
                  },
                  child: const Text('完成'),
                ),
                TextButton(
                  onPressed: () => showVaccineSheet(context, existing: shot),
                  child: const Text('改'),
                ),
                TextButton(
                  onPressed: () async {
                    if (!await confirmDelete(context, '删掉这针？')) return;
                    await app.removeVaccine(shot.id);
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
