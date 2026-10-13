import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/health/disease_catalog.dart';
import '../../domain/health/life_stage.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    if (cat == null) {
      return const Scaffold(body: Center(child: Text('先在首页选择一只猫')));
    }
    final latest = app.latestWeight;
    final stage = lifeStageFor(cat.birthday, app.now);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
          children: [
            Text(
              cat.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              latest == null
                  ? '还没有体重'
                  : '最近 ${latest.weightKg.toStringAsFixed(2)} kg',
              style: const TextStyle(color: AppColors.muted),
            ),
            const Text(
              '仅供参考，请遵医嘱。',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => showWeightSheet(context),
              child: const Text('记体重'),
            ),
            const SizedBox(height: 16),
            _link(
              title: '按年龄体检',
              detail:
                  '${ageLabel(cat.birthday, app.now)} · ${lifeStageLabel(stage)}',
              onTap: () => context.push('/checkups'),
            ),
            for (final condition in app.catConditions)
              _link(
                title: diseaseById(condition.diseaseId)?.name ?? '已标记的疾病',
                detail: condition.stageLabel.isEmpty
                    ? '已确诊'
                    : condition.stageLabel,
                onTap: () => context.push('/disease?id=${condition.diseaseId}'),
              ),
            _link(
              title: '疾病养护',
              detail: '只看和${cat.name}有关的',
              onTap: () => context.push('/diseases'),
            ),
            const SizedBox(height: 8),
            SectionHeader(
              title: '疫苗',
              action: '添加',
              onAction: () => showVaccineSheet(context),
            ),
            for (final item in app.catVaccines)
              _record(
                title: item.name,
                detail:
                    '${formatDate(item.givenOn)}'
                    '${item.nextDue == null ? '' : ' · 下次 ${formatDate(item.nextDue!)}'}',
                onTap: () => showVaccineSheet(context, existing: item),
                onDelete: () async {
                  if (await confirmDelete(context, '删除这条疫苗记录？')) {
                    await app.removeVaccine(item.id);
                  }
                },
              ),
            SectionHeader(
              title: '驱虫',
              action: '添加',
              onAction: () => showDewormSheet(context),
            ),
            for (final item in app.catDeworms)
              _record(
                title: '${dewormLabel(item.kind)} · ${item.product}',
                detail:
                    '${formatDate(item.givenOn)}'
                    '${item.nextDue == null ? '' : ' · 下次 ${formatDate(item.nextDue!)}'}',
                onTap: () => showDewormSheet(context, existing: item),
                onDelete: () async {
                  if (await confirmDelete(context, '删除这条驱虫记录？')) {
                    await app.removeDeworm(item.id);
                  }
                },
              ),
            SectionHeader(
              title: '就医',
              action: '添加',
              onAction: () => showVisitSheet(context),
            ),
            for (final item in app.catVisits)
              _record(
                title: item.reason,
                detail: formatDate(item.visitedOn),
                onTap: () => showVisitSheet(context, existing: item),
                onDelete: () async {
                  if (await confirmDelete(context, '删除这条就医记录？')) {
                    await app.removeVisit(item.id);
                  }
                },
              ),
            if (app.catWeights.isNotEmpty) ...[
              const SectionHeader(title: '体重'),
              for (final item in app.catWeights.reversed.take(4))
                _record(
                  title: '${item.weightKg.toStringAsFixed(2)} kg',
                  detail: formatDate(item.loggedOn),
                  onTap: () => showWeightSheet(context),
                  onDelete: () async {
                    if (await confirmDelete(context, '删除这次称重？')) {
                      await app.removeWeight(item.id);
                    }
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _link({
    required String title,
    required String detail,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            detail,
            style: const TextStyle(color: AppColors.muted),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _record({
    required String title,
    required String detail,
    required Future<void> Function() onDelete,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(title),
      subtitle: Text(detail, style: const TextStyle(color: AppColors.muted)),
      onTap: onTap,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: AppColors.muted),
        onPressed: () => onDelete(),
      ),
    );
  }
}
