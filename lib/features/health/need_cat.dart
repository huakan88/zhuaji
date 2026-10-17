import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../state/app_controller.dart';

/// A health page opened before any cat is chosen.
class NeedCatPage extends StatelessWidget {
  const NeedCatPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final none = app.cats.isEmpty;
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: zhuajiBar(title),
      body: EmptyHint(
        title: none ? '还没猫' : '先点一只猫',
        body: none ? '建好档案，才能记这一笔' : '回到猫咪页，点一下名字',
        action: none ? '建档' : '去猫咪',
        onAction: () {
          if (none) {
            context.push('/cat-form');
          } else {
            context.go('/cats');
          }
        },
      ),
    );
  }
}
