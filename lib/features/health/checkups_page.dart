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
import 'known_or_custom.dart';
import 'need_cat.dart';

class CheckupsPage extends StatefulWidget {
  const CheckupsPage({super.key});

  @override
  State<CheckupsPage> createState() => _CheckupsPageState();
}

class _CheckupsPageState extends State<CheckupsPage> {
  final _customText = TextEditingController();
  String? _selected;
  var _custom = false;
  var _busy = false;

  @override
  void dispose() {
    _customText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    if (cat == null) return const NeedCatPage(title: '体检');
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
          KnownOrCustom(
            known: [for (final advice in plan.items) advice.item.name],
            selected: selected?.item.name ?? '',
            custom: _custom,
            controller: _customText,
            hint: '项目',
            onKnown: (label) => setState(() {
              _custom = false;
              for (final advice in plan.items) {
                if (advice.item.name == label) {
                  _selected = advice.item.id;
                  break;
                }
              }
            }),
            onCustom: () => setState(() => _custom = true),
          ),
          if (_custom) ...[
            const SizedBox(height: 12),
            Text(
              '按你写的名字记下，一年后再提醒。',
              style: zhuaji.copyWith(
                color: AppColors.of(context).muted,
                height: 1.35,
              ),
            ),
          ] else if (selected != null) ...[
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
            onPressed: (!_custom && selected == null) || _busy
                ? null
                : () async {
                    final advice = selected;
                    late final String itemId;
                    late final int intervalDays;
                    if (_custom) {
                      final typed = _customText.text.trim();
                      if (typed.isEmpty) {
                        showMessage(context, '先写上项目');
                        return;
                      }
                      itemId = typed;
                      intervalDays = 365;
                    } else if (advice != null) {
                      itemId = advice.item.id;
                      intervalDays = advice.plan.intervalDays;
                    } else {
                      return;
                    }
                    setState(() => _busy = true);
                    await app.completeCheckup(
                      itemId: itemId,
                      result: '已完成',
                      intervalDays: intervalDays,
                    );
                    if (!mounted) return;
                    setState(() => _busy = false);
                    if (!context.mounted) return;
                    showMessage(context, '记下了');
                    if (_custom) return;
                    final kind = suggestedLabKind(itemId);
                    if (kind != null) {
                      context.push('/lab?kind=${kind.name}&checkup=$itemId');
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
