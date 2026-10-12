import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../state/app_controller.dart';

class CatsPage extends StatelessWidget {
  const CatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            if (cat == null)
              EmptyHint(
                title: '还没有猫咪',
                body: '添加后可以在这里切换档案。',
                action: '添加猫咪',
                onAction: () => context.push('/cat-form'),
              )
            else ...[
              Row(
                children: [
                  CatAvatar(path: cat.avatarPath, size: 72, ring: AppColors.coral),
                  const SizedBox(width: 14),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push('/cat?id=${cat.id}'),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            if (cat.breed != null) cat.breed!,
                            ageLabel(cat.birthday, app.now),
                          ].join(' · '),
                          style: const TextStyle(color: AppColors.muted, fontSize: 13),
                        ),
                      ],
                    ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/cat-form?id=${cat.id}'),
                    child: const Text('编辑'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E6D4),
                  borderRadius: BorderRadius.circular(Radii.l),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('家庭照护', style: TextStyle(fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text(
                            '疫苗、驱虫和猫粮提醒都留在这台手机上。',
                            style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => context.push('/reminders'),
                      child: const Text('去看看'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const SectionHeader(title: '我的宠物'),
              const SizedBox(height: 12),
              SizedBox(
                height: 108,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: app.cats.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    if (index == app.cats.length) {
                      return GestureDetector(
                        onTap: () => context.push('/cat-form'),
                        child: const Column(
                          children: [
                            SizedBox(
                              width: 68,
                              height: 68,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  shape: BoxShape.circle,
                                  boxShadow: softShadow,
                                ),
                                child: Icon(Icons.add_rounded),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('添加', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    }
                    final item = app.cats[index];
                    final selected = item.id == app.activeCatId;
                    return GestureDetector(
                      onTap: () async {
                        await app.selectCat(item.id);
                        if (context.mounted) context.push('/cat?id=${item.id}');
                      },
                      child: Column(
                        children: [
                          CatAvatar(
                            path: item.avatarPath,
                            size: 68,
                            selected: selected,
                            ring: ringPalette[index % ringPalette.length],
                          ),
                          const SizedBox(height: 8),
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
              const SizedBox(height: 8),
              _setting(context, Icons.notifications_none_rounded, '提醒', '喂食、疫苗、保质期', () => context.push('/reminders')),
              _setting(context, Icons.restaurant_outlined, '喂养', '热量估算和七日换粮', () => context.push('/feeding')),
              _setting(context, Icons.photo_outlined, '体态对比', '并排看较早和最近的照片', () => context.push('/photos')),
              _setting(context, Icons.pets_outlined, '当前档案', cat.name, () => context.push('/cat?id=${cat.id}')),
              const SizedBox(height: 12),
              const DisclaimerBanner(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _setting(
    BuildContext context,
    IconData icon,
    String title,
    String detail,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.cream,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(detail, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
          onTap: onTap,
        ),
      ),
    );
  }
}
