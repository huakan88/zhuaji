import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../state/app_controller.dart';

class LegalSettings extends StatelessWidget {
  const LegalSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final basic = app.privacyChoice == PrivacyChoice.basic;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: BrandMark(size: 72)),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '花爪',
            style: zhuaji.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 12),
        const SectionLabel('协议与数据'),
        const SizedBox(height: 8),
        if (basic) ...[
          Text(
            '当前是基本功能：记录留在这台手机，不联网查条码，也不发提醒。',
            style: zhuaji.copyWith(
              fontSize: 13,
              height: 1.4,
              color: AppColors.of(context).muted,
            ),
          ),
          const SizedBox(height: 8),
        ],
        QuietCard(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: [
              _link(context, '隐私政策', '/privacy'),
              _link(context, '用户协议', '/agreement'),
              _link(context, '权限说明', '/permissions'),
              if (basic)
                _action(context, '同意完整功能', () => app.acceptPrivacy())
              else
                _action(context, '撤回同意', () => _withdraw(context, app)),
              _action(context, '删除本机数据', () => _erase(context, app)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _link(BuildContext context, String label, String route) {
    return _row(label, () => context.push(route));
  }

  Widget _action(
    BuildContext context,
    String label,
    Future<void> Function() action,
  ) {
    return _row(label, () async {
      await action();
    });
  }

  Widget _row(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          alignment: Alignment.centerLeft,
        ),
        child: Text(label),
      ),
    );
  }

  Future<void> _withdraw(BuildContext context, AppController app) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('撤回同意？'),
        content: const Text('之后不再联网查条码，也不再安排提醒。已经记在这台手机上的猫和粮仓还在。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('撤回'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await app.useBasicMode();
    if (!context.mounted) return;
    showMessage(context, '已改为基本功能');
  }

  Future<void> _erase(BuildContext context, AppController app) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('删除本机数据？'),
        content: const Text('猫咪、健康记录、粮仓和搜索记录会从这台手机抹掉，不能恢复。内置猫粮表会留下。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await app.erasePersonalData();
  }
}
