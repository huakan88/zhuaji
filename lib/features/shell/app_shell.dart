import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../state/app_controller.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppScope.of<AppController>(context).enableNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final showBar = !app.loading && app.error == null;
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      extendBody: true,
      body: app.loading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.of(context).brandDeep,
              ),
            )
          : app.error != null
          ? EmptyHint(
              title: '没打开',
              body: app.error!,
              action: '重试',
              onAction: app.init,
            )
          : widget.shell,
      bottomNavigationBar: showBar
          ? _TabBar(
              index: widget.shell.currentIndex,
              onTap: widget.shell.goBranch,
            )
          : null,
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        border: Border(top: BorderSide(color: AppColors.of(context).line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _item(context, 0, Icons.today_outlined, '今天'),
              _item(context, 1, Icons.favorite_border, '健康'),
              _item(context, 2, Icons.inventory_2_outlined, '粮仓'),
              _item(context, 3, Icons.pets_outlined, '猫咪'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int slot, IconData icon, String label) {
    final selected = index == slot;
    final color = selected
        ? AppColors.of(context).brandDeep
        : AppColors.of(context).muted;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(slot),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6, top: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: zhuaji.copyWith(
                  fontSize: 11,
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
