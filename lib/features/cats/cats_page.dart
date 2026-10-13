import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class CatsPage extends StatelessWidget {
  const CatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('猫')),
      body: ListView(
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
          const SizedBox(height: 24),
          if (cat == null)
            EmptyHint(
              title: '还没猫',
              body: '',
              action: '建档',
              onAction: () => context.push('/cat-form'),
            )
          else ...[
            Center(
              child: CatAvatar(path: cat.avatarPath, size: 168, selected: true),
            ),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: () => context.push('/cat-form?id=${cat.id}'),
                child: Text(
                  cat.name,
                  style: zhuaji.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: GestureDetector(
                onTap: () => showWeightSheet(context),
                child: Text(
                  app.latestWeight == null
                      ? '— kg'
                      : '${app.latestWeight!.weightKg.toStringAsFixed(2)} kg',
                  style: zhuaji.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: AppColors.coralDeep,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/checkups'),
                    child: const Text('体检'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/diseases'),
                    child: const Text('看病'),
                  ),
                ),
              ],
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
    );
  }
}
