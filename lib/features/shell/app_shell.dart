import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      backgroundColor: AppColors.background,
      extendBody: true,
      body: app.loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.coralDeep),
            )
          : app.error != null
          ? EmptyHint(
              title: '数据没有准备好',
              body: app.error!,
              action: '重试',
              onAction: app.init,
            )
          : widget.shell,
      bottomNavigationBar: showBar
          ? NavigationBar(
              height: 68,
              backgroundColor: Colors.white,
              indicatorColor: AppColors.tintCoral,
              selectedIndex: widget.shell.currentIndex,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.today_outlined),
                  label: '今天',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_border_rounded),
                  label: '健康',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  label: '我的',
                ),
              ],
              onDestinationSelected: (index) => widget.shell.goBranch(index),
            )
          : null,
    );
  }
}
