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

  int _branchFor(int slot) => switch (slot) {
    0 => 0,
    1 => 1,
    3 => 2,
    _ => 3,
  };

  int _slotFor(int branch) => switch (branch) {
    0 => 0,
    1 => 1,
    2 => 3,
    _ => 4,
  };

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
              slot: _slotFor(widget.shell.currentIndex),
              onSlot: (slot) {
                if (slot == 2) {
                  context.push('/scan');
                  return;
                }
                widget.shell.goBranch(_branchFor(slot));
              },
            )
          : null,
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.slot, required this.onSlot});

  final int slot;
  final ValueChanged<int> onSlot;

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
          height: 72,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _item(context, 0, Icons.today_outlined, '今天'),
              _item(context, 1, Icons.favorite_border, '健康'),
              _scan(context),
              _item(context, 3, Icons.inventory_2_outlined, '粮仓'),
              _item(context, 4, Icons.pets_outlined, '猫咪'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int index, IconData icon, String label) {
    final selected = slot == index;
    final color = selected
        ? AppColors.of(context).brandDeep
        : AppColors.of(context).muted;
    return Expanded(
      child: InkWell(
        onTap: () => onSlot(index),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
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

  Widget _scan(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onSlot(2),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const _ScanMark(),
              const SizedBox(height: 2),
              Text(
                '扫粮',
                style: zhuaji.copyWith(
                  fontSize: 11,
                  color: AppColors.of(context).brandDeep,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanMark extends StatelessWidget {
  const _ScanMark();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.of(context).brand,
        shape: BoxShape.circle,
      ),
      child: SizedBox(
        width: 48,
        height: 48,
        child: Icon(
          Icons.qr_code_scanner,
          color: AppColors.of(context).onBrand,
          size: 22,
        ),
      ),
    );
  }
}
