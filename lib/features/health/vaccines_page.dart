import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/care/easy_log.dart';
import '../../domain/dates.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class VaccinesPage extends StatefulWidget {
  const VaccinesPage({super.key});

  @override
  State<VaccinesPage> createState() => _VaccinesPageState();
}

class _VaccinesPageState extends State<VaccinesPage> {
  static const _names = ['猫三联', '狂犬'];
  var _name = '猫三联';
  DateTime? _given;
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    if (cat == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: zhuajiBar('疫苗'),
        body: const Center(child: Text('先选择一只猫')),
      );
    }
    final given = _given ??= dateOnly(app.now);
    final next = nextVaccineDate(cat.birthday, given);
    final shots = [...app.catVaccines]
      ..sort((a, b) {
        final left = a.nextDue ?? a.givenOn;
        final right = b.nextDue ?? b.givenOn;
        return left.compareTo(right);
      });
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: zhuajiBar('疫苗'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          if (shots.isEmpty)
            Text('还没记', style: zhuaji.copyWith(color: AppColors.muted))
          else
            for (final shot in shots.take(3)) _Record(shot: shot),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final label in _names)
                ChoiceChip(
                  label: Text(label),
                  selected: _name == label,
                  selectedColor: AppColors.coral,
                  onSelected: (_) => setState(() => _name = label),
                ),
            ],
          ),
          DateLine(
            label: '接种',
            date: given,
            onTap: () async {
              final picked = await pickDate(context, given);
              if (picked == null) return;
              setState(() => _given = dateOnly(picked));
            },
          ),
          Text(
            '下次 ${formatDate(next)}',
            style: zhuaji.copyWith(color: AppColors.muted),
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
                    await app.saveVaccine(
                      VaccineDraft(
                        catId: cat.id,
                        name: _name,
                        givenOn: given,
                        nextDue: next,
                      ),
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
  const _Record({required this.shot});

  final VaccineRecord shot;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final due = shot.nextDue;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                shot.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: zhuaji.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                due == null ? '下次还没定' : '下次 ${countdownOf(due, app.now)}',
                style: zhuaji.copyWith(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            final next = await app.completeVaccine(shot);
            if (!context.mounted) return;
            showMessage(context, '下次 ${formatDate(next)}');
          },
          child: const Text('完成'),
        ),
        TextButton(
          onPressed: () async {
            if (!await confirmDelete(context, '删掉这针？')) return;
            await app.removeVaccine(shot.id);
          },
          child: const Text('删除'),
        ),
      ],
    );
  }
}
