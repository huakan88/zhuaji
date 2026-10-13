import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/health/disease_catalog.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class CatsPage extends StatelessWidget {
  const CatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('猫')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          SizedBox(
            height: 76,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final item in app.cats) ...[
                  GestureDetector(
                    onTap: () => app.selectCat(item.id),
                    child: SizedBox(
                      width: 64,
                      child: Column(
                        children: [
                          CatAvatar(
                            path: item.avatarPath,
                            size: 48,
                            selected: item.id == cat?.id,
                          ),
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: zhuaji.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                GestureDetector(
                  onTap: () => context.push('/cat-form'),
                  child: SizedBox(
                    width: 64,
                    child: Column(
                      children: [
                        const CatAvatar(path: null, size: 48),
                        Text('添加', style: zhuaji.copyWith(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (cat == null)
            EmptyHint(
              title: '还没猫',
              body: '',
              action: '建档',
              onAction: () => context.push('/cat-form'),
            )
          else ...[
            Center(
              child: CatAvatar(path: cat.avatarPath, size: 168, selected: true),
            ),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: () => context.push('/cat-form?id=${cat.id}'),
                child: Text(
                  cat.name,
                  style: zhuaji.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: GestureDetector(
                onTap: () => showWeightSheet(context),
                child: Text(
                  app.latestWeight == null
                      ? '— kg'
                      : '${app.latestWeight!.weightKg.toStringAsFixed(2)} kg',
                  style: zhuaji.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: AppColors.coralDeep,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            _EntryRow(
              left: _Entry(
                title: '疫苗',
                detail: _dueLine(app.nextVaccine?.nextDue, app),
                onTap: () => context.push('/vaccines'),
              ),
              right: _Entry(
                title: '驱虫',
                detail: _dueLine(_soonestDeworm(app)?.nextDue, app),
                onTap: () => context.push('/deworms'),
              ),
            ),
            const SizedBox(height: 8),
            _EntryRow(
              left: _Entry(
                title: '就医',
                detail: app.catVisits.isEmpty
                    ? '还没记'
                    : app.catVisits.first.reason,
                onTap: () => context.push('/visits'),
              ),
              right: _Entry(
                title: '体检',
                detail: '按年龄',
                onTap: () => context.push('/checkups'),
              ),
            ),
            const SizedBox(height: 8),
            _EntryRow(
              left: _Entry(
                title: '看病',
                detail: _diseaseLine(app),
                onTap: () => context.push('/diseases'),
              ),
              right: _Entry(
                title: '粮仓',
                detail: app.pantry.isEmpty ? '还没有' : '${app.pantry.length} 袋',
                onTap: () => context.push('/pantry'),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () async {
                  if (await confirmDelete(context, '删除${cat.name}？')) {
                    await app.removeCat(cat.id);
                  }
                },
                child: const Text('删除'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _dueLine(DateTime? due, AppController app) {
  if (due == null) return '还没记';
  return countdownOf(due, app.now);
}

DewormRecord? _soonestDeworm(AppController app) {
  DewormRecord? soonest;
  for (final item in app.catDeworms) {
    final due = item.nextDue;
    if (due == null) continue;
    if (soonest == null || due.isBefore(soonest.nextDue!)) soonest = item;
  }
  return soonest;
}

String _diseaseLine(AppController app) {
  if (app.catConditions.isEmpty) return '搜病名';
  return diseaseById(app.catConditions.first.diseaseId)?.name ?? '已记';
}

class _Entry {
  const _Entry({
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final String title;
  final String detail;
  final VoidCallback onTap;
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.left, required this.right});

  final _Entry left;
  final _Entry right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _EntryButton(entry: left)),
        const SizedBox(width: 8),
        Expanded(child: _EntryButton(entry: right)),
      ],
    );
  }
}

class _EntryButton extends StatelessWidget {
  const _EntryButton({required this.entry});

  final _Entry entry;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: entry.onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        alignment: Alignment.centerLeft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.title,
            style: zhuaji.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          Text(
            entry.detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: zhuaji.copyWith(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
