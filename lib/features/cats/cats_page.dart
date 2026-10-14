import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../domain/models.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../state/app_controller.dart';

class CatsPage extends StatelessWidget {
  const CatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    final kg = app.latestWeight?.weightKg;
    return Scaffold(
      backgroundColor: AppColors.background,
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
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '体重在健康里改',
                            style: zhuaji.copyWith(
                              fontSize: 12,
                              color: AppColors.muted,
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
              const SizedBox(height: 24),
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
