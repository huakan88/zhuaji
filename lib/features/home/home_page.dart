import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
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
    final calories = app.calories;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatDate(app.now),
                        style: const TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                      const Text(
                        '爪记',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/reminders'),
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ],
            ),
            const SizedBox(height: Space.x3),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: app.cats.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  if (index == app.cats.length) {
                    return GestureDetector(
                      onTap: () => context.push('/cat-form'),
                      child: const Column(
                        children: [
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.cream,
                              ),
                              child: Icon(Icons.add_rounded),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text('添加', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    );
                  }
                  final item = app.cats[index];
                  final selected = item.id == cat.id;
                  return GestureDetector(
                    onTap: () => app.selectCat(item.id),
                    child: Column(
                      children: [
                        CatAvatar(
                          path: item.avatarPath,
                          size: 64,
                          selected: selected,
                          ring: ringPalette[index % ringPalette.length],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: Space.x4),
            ClipRRect(
              borderRadius: BorderRadius.circular(Radii.xl),
              child: SizedBox(
                height: 300,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CatImage(path: cat.avatarPath),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0xCC1E1E1E)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (cat.breed != null)
                                TagChip(label: cat.breed!, tint: Colors.white),
                              if (cat.coatColor != null)
                                TagChip(
                                  label: cat.coatColor!,
                                  tint: AppColors.green,
                                ),
                              TagChip(
                                label: ageLabel(cat.birthday, app.now),
                                tint: Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _stat('今日状态', app.mood),
                              const SizedBox(width: 8),
                              _stat(
                                '体重',
                                app.latestWeight == null
                                    ? '未记'
                                    : '${app.latestWeight!.weightKg.toStringAsFixed(2)} kg',
                              ),
                              const SizedBox(width: 8),
                              _stat('今日进食', '${app.todayGrams.round()} g'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Space.x5),
            Row(
              children: [
                _quick(context, Icons.restaurant_outlined, '喂食', const Color(0xFFFFF1EA), () => context.push('/feeding')),
                _quick(context, Icons.favorite_border_rounded, '健康', const Color(0xFFF4F8EA), () => context.go('/health')),
                _quick(context, Icons.qr_code_scanner_rounded, '扫码', const Color(0xFFF6F1E8), () => context.push('/scan')),
                _quick(context, Icons.monitor_weight_outlined, '体重', const Color(0xFFFFF1EA), () => showWeightSheet(context)),
                _quick(context, Icons.notifications_none_rounded, '提醒', const Color(0xFFF4F8EA), () => context.push('/reminders')),
              ],
            ),
            const SizedBox(height: Space.x5),
            const SectionHeader(title: '今日照护'),
            const SizedBox(height: Space.x3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final task in app.todayTasks) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                task.done
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                color: task.done ? AppColors.olive : AppColors.muted,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      task.detail,
                                      style: const TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _mini(
                        '下次疫苗',
                        app.nextVaccine?.name ?? '还没记录',
                        app.nextVaccine?.nextDue == null
                            ? '点健康页添加'
                            : formatDate(app.nextVaccine!.nextDue!),
                        () => context.go('/health'),
                      ),
                      const SizedBox(height: 12),
                      _mini(
                        '临期猫粮',
                        app.nearestExpiry?.product.name ?? '粮仓是空的',
                        app.nearestExpiry?.item.expiryDate == null
                            ? '扫一条码开始'
                            : countdownOf(app.nearestExpiry!.item.expiryDate!, app.now),
                        () => context.go('/pantry'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.x4),
            SoftCard(
              color: AppColors.cream,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('照护指数', style: TextStyle(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      TagChip(label: app.careLevel, tint: AppColors.green),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: app.careScore / 5,
                      backgroundColor: Colors.white,
                      color: AppColors.olive,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    calories == null
                        ? '记下体重后，这里会给出每日热量估算。'
                        : '${calories.summary}。${calories.assumedKcal ? '未关联粮食品牌时按示例 380 kcal/100g 估算。' : ''}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.x4),
            const DisclaimerBanner(),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xCCFFFFFF),
          borderRadius: BorderRadius.circular(Radii.m),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
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
        borderRadius: BorderRadius.circular(Radii.l),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mini(String title, String headline, String detail, VoidCallback onTap) {
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
