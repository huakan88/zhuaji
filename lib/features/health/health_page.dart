import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/weight_chart.dart';
import '../../domain/dates.dart';
import '../../domain/health/disease_catalog.dart';
import '../../domain/health/life_stage.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    if (cat == null) {
      return const Scaffold(body: Center(child: Text('先在首页选择一只猫')));
    }
    final days = _recordDays(app);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            Text(
              cat.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final entry in ['成长', '健康', '互动'].indexed)
                  Padding(
                    padding: const EdgeInsets.only(right: 22),
                    child: GestureDetector(
                      key: Key('tab-${entry.$2}'),
                      onTap: () => setState(() => _tab = entry.$1),
                      child: Column(
                        children: [
                          Text(
                            entry.$2,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: _tab == entry.$1 ? FontWeight.w700 : FontWeight.w500,
                              color: _tab == entry.$1 ? AppColors.ink : AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 18,
                            height: 3,
                            decoration: BoxDecoration(
                              color: _tab == entry.$1 ? AppColors.coralDeep : Colors.transparent,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_tab == 0) ..._growth(context, app, cat, days),
            if (_tab == 1) ..._health(context, app),
            if (_tab == 2) ..._play(context, app),
            const SizedBox(height: 8),
            const DisclaimerBanner(),
          ],
        ),
      ),
    );
  }

  int _recordDays(AppController app) {
    final points = <DateTime>[
      if (app.active != null) app.active!.createdAt,
      for (final item in app.catWeights) item.loggedOn,
      for (final item in app.photos) item.takenAt,
    ];
    if (points.isEmpty) return 1;
    final earliest = points.map(dateOnly).reduce((a, b) => a.isBefore(b) ? a : b);
    final days = dateOnly(app.now).difference(earliest).inDays;
    return days < 1 ? 1 : days;
  }

  List<Widget> _growth(BuildContext context, AppController app, CatProfile cat, int days) {
    return [
      SoftCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('已经一起', style: TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 4),
                  Text('$days 天', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, height: 1)),
                  const SizedBox(height: 6),
                  Text(
                    '从最早的记录算起 · ${ageLabel(cat.birthday, app.now)}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(Radii.m),
              child: SizedBox(
                width: 104,
                height: 128,
                child: CatImage(path: cat.avatarPath),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      const SectionHeader(title: '成长时间线'),
      const SizedBox(height: 10),
      SoftCard(child: _Dots(weights: app.catWeights)),
      const SizedBox(height: 16),
      const SectionHeader(title: '体重趋势'),
      const SizedBox(height: 10),
      SoftCard(child: WeightChart(weights: app.catWeights)),
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton(
          onPressed: () => showWeightSheet(context),
          child: const Text('记体重'),
        ),
      ),
      const SizedBox(height: 16),
      const SectionHeader(title: '称重记录'),
      for (final item in app.catWeights.reversed.take(6))
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
    ];
  }

  List<Widget> _health(BuildContext context, AppController app) {
    final cat = app.active!;
    final stage = lifeStageFor(cat.birthday, app.now);
    final done = app.careRing.where((item) => item.done).length;
    final percent = app.careRing.isEmpty ? 0 : (done * 100 / app.careRing.length).round();
    return [
      const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          '体检和疾病养护仅供参考，请遵医嘱。',
          style: TextStyle(color: AppColors.olive, fontSize: 12, height: 1.4),
        ),
      ),
      _linkCard(
        title: '按年龄体检',
        detail: '${ageLabel(cat.birthday, app.now)} · ${lifeStageLabel(stage)}',
        onTap: () => context.push('/checkups'),
      ),
      for (final condition in app.catConditions)
        _linkCard(
          title: diseaseById(condition.diseaseId)?.name ?? '已标记的疾病',
          detail:
              '${condition.stageLabel.isEmpty ? '已确诊' : condition.stageLabel}'
              '${condition.nextRecheck == null ? '' : ' · 复查 ${formatDate(condition.nextRecheck!)}'}',
          onTap: () => context.push('/disease?id=${condition.diseaseId}'),
        ),
      _linkCard(
        title: '疾病养护',
        detail: '常见病的饮食、饮水、复查和警示',
        onTap: () => context.push('/diseases'),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton(
          onPressed: () => showWaterSheet(context),
          child: Text('记饮水 · 今日 ${app.todayWaterMl.round()} ml'),
        ),
      ),
      const SizedBox(height: 16),
      SoftCard(
        child: Row(
          children: [
            SizedBox(
              width: 132,
              height: 132,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 42,
                      startDegreeOffset: -90,
                      sections: [
                        for (final slice in app.careRing)
                          PieChartSectionData(
                            value: 1,
                            color: slice.done ? AppColors.sage : AppColors.line,
                            radius: 16,
                            showTitle: false,
                          ),
                      ],
                    ),
                    duration: Duration.zero,
                  ),
                  Text('$percent%', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('本周照护', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
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
      const SizedBox(height: 16),
      SectionHeader(title: '疫苗', action: '添加', onAction: () => showVaccineSheet(context)),
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
      SectionHeader(title: '驱虫', action: '添加', onAction: () => showDewormSheet(context)),
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
      SectionHeader(title: '就医', action: '添加', onAction: () => showVisitSheet(context)),
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
    ];
  }

  List<Widget> _play(BuildContext context, AppController app) {
    return [
      const SectionHeader(title: '今日'),
      const SizedBox(height: 8),
      for (final task in app.todayTasks)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SoftCard(
            padding: const EdgeInsets.all(14),
            child: InkWell(
              onTap: () => _openTask(context, task.title),
              child: Row(
              children: [
                Icon(
                  task.done ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: task.done ? AppColors.sage : AppColors.muted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(task.detail, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      const SizedBox(height: 8),
      SectionHeader(title: '笔记', action: '写一条', onAction: () => showNoteSheet(context)),
      for (final item in app.catNotes)
        _record(
          title: item.content,
          detail: formatDate(item.notedOn),
          onTap: () => showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('这条笔记'),
              content: Text(item.content),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('关闭'),
                ),
              ],
            ),
          ),
          onDelete: () async {
            if (await confirmDelete(context, '删除这条笔记？')) {
              await app.removeNote(item.id);
            }
          },
        ),
      if (app.catNotes.isEmpty)
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('还没有笔记。', style: TextStyle(color: AppColors.muted)),
        ),
      OutlinedButton(
        onPressed: () => context.push('/feeding'),
        child: const Text('去记喂食'),
      ),
    ];
  }

  void _openTask(BuildContext context, String title) {
    switch (title) {
      case '今日喂食':
        context.push('/feeding');
      case '一周体重':
        showWeightSheet(context);
      case '疫苗日期':
        setState(() => _tab = 1);
    }
  }

  Widget _linkCard({
    required String title,
    required String detail,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(detail, style: const TextStyle(color: AppColors.muted)),
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

class _Dots extends StatelessWidget {
  const _Dots({required this.weights});

  final List<WeightRecord> weights;

  @override
  Widget build(BuildContext context) {
    if (weights.isEmpty) {
      return const Text('时间线会随着称重慢慢长出来。', style: TextStyle(color: AppColors.muted));
    }
    final shown = weights.length <= 5 ? weights : weights.sublist(weights.length - 5);
    return Row(
      children: [
        for (final item in shown)
          Expanded(
            child: Column(
              children: [
                Text(
                  formatMonthDay(item.loggedOn),
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(color: AppColors.sage, shape: BoxShape.circle),
                ),
                const SizedBox(height: 8),
                Text(
                  item.weightKg.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
