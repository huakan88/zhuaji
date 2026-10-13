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
              body: '拍一张照片，写个名字就能开始。其他资料可以以后再补。',
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Row(
              children: [
                CatAvatar(path: cat.avatarPath, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: _CatMenu(app: app, cat: cat),
                ),
                IconButton(
                  tooltip: '提醒',
                  onPressed: () => context.push('/reminders'),
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const SectionHeader(title: '今天'),
            const SizedBox(height: 10),
            _MealRow(
              app: app,
              slot: MealSlot.breakfast,
              title: '早餐',
              time: '08:00',
            ),
            const SizedBox(height: 10),
            _MealRow(
              app: app,
              slot: MealSlot.dinner,
              title: '晚餐',
              time: '18:30',
            ),
            const SizedBox(height: 16),
            const Text(
              '不舒服就点一下',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _TagRow(
              labels: const ['呕吐', '腹泻', '精神差', '食欲差'],
              prefix: '症状',
              notes: app.catNotes,
              now: app.now,
              onPick: (label) => app.addNote('症状：$label'),
            ),
            const SizedBox(height: 14),
            const Text('便便', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _TagRow(
              labels: const ['正常', '软便', '干硬', '没拉'],
              prefix: '便便',
              notes: app.catNotes,
              now: app.now,
              onPick: (label) => app.addNote('便便：$label'),
            ),
            const SizedBox(height: 18),
            const SectionHeader(title: '需要留意'),
            const SizedBox(height: 10),
            if (alerts.isEmpty)
              const Text(
                '今天没有额外要处理的事。',
                style: TextStyle(color: AppColors.muted),
              )
            else
              for (final alert in alerts) ...[
                _AlertTile(alert: alert),
                const SizedBox(height: 8),
              ],
          ],
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
          detail: '计划在 ${formatMonthDay(deworm)}',
          onTap: (context) => context.go('/health'),
        ),
      );
    }
    final vaccine = app.nextVaccine?.nextDue;
    if (vaccine != null && calendarDays(app.now, vaccine) <= 30) {
      items.add(
        _Alert(
          title: '下次疫苗',
          detail: app.nextVaccine?.name ?? formatDate(vaccine),
          onTap: (context) => context.go('/health'),
        ),
      );
    }
    final expiry = app.nearestExpiry?.item.expiryDate;
    if (expiry != null && calendarDays(app.now, expiry) <= 30) {
      items.add(
        _Alert(
          title: '临期猫粮',
          detail: app.nearestExpiry?.product.name ?? '去粮仓看看',
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

class _MealRow extends StatelessWidget {
  const _MealRow({
    required this.app,
    required this.slot,
    required this.title,
    required this.time,
  });

  final AppController app;
  final MealSlot slot;
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    final fed = app.todayFeedings.where((meal) => meal.slot == slot).toList();
    return SoftCard(
      child: fed.isEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title · $time',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  '按上次分量，点一下就记上',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('少'),
                      onPressed: () => app.markFed(slot, Portion.less),
                    ),
                    ActionChip(
                      label: const Text('已喂'),
                      backgroundColor: AppColors.coral,
                      onPressed: () => app.markFed(slot, Portion.normal),
                    ),
                    ActionChip(
                      label: const Text('多'),
                      onPressed: () => app.markFed(slot, Portion.more),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.sage),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$title已喂 ${fed.fold<double>(0, (sum, meal) => sum + meal.grams).round()} g',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({
    required this.labels,
    required this.prefix,
    required this.notes,
    required this.now,
    required this.onPick,
  });

  final List<String> labels;
  final String prefix;
  final List<HealthNote> notes;
  final DateTime now;
  final Future<void> Function(String label) onPick;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final label in labels)
          FilterChip(
            label: Text(label),
            selected: notes.any(
              (note) =>
                  note.content == '$prefix：$label' &&
                  isSameDay(note.notedOn, now),
            ),
            selectedColor: AppColors.coral,
            showCheckmark: false,
            onSelected: (selected) async {
              if (!selected) return;
              await onPick(label);
              if (context.mounted) showMessage(context, '已记下');
            },
          ),
      ],
    );
  }
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
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
