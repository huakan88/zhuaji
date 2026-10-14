import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    const tiles = [
      _Tile('体重', Icons.monitor_weight_outlined, '/weight'),
      _Tile('疫苗', Icons.vaccines_outlined, '/vaccines'),
      _Tile('驱虫', Icons.bug_report_outlined, '/deworms'),
      _Tile('就医', Icons.local_hospital_outlined, '/visits'),
      _Tile('体检', Icons.fact_check_outlined, '/checkups'),
      _Tile('看病', Icons.healing_outlined, '/diseases'),
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('健康')),
      body: GridView.count(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.15,
        children: [
          for (final tile in tiles)
            Material(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.push(tile.path),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(tile.icon, size: 40, color: AppColors.coralDeep),
                    const SizedBox(height: 10),
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
    );
  }
}

class _Tile {
  const _Tile(this.label, this.icon, this.path);

  final String label;
  final IconData icon;
  final String path;
}
