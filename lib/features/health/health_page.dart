import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    const tiles = [
      _Tile(
        '体重',
        Icons.monitor_weight_outlined,
        '/weight',
        AppColors.tintSage,
        AppColors.olive,
      ),
      _Tile(
        '疫苗',
        Icons.vaccines_outlined,
        '/vaccines',
        AppColors.tintCoral,
        AppColors.coralDeep,
      ),
      _Tile(
        '驱虫',
        Icons.bug_report_outlined,
        '/deworms',
        AppColors.tintGreen,
        AppColors.olive,
      ),
      _Tile(
        '就医',
        Icons.local_hospital_outlined,
        '/visits',
        AppColors.tintBrown,
        AppColors.brown,
      ),
      _Tile(
        '体检',
        Icons.fact_check_outlined,
        '/checkups',
        AppColors.tintOlive,
        AppColors.sage,
      ),
      _Tile(
        '看病',
        Icons.healing_outlined,
        '/diseases',
        AppColors.tintRose,
        AppColors.danger,
      ),
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: zhuajiBar('健康'),
      body: FadeIn(
        child: GridView.count(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.12,
          children: [
            for (final tile in tiles)
              Pressable(
                onTap: () => context.push(tile.path),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: softShadow,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: tile.tint,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(tile.icon, size: 32, color: tile.ink),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tile.label,
                        style: zhuaji.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tile {
  const _Tile(this.label, this.icon, this.path, this.tint, this.ink);

  final String label;
  final IconData icon;
  final String path;
  final Color tint;
  final Color ink;
}
