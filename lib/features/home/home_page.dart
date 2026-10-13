import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/care/easy_log.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    if (app.cats.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Space.x6),
            child: EmptyHint(
              title: '还没有猫',
              body: '拍一张，写名字。',
              action: '添加',
              onAction: () => context.push('/cat-form'),
            ),
          ),
        ),
      );
    }
    final cat = app.active!;
    final alerts = _alerts(context, app);
    final visible = alerts.take(3).toList();
    final rest = alerts.skip(3).toList();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CatHeader(app: app, cat: cat),
              const SizedBox(height: 8),
              const Divider(height: 1),
              if (visible.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Text(
                    '今天没事',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted),
                  ),
                )
              else
                for (final alert in visible) _AlertRow(alert: alert),
              if (rest.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => _showRest(context, rest),
                    child: const Text('全部'),
                  ),
                ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.push('/scan'),
                child: const Text('扫码'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_Alert> _alerts(BuildContext context, AppController app) {
    final items = <_Alert>[];
    final expiry = app.nearestExpiry?.item.expiryDate;
    if (expiry != null && calendarDays(app.now, expiry) <= 30) {
      final days = calendarDays(app.now, expiry);
      items.add(
        _Alert(
          title: '临期猫粮',
          detail: days <= 0 ? '今天到期' : '还剩 $days 天',
          onTap: () => context.push('/pantry'),
        ),
      );
    }
    final vaccine = app.nextVaccine?.nextDue;
    if (vaccine != null && calendarDays(app.now, vaccine) <= 30) {
      items.add(
        _Alert(
          title: '下次疫苗',
          detail: app.nextVaccine?.name ?? formatMonthDay(vaccine),
          onTap: () => context.go('/health'),
        ),
      );
    }
    final deworm = app.nextExternal?.nextDue ?? app.nextInternal?.nextDue;
    if (deworm != null && calendarDays(app.now, deworm) <= 14) {
      items.add(
        _Alert(
          title: '驱虫',
          detail: formatMonthDay(deworm),
          onTap: () => context.go('/health'),
        ),
      );
    }
    final weight = weightChangeOverMonth(app.catWeights);
    if (weight != null && weight.notable) {
      final direction = weight.percent > 0 ? '上升' : '下降';
      final percent = (weight.percent.abs() * 100).toStringAsFixed(0);
      items.add(
        _Alert(
          title: '体重变化',
          detail: '近${weight.days}天$direction $percent%',
          onTap: () => context.go('/health'),
        ),
      );
    }
    return items;
  }

  void _showRest(BuildContext context, List<_Alert> rest) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('全部')),
            for (final alert in rest) _AlertRow(alert: alert, dismiss: true),
          ],
        ),
      ),
    );
  }
}

int calendarDays(DateTime from, DateTime to) {
  final start = DateTime(from.year, from.month, from.day);
  final end = DateTime(to.year, to.month, to.day);
  return end.difference(start).inDays;
}

class _Alert {
  const _Alert({
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final String title;
  final String detail;
  final VoidCallback onTap;
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.alert, this.dismiss = false});

  final _Alert alert;
  final bool dismiss;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(alert.title),
      subtitle: Text(
        alert.detail,
        style: const TextStyle(color: AppColors.muted),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
      onTap: () {
        if (dismiss) Navigator.of(context).pop();
        alert.onTap();
      },
    );
  }
}

class _CatHeader extends StatelessWidget {
  const _CatHeader({required this.app, required this.cat});

  final AppController app;
  final CatProfile cat;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CatAvatar(path: cat.avatarPath, size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: _CatMenu(app: app, cat: cat),
        ),
        for (final item in app.cats)
          if (item.id != cat.id)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => app.selectCat(item.id),
                child: CatAvatar(path: item.avatarPath, size: 32),
              ),
            ),
      ],
    );
  }
}

class _CatMenu extends StatelessWidget {
  const _CatMenu({required this.app, required this.cat});

  final AppController app;
  final CatProfile cat;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      offset: const Offset(0, 36),
      onSelected: (id) {
        if (id == -1) {
          context.push('/cat-form');
          return;
        }
        app.selectCat(id);
      },
      itemBuilder: (context) => [
        for (final item in app.cats)
          PopupMenuItem(value: item.id, child: Text(item.name)),
        const PopupMenuItem(value: -1, child: Text('添加猫咪')),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  cat.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            ],
          ),
          Text(
            ageLabel(cat.birthday, app.now),
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
