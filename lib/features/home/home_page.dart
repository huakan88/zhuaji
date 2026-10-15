import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/dates.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    final todos = _todos(context, app, cat);
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: zhuajiBar('今天'),
      body: FadeIn(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 108),
          children: [
            if (app.cats.length > 1) ...[
              _CatSwitch(app: app, activeCount: todos.length),
              const SizedBox(height: 12),
            ],
            if (cat != null)
              HeroCard(
                path: cat.avatarPath,
                title: cat.name,
                subtitle: _meta(cat, app.now),
              ),
            const SizedBox(height: 16),
            QuietCard(
              onTap: () => context.push('/calendar'),
              child: Row(
                children: [
                  const IconWell(icon: Icons.calendar_today_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '未来 30 天',
                          style: zhuaji.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '疫苗、驱虫、体检、粮和复诊',
                          style: zhuaji.copyWith(
                            fontSize: 12,
                            color: AppColors.of(context).muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionLabel(todos.isEmpty ? '今天要办' : '今天要办  ${todos.length}'),
            const SizedBox(height: 8),
            if (todos.isEmpty)
              const EmptyHint(title: '今天没什么要办', body: '到期、疫苗和驱虫会出现在这里'),
            for (final todo in todos) ...[
              _TodoRow(todo: todo),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  List<_Todo> _todos(BuildContext context, AppController app, CatProfile? cat) {
    final items = <_Todo>[];
    final soon = dateOnly(app.now).add(const Duration(days: 30));
    final today = dateOnly(app.now);
    final foods =
        [
          for (final entry in app.pantry)
            if ((_foodDue(entry, soon) || _openedToday(entry, today)) &&
                !app.pantryAcked(entry))
              entry,
        ]..sort((a, b) {
          final aFresh = _openedToday(a, today);
          final bFresh = _openedToday(b, today);
          if (aFresh != bFresh) return aFresh ? -1 : 1;
          final left = a.item.expiryDate ?? _useBy(a) ?? app.now;
          final right = b.item.expiryDate ?? _useBy(b) ?? app.now;
          return left.compareTo(right);
        });
    for (final entry in foods) {
      items.add(
        _Todo(
          title: '到期粮',
          detail: entry.product.name,
          onTap: () async {
            await app.ackPantry(entry);
            if (!context.mounted) return;
            showUndo(context, '知道了，还在粮仓', () => app.unackPantry(entry));
          },
        ),
      );
    }
    if (cat != null) {
      final shots = [
        for (final shot in app.catVaccines)
          if (shot.nextDue != null && !dateOnly(shot.nextDue!).isAfter(soon))
            shot,
      ]..sort((a, b) => a.nextDue!.compareTo(b.nextDue!));
      for (final shot in shots) {
        items.add(
          _Todo(
            title: '疫苗',
            detail: shot.name,
            onTap: () async {
              final next = await app.completeVaccine(shot);
              if (!context.mounted) return;
              showUndo(
                context,
                '${shot.name}记下了，下次 ${formatDate(next)}',
                () => app.restoreVaccine(shot),
              );
            },
          ),
        );
      }
      final worms = [
        for (final item in app.catDeworms)
          if (item.nextDue != null && !dateOnly(item.nextDue!).isAfter(soon))
            item,
      ]..sort((a, b) => a.nextDue!.compareTo(b.nextDue!));
      for (final item in worms) {
        items.add(
          _Todo(
            title: '驱虫',
            detail: item.product,
            onTap: () async {
              final next = await app.completeDeworm(item);
              if (!context.mounted) return;
              showUndo(
                context,
                '${item.product}记下了，下次 ${formatDate(next)}',
                () => app.restoreDeworm(item),
              );
            },
          ),
        );
      }
      if (app.weightAlertVisible(cat)) {
        final kg = app.latestWeight?.weightKg;
        items.add(
          _Todo(
            title: '体重',
            detail: kg == null ? '去称一下' : '${kg.toStringAsFixed(2)} kg',
            onTap: () async {
              await context.push('/weight');
            },
          ),
        );
      }
    }
    return items;
  }

  String _meta(CatProfile cat, DateTime now) {
    final parts = <String>[
      if (cat.breed != null && cat.breed!.isNotEmpty) cat.breed!,
      ageLabel(cat.birthday, now),
    ];
    return parts.join(' · ');
  }

  bool _foodDue(PantryEntry entry, DateTime soon) {
    final expiry = entry.item.expiryDate;
    if (expiry != null && !dateOnly(expiry).isAfter(soon)) return true;
    final useBy = _useBy(entry);
    if (useBy != null && !dateOnly(useBy).isAfter(soon)) return true;
    return false;
  }

  bool _openedToday(PantryEntry entry, DateTime today) {
    final opened = entry.item.openedAt;
    if (opened == null) return false;
    return dateOnly(opened) == today;
  }

  DateTime? _useBy(PantryEntry entry) {
    final opened = entry.item.openedAt;
    if (opened == null || entry.openWindowDays <= 0) return null;
    return dateOnly(opened).add(Duration(days: entry.openWindowDays));
  }
}

class _CatSwitch extends StatelessWidget {
  const _CatSwitch({required this.app, required this.activeCount});

  final AppController app;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final item in app.cats) ...[
            _CatPill(
              cat: item,
              count: item.id == app.activeCatId
                  ? activeCount
                  : app.dueCountFor(item),
              selected: item.id == app.activeCatId,
              onTap: () => app.selectCat(item.id),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _CatPill extends StatelessWidget {
  const _CatPill({
    required this.cat,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final CatProfile cat;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 4, 14, 4),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.of(context).brandTint
              : AppColors.of(context).card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.of(context).brandDeep
                : AppColors.of(context).line,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: SizedBox(
                width: 34,
                height: 34,
                child: CatImage(path: cat.avatarPath),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              cat.name,
              style: zhuaji.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            Text(
              count == 0 ? '没事' : '$count 件',
              style: zhuaji.copyWith(
                fontSize: 12,
                color: count == 0
                    ? AppColors.of(context).muted
                    : AppColors.of(context).brandDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Todo {
  const _Todo({required this.title, required this.detail, required this.onTap});

  final String title;
  final String detail;
  final Future<void> Function() onTap;
}

class _TodoRow extends StatefulWidget {
  const _TodoRow({required this.todo});

  final _Todo todo;

  @override
  State<_TodoRow> createState() => _TodoRowState();
}

class _TodoRowState extends State<_TodoRow> {
  IconData get _icon => switch (widget.todo.title) {
    '疫苗' => Icons.vaccines_outlined,
    '驱虫' => Icons.bug_report_outlined,
    '体重' => Icons.monitor_weight_outlined,
    _ => Icons.inventory_2_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.todo.onTap,
      child: QuietCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            IconWell(icon: _icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.todo.title,
                    style: zhuaji.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.todo.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: zhuaji.copyWith(
                      fontSize: 12,
                      color: AppColors.of(context).muted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.of(context).brand),
              ),
              child: Icon(
                Icons.check,
                color: AppColors.of(context).brandDeep,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
