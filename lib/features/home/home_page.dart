import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/paw_icon.dart';
import '../../core/widgets/weight_chart.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    if (app.cats.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Space.x6),
            child: EmptyHint(
              title: '还没有猫咪',
              body: '先建立档案。每只猫的疫苗、体重和喂食都分开记。',
              action: '添加第一只猫',
              onAction: () => context.push('/cat-form'),
            ),
          ),
        ),
      );
    }
    final cat = app.active!;
    final happy = app.careScore >= 4;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            Row(
              children: [
                Expanded(child: _CatMenu(app: app, cat: cat)),
                IconButton(
                  onPressed: () => context.push('/reminders'),
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(Radii.xl),
              child: SizedBox(
                height: 460,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CatImage(path: cat.avatarPath),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0x661E1E1E)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      top: 14,
                      child: _FloatBadge(
                        icon: Icons.favorite_rounded,
                        label: happy ? '心情 开心' : '心情 ${app.mood}',
                      ),
                    ),
                    Positioned(
                      left: 14,
                      top: 52,
                      child: _FloatBadge(
                        icon: Icons.health_and_safety_outlined,
                        label: app.careScore >= 3 ? '健康 良好' : '健康 留意',
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: _Greeting(app: app, happy: happy),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SoftCard(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '照护 Lv.${app.careScore + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Text(
                        '亲密 ${app.careScore}/5',
                        style: const TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: app.careScore / 5,
                      backgroundColor: AppColors.cream,
                      color: AppColors.sage,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _quick(context, Icons.restaurant_outlined, '喂食', AppColors.tintCoral, () => context.push('/feeding')),
                _quick(context, Icons.favorite_border_rounded, '健康', AppColors.tintGreen, () => context.go('/health')),
                _quick(context, Icons.qr_code_scanner_rounded, '扫码', AppColors.cream, () => context.push('/scan')),
                _quick(context, Icons.monitor_weight_outlined, '体重', AppColors.tintCoral, () => showWeightSheet(context)),
              ],
            ),
            const SizedBox(height: 22),
            const SectionHeader(title: '成长记录'),
            const SizedBox(height: 10),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.latestWeight == null
                        ? '还没有体重'
                        : '最近 ${app.latestWeight!.weightKg.toStringAsFixed(2)} kg',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  WeightChart(weights: app.catWeights, compact: true),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SectionHeader(
              title: '最近日记',
              action: '全部',
              onAction: () => context.push('/photos'),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 112,
              child: app.photos.isEmpty
                  ? const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('还没有体态照片', style: TextStyle(color: AppColors.muted)),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: app.photos.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final photo = app.photos[app.photos.length - 1 - index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(Radii.m),
                          child: SizedBox(
                            width: 112,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CatImage(path: photo.path),
                                Positioned(
                                  left: 8,
                                  bottom: 8,
                                  child: Text(
                                    formatMonthDay(photo.takenAt),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _BigCard(app: app),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _SmallCard(
                        title: '驱虫',
                        headline: app.nextExternal == null && app.nextInternal == null
                            ? '还没记录'
                            : '体内 ${app.nextInternal?.nextDue == null ? '—' : formatMonthDay(app.nextInternal!.nextDue!)}',
                        detail: app.nextExternal?.nextDue == null
                            ? '点健康页补上'
                            : '体外 ${formatMonthDay(app.nextExternal!.nextDue!)}',
                        onTap: () => context.go('/health'),
                      ),
                      const SizedBox(height: 12),
                      _SmallCard(
                        title: '临期猫粮',
                        headline: app.nearestExpiry?.product.name ?? '粮仓是空的',
                        detail: app.nearestExpiry?.item.expiryDate == null
                            ? '扫一条码开始'
                            : countdownOf(app.nearestExpiry!.item.expiryDate!, app.now),
                        onTap: () => context.go('/pantry'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const DisclaimerBanner(),
          ],
        ),
      ),
    );
  }

  Widget _quick(
    BuildContext context,
    IconData icon,
    String label,
    Color tint,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: tint,
                shape: BoxShape.circle,
                boxShadow: softShadow,
              ),
              child: Icon(icon, color: AppColors.ink, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _CatMenu extends StatelessWidget {
  const _CatMenu({required this.app, required this.cat});

  final AppController app;
  final CatProfile cat;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      offset: const Offset(0, 48),
      onSelected: (id) {
        if (id == -1) {
          context.push('/cat-form');
          return;
        }
        app.selectCat(id);
      },
      itemBuilder: (context) => [
        for (final item in app.cats)
          PopupMenuItem(value: item.id, child: Text(item.name)),
        const PopupMenuItem(value: -1, child: Text('添加猫咪')),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                cat.name,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
            ],
          ),
          Text(
            ageLabel(cat.birthday, app.now),
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _FloatBadge extends StatelessWidget {
  const _FloatBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xF7FFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.coralDeep),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.app, required this.happy});

  final AppController app;
  final bool happy;

  @override
  Widget build(BuildContext context) {
    final fed = app.todayFeedings.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xF7FFFFFF),
        borderRadius: BorderRadius.circular(Radii.l),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.tintCoral,
              shape: BoxShape.circle,
            ),
            child: const PawIcon(size: 18, color: AppColors.coralDeep),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  happy ? '今天过得很开心' : '今天想多陪一会儿',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  fed
                      ? '已经记下 ${app.todayGrams.round()} g，想和你玩逗猫棒。'
                      : '还没记下今天的一餐。',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BigCard extends StatelessWidget {
  const _BigCard({required this.app});

  final AppController app;

  @override
  Widget build(BuildContext context) {
    final due = app.nextVaccine?.nextDue;
    return GestureDetector(
      onTap: () => context.go('/health'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.l),
        child: SizedBox(
          height: 210,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CatImage(path: app.photos.isEmpty ? app.active?.avatarPath : app.photos.last.path),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xCC2C2A28)],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '下次疫苗',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      app.nextVaccine?.name ?? '还没记录',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      due == null ? '到健康页补上日期' : formatDate(due),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallCard extends StatelessWidget {
  const _SmallCard({
    required this.title,
    required this.headline,
    required this.detail,
    required this.onTap,
  });

  final String title;
  final String headline;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            const SizedBox(height: 6),
            Text(
              headline,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(detail, style: const TextStyle(fontSize: 12, color: AppColors.brown)),
          ],
        ),
      ),
    );
  }
}
