import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class VisitsPage extends StatelessWidget {
  const VisitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    if (app.active == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('就医')),
        body: const Center(child: Text('先选择一只猫')),
      );
    }
    final visits = app.catVisits;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('就医')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            '先点原因，再保存。这是你自己的记录。',
            style: zhuaji.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          if (visits.isEmpty)
            const EmptyHint(title: '还没去过', body: '点下面记下这一次')
          else
            for (final visit in visits) ...[
              _VisitCard(visit: visit),
              const SizedBox(height: 12),
            ],
          FilledButton(
            onPressed: () => showVisitSheet(context),
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

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.visit});

  final VetRecord visit;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final place = (visit.clinic ?? '').trim();
    final diagnosis = (visit.diagnosis ?? '').trim();
    final treatment = (visit.treatment ?? '').trim();
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              visit.reason,
              style: zhuaji.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              place.isEmpty
                  ? formatDate(visit.visitedOn)
                  : '${formatDate(visit.visitedOn)} · $place',
              style: zhuaji.copyWith(color: AppColors.muted),
            ),
            if (diagnosis.isNotEmpty)
              Text(diagnosis, style: zhuaji.copyWith(height: 1.4)),
            if (treatment.isNotEmpty)
              Text(
                treatment,
                style: zhuaji.copyWith(color: AppColors.muted, height: 1.4),
              ),
            Row(
              children: [
                TextButton(
                  onPressed: () => showVisitSheet(context, existing: visit),
                  child: const Text('改'),
                ),
                TextButton(
                  onPressed: () async {
                    if (!await confirmDelete(context, '删掉这次？')) return;
                    await app.removeVisit(visit.id);
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
