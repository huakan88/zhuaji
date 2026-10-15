import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/haptics.dart';
import '../../core/widgets/care_timeline.dart';
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
                      onTap: () {
                        pawTap();
                        app.selectCat(item.id);
                      },
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
                height: 220,
                onTitleTap: () => context.push('/cat-form?id=${cat.id}'),
              ),
              const SizedBox(height: 12),
              QuietCard(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        pawTap();
                        context.push('/cat-form?id=${cat.id}');
                      },
                      child: Column(
                        children: [
                          _ProfileLine(
                            label: '品种',
                            value: (cat.breed == null || cat.breed!.isEmpty)
                                ? '还没写'
                                : cat.breed!,
                          ),
                          Divider(
                            height: 16,
                            color: AppColors.of(context).line,
                          ),
                          _ProfileLine(
                            label: '年龄',
                            value: ageLabel(cat.birthday, app.now),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 16, color: AppColors.of(context).line),
                    GestureDetector(
                      onTap: () {
                        pawTap();
                        context.push('/weight');
                      },
                      child: _ProfileLine(
                        label: '体重',
                        value: kg == null
                            ? '还没称'
                            : '${kg.toStringAsFixed(2)} kg',
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
              CareTimeline(events: events, empty: '记过的事会出现在这里'),
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

class _ProfileLine extends StatelessWidget {
  const _ProfileLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: zhuaji.copyWith(
              fontSize: 13,
              color: AppColors.of(context).muted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: zhuaji.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
