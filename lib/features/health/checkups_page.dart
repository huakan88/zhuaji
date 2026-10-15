import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/health/checkup_catalog.dart';
import '../../domain/health/lab_catalog.dart';
import '../../domain/health/life_stage.dart';
import '../../state/app_controller.dart';

class CheckupsPage extends StatefulWidget {
  const CheckupsPage({super.key});

  @override
  State<CheckupsPage> createState() => _CheckupsPageState();
}

class _CheckupsPageState extends State<CheckupsPage> {
  String? _selected;
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    if (cat == null) {
      return Scaffold(
        backgroundColor: AppColors.of(context).background,
        appBar: zhuajiBar('体检'),
        body: const Center(child: Text('先选择一只猫')),
      );
    }
    final plan = recommendCheckups(
      birthday: cat.birthday,
      breed: cat.breed,
      now: app.now,
    );
    final selectedId = _selected ??= plan.items.isEmpty
        ? ''
        : plan.items.first.item.id;
    CheckupAdvice? selected;
    for (final advice in plan.items) {
      if (advice.item.id == selectedId) selected = advice;
    }
    selected ??= plan.items.isEmpty ? null : plan.items.first;
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: zhuajiBar('体检'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          Text(
            '${ageLabel(cat.birthday, app.now)} · ${lifeStageLabel(plan.stage)}',
            style: zhuaji.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final advice in plan.items)
                ChoiceChip(
                  label: Text(advice.item.name),
                  selected: advice.item.id == selected?.item.id,
                  selectedColor: AppColors.of(context).brandTint,
                  onSelected: (_) => setState(() => _selected = advice.item.id),
                ),
            ],
          ),
          if (selected != null) ...[
            const SizedBox(height: 12),
            Text(
              selected.plan.frequency,
              style: zhuaji.copyWith(
                color: AppColors.of(context).muted,
                height: 1.35,
              ),
            ),
            if (suggestedLabKind(selected.item.id) != null) ...[
              const SizedBox(height: 8),
              Text(
                '做完后去存化验单',
                style: zhuaji.copyWith(
                  fontSize: 13,
                  color: AppColors.of(context).brandDeep,
                ),
              ),
            ],
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: selected == null || _busy
                ? null
                : () async {
                    final advice = selected;
                    if (advice == null) return;
                    setState(() => _busy = true);
                    await app.completeCheckup(
                      itemId: advice.item.id,
                      result: '已完成',
                      intervalDays: advice.plan.intervalDays,
                    );
                    if (!mounted) return;
                    setState(() => _busy = false);
                    if (!context.mounted) return;
                    showMessage(context, '记下了');
                    final kind = suggestedLabKind(advice.item.id);
                    if (kind != null) {
                      context.push(
                        '/lab?kind=${kind.name}&checkup=${advice.item.id}',
                      );
                    }
                  },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('完成'),
          ),
        ),
      ),
    );
  }
}
