import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../domain/dates.dart';
import '../../core/widgets/common.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    final todos = _todos(context, app, cat);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('今天')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          Center(
            child: cat == null
                ? GestureDetector(
                    onTap: () => context.push('/cat-form'),
                    child: const CatAvatar(
                      path: null,
                      size: 96,
                      selected: true,
                    ),
                  )
                : CatAvatar(path: cat.avatarPath, size: 96, selected: true),
          ),
          if (cat != null) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                cat.name,
                style: zhuaji.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 28),
          if (todos.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '今天没什么要办',
                style: zhuaji.copyWith(color: AppColors.muted),
              ),
            ),
          for (final todo in todos) ...[
            _TodoRow(todo: todo),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => context.push('/scan'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              textStyle: zhuaji.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('扫粮'),
          ),
        ],
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
            if (_foodDue(entry, soon) || _openedToday(entry, today)) entry,
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
            await context.push('/bag?id=${entry.item.id}');
          },
        ),
      );
    }
    if (cat != null) {
      final soonShot = dateOnly(app.now).add(const Duration(days: 30));
      final shots = [
        for (final shot in app.catVaccines)
          if (shot.nextDue != null &&
              !dateOnly(shot.nextDue!).isAfter(soonShot))
            shot,
      ]..sort((a, b) => a.nextDue!.compareTo(b.nextDue!));
      for (final shot in shots) {
        items.add(
          _Todo(
            title: '疫苗',
            detail: shot.name,
            onTap: () async {
              await context.push('/vaccines');
            },
          ),
        );
      }
      final soonDeworm = dateOnly(app.now).add(const Duration(days: 30));
      final worms = [
        for (final item in app.catDeworms)
          if (item.nextDue != null &&
              !dateOnly(item.nextDue!).isAfter(soonDeworm))
            item,
      ]..sort((a, b) => a.nextDue!.compareTo(b.nextDue!));
      for (final item in worms) {
        items.add(
          _Todo(
            title: '驱虫',
            detail: item.product,
            onTap: () async {
              await context.push('/deworms');
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
              final saved = await showWeightSheet(context);
              if (!saved || !context.mounted) return;
              await app.ackWeightAlert(cat);
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

class _TodoRow extends StatelessWidget {
  const _TodoRow({required this.todo});

  final _Todo todo;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: todo.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(
                todo.title,
                style: zhuaji.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  todo.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: zhuaji.copyWith(color: AppColors.muted),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
