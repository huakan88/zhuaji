import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
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
  final input = TextEditingController(
    text: app.latestWeight?.weightKg.toStringAsFixed(2) ?? '',
  );
  try {
    await _sheet(
    context,
    title: '记录体重',
    child: TextField(
      controller: input,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      decoration: const InputDecoration(labelText: '体重（kg）'),
    ),
    onSubmit: () async {
      final kg = double.tryParse(input.text);
      if (kg == null || kg <= 0 || kg > 20) {
        return '请填写 0 到 20 kg 之间的体重';
      }
      await app.addWeight(kg);
      return null;
    },
  );
  } finally {
    input.dispose();
  }
}

Future<void> showNoteSheet(BuildContext context) async {
  final app = AppScope.of<AppController>(context);
  if (app.active == null) return;
  final input = TextEditingController();
  try {
    await _sheet(
    context,
    title: '健康笔记',
    child: TextField(
      controller: input,
      maxLines: 4,
      decoration: const InputDecoration(hintText: '食欲、精神、排便，或者你想记住的小事'),
    ),
    onSubmit: () async {
      if (input.text.trim().isEmpty) return '先写一点内容';
      await app.addNote(input.text);
      return null;
    },
  );
  } finally {
    input.dispose();
  }
}

Future<void> showVaccineSheet(BuildContext context, {VaccineRecord? existing}) async {
  final app = AppScope.of<AppController>(context);
  final cat = app.active;
  if (cat == null) return;
  final name = TextEditingController(text: existing?.name ?? '猫三联');
  final clinic = TextEditingController(text: existing?.clinic ?? '');
  final notes = TextEditingController(text: existing?.notes ?? '');
  var given = existing?.givenOn ?? app.now;
  var due = existing?.nextDue ?? app.now.add(const Duration(days: 365));
  try {
    await _sheet(
    context,
    title: existing == null ? '添加疫苗' : '编辑疫苗',
    child: StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: '名称')),
          const SizedBox(height: 12),
          TextField(controller: clinic, decoration: const InputDecoration(labelText: '医院（可选）')),
          const SizedBox(height: 12),
          _dateTile('接种日期', given, () async {
            final picked = await pickDate(context, given);
            if (picked != null) setState(() => given = picked);
          }),
          _dateTile('下次日期', due, () async {
            final picked = await pickDate(context, due);
            if (picked != null) setState(() => due = picked);
          }),
          TextField(controller: notes, decoration: const InputDecoration(labelText: '备注')),
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

Future<void> showDewormSheet(BuildContext context, {DewormRecord? existing}) async {
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
          TextField(controller: notes, decoration: const InputDecoration(labelText: '备注')),
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
          TextField(controller: clinic, decoration: const InputDecoration(labelText: '医院')),
          const SizedBox(height: 12),
          TextField(controller: reason, decoration: const InputDecoration(labelText: '原因')),
          const SizedBox(height: 12),
          TextField(controller: diagnosis, decoration: const InputDecoration(labelText: '诊断（你的记录）')),
          const SizedBox(height: 12),
          TextField(controller: treatment, decoration: const InputDecoration(labelText: '处理')),
          const SizedBox(height: 12),
          TextField(controller: notes, decoration: const InputDecoration(labelText: '备注')),
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

Future<void> showFeedingSheet(BuildContext context) async {
  final app = AppScope.of<AppController>(context);
  final cat = app.active;
  if (cat == null) return;
  final grams = TextEditingController(text: '40');
  final custom = TextEditingController();
  var form = FoodForm.dry;
  var slot = MealSlot.breakfast;
  int? productId;
  try {
    await _sheet(
    context,
    title: '记一餐',
    child: StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          DropdownButtonFormField<int?>(
            initialValue: productId,
            decoration: const InputDecoration(labelText: '猫粮（可选）'),
            items: [
              const DropdownMenuItem(value: null, child: Text('不关联图鉴，自己写')),
              for (final product in app.products)
                DropdownMenuItem(
                  value: product.id,
                  child: Text(
                    product.displayName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (value) => setState(() {
              productId = value;
              final product = value == null ? null : app.productById(value);
              if (product != null) {
                form = product.foodForm;
                custom.text = product.displayName;
              }
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: custom,
            decoration: const InputDecoration(labelText: '食物名称'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<FoodForm>(
            initialValue: form,
            decoration: const InputDecoration(labelText: '类型'),
            items: [
              for (final item in FoodForm.values)
                DropdownMenuItem(value: item, child: Text(formLabel(item))),
            ],
            onChanged: (value) => setState(() => form = value ?? form),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: grams,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: '克数'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<MealSlot>(
            initialValue: slot,
            decoration: const InputDecoration(labelText: '餐次'),
            items: [
              for (final item in MealSlot.values)
                DropdownMenuItem(value: item, child: Text(slotLabel(item))),
            ],
            onChanged: (value) => setState(() => slot = value ?? slot),
          ),
        ],
      ),
    ),
    onSubmit: () async {
      final amount = double.tryParse(grams.text);
      final name = custom.text.trim().isEmpty ? '未命名食物' : custom.text.trim();
      if (amount == null || amount <= 0 || amount > 500) {
        return '克数请填 0 到 500';
      }
      final product = productId == null ? null : app.productById(productId!);
      final kcal = product?.kcalPer100g == null
          ? null
          : amount * product!.kcalPer100g! / 100;
      await app.saveFeeding(
        FeedingDraft(
          catId: cat.id,
          loggedAt: app.now,
          foodName: name,
          foodForm: form,
          grams: amount,
          kcal: kcal,
          productId: productId,
          slot: slot,
        ),
      );
      return null;
    },
  );
  } finally {
    grams.dispose();
    custom.dispose();
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  child,
                  if (error.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(error, style: const TextStyle(color: AppColors.danger)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      final String? message;
                      try {
                        message = await onSubmit();
                      } catch (caught) {
                        if (!sheetContext.mounted) return;
                        setLocal(() => error = '没有保存成功，请再试一次');
                        debugPrint('记录没有写入：$caught');
                        return;
                      }
                      if (!sheetContext.mounted) return;
                      if (message == null) {
                        Navigator.pop(sheetContext);
                      } else {
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

Future<void> showCheckupResultSheet(
  BuildContext context, {
  required String itemId,
  required String itemName,
  required int intervalDays,
}) async {
  final app = AppScope.of<AppController>(context);
  if (app.active == null) {
    showMessage(context, '先选择一只猫');
    return;
  }
  final result = TextEditingController();
  try {
    await _sheet(
      context,
      title: '记录$itemName',
      child: TextField(
        controller: result,
        minLines: 2,
        maxLines: 4,
        decoration: const InputDecoration(
          labelText: '兽医怎么说',
          hintText: '写下结论或报告要点，不要只写“正常”',
        ),
      ),
      onSubmit: () async {
        final text = result.text.trim();
        if (text.isEmpty) return '先写一点检查结果';
        await app.completeCheckup(
          itemId: itemId,
          result: text,
          intervalDays: intervalDays,
        );
        return null;
      },
    );
  } finally {
    result.dispose();
  }
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
