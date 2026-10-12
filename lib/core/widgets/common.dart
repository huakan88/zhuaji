import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/dates.dart';
import '../copy.dart';
import '../format.dart';
import '../theme/app_tokens.dart';

class AppScope extends InheritedNotifier<Listenable> {
  const AppScope({
    required this.controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  final Listenable controller;

  static T of<T extends Listenable>(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope 没有挂上');
    return scope!.controller as T;
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    required this.child,
    this.padding = const EdgeInsets.all(Space.x4),
    this.color = AppColors.card,
    this.radius = Radii.l,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: softShadow,
      ),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip({
    required this.label,
    this.tint = AppColors.tintCoral,
    this.color = AppColors.ink,
    super.key,
  });

  final String label;
  final Color tint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.action,
    this.onAction,
    super.key,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Space.x4),
      decoration: BoxDecoration(
        color: AppColors.tintGreen,
        borderRadius: BorderRadius.circular(Radii.l),
      ),
      child: const Text(
        kDisclaimer,
        style: TextStyle(color: AppColors.olive, height: 1.45, fontSize: 12),
      ),
    );
  }
}

class EmptyHint extends StatelessWidget {
  const EmptyHint({
    required this.title,
    required this.body,
    this.action,
    this.onAction,
    super.key,
  });

  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.x6),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.xl),
            child: Image.asset(
              'assets/cats/cat-icon.jpg',
              width: 96,
              height: 96,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: Space.x4),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Space.x2),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, height: 1.4),
          ),
          if (action != null) ...[
            const SizedBox(height: Space.x4),
            FilledButton(onPressed: onAction, child: Text(action!)),
          ],
        ],
      ),
    );
  }
}

class CatImage extends StatelessWidget {
  const CatImage({required this.path, this.fit = BoxFit.cover, super.key});

  final String? path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final source = path;
    if (source == null || source.isEmpty) {
      return const ColoredBox(
        color: AppColors.cream,
        child: Center(
          child: Icon(Icons.pets_rounded, color: AppColors.coralDeep, size: 42),
        ),
      );
    }
    if (source.startsWith('asset:')) {
      return Image.asset(source.substring(6), fit: fit);
    }
    return Image.file(
      File(source),
      fit: fit,
      errorBuilder: (context, error, stack) => const ColoredBox(
        color: AppColors.cream,
        child: Center(child: Icon(Icons.broken_image_outlined)),
      ),
    );
  }
}

class CatAvatar extends StatelessWidget {
  const CatAvatar({
    required this.path,
    required this.size,
    this.ring = AppColors.coral,
    this.selected = false,
    super.key,
  });

  final String? path;
  final double size;
  final Color ring;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? ring : ring.withValues(alpha: 0.35),
          width: selected ? 3 : 1.5,
        ),
      ),
      child: ClipOval(child: CatImage(path: path)),
    );
  }
}

class FoodDateCard extends StatelessWidget {
  const FoodDateCard({
    required this.brand,
    required this.name,
    required this.spec,
    required this.form,
    required this.storage,
    required this.now,
    this.isSample = false,
    this.production,
    this.expiry,
    this.batch,
    this.source,
    this.openedAt,
    this.afterOpenDays,
    this.bestBeforeOnly = false,
    super.key,
  });

  final String brand;
  final String name;
  final String spec;
  final String form;
  final String storage;
  final DateTime now;
  final bool isSample;
  final DateTime? production;
  final DateTime? expiry;
  final String? batch;
  final String? source;
  final DateTime? openedAt;
  final int? afterOpenDays;
  final bool bestBeforeOnly;

  @override
  Widget build(BuildContext context) {
    final days = expiry == null ? null : calendarDaysUntil(now, expiry!);
    final openDue = openedAt == null || afterOpenDays == null
        ? null
        : dateOnly(openedAt!).add(Duration(days: afterOpenDays!));
    return SoftCard(
      radius: Radii.xl,
      padding: const EdgeInsets.all(Space.x5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(brand, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: Space.x1),
          Text(
            name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Space.x3),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TagChip(label: form, tint: AppColors.tintGreen, color: AppColors.olive),
              TagChip(label: spec),
              if (isSample)
                const TagChip(label: '示例数据', tint: AppColors.cream, color: AppColors.brown),
              if (source != null) TagChip(label: source!, tint: AppColors.cream),
            ],
          ),
          const SizedBox(height: Space.x4),
          const Divider(),
          _line('生产日期', production == null ? '未记录' : formatDate(production!)),
          _line(
            '保质期',
            expiry == null ? '未记录' : formatDate(expiry!),
            trailing: days == null
                ? null
                : TagChip(
                    label: countdownLabel(days),
                    tint: days < 0 || days <= 7
                        ? const Color(0xFFF8E4E0)
                        : days <= 30
                        ? AppColors.tintCoral
                        : AppColors.tintGreen,
                    color: days < 0 || days <= 7 ? AppColors.danger : AppColors.ink,
                  ),
          ),
          if (bestBeforeOnly)
            const Padding(
              padding: EdgeInsets.only(bottom: Space.x2),
              child: Text(
                '当前日期来自最佳赏味期（AI 15），不等同于失效日期。',
                style: TextStyle(color: AppColors.brown, fontSize: 12),
              ),
            ),
          if (batch != null && batch!.isNotEmpty) _line('批号', batch!),
          _line('储存', storage),
          _line(
            '开封后',
            openDue == null
                ? (afterOpenDays == null ? '未开封' : '建议 $afterOpenDays 天内喂完')
                : '${countdownOf(openDue, now)}（建议 ${formatDate(openDue)} 前）',
          ),
          const SizedBox(height: Space.x2),
          const Text(
            '到期前会在 30 天和 7 天提醒。开封后按干粮约 4–6 周、湿粮冷藏尽快喂完来倒计时。',
            style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          Expanded(child: Text(value, style: const TextStyle(height: 1.35))),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }
}

Future<bool> confirmDelete(BuildContext context, String title) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: const Text('删除后，相关提醒也会一起取消。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('删除'),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
