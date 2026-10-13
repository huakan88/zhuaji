import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
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
    final weightLine = latest == null
        ? '还没有体重'
        : '最近 ${latest.weightKg.toStringAsFixed(2)} kg';
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
          children: [
            Text(
              cat.name,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              weightLine,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => showWeightSheet(context),
              child: const Text('记体重'),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                TextButton(
                  onPressed: () => context.push('/checkups'),
                  child: const Text('体检'),
                ),
                TextButton(
                  onPressed: () => context.push('/diseases'),
                  child: const Text('养护'),
                ),
              ],
            ),
            SectionHeader(
              title: '疫苗',
              action: '添加',
              onAction: () => showVaccineSheet(context),
            ),
            if (app.catVaccines.isEmpty) const _QuietLine('还没记'),
            for (final item in app.catVaccines)
              _record(
                title: item.name,
                detail:
                    '${formatDate(item.givenOn)}'
                    '${item.nextDue == null ? '' : ' · 下次 ${formatDate(item.nextDue!)}'}',
                onTap: () => showVaccineSheet(context, existing: item),
                onComplete: () async {
                  final next = await app.completeVaccine(item);
                  if (!context.mounted) return;
                  showMessage(context, '下次 ${formatDate(next)}');
                },
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
            if (app.catDeworms.isEmpty) const _QuietLine('还没记'),
            for (final item in app.catDeworms)
              _record(
                title: '${dewormLabel(item.kind)} · ${item.product}',
                detail:
                    '${formatDate(item.givenOn)}'
                    '${item.nextDue == null ? '' : ' · 下次 ${formatDate(item.nextDue!)}'}',
                onTap: () => showDewormSheet(context, existing: item),
                onComplete: () async {
                  final next = await app.completeDeworm(item);
                  if (!context.mounted) return;
                  showMessage(context, '下次 ${formatDate(next)}');
                },
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
            if (app.catVisits.isEmpty) const _QuietLine('还没记'),
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
              for (final item in app.catWeights.reversed.take(1))
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
            const SizedBox(height: 12),
            const Text(
              '仅供参考，请遵医嘱。',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _record({
    required String title,
    required String detail,
    required Future<void> Function() onDelete,
    VoidCallback? onTap,
    Future<void> Function()? onComplete,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(title),
      subtitle: Text(detail, style: const TextStyle(color: AppColors.muted)),
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onComplete != null)
            TextButton(
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => onComplete(),
              child: const Text('已完成'),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.muted),
            onPressed: () => onDelete(),
          ),
        ],
      ),
    );
  }
}

class _QuietLine extends StatelessWidget {
  const _QuietLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.muted, height: 1.35),
      ),
    );
  }
}
