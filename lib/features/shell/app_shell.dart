import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/paw_icon.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

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
      backgroundColor: AppColors.background,
      extendBody: true,
      body: app.loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.coralDeep))
          : app.error != null
          ? EmptyHint(
              title: '数据没有准备好',
              body: app.error!,
              action: '重试',
              onAction: app.init,
            )
          : widget.shell,
      bottomNavigationBar: showBar
          ? SizedBox(
              height: 92,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 68,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x142C2A28),
                          blurRadius: 18,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _item(0, Icons.home_outlined, '首页'),
                        _item(1, Icons.favorite_border_rounded, '健康'),
                        const SizedBox(width: 76),
                        _item(2, Icons.kitchen_outlined, '粮仓'),
                        _item(3, Icons.person_outline_rounded, '我的'),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: Material(
                      color: AppColors.coral,
                      elevation: 6,
                      shadowColor: const Color(0x66E58B72),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _openQuickAdd(context),
                        child: const SizedBox(
                          width: 62,
                          height: 62,
                          child: Center(
                            child: PawIcon(size: 30, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _item(int index, IconData icon, String label) {
    final selected = widget.shell.currentIndex == index;
    final color = selected ? AppColors.coralDeep : AppColors.muted;
    return Expanded(
      child: InkWell(
        onTap: () => widget.shell.goBranch(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }

  Future<void> _openQuickAdd(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
      ),
      builder: (sheetContext) {
        final actions = [
          (Icons.restaurant_outlined, '记喂食', () => context.push('/feeding')),
          (Icons.monitor_weight_outlined, '记体重', () => showWeightSheet(context)),
          (Icons.qr_code_scanner_rounded, '扫条码', () => context.push('/scan')),
          (Icons.vaccines_outlined, '记疫苗', () => showVaccineSheet(context)),
          (Icons.bug_report_outlined, '记驱虫', () => showDewormSheet(context)),
          (Icons.local_hospital_outlined, '记就医', () => showVisitSheet(context)),
          (Icons.edit_note_outlined, '写笔记', () => showNoteSheet(context)),
          (Icons.swap_horiz_rounded, '开始换粮', () => context.push('/feeding')),
        ];
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                app.active == null ? '先添加一只猫' : '给${app.active!.name}记一笔',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                children: [
                  for (final action in actions)
                    InkWell(
                      onTap: () {
                        Navigator.pop(sheetContext);
                        if (app.active == null && action.$2 != '扫条码') {
                          context.push('/cat-form');
                          return;
                        }
                        action.$3();
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: AppColors.tintCoral,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(action.$1, color: AppColors.ink),
                          ),
                          const SizedBox(height: 6),
                          Text(action.$2, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
