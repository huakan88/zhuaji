import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/weight_trend.dart';
import '../../domain/care/care_story.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';

class CatsPage extends StatelessWidget {
  const CatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    final kg = app.latestWeight?.weightKg;
    final events = cat == null
        ? const <CareEvent>[]
        : recentCare(
            catId: cat.id,
            vaccines: app.vaccines,
            deworms: app.deworms,
            visits: app.visits,
            checkups: app.checkups,
            weights: app.weights,
            now: app.now,
          );
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: zhuajiBar('猫咪'),
      body: FadeIn(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            SizedBox(
              height: 76,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final item in app.cats) ...[
                    GestureDetector(
                      onTap: () => app.selectCat(item.id),
                      child: SizedBox(
                        width: 64,
                        child: Column(
                          children: [
                            CatAvatar(
                              path: item.avatarPath,
                              size: 48,
                              selected: item.id == cat?.id,
                            ),
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: zhuaji.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  GestureDetector(
                    onTap: () => context.push('/cat-form'),
                    child: SizedBox(
                      width: 64,
                      child: Column(
                        children: [
                          const CatAvatar(path: null, size: 48),
                          Text('添加', style: zhuaji.copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionLabel('外观'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final mode in ZhuajiThemeMode.values)
                  ChoiceChip(
                    label: Text(mode.label),
                    selected: app.themeMode == mode,
                    onSelected: (_) => app.setThemeMode(mode),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (cat == null)
              EmptyHint(
                title: '还没猫',
                body: '拍一张，写个名字',
                action: '建档',
                onAction: () => context.push('/cat-form'),
              )
            else ...[
              HeroCard(
                path: cat.avatarPath,
                title: cat.name,
                subtitle: _meta(cat, app.now),
                height: 280,
                onTitleTap: () => context.push('/cat-form?id=${cat.id}'),
              ),
              const SizedBox(height: 12),
              QuietCard(
                child: Row(
                  children: [
                    const IconWell(icon: Icons.monitor_weight_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '体重',
                            style: zhuaji.copyWith(
                              fontSize: 12,
                              color: AppColors.of(context).muted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '体重在健康里改',
                            style: zhuaji.copyWith(
                              fontSize: 12,
                              color: AppColors.of(context).muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      kg == null ? '— kg' : '${kg.toStringAsFixed(2)} kg',
                      style: zhuaji.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (app.catWeights.length > 1) ...[
                const SizedBox(height: 8),
                QuietCard(child: WeightTrend(weights: app.catWeights)),
              ],
              const SizedBox(height: 24),
              const SectionLabel('最近'),
              const SizedBox(height: 8),
              _RecentCare(events: events),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text: vetCard(
                        cat: cat,
                        vaccines: app.vaccines,
                        deworms: app.deworms,
                        visits: app.visits,
                        weights: app.weights,
                        conditions: app.conditions,
                        now: app.now,
                        labs: app.labs,
                        foods: app.products,
                      ),
                    ),
                  );
                  if (!context.mounted) return;
                  showMessage(context, '已复制，可以发给医生');
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Icon(Icons.content_copy_outlined, size: 18),
                label: const Text('复制健康卡'),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () async {
                    if (await confirmDelete(context, '删除${cat.name}？')) {
                      await app.removeCat(cat.id);
                    }
                  },
                  child: const Text('删除'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _meta(CatProfile cat, DateTime now) {
    final parts = <String>[
      if (cat.breed != null && cat.breed!.isNotEmpty) cat.breed!,
      ageLabel(cat.birthday, now),
    ];
    return parts.join(' · ');
  }
}

class _RecentCare extends StatelessWidget {
  const _RecentCare({required this.events});

  final List<CareEvent> events;

  IconData _icon(CareKind kind) => switch (kind) {
    CareKind.vaccine => Icons.vaccines_outlined,
    CareKind.deworm => Icons.bug_report_outlined,
    CareKind.visit => Icons.local_hospital_outlined,
    CareKind.checkup => Icons.fact_check_outlined,
    CareKind.weight => Icons.monitor_weight_outlined,
  };

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Text(
        '记过的疫苗、驱虫和就医会出现在这里',
        style: zhuaji.copyWith(
          fontSize: 13,
          color: AppColors.of(context).muted,
        ),
      );
    }
    return QuietCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < events.length; i++) ...[
            if (i > 0) Divider(height: 1, color: AppColors.of(context).line),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(
                    _icon(events[i].kind),
                    size: 20,
                    color: AppColors.of(context).ink,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${events[i].title} · ${events[i].detail}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: zhuaji.copyWith(fontSize: 15),
                    ),
                  ),
                  Text(
                    formatMonthDay(events[i].on),
                    style: zhuaji.copyWith(
                      fontSize: 12,
                      color: AppColors.of(context).muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
