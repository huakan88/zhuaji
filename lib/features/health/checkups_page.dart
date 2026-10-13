import 'package:flutter/material.dart';

import '../../core/copy.dart';
import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/health/checkup_catalog.dart';
import '../../domain/health/life_stage.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

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
      appBar: AppBar(title: Text('${cat.name}的体检')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            '${ageLabel(cat.birthday, app.now)} · ${lifeStageLabel(plan.stage)}（${lifeStageRange(plan.stage)}）',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            cat.breed == null || cat.breed!.isEmpty ? '品种还没写' : '品种：${cat.breed}',
            style: const TextStyle(color: AppColors.muted),
          ),
          if (plan.birthdayMissing) ...[
            const SizedBox(height: 8),
            const Text(
              '档案里还没有生日，下面暂时按成年猫的基线列出。补上生日后会改到对应年龄段。',
              style: TextStyle(color: AppColors.brown, height: 1.4),
            ),
          ],
          const SizedBox(height: 12),
          const Text(
            kGuidelineSources,
            style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 16),
          for (final advice in plan.items) ...[
            _CheckupCard(advice: advice),
            const SizedBox(height: 10),
          ],
          const DisclaimerBanner(),
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
    final logs = app.checkupsFor(advice.item.id);
    CheckupRecord? latestDone;
    DateTime? nextDue;
    for (final log in logs) {
      if (log.completedOn != null &&
          (latestDone == null || log.completedOn!.isAfter(latestDone.completedOn!))) {
        latestDone = log;
      }
      if (log.nextDue != null && (nextDue == null || log.nextDue!.isBefore(nextDue))) {
        nextDue = log.nextDue;
      }
    }
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  advice.item.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              if (advice.becauseOfBreed)
                const TagChip(label: '品种相关', tint: AppColors.tintCoral, color: AppColors.coralDeep),
            ],
          ),
          const SizedBox(height: 6),
          Text(advice.plan.frequency, style: const TextStyle(height: 1.4)),
          const SizedBox(height: 6),
          Text(advice.item.why, style: const TextStyle(color: AppColors.muted, height: 1.4, fontSize: 13)),
          if (advice.becauseOfBreed) ...[
            const SizedBox(height: 4),
            Text(advice.item.breedReason, style: const TextStyle(color: AppColors.brown, fontSize: 12)),
          ],
          const SizedBox(height: 6),
          Text(
            '出处：${advice.item.source}',
            style: const TextStyle(color: AppColors.olive, fontSize: 12),
          ),
          if (latestDone != null) ...[
            const SizedBox(height: 8),
            Text(
              '最近一次 ${formatDate(latestDone.completedOn!)}：${latestDone.result}',
              style: const TextStyle(height: 1.35),
            ),
          ],
          if (nextDue != null) ...[
            const SizedBox(height: 4),
            Text(
              '下次提醒 ${formatDate(nextDue)}',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: () => showCheckupResultSheet(
                  context,
                  itemId: advice.item.id,
                  itemName: advice.item.name,
                  intervalDays: advice.plan.intervalDays,
                ),
                child: const Text('记录完成'),
              ),
              OutlinedButton(
                onPressed: () async {
                  final message = await app.scheduleCheckup(
                    itemId: advice.item.id,
                    intervalDays: advice.plan.intervalDays,
                  );
                  if (!context.mounted) return;
                  showMessage(
                    context,
                    message ?? '已加入提醒，可在提醒页查看',
                  );
                },
                child: const Text('加入提醒'),
              ),
              if (latestDone != null || logs.isNotEmpty)
                TextButton(
                  onPressed: () async {
                    final target = latestDone ?? logs.first;
                    if (await confirmDelete(context, '删除「${advice.item.name}」最近的一条记录？')) {
                      await app.removeCheckup(target.id);
                    }
                  },
                  child: const Text('删除最近一条'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
