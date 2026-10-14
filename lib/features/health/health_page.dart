import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    final kg = app.latestWeight?.weightKg;
    const tiles = [
      _Tile('体重', '步进记下', Icons.monitor_weight_outlined, '/weight'),
      _Tile('疫苗', '猫三联、狂犬', Icons.vaccines_outlined, '/vaccines'),
      _Tile('驱虫', '体内、体外', Icons.bug_report_outlined, '/deworms'),
      _Tile('就医', '体检、呕吐', Icons.local_hospital_outlined, '/visits'),
      _Tile('体检', '按年龄', Icons.fact_check_outlined, '/checkups'),
      _Tile('看病', '点病名', Icons.healing_outlined, '/diseases'),
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: zhuajiBar('健康'),
      body: FadeIn(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 108),
          children: [
            if (cat != null) ...[
              Row(
                children: [
                  CatAvatar(path: cat.avatarPath, size: 56, selected: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name,
                          style: zhuaji.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _meta(cat, app.now),
                          style: zhuaji.copyWith(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (kg != null)
                    Text(
                      '${kg.toStringAsFixed(2)} kg',
                      style: zhuaji.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            const SectionLabel('护理'),
            const SizedBox(height: 8),
            QuietCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 4,
                childAspectRatio: 0.92,
                children: [
                  for (final tile in tiles)
                    InkWell(
                      onTap: () => context.push(tile.path),
                      borderRadius: BorderRadius.circular(Radii.m),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconWell(icon: tile.icon),
                          const SizedBox(height: 8),
                          Text(
                            tile.label,
                            style: zhuaji.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tile.caption,
                            textAlign: TextAlign.center,
                            style: zhuaji.copyWith(
                              fontSize: 11,
                              color: AppColors.muted,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _meta(CatProfile cat, DateTime now) {
    final parts = <String>[
      if (cat.breed != null && cat.breed!.isNotEmpty) cat.breed!,
      ageLabel(cat.birthday, now),
    ];
    return parts.join(' · ');
  }
}

class _Tile {
  const _Tile(this.label, this.caption, this.icon, this.path);

  final String label;
  final String caption;
  final IconData icon;
  final String path;
}
