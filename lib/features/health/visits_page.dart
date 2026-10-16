import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/dates.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import '../records/record_sheets.dart';
import 'known_or_custom.dart';

class VisitsPage extends StatefulWidget {
  const VisitsPage({super.key});

  @override
  State<VisitsPage> createState() => _VisitsPageState();
}

class _VisitsPageState extends State<VisitsPage> {
  static const _reasons = ['体检', '疫苗', '不吃饭', '呕吐'];
  final _reasonText = TextEditingController();
  final _clinicText = TextEditingController();
  var _reason = '体检';
  var _reasonCustom = false;
  DateTime? _date;
  String? _clinic;
  var _clinicCustom = false;
  var _busy = false;

  @override
  void dispose() {
    _reasonText.dispose();
    _clinicText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    if (cat == null) {
      return Scaffold(
        backgroundColor: AppColors.of(context).background,
        appBar: zhuajiBar('就医'),
        body: const Center(child: Text('先选择一只猫')),
      );
    }
    final date = _date ??= dateOnly(app.now);
    final visits = app.catVisits;
    final clinics = app.knownClinics;
    final clinic = _clinic ??= clinics.isEmpty ? '' : clinics.first;
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: zhuajiBar('就医'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          if (visits.isEmpty)
            Text(
              '还没去过',
              style: zhuaji.copyWith(color: AppColors.of(context).muted),
            )
          else
            for (final visit in visits.take(3)) _Record(visit: visit),
          const SizedBox(height: 8),
          KnownOrCustom(
            known: _reasons,
            selected: _reason,
            custom: _reasonCustom,
            controller: _reasonText,
            hint: '原因',
            onKnown: (label) => setState(() {
              _reasonCustom = false;
              _reason = label;
            }),
            onCustom: () => setState(() => _reasonCustom = true),
          ),
          const SizedBox(height: 8),
          KnownOrCustom(
            known: clinics,
            selected: clinic,
            custom: _clinicCustom,
            controller: _clinicText,
            hint: '医院',
            onKnown: (name) => setState(() {
              _clinicCustom = false;
              _clinic = clinic == name ? '' : name;
            }),
            onCustom: () => setState(() => _clinicCustom = true),
          ),
          DateChips(
            label: '就诊',
            date: date,
            today: app.now,
            onChanged: (value) => setState(() => _date = value),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: _busy
                ? null
                : () async {
                    final reason = chosenOrTyped(
                      custom: _reasonCustom,
                      controller: _reasonText,
                      selected: _reason,
                    );
                    if (reason == null) {
                      showMessage(context, '先写上名字');
                      return;
                    }
                    final typedClinic = chosenOrTyped(
                      custom: _clinicCustom,
                      controller: _clinicText,
                      selected: clinic,
                    );
                    if (_clinicCustom && typedClinic == null) {
                      showMessage(context, '先写上名字');
                      return;
                    }
                    final place = _clinicCustom ? typedClinic : clinic;
                    setState(() => _busy = true);
                    await app.saveVisit(
                      VetDraft(
                        catId: cat.id,
                        visitedOn: date,
                        reason: reason,
                        clinic: place == null || place.isEmpty ? null : place,
                      ),
                    );
                    if (!mounted) return;
                    setState(() => _busy = false);
                    if (!context.mounted) return;
                    showMessage(context, '记下了');
                  },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('记下'),
          ),
        ),
      ),
    );
  }
}

class _Record extends StatelessWidget {
  const _Record({required this.visit});

  final VetRecord visit;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final place = (visit.clinic ?? '').trim();
    final when = place.isEmpty
        ? formatDate(visit.visitedOn)
        : '${formatDate(visit.visitedOn)} · $place';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                visit.reason,
                style: zhuaji.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                when,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: zhuaji.copyWith(
                  color: AppColors.of(context).muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            if (!await confirmDelete(context, '删掉这次？')) return;
            await app.removeVisit(visit.id);
          },
          child: const Text('删除'),
        ),
      ],
    );
  }
}
