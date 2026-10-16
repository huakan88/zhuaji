import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// Chip that opens a free-text name. Known choices stay beside it.
const otherChoiceLabel = '其他 / 手动输入';

/// A fixed list plus one manual name. [custom] shows the text field.
class KnownOrCustom extends StatelessWidget {
  const KnownOrCustom({
    required this.known,
    required this.selected,
    required this.custom,
    required this.controller,
    required this.onKnown,
    required this.onCustom,
    required this.hint,
    super.key,
  });

  final List<String> known;
  final String selected;
  final bool custom;
  final TextEditingController controller;
  final ValueChanged<String> onKnown;
  final VoidCallback onCustom;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final label in known)
              ChoiceChip(
                label: Text(label),
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                selected: !custom && selected == label,
                selectedColor: AppColors.of(context).brandTint,
                onSelected: (_) => onKnown(label),
              ),
            ChoiceChip(
              label: const Text(otherChoiceLabel),
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              selected: custom,
              selectedColor: AppColors.of(context).brandTint,
              onSelected: (_) => onCustom(),
            ),
          ],
        ),
        if (custom) ...[
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ],
    );
  }
}

/// The name to store. Null when manual entry is selected and still blank.
String? chosenOrTyped({
  required bool custom,
  required TextEditingController controller,
  required String selected,
}) {
  if (!custom) {
    final known = selected.trim();
    if (known.isEmpty) return null;
    return known;
  }
  final typed = controller.text.trim();
  if (typed.isEmpty) return null;
  return typed;
}

/// Preset amounts plus one typed number. The field stays hidden until 其他.
class NumberOrCustom extends StatelessWidget {
  const NumberOrCustom({
    required this.labels,
    required this.values,
    required this.selected,
    required this.custom,
    required this.controller,
    required this.onKnown,
    required this.onCustom,
    this.hint = '数字',
    this.onApply,
    this.applyLabel = '用这个',
    super.key,
  });

  final List<String> labels;
  final List<num> values;
  final num? selected;
  final bool custom;
  final TextEditingController controller;
  final ValueChanged<num> onKnown;
  final VoidCallback onCustom;
  final String hint;
  final VoidCallback? onApply;
  final String applyLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < labels.length && i < values.length; i++)
              ChoiceChip(
                label: Text(labels[i]),
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                selected: !custom && selected == values[i],
                selectedColor: AppColors.of(context).brandTint,
                onSelected: (_) => onKnown(values[i]),
              ),
            ChoiceChip(
              label: const Text(otherChoiceLabel),
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              selected: custom,
              selectedColor: AppColors.of(context).brandTint,
              onSelected: (_) => onCustom(),
            ),
          ],
        ),
        if (custom) ...[
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onApply?.call(),
            decoration: InputDecoration(hintText: hint),
          ),
          if (onApply != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(onPressed: onApply, child: Text(applyLabel)),
            ),
        ],
      ],
    );
  }
}

/// A positive number from the manual field. Null when it is blank or not a number.
double? typedAmount(TextEditingController controller) {
  final text = controller.text.trim();
  if (text.isEmpty) return null;
  final value = double.tryParse(text);
  if (value == null || value <= 0 || value.isNaN || value.isInfinite) {
    return null;
  }
  return value;
}

/// A positive whole number. Null when it is blank or not a whole number.
int? typedWhole(TextEditingController controller) {
  final text = controller.text.trim();
  if (text.isEmpty) return null;
  final value = int.tryParse(text);
  if (value == null || value <= 0) return null;
  return value;
}
