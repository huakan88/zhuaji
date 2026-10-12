import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
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
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          SizedBox(
            height: 280,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CatImage(path: cat.avatarPath),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x33000000), Color(0xCC1E1E1E)],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: SafeArea(
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cat.recognitionDetail != null)
                  SoftCard(
                    color: AppColors.tintCoral,
                    child: Text(cat.recognitionDetail!, style: const TextStyle(height: 1.4)),
                  ),
                const SizedBox(height: Space.x4),
                SoftCard(
                  child: Column(
                    children: [
                      _row('年龄', ageLabel(cat.birthday, app.now)),
                      _row('目标', goalLabel(cat.goal)),
                      _row(
                        '最近体重',
                        app.catWeights.isEmpty
                            ? '未记录'
                            : '${app.catWeights.last.weightKg.toStringAsFixed(2)} kg',
                      ),
                      if (cat.notes.isNotEmpty) _row('备注', cat.notes),
                    ],
                  ),
                ),
                const SizedBox(height: Space.x4),
                FilledButton(
                  onPressed: () => context.push('/cat-form?id=${cat.id}'),
                  child: const Text('编辑资料'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () async {
                    await app.selectCat(cat.id);
                    if (context.mounted) context.push('/photos');
                  },
                  child: const Text('体态对比'),
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
