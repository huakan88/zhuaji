import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';

Future<DateTime?> pickDate(BuildContext context, DateTime initial) {
  return pickDateWheel(context, initial);
}

/// Date wheels, so a missed scan does not ask anyone to type a date.
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

class DateLine extends StatelessWidget {
  const DateLine({
    required this.label,
    required this.date,
    required this.onTap,
    super.key,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                label,
                style: zhuaji.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: Text(
                formatDate(date),
                style: zhuaji.copyWith(fontSize: 16),
              ),
            ),
            Text('改', style: zhuaji.copyWith(color: AppColors.coralDeep)),
          ],
        ),
      ),
    );
  }
}
