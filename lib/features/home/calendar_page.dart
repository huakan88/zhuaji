import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/care/agenda.dart';
import '../../domain/dates.dart';
import '../../state/app_controller.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final start = dateOnly(app.now);
    final selected = dateOnly(_selected ?? start);
    final items = app.agenda();
    final days = [
      for (var i = 0; i < agendaSpanDays; i++) start.add(Duration(days: i)),
    ];
    final leading = start.weekday - 1;
    final cells = <DateTime?>[for (var i = 0; i < leading; i++) null, ...days];
    final onDay = agendaOn(items, selected);
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: zhuajiBar('未来 30 天'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
        children: [
          Row(
            children: [
              for (final label in const ['一', '二', '三', '四', '五', '六', '日'])
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: zhuaji.copyWith(
                        fontSize: 12,
                        color: AppColors.of(context).muted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 0,
            childAspectRatio: 1,
            children: [
              for (final day in cells)
                _DayCell(
                  day: day,
                  count: day == null ? 0 : agendaOn(items, day).length,
                  selected: day != null && dateOnly(day) == selected,
                  onTap: day == null
                      ? null
                      : () => setState(() => _selected = day),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SectionLabel(formatDate(selected)),
          const SizedBox(height: 8),
          if (onDay.isEmpty)
            const EmptyHint(title: '这天没什么要办', body: '有安排的日子下面有一个小点')
          else
            for (final item in onDay) ...[
              _AgendaRow(item: item),
              const SizedBox(height: 8),
            ],
          const SizedBox(height: 20),
          Text(
            'Android 现在可以在桌面加「今天的事」，点一下进对应的页。iPhone 要等安装包里带上小组件后才会出现。',
            style: zhuaji.copyWith(
              fontSize: 13,
              color: AppColors.of(context).muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('小组件显示待办'),
                selected: app.widgetEnabled,
                selectedColor: AppColors.of(context).brandTint,
                onSelected: (_) => app.setWidgetEnabled(true),
              ),
              ChoiceChip(
                label: const Text('小组件不显示'),
                selected: !app.widgetEnabled,
                selectedColor: AppColors.of(context).brandTint,
                onSelected: (_) => app.setWidgetEnabled(false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final DateTime? day;
  final int count;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final value = day;
    if (value == null) return const SizedBox.shrink();
    return Material(
      color: selected
          ? AppColors.of(context).brandTint
          : AppColors.of(context).card,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? AppColors.of(context).brandDeep
                  : AppColors.of(context).line,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${value.day}',
                style: zhuaji.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: count > 0
                      ? AppColors.of(context).brandDeep
                      : AppColors.clear,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgendaRow extends StatelessWidget {
  const _AgendaRow({required this.item});

  final AgendaItem item;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    return QuietCard(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.overdue ? '${item.title} · 已过' : item.title,
                  style: zhuaji.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.detail,
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
          TextButton(
            onPressed: () async {
              final text = await app.completeAgenda(item);
              if (!context.mounted) return;
              showMessage(context, text);
            },
            child: const Text('完成'),
          ),
          TextButton(
            onPressed: () async {
              await app.postponeAgenda(item);
              if (!context.mounted) return;
              showMessage(context, '顺延了 7 天');
            },
            child: const Text('顺延'),
          ),
        ],
      ),
    );
  }
}
