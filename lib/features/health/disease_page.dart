import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/copy.dart';
import '../../core/format.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/health/checkup_catalog.dart';
import '../../domain/health/disease_catalog.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';

class DiseaseLibraryPage extends StatefulWidget {
  const DiseaseLibraryPage({super.key});

  @override
  State<DiseaseLibraryPage> createState() => _DiseaseLibraryPageState();
}

class _DiseaseLibraryPageState extends State<DiseaseLibraryPage> {
  var _query = '';
  var _showAll = false;

  bool _matchesDisease(DiseaseInfo disease, String query, Set<String> related) {
    if (query.isNotEmpty) {
      return disease.name.contains(query) || disease.summary.contains(query);
    }
    return _showAll || related.contains(disease.id);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    final query = _query.trim();
    final related = <String>{
      for (final item in app.catConditions) item.diseaseId,
    };
    if (breedMatches(cat?.breed, const ['缅因', '布偶', 'maine', 'ragdoll'])) {
      related.add('hcm');
    }
    final items = [
      for (final disease in diseaseCatalog)
        if (_matchesDisease(disease, query, related)) disease,
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('疾病养护')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const Text(
            '仅供参考，请遵医嘱。',
            style: TextStyle(
              color: AppColors.olive,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            kGuidelineSources,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: '搜索疾病',
              hintText: '例如肾病、口炎',
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 12),
          if (query.isEmpty && cat != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _showAll ? '正在看全部疾病' : '先列出和${cat.name}有关的',
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
          if (query.isEmpty && !_showAll)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _showAll = true),
                child: const Text('看其他疾病'),
              ),
            ),
          if (items.isEmpty)
            EmptyHint(
              title: query.isEmpty ? '还没有对上的病' : '没有这种病',
              body: query.isEmpty ? '可以看其他疾病，或搜索名字。' : '换个词，或从列表里点开常见病。',
            )
          else
            for (final disease in items) ...[
              SoftCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    disease.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    disease.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      height: 1.35,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/disease?id=${disease.id}'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          const SizedBox(height: 8),
          const DisclaimerBanner(),
        ],
      ),
    );
  }
}

class DiseaseDetailPage extends StatelessWidget {
  const DiseaseDetailPage({required this.diseaseId, super.key});

  final String diseaseId;

  @override
  Widget build(BuildContext context) {
    final disease = diseaseById(diseaseId);
    if (disease == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('疾病养护')),
        body: const Center(child: Text('没有这种病')),
      );
    }
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    final marked = cat == null ? null : app.conditionFor(disease.id);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(disease.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const Text(
            '仅供参考，请遵医嘱。',
            style: TextStyle(
              color: AppColors.olive,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(disease.summary, style: const TextStyle(height: 1.45)),
          const SizedBox(height: 8),
          Text(
            '出处：${disease.sources}',
            style: const TextStyle(
              color: AppColors.olive,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SoftCard(
            color: AppColors.tintCoral,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '需要立即就医',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                for (final flag in disease.redFlags)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '· $flag',
                      style: const TextStyle(height: 1.35),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (cat == null)
            const Text(
              '先在首页选择一只猫，才能标记确诊和记饮水。',
              style: TextStyle(color: AppColors.brown),
            )
          else
            _MarkCard(disease: disease, catName: cat.name),
          const SizedBox(height: 12),
          _block('饮食', disease.diet),
          _block('饮水', disease.water),
          _block('用药', disease.medication),
          _block('复查频率', disease.recheck),
          _block('居家监测', disease.monitoring),
          if (cat != null) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => showWeightSheet(context),
                    child: const Text('记体重'),
                  ),
                ),
                if (disease.trackWater) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => showWaterSheet(context),
                      child: const Text('记饮水'),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '最近体重 ${app.latestWeight == null ? '还没有' : '${app.latestWeight!.weightKg.toStringAsFixed(2)} kg'}'
              ' · 今日饮水 ${app.todayWaterMl.round()} ml',
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            for (final log in app.catWaters.take(5))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${log.milliliters.round()} ml'),
                subtitle: Text(formatDate(log.loggedOn)),
                trailing: IconButton(
                  tooltip: '删除',
                  onPressed: () async {
                    if (await confirmDelete(context, '删除这条饮水记录？')) {
                      await app.removeWater(log.id);
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            if (marked?.nextRecheck != null)
              Text(
                '复查提醒：${formatDate(marked!.nextRecheck!)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
          ],
          const SizedBox(height: 12),
          const Text(
            kGuidelineSources,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          const DisclaimerBanner(),
        ],
      ),
    );
  }

  Widget _block(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(body, style: const TextStyle(height: 1.45)),
          ],
        ),
      ),
    );
  }
}

class _MarkCard extends StatefulWidget {
  const _MarkCard({required this.disease, required this.catName});

  final DiseaseInfo disease;
  final String catName;

  @override
  State<_MarkCard> createState() => _MarkCardState();
}

class _MarkCardState extends State<_MarkCard> {
  String? _stage;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final marked = app.conditionFor(widget.disease.id);
    final stage =
        _stage ??
        (marked == null || marked.stageLabel.isEmpty
            ? null
            : marked.stageLabel);
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            marked == null
                ? '还没有标成${widget.catName}的确诊'
                : '已标为${widget.catName}的确诊',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (marked != null) ...[
            const SizedBox(height: 4),
            Text(
              '${formatDate(marked.diagnosedOn)}'
              '${marked.stageLabel.isEmpty ? '' : ' · ${marked.stageLabel}'}',
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
          if (widget.disease.stages.isNotEmpty) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: widget.disease.stages.contains(stage)
                  ? stage
                  : null,
              decoration: const InputDecoration(labelText: '兽医给出的分期'),
              items: [
                for (final item in widget.disease.stages)
                  DropdownMenuItem(value: item, child: Text(item)),
              ],
              onChanged: (value) => setState(() => _stage = value),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: () async {
                  await app.markDisease(
                    diseaseId: widget.disease.id,
                    stageLabel: stage ?? marked?.stageLabel ?? '',
                  );
                  if (!context.mounted) return;
                  showMessage(context, '已记到${widget.catName}的健康页，并安排复查提醒');
                },
                child: Text(marked == null ? '标记确诊' : '更新分期'),
              ),
              if (marked != null)
                OutlinedButton(
                  onPressed: () async {
                    final picked = await pickDate(
                      context,
                      marked.nextRecheck ?? app.now,
                    );
                    if (picked == null) return;
                    await app.setRecheck(marked.id, picked);
                    if (!context.mounted) return;
                    showMessage(context, '复查日已改成 ${formatDate(picked)}');
                  },
                  child: const Text('改复查日'),
                ),
              if (marked != null)
                TextButton(
                  onPressed: () async {
                    if (await confirmDelete(
                      context,
                      '取消${widget.catName}的这项确诊标记？',
                    )) {
                      await app.removeCondition(marked.id);
                    }
                  },
                  child: const Text('取消标记'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
