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
              title: '还没有猫咪',
              body: '拍一张，写个名字。',
              action: '添加第一只猫',
              onAction: () => context.push('/cat-form'),
            ),
          ),
        ),
      );
    }
    final cat = app.active!;
    final alerts = _alerts(app);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CatAvatar(path: cat.avatarPath, size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CatMenu(app: app, cat: cat),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                '今天',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (alerts.isEmpty)
                const Text(
                  '今天没有要处理的事',
                  style: TextStyle(color: AppColors.muted),
                )
              else
                for (final alert in alerts) ...[
                  _AlertTile(alert: alert),
                  const SizedBox(height: 8),
                ],
              const Spacer(),
              FilledButton(
                onPressed: () => context.push('/scan'),
                child: const Text('扫条码'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_Alert> _alerts(AppController app) {
    final items = <_Alert>[];
    final weight = weightChangeOverMonth(app.catWeights);
    if (weight != null && weight.notable) {
      final direction = weight.percent > 0 ? '增加' : '下降';
      final percent = (weight.percent.abs() * 100).toStringAsFixed(0);
      items.add(
        _Alert(
          title: '体重变化',
          detail: '近 ${weight.days} 天$direction了 $percent%',
          onTap: (context) => context.go('/health'),
        ),
      );
    }
    final deworm = app.nextExternal?.nextDue ?? app.nextInternal?.nextDue;
    if (deworm != null && calendarDays(app.now, deworm) <= 14) {
      items.add(
        _Alert(
          title: '驱虫',
          detail: formatMonthDay(deworm),
          onTap: (context) => context.go('/health'),
        ),
      );
    }
    final vaccine = app.nextVaccine?.nextDue;
    if (vaccine != null && calendarDays(app.now, vaccine) <= 30) {
      items.add(
        _Alert(
          title: '下次疫苗',
          detail: app.nextVaccine?.name ?? formatMonthDay(vaccine),
          onTap: (context) => context.go('/health'),
        ),
      );
    }
    final expiry = app.nearestExpiry?.item.expiryDate;
    if (expiry != null && calendarDays(app.now, expiry) <= 30) {
      final days = calendarDays(app.now, expiry);
      items.add(
        _Alert(
          title: '临期猫粮',
          detail: days <= 0 ? '今天到期' : '还剩 $days 天',
          onTap: (context) => context.push('/pantry'),
        ),
      );
    }
    return items;
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
  final void Function(BuildContext context) onTap;
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final _Alert alert;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(
          alert.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          alert.detail,
          style: const TextStyle(color: AppColors.muted),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => alert.onTap(context),
      ),
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
      offset: const Offset(0, 40),
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
              const Icon(Icons.keyboard_arrow_down_rounded),
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
