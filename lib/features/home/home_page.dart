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
      backgroundColor: AppColors.background,
      appBar: zhuajiBar('今天'),
      body: FadeIn(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            if (cat != null)
              Text(
                cat.name,
                style: zhuaji.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            const SizedBox(height: 12),
            if (todos.isEmpty)
              const EmptyHint(title: '今天没什么要办', body: '到期、疫苗和驱虫会出现在这里'),
            for (final todo in todos) ...[
              _TodoRow(todo: todo),
              const SizedBox(height: 10),
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
            showMessage(context, '还在粮仓');
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
              showMessage(context, '下次 ${formatDate(next)}');
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
              showMessage(context, '下次 ${formatDate(next)}');
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
  var _down = false;

  Color get _bar => switch (widget.todo.title) {
    '疫苗' => AppColors.sage,
    '驱虫' => AppColors.olive,
    '体重' => AppColors.brown,
    _ => AppColors.coralDeep,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.todo.onTap,
      child: AnimatedScale(
        scale: _down ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            boxShadow: softShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(width: 6, color: _bar),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Text(
                            widget.todo.title,
                            style: zhuaji.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.todo.detail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: zhuaji.copyWith(color: AppColors.muted),
                            ),
                          ),
                          AnimatedScale(
                            scale: _down ? 1.2 : 1,
                            duration: const Duration(milliseconds: 140),
                            child: const Icon(
                              Icons.check,
                              color: AppColors.coralDeep,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
