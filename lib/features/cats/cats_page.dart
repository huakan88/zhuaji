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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
          child: cat == null
              ? EmptyHint(
                  title: '还没有猫咪',
                  body: '拍一张，起个名字就够了。',
                  action: '添加猫咪',
                  onAction: () => context.push('/cat-form'),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SoftCard(
                      radius: Radii.xl,
                      child: InkWell(
                        onTap: () => context.push('/cat?id=${cat.id}'),
                        child: Row(
                          children: [
                            CatAvatar(
                              path: cat.avatarPath,
                              size: 72,
                              ring: AppColors.coral,
                              selected: true,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ageLabel(cat.birthday, app.now),
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '点开头像看档案',
                                    style: TextStyle(
                                      color: AppColors.olive,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.muted,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.push('/cat-form?id=${cat.id}'),
                      child: const Text('编辑资料'),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 96,
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
                                    width: 64,
                                    height: 64,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: AppColors.card,
                                        shape: BoxShape.circle,
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
                          final selected = item.id == app.activeCatId;
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
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SoftCard(
                      radius: Radii.xl,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.tintCoral,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.kitchen_outlined,
                            color: AppColors.coralDeep,
                          ),
                        ),
                        title: const Text(
                          '粮仓',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: const Text(
                          '看看还有哪袋要吃完',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.muted,
                        ),
                        onTap: () => context.push('/pantry'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
