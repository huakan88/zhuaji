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
                  title: '还没有猫',
                  body: '拍一张，写名字。',
                  action: '添加',
                  onAction: () => context.push('/cat-form'),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      onTap: () => context.push('/cat?id=${cat.id}'),
                      child: Row(
                        children: [
                          CatAvatar(path: cat.avatarPath, size: 56),
                          const SizedBox(width: 12),
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
                                Text(
                                  ageLabel(cat.birthday, app.now),
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
                    const Spacer(),
                    FilledButton(
                      onPressed: () => context.push('/pantry'),
                      child: const Text('粮仓'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
