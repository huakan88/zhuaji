import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/health/checkup_catalog.dart';
import '../../domain/health/life_stage.dart';
import '../../state/app_controller.dart';

class CheckupsPage extends StatelessWidget {
  const CheckupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    if (cat == null) {
      return const Scaffold(body: Center(child: Text('先选择一只猫')));
    }
    final plan = recommendCheckups(
      birthday: cat.birthday,
      breed: cat.breed,
      now: app.now,
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('体检')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            '${ageLabel(cat.birthday, app.now)} · ${lifeStageLabel(plan.stage)}',
            style: zhuaji.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (final advice in plan.items) ...[
            _CheckupCard(advice: advice),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _CheckupCard extends StatelessWidget {
  const _CheckupCard({required this.advice});

  final CheckupAdvice advice;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    DateTime? nextDue;
    for (final log in app.checkupsFor(advice.item.id)) {
      if (log.nextDue != null &&
          (nextDue == null || log.nextDue!.isBefore(nextDue))) {
        nextDue = log.nextDue;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        const SizedBox(height: 10),
        Text(
          advice.item.name,
          style: zhuaji.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          advice.plan.frequency,
          style: zhuaji.copyWith(color: AppColors.muted, height: 1.35),
        ),
        if (nextDue != null) ...[
          const SizedBox(height: 4),
          Text(
            formatDate(nextDue),
            style: zhuaji.copyWith(color: AppColors.muted, fontSize: 12),
          ),
        ],
        TextButton(
          onPressed: () async {
            await app.completeCheckup(
              itemId: advice.item.id,
              result: '已完成',
              intervalDays: advice.plan.intervalDays,
            );
            if (!context.mounted) return;
            showMessage(context, '记下了');
          },
          child: const Text('完成'),
        ),
      ],
    );
  }
}
