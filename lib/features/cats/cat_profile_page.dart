import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/dates.dart';
import '../../state/app_controller.dart';

class CatProfilePage extends StatelessWidget {
  const CatProfilePage({required this.catId, super.key});

  final int catId;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.catById(catId);
    if (cat == null) {
      return const Scaffold(body: Center(child: Text('这只猫已经不在名单里')));
    }
    if (app.activeCatId != cat.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (app.activeCatId != cat.id) app.selectCat(cat.id);
      });
    }
    final weights = app.weights.where((item) => item.catId == cat.id).toList();
    final vaccines = app.vaccines.where((item) => item.catId == cat.id).length;
    final deworms = app.deworms.where((item) => item.catId == cat.id).length;
    final points = <DateTime>[
      cat.createdAt,
      for (final item in weights) item.loggedOn,
    ];
    final earliest = points
        .map(dateOnly)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final days = dateOnly(app.now).difference(earliest).inDays;
    final recordDays = days < 1 ? 1 : days;
    final latest = weights.isEmpty ? null : weights.last.weightKg;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          SizedBox(
            height: 320,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CatImage(path: cat.avatarPath),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x22000000),
                        Color(0x00000000),
                        Color(0xCC2C2A28),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: SafeArea(
                    child: Material(
                      color: const Color(0xCCFFFFFF),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: '返回',
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (cat.breed != null)
                            TagChip(label: cat.breed!, tint: Colors.white),
                          if (cat.coatColor != null)
                            TagChip(
                              label: cat.coatColor!,
                              tint: AppColors.green,
                            ),
                          TagChip(label: sexLabel(cat.sex), tint: Colors.white),
                          TagChip(
                            label: cat.neutered ? '已绝育' : '未绝育',
                            tint: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SoftCard(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    _stat('记录天数', '$recordDays', () => context.go('/health')),
                    _stat('疫苗', '$vaccines', () => context.go('/health')),
                    _stat('驱虫', '$deworms', () => context.go('/health')),
                    _stat(
                      '体重',
                      latest == null ? '—' : latest.toStringAsFixed(1),
                      () => context.go('/health'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton(
                  onPressed: () => context.push('/cat-form?id=${cat.id}'),
                  child: const Text('编辑'),
                ),
                TextButton(
                  onPressed: () async {
                    if (await confirmDelete(context, '删除 ${cat.name} 和全部记录？')) {
                      await app.removeCat(cat.id);
                      if (context.mounted) context.pop();
                    }
                  },
                  child: const Text('删除这只猫'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
