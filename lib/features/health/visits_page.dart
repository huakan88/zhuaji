import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/dates.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class VisitsPage extends StatefulWidget {
  const VisitsPage({super.key});

  @override
  State<VisitsPage> createState() => _VisitsPageState();
}

class _VisitsPageState extends State<VisitsPage> {
  static const _reasons = ['体检', '疫苗', '不吃饭', '呕吐'];
  var _reason = '体检';
  DateTime? _date;
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    if (cat == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: zhuajiBar('就医'),
        body: const Center(child: Text('先选择一只猫')),
      );
    }
    final date = _date ??= dateOnly(app.now);
    final visits = app.catVisits;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: zhuajiBar('就医'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          if (visits.isEmpty)
            Text('还没去过', style: zhuaji.copyWith(color: AppColors.muted))
          else
            for (final visit in visits.take(3)) _Record(visit: visit),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final label in _reasons)
                ChoiceChip(
                  label: Text(label),
                  selected: _reason == label,
                  selectedColor: AppColors.coral,
                  onSelected: (_) => setState(() => _reason = label),
                ),
            ],
          ),
          DateLine(
            label: '就诊',
            date: date,
            onTap: () async {
              final picked = await pickDate(context, date);
              if (picked == null) return;
              setState(() => _date = dateOnly(picked));
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    await app.saveVisit(
                      VetDraft(catId: cat.id, visitedOn: date, reason: _reason),
                    );
                    if (!mounted) return;
                    setState(() => _busy = false);
                    if (!context.mounted) return;
                    showMessage(context, '记下了');
                  },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('记下'),
          ),
        ),
      ),
    );
  }
}

class _Record extends StatelessWidget {
  const _Record({required this.visit});

  final VetRecord visit;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final place = (visit.clinic ?? '').trim();
    final when = place.isEmpty
        ? formatDate(visit.visitedOn)
        : '${formatDate(visit.visitedOn)} · $place';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                visit.reason,
                style: zhuaji.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                when,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: zhuaji.copyWith(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            if (!await confirmDelete(context, '删掉这次？')) return;
            await app.removeVisit(visit.id);
          },
          child: const Text('删除'),
        ),
      ],
    );
  }
}
