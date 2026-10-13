import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/care/easy_log.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';

Future<DateTime?> pickDate(BuildContext context, DateTime initial) {
  return showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
}

Future<void> showWeightSheet(BuildContext context) async {
  final app = AppScope.of<AppController>(context);
  if (app.active == null) return;
  final kg = ValueNotifier<double>(app.latestWeight?.weightKg ?? 4);
  try {
    await _sheet(
      context,
      title: '记录体重',
      child: ValueListenableBuilder<double>(
        valueListenable: kg,
        builder: (context, value, _) => Column(
          children: [
            Text(
              '${value.toStringAsFixed(2)} kg',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              '默认是上次的体重',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        kg.value = (value - 0.05).clamp(0.5, 12).toDouble(),
                    child: const Text('轻一点'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        kg.value = (value + 0.05).clamp(0.5, 12).toDouble(),
                    child: const Text('重一点'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onSubmit: () async {
        final value = kg.value;
        if (value <= 0 || value > 20) return '请填写 0 到 20 kg 之间的体重';
        await app.addWeight(value);
        return null;
      },
    );
  } finally {
    kg.dispose();
  }
}

Future<void> showVaccineSheet(
  BuildContext context, {
  VaccineRecord? existing,
}) async {
  final app = AppScope.of<AppController>(context);
  final cat = app.active;
  if (cat == null) return;
  final name = TextEditingController(text: existing?.name ?? '猫三联');
  final clinic = TextEditingController(text: existing?.clinic ?? '');
  final notes = TextEditingController(text: existing?.notes ?? '');
  var given = existing?.givenOn ?? app.now;
  var due = existing?.nextDue ?? nextVaccineDate(cat.birthday, given);
  try {
    await _sheet(
      context,
      title: existing == null ? '添加疫苗' : '编辑疫苗',
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '下次日期已按接种日自动算好',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final label in ['猫三联', '狂犬'])
                  ChoiceChip(
                    label: Text(label),
                    selected: name.text == label,
                    selectedColor: AppColors.coral,
                    onSelected: (_) {
                      name.text = label;
                      setState(() {});
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: '名称'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: clinic,
              decoration: const InputDecoration(labelText: '医院（可选）'),
            ),
            const SizedBox(height: 12),
            _dateTile('接种日期', given, () async {
              final picked = await pickDate(context, given);
              if (picked != null) setState(() => given = picked);
            }),
            _dateTile('下次日期', due, () async {
              final picked = await pickDate(context, due);
              if (picked != null) setState(() => due = picked);
            }),
            TextField(
              controller: notes,
              decoration: const InputDecoration(labelText: '备注'),
            ),
          ],
        ),
      ),
      onSubmit: () async {
        if (name.text.trim().isEmpty) return '先写疫苗名称';
        await app.saveVaccine(
          VaccineDraft(
            id: existing?.id,
            catId: cat.id,
            name: name.text,
            givenOn: given,
            nextDue: due,
            clinic: clinic.text,
            notes: notes.text,
          ),
        );
        return null;
      },
    );
  } finally {
    name.dispose();
    clinic.dispose();
    notes.dispose();
  }
}

Future<void> showDewormSheet(
  BuildContext context, {
  DewormRecord? existing,
}) async {
  final app = AppScope.of<AppController>(context);
  final cat = app.active;
  if (cat == null) return;
  final product = TextEditingController(text: existing?.product ?? '');
  final notes = TextEditingController(text: existing?.notes ?? '');
  var kind = existing?.kind ?? DewormKind.internal;
  var given = existing?.givenOn ?? app.now;
  var due = existing?.nextDue ?? app.now.add(const Duration(days: 90));
  try {
    await _sheet(
      context,
      title: existing == null ? '添加驱虫' : '编辑驱虫',
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            SegmentedButton<DewormKind>(
              segments: const [
                ButtonSegment(value: DewormKind.internal, label: Text('体内')),
                ButtonSegment(value: DewormKind.external, label: Text('体外')),
              ],
              selected: {kind},
              onSelectionChanged: (value) => setState(() => kind = value.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: product,
              decoration: const InputDecoration(labelText: '药品名称'),
            ),
            _dateTile('使用日期', given, () async {
              final picked = await pickDate(context, given);
              if (picked != null) setState(() => given = picked);
            }),
            _dateTile('下次日期', due, () async {
              final picked = await pickDate(context, due);
              if (picked != null) setState(() => due = picked);
            }),
            TextField(
              controller: notes,
              decoration: const InputDecoration(labelText: '备注'),
            ),
          ],
        ),
      ),
      onSubmit: () async {
        if (product.text.trim().isEmpty) return '先写药品名称';
        await app.saveDeworm(
          DewormDraft(
            id: existing?.id,
            catId: cat.id,
            kind: kind,
            product: product.text,
            givenOn: given,
            nextDue: due,
            notes: notes.text,
          ),
        );
        return null;
      },
    );
  } finally {
    product.dispose();
    notes.dispose();
  }
}

Future<void> showVisitSheet(BuildContext context, {VetRecord? existing}) async {
  final app = AppScope.of<AppController>(context);
  final cat = app.active;
  if (cat == null) return;
  final reason = TextEditingController(text: existing?.reason ?? '');
  final clinic = TextEditingController(text: existing?.clinic ?? '');
  final diagnosis = TextEditingController(text: existing?.diagnosis ?? '');
  final treatment = TextEditingController(text: existing?.treatment ?? '');
  final notes = TextEditingController(text: existing?.notes ?? '');
  var date = existing?.visitedOn ?? app.now;
  try {
    await _sheet(
      context,
      title: existing == null ? '就医记录' : '编辑就医',
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            _dateTile('就诊日期', date, () async {
              final picked = await pickDate(context, date);
              if (picked != null) setState(() => date = picked);
            }),
            TextField(
              controller: clinic,
              decoration: const InputDecoration(labelText: '医院'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reason,
              decoration: const InputDecoration(labelText: '原因'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: diagnosis,
              decoration: const InputDecoration(labelText: '诊断（你的记录）'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: treatment,
              decoration: const InputDecoration(labelText: '处理'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notes,
              decoration: const InputDecoration(labelText: '备注'),
            ),
          ],
        ),
      ),
      onSubmit: () async {
        if (reason.text.trim().isEmpty) return '先写就医原因';
        await app.saveVisit(
          VetDraft(
            id: existing?.id,
            catId: cat.id,
            visitedOn: date,
            clinic: clinic.text,
            reason: reason.text,
            diagnosis: diagnosis.text,
            treatment: treatment.text,
            notes: notes.text,
          ),
        );
        return null;
      },
    );
  } finally {
    reason.dispose();
    clinic.dispose();
    diagnosis.dispose();
    treatment.dispose();
    notes.dispose();
  }
}

Future<void> _sheet(
  BuildContext context, {
  required String title,
  required Widget child,
  required Future<String?> Function() onSubmit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
    ),
    builder: (sheetContext) {
      var error = '';
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          24 + MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: StatefulBuilder(
          builder: (context, setLocal) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  child,
                  if (error.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      error,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      final navigator = Navigator.of(sheetContext);
                      final String? message;
                      try {
                        message = await onSubmit();
                      } catch (caught) {
                        if (!sheetContext.mounted) return;
                        setLocal(() => error = '没有保存成功，请再试一次');
                        debugPrint('记录没有写入：$caught');
                        return;
                      }
                      if (message == null) {
                        navigator.pop();
                      } else if (sheetContext.mounted) {
                        final shown = message;
                        setLocal(() => error = shown);
                      }
                    },
                    child: const Text('保存'),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Future<void> showWaterSheet(BuildContext context) async {
  final app = AppScope.of<AppController>(context);
  if (app.active == null) {
    showMessage(context, '先选择一只猫');
    return;
  }
  final amount = TextEditingController();
  try {
    await _sheet(
      context,
      title: '记录饮水',
      child: TextField(
        controller: amount,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: '大约喝了多少毫升',
          hintText: '例如 180',
        ),
      ),
      onSubmit: () async {
        final value = double.tryParse(amount.text.trim());
        if (value == null || value < 1 || value > 2000) {
          return '饮水量请填 1 到 2000 毫升';
        }
        await app.addWater(value);
        return null;
      },
    );
  } finally {
    amount.dispose();
  }
}

/// Date wheels, so a missed OCR read does not ask anyone to type a date.
Future<DateTime?> pickDateWheel(BuildContext context, DateTime initial) {
  var selected = DateTime(initial.year, initial.month, initial.day);
  return showModalBottomSheet<DateTime>(
    context: context,
    builder: (context) => SafeArea(
      child: SizedBox(
        height: 320,
        child: Column(
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context, selected),
                  child: const Text('确定'),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: selected,
                minimumDate: DateTime(2000),
                maximumDate: DateTime(2100, 12, 31),
                onDateTimeChanged: (value) => selected = value,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _dateTile(String label, DateTime date, VoidCallback onTap) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: Text(formatDate(date)),
    trailing: const Icon(Icons.calendar_today_outlined, size: 18),
    onTap: onTap,
  );
}
