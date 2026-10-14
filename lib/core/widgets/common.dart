import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/dates.dart';
import '../format.dart';
import '../theme/app_fonts.dart';
import '../theme/app_tokens.dart';
import 'paw_icon.dart';

class AppScope extends InheritedNotifier<Listenable> {
  const AppScope({required this.controller, required super.child, super.key})
    : super(notifier: controller);

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
        border: Border.all(color: AppColors.line),
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
        style: zhuaji.copyWith(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w700,
        ),
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
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

AppBar zhuajiBar(String title) {
  return AppBar(
    title: Text(title),
    toolbarHeight: 56,
    backgroundColor: AppColors.background,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
  );
}

class QuietCard extends StatelessWidget {
  const QuietCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(Radii.l),
        border: Border.all(color: AppColors.line),
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

class PhotoFrame extends StatelessWidget {
  const PhotoFrame({required this.path, this.height = 248, super.key});

  final String? path;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.xl),
        border: Border.all(color: AppColors.line),
      ),
      child: CatImage(path: path),
    );
  }
}

class HeroCard extends StatelessWidget {
  const HeroCard({
    required this.path,
    required this.title,
    required this.subtitle,
    this.height = 252,
    this.onTitleTap,
    super.key,
  });

  final String? path;
  final String title;
  final String subtitle;
  final double height;
  final VoidCallback? onTitleTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(Radii.xl),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height,
            width: double.infinity,
            child: CatImage(path: path),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onTitleTap,
                  child: Text(
                    title,
                    style: zhuaji.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: zhuaji.copyWith(
                      fontSize: 13,
                      color: AppColors.muted,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: zhuaji.copyWith(
        fontSize: 12,
        color: AppColors.muted,
        height: 1.35,
      ),
    );
  }
}

class IconWell extends StatelessWidget {
  const IconWell({required this.icon, super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(Radii.s),
      ),
      child: Icon(icon, size: 22, color: AppColors.ink),
    );
  }
}

class FadeIn extends StatelessWidget {
  const FadeIn({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class Pressable extends StatefulWidget {
  const Pressable({required this.child, required this.onTap, super.key});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  var _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _EmptyIllustration extends StatelessWidget {
  const _EmptyIllustration();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.xl),
      child: const Image(
        image: AssetImage('assets/cats/cat-icon.jpg'),
        width: 96,
        height: 96,
        fit: BoxFit.cover,
      ),
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
      child: Text(
        '仅供参考，请遵医嘱。',
        style: zhuaji.copyWith(color: AppColors.muted, fontSize: 12),
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
          const _EmptyIllustration(),
          const SizedBox(height: Space.x4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: Space.x2),
          Text(
            body,
            textAlign: TextAlign.center,
            style: zhuaji.copyWith(color: AppColors.muted, height: 1.4),
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
        child: Center(child: PawIcon(size: 42, color: AppColors.coralDeep)),
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
    final openDue =
        openedAt == null || afterOpenDays == null || afterOpenDays! <= 0
        ? null
        : dateOnly(openedAt!).add(Duration(days: afterOpenDays!));
    return SoftCard(
      radius: Radii.xl,
      padding: const EdgeInsets.all(Space.x5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(brand, style: zhuaji.copyWith(color: AppColors.muted)),
          const SizedBox(height: Space.x1),
          Text(
            name,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: Space.x3),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TagChip(
                label: form,
                tint: AppColors.tintGreen,
                color: AppColors.olive,
              ),
              if (spec.isNotEmpty) TagChip(label: spec),
              if (isSample)
                const TagChip(
                  label: '示例数据',
                  tint: AppColors.cream,
                  color: AppColors.brown,
                ),
              if (source != null)
                TagChip(label: source!, tint: AppColors.cream),
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
                    color: days < 0 || days <= 7
                        ? AppColors.danger
                        : AppColors.ink,
                  ),
          ),
          if (bestBeforeOnly)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.x2),
              child: Text(
                '这是最佳赏味期，不等于坏掉的日子。',
                style: zhuaji.copyWith(color: AppColors.brown, fontSize: 12),
              ),
            ),
          if (batch != null && batch!.isNotEmpty) _line('批号', batch!),
          _line('储存', storage),
          _line(
            '开封后',
            openDue == null
                ? (afterOpenDays == null || afterOpenDays! <= 0
                      ? '时限以包装为准'
                      : '建议 $afterOpenDays 天内喂完')
                : '${countdownOf(openDue, now)}（建议 ${formatDate(openDue)} 前）',
          ),
          const SizedBox(height: Space.x2),
          const SizedBox(height: 4),
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
            child: Text(label, style: zhuaji.copyWith(color: AppColors.muted)),
          ),
          Expanded(child: Text(value, style: zhuaji.copyWith(height: 1.35))),
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

void showUndo(
  BuildContext context,
  String text,
  Future<void> Function() onUndo,
) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: '撤销',
        textColor: AppColors.tintCoral,
        onPressed: () => onUndo(),
      ),
    ),
  );
}

void showMessage(BuildContext context, String text) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
  );
}
