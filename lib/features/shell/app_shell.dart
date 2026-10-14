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
      backgroundColor: AppColors.background,
      extendBody: true,
      body: app.loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.coralDeep),
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
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: softShadow,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 92,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _item(0, Icons.today_outlined, '今天'),
              _item(1, Icons.favorite_border, '健康'),
              const _ScanSlot(),
              _item(3, Icons.inventory_2_outlined, '粮仓'),
              _item(4, Icons.pets_outlined, '猫咪'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int index, IconData icon, String label) {
    final selected = slot == index;
    final color = selected ? AppColors.coralDeep : AppColors.muted;
    return Expanded(
      child: InkWell(
        onTap: () => onSlot(index),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                style: zhuaji.copyWith(
                  fontSize: 12,
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

class _ScanSlot extends StatefulWidget {
  const _ScanSlot();

  @override
  State<_ScanSlot> createState() => _ScanSlotState();
}

class _ScanSlotState extends State<_ScanSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bar = context.findAncestorWidgetOfExactType<_TabBar>()!;
    return Expanded(
      child: GestureDetector(
        onTap: () => bar.onSlot(2),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedBuilder(
                animation: _glow,
                builder: (context, child) {
                  final t = Curves.easeInOut.transform(_glow.value);
                  return Transform.translate(
                    offset: Offset(0, -6 - 2 * t),
                    child: Transform.scale(scale: 1 + 0.04 * t, child: child),
                  );
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.coral, AppColors.coralDeep],
                    ),
                    boxShadow: scanGlow,
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '扫粮',
                style: zhuaji.copyWith(
                  fontSize: 12,
                  color: AppColors.coralDeep,
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
