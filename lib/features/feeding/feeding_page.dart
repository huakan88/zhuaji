import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/feeding/feeding_math.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class FeedingPage extends StatelessWidget {
  const FeedingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    if (cat == null) {
      return const Scaffold(body: Center(child: Text('先选择一只猫')));
    }
    final calories = app.calories;
    final plan = app.activeTransition;
    final ratio = plan == null ? null : transitionRatio(transitionDayNumber(plan.startDate, app.now));
    return Scaffold(
      appBar: AppBar(title: Text('${cat.name}的喂养')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          SoftCard(
            color: AppColors.cream,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('热量估算', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  calories == null
                      ? '先记一次体重。估算用静息能量，绝育成猫约 ×1.2，幼猫 ×2.5，减重目标 ×0.8。'
                      : '${calories.summary}（系数 ${calories.factor}）。'
                          '${calories.assumedKcal ? '没有关联具体猫粮时，按示例 380 kcal/100g。' : '按最近一餐关联猫粮的示例热量。'}',
                  style: const TextStyle(height: 1.45),
                ),
                const SizedBox(height: 8),
                Text(
                  '今天已记录 ${app.todayGrams.round()} g',
                  style: const TextStyle(color: AppColors.olive, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.x4),
          FilledButton(
            onPressed: () => showFeedingSheet(context),
            child: const Text('记一餐'),
          ),
          const SizedBox(height: Space.x4),
          const SectionHeader(title: '今天和最近'),
          for (final meal in app.catFeedings.take(12))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SoftCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${slotLabel(meal.slot)} · ${meal.foodName}'),
                  subtitle: Text(
                    '${formatDate(meal.loggedAt)} ${formatClock(meal.loggedAt.hour, meal.loggedAt.minute)} · ${meal.grams.round()} g'
                    '${meal.kcal == null ? '' : ' · 约 ${meal.kcal!.round()} kcal'}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => app.removeFeeding(meal.id),
                  ),
                ),
              ),
            ),
          const SizedBox(height: Space.x4),
          const SectionHeader(title: '喂食提醒'),
          for (final slot in app.remindersFor(cat.id))
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SwitchListTile(
                title: Text(slot.slot == 0 ? '早餐' : '晚餐'),
                subtitle: Text(formatClock(slot.hour, slot.minute)),
                value: slot.enabled,
                onChanged: (value) => app.saveReminder(
                  slot.copyWith(enabled: value),
                ),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 8, minute: 0),
              );
              if (time == null) return;
              final slots = app.remindersFor(cat.id);
              final morning = slots.where((item) => item.slot == 0).firstOrNull;
              if (morning == null) return;
              await app.saveReminder(
                morning.copyWith(hour: time.hour, minute: time.minute, enabled: true),
              );
            },
            child: const Text('调整早餐时间'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 18, minute: 30),
              );
              if (time == null) return;
              final evening = app.remindersFor(cat.id).where((item) => item.slot == 1).firstOrNull;
              if (evening == null) return;
              await app.saveReminder(
                evening.copyWith(hour: time.hour, minute: time.minute, enabled: true),
              );
            },
            child: const Text('调整晚餐时间'),
          ),
          const SizedBox(height: Space.x5),
          const SectionHeader(title: '七日换粮'),
          SoftCard(
            child: plan == null || ratio == null
                ? const Text(
                    '换粮建议用 7 天：前两天新粮 25%，接着各两天 50% 和 75%，第七天全部换成新粮。每天早上会提醒。',
                    style: TextStyle(height: 1.45),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('第 ${ratio.day} 天', style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text('${plan.fromFood} → ${plan.toFood}'),
                      const SizedBox(height: 6),
                      Text(ratio.label, style: const TextStyle(color: AppColors.olive)),
                    ],
                  ),
          ),
          const SizedBox(height: 8),
          if (plan == null)
            FilledButton(
              onPressed: () => _start(context, app),
              child: const Text('开始 7 天换粮'),
            )
          else
            OutlinedButton(
              onPressed: () => app.removeTransition(plan.id),
              child: const Text('结束这次换粮'),
            ),
          const SizedBox(height: Space.x4),
          const DisclaimerBanner(),
        ],
      ),
    );
  }

  Future<void> _start(BuildContext context, AppController app) async {
    final from = TextEditingController();
    final to = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('开始换粮'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: from, decoration: const InputDecoration(labelText: '原来的粮')),
            const SizedBox(height: 12),
            TextField(controller: to, decoration: const InputDecoration(labelText: '新的粮')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('开始')),
        ],
      ),
    );
    if (ok == true && from.text.trim().isNotEmpty && to.text.trim().isNotEmpty) {
      await app.startTransition(fromFood: from.text, toFood: to.text);
    }
  }
}

extension on FeedingReminder {
  FeedingReminder copyWith({int? hour, int? minute, bool? enabled}) {
    return FeedingReminder(
      id: id,
      catId: catId,
      slot: slot,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      enabled: enabled ?? this.enabled,
    );
  }
}
