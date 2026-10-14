import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../state/app_controller.dart';

class WeightPage extends StatefulWidget {
  const WeightPage({super.key});

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  double? _kg;
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    if (cat == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: zhuajiBar('体重'),
        body: const Center(child: Text('先选择一只猫')),
      );
    }
    final kg = _kg ??= app.latestWeight?.weightKg ?? 4;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: zhuajiBar('体重'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          children: [
            Text(cat.name, style: zhuaji.copyWith(color: AppColors.muted)),
            const SizedBox(height: 12),
            Text(
              '${kg.toStringAsFixed(2)} kg',
              style: zhuaji.copyWith(fontSize: 48, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '点一下，每次 0.05 kg',
              style: zhuaji.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(
                      () => _kg = (kg - 0.05).clamp(0.5, 12).toDouble(),
                    ),
                    child: const Text('轻一点'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(
                      () => _kg = (kg + 0.05).clamp(0.5, 12).toDouble(),
                    ),
                    child: const Text('重一点'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    await app.addWeight(kg);
                    await app.ackWeightAlert(cat);
                    if (!context.mounted) return;
                    context.pop();
                  },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('保存'),
          ),
        ),
      ),
    );
  }
}
