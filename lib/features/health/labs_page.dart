import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/health/lab_catalog.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';

class LabsPage extends StatelessWidget {
  const LabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final reports = [...app.catLabs]
      ..sort((a, b) => b.takenOn.compareTo(a.takenOn));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: zhuajiBar('化验单'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            '按时间留下原图。血常规和生化可以对照常用范围看一看。',
            style: zhuaji.copyWith(
              fontSize: 13,
              height: 1.4,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          if (reports.isEmpty)
            EmptyHint(
              title: '还没有',
              body: '拍一张化验单，或从相册选',
              action: '记一份',
              onAction: () => context.push('/lab'),
            )
          else
            for (final report in reports) ...[
              QuietCard(
                onTap: () => context.push('/lab?id=${report.id}'),
                child: Row(
                  children: [
                    _Thumb(path: report.photos.isEmpty ? null : report.photos.first),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${formatDate(report.takenOn)} · ${labKindLabel(report.kind)}',
                            style: zhuaji.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _summary(report),
                            style: zhuaji.copyWith(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: () => context.push('/lab'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: const Text('记一份'),
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final file = path == null ? null : File(path!);
    final ready = file != null && file.existsSync();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 56,
        height: 56,
        child: ready
            ? Image.file(file, fit: BoxFit.cover)
            : const ColoredBox(
                color: AppColors.cream,
                child: Icon(Icons.image_outlined, color: AppColors.muted),
              ),
      ),
    );
  }
}

String _summary(LabReport report) {
  var high = 0;
  var low = 0;
  for (final value in report.values) {
    final reading = readLabValue(value);
    if (reading == null) continue;
    if (reading.flag == LabFlag.high) high++;
    if (reading.flag == LabFlag.low) low++;
  }
  if (report.values.isEmpty) return '${report.photos.length} 张原图';
  if (high == 0 && low == 0) return '读到的都在范围内';
  return [
    if (high > 0) '$high 项偏高',
    if (low > 0) '$low 项偏低',
  ].join('，');
}
