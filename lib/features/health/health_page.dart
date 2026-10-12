import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    if (cat == null) {
      return const Scaffold(
        body: Center(child: Text('先在首页选择一只猫')),
      );
    }
    final weights = app.catWeights;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text(
              '健康档案',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(cat.name, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: Space.x4),
            SoftCard(
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 38,
                            startDegreeOffset: -90,
                            sections: [
                              for (final slice in app.careRing)
                                PieChartSectionData(
                                  value: 1,
                                  color: slice.done ? AppColors.green : AppColors.line,
                                  radius: 14,
                                  showTitle: false,
                                ),
                            ],
                          ),
                          duration: Duration.zero,
                        ),
                        Text(
                          '${(app.careRing.where((item) => item.done).length * 100 / app.careRing.length).round()}%',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('照护环', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final slice in app.careRing)
                              TagChip(
                                label: slice.label,
                                tint: slice.done ? AppColors.tintGreen : AppColors.cream,
                                color: slice.done ? AppColors.olive : AppColors.muted,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.x4),
            const SectionHeader(title: '体重趋势'),
            const SizedBox(height: Space.x2),
            SoftCard(
              child: weights.length < 2
                  ? const Text('至少记下两次体重，曲线才会出现。', style: TextStyle(color: AppColors.muted))
                  : SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          minY: _minY(weights),
                          maxY: _maxY(weights),
                          gridData: const FlGridData(show: true, drawVerticalLine: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: weights.length > 6 ? 2 : 1,
                                getTitlesWidget: (value, meta) {
                                  final index = value.round();
                                  if (index < 0 || index >= weights.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      formatMonthDay(weights[index].loggedOn),
                                      style: const TextStyle(fontSize: 10, color: AppColors.muted),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                for (var i = 0; i < weights.length; i++)
                                  FlSpot(i.toDouble(), weights[i].weightKg),
                              ],
                              isCurved: true,
                              color: AppColors.olive,
                              barWidth: 3,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.green.withValues(alpha: 0.35),
                              ),
                            ),
                          ],
                        ),
                        duration: Duration.zero,
                      ),
                    ),
            ),
            const SizedBox(height: Space.x2),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: () => showWeightSheet(context),
                child: const Text('记体重'),
              ),
            ),
            const SizedBox(height: Space.x4),
            const SectionHeader(title: '成长时间线'),
            const SizedBox(height: Space.x2),
            SoftCard(child: _Timeline(app: app)),
            const SizedBox(height: Space.x5),
            SectionHeader(
              title: '疫苗',
              action: '添加',
              onAction: () => showVaccineSheet(context),
            ),
            for (final item in app.catVaccines)
              _record(
                title: item.name,
                detail:
                    '接种 ${formatDate(item.givenOn)}'
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
                detail:
                    '${formatDate(item.visitedOn)}'
                    '${item.clinic == null ? '' : ' · ${item.clinic}'}'
                    '${item.diagnosis == null ? '' : '\n${item.diagnosis}'}',
                onTap: () => showVisitSheet(context, existing: item),
                onDelete: () async {
                  if (await confirmDelete(context, '删除这条就医记录？')) {
                    await app.removeVisit(item.id);
                  }
                },
              ),
            SectionHeader(
              title: '笔记',
              action: '写一条',
              onAction: () => showNoteSheet(context),
            ),
            for (final item in app.catNotes)
              _record(
                title: item.content,
                detail: formatDate(item.notedOn),
                onDelete: () async {
                  if (await confirmDelete(context, '删除这条笔记？')) {
                    await app.removeNote(item.id);
                  }
                },
              ),
            const SizedBox(height: Space.x4),
            const DisclaimerBanner(),
          ],
        ),
      ),
    );
  }

  double _minY(List<WeightRecord> weights) {
    final min = weights.map((item) => item.weightKg).reduce((a, b) => a < b ? a : b);
    return (min - 0.3).clamp(0, 30);
  }

  double _maxY(List<WeightRecord> weights) {
    final max = weights.map((item) => item.weightKg).reduce((a, b) => a > b ? a : b);
    return max + 0.3;
  }

  Widget _record({
    required String title,
    required String detail,
    required Future<void> Function() onDelete,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title),
          subtitle: Text(detail, style: const TextStyle(color: AppColors.muted)),
          onTap: onTap,
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.muted),
            onPressed: () => onDelete(),
          ),
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.app});

  final AppController app;

  @override
  Widget build(BuildContext context) {
    final events = <({DateTime at, String title, String detail})>[
      for (final item in app.catWeights)
        (at: item.loggedOn, title: '体重 ${item.weightKg.toStringAsFixed(2)} kg', detail: '称重'),
      for (final item in app.photos)
        (at: item.takenAt, title: '体态照片', detail: item.note.isEmpty ? '对比用' : item.note),
      for (final item in app.catVisits)
        (at: item.visitedOn, title: item.reason, detail: '就医'),
      for (final item in app.catVaccines)
        (at: item.givenOn, title: item.name, detail: '疫苗'),
      for (final item in app.catDeworms)
        (at: item.givenOn, title: item.product, detail: dewormLabel(item.kind)),
    ]..sort((a, b) => b.at.compareTo(a.at));
    if (events.isEmpty) {
      return const Text('时间线会随着称重、照片和就医慢慢长出来。', style: TextStyle(color: AppColors.muted));
    }
    return Column(
      children: [
        for (final event in events.take(8))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.coral,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(width: 2, height: 36, color: AppColors.line),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(formatDate(event.at), style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                      Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(event.detail, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
