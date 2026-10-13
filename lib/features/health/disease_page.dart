import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/health/checkup_catalog.dart';
import '../../domain/health/disease_catalog.dart';
import '../../state/app_controller.dart';

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
      appBar: AppBar(title: const Text('看病')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          TextField(
            decoration: const InputDecoration(labelText: '搜索'),
            onChanged: (value) => setState(() => _query = value),
          ),
          if (query.isEmpty && !_showAll)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _showAll = true),
                child: const Text('全部'),
              ),
            ),
          if (items.isEmpty)
            const EmptyHint(title: '没有', body: '')
          else
            for (final disease in items) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  disease.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onTap: () => context.push('/disease?id=${disease.id}'),
              ),
              const Divider(height: 1),
            ],
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
        appBar: AppBar(title: const Text('看病')),
        body: const Center(child: Text('没有')),
      );
    }
    final app = AppScope.of<AppController>(context);
    final marked = app.active == null ? null : app.conditionFor(disease.id);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(disease.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(disease.summary, style: const TextStyle(height: 1.4)),
          const SizedBox(height: 16),
          const Text('红灯', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          for (final flag in disease.redFlags)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('· $flag'),
            ),
          const SizedBox(height: 16),
          const Text('喂养', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(disease.diet, style: const TextStyle(height: 1.4)),
          if (app.active != null) ...[
            const SizedBox(height: 20),
            FilledButton(
              onPressed: marked != null
                  ? null
                  : () async {
                      await app.markDisease(diseaseId: disease.id);
                      if (!context.mounted) return;
                      showMessage(context, '记下了');
                    },
              child: Text(marked == null ? '记下' : '已记'),
            ),
          ],
        ],
      ),
    );
  }
}
