import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/weight_chart.dart';
import '../../domain/dates.dart';
import '../../domain/models.dart';
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
    final ownPhotos = app.activeCatId == cat.id ? app.photos : const <CatPhoto>[];
    final weights = app.weights.where((item) => item.catId == cat.id).toList();
    final vaccines = app.vaccines.where((item) => item.catId == cat.id).length;
    final deworms = app.deworms.where((item) => item.catId == cat.id).length;
    final points = <DateTime>[
      cat.createdAt,
      for (final item in weights) item.loggedOn,
      for (final item in ownPhotos) item.takenAt,
    ];
    final earliest = points.map(dateOnly).reduce((a, b) => a.isBefore(b) ? a : b);
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
                      colors: [Color(0x22000000), Color(0x00000000), Color(0xCC2C2A28)],
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
                          if (cat.breed != null) TagChip(label: cat.breed!, tint: Colors.white),
                          if (cat.coatColor != null)
                            TagChip(label: cat.coatColor!, tint: AppColors.green),
                          TagChip(label: sexLabel(cat.sex), tint: Colors.white),
                          TagChip(label: cat.neutered ? '已绝育' : '未绝育', tint: Colors.white),
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
                    _stat('体重', latest == null ? '—' : latest.toStringAsFixed(1), () => context.go('/health')),
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
                if (cat.recognitionDetail != null) ...[
                  SoftCard(
                    color: AppColors.tintCoral,
                    child: Text(cat.recognitionDetail!, style: const TextStyle(height: 1.45)),
                  ),
                  const SizedBox(height: 14),
                ],
                const SectionHeader(title: '成长记录'),
                const SizedBox(height: 10),
                SoftCard(child: WeightChart(weights: weights, compact: true)),
                const SizedBox(height: 16),
                SectionHeader(
                  title: '最近日记',
                  action: '对比',
                  onAction: () async {
                    await app.selectCat(cat.id);
                    if (context.mounted) context.push('/photos');
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 108,
                  child: ownPhotos.isEmpty
                      ? const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('还没有体态照片', style: TextStyle(color: AppColors.muted)),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: ownPhotos.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final photo = ownPhotos[ownPhotos.length - 1 - index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(Radii.m),
                              child: SizedBox(
                                width: 108,
                                child: CatImage(path: photo.path),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                SoftCard(
                  child: Column(
                    children: [
                      _row('年龄', ageLabel(cat.birthday, app.now)),
                      _row('目标', goalLabel(cat.goal)),
                      _row('最近体重', latest == null ? '未记录' : '${latest.toStringAsFixed(2)} kg'),
                      if (cat.notes.isNotEmpty) _row('备注', cat.notes),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => context.push('/cat-form?id=${cat.id}'),
                        child: const Text('编辑资料'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await app.selectCat(cat.id);
                          if (context.mounted) context.push('/photos');
                        },
                        child: const Text('体态对比'),
                      ),
                    ),
                  ],
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
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          Expanded(child: Text(value, style: const TextStyle(height: 1.35))),
        ],
      ),
    );
  }
}
