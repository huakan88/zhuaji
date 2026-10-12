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
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text(
              '我的猫咪',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '每只猫有自己的档案、体重和提醒。',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: Space.x4),
            if (app.cats.isEmpty)
              EmptyHint(
                title: '名单是空的',
                body: '添加后可以拍照、记录毛色，并在首页切换。',
                action: '添加猫咪',
                onAction: () => context.push('/cat-form'),
              )
            else
              for (final cat in app.cats)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SoftCard(
                    padding: const EdgeInsets.all(12),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CatAvatar(
                        path: cat.avatarPath,
                        size: 56,
                        selected: cat.id == app.activeCatId,
                        ring: ringPalette[app.cats.indexOf(cat) % ringPalette.length],
                      ),
                      title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        [
                          if (cat.breed != null) cat.breed!,
                          ageLabel(cat.birthday, app.now),
                          sexLabel(cat.sex),
                          if (cat.isSample) '示例档案',
                        ].join(' · '),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await app.selectCat(cat.id);
                        if (context.mounted) context.push('/cat?id=${cat.id}');
                      },
                    ),
                  ),
                ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => context.push('/cat-form'),
              child: const Text('添加猫咪'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.push('/reminders'),
              child: const Text('全部提醒'),
            ),
            const SizedBox(height: Space.x5),
            const DisclaimerBanner(),
          ],
        ),
      ),
    );
  }
}
