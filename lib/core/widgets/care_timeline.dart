import 'package:flutter/material.dart';

import '../format.dart';
import '../theme/app_fonts.dart';
import '../theme/app_tokens.dart';
import '../../domain/care/care_story.dart';
import 'common.dart';

/// A short vertical list: icon, title, and the day on the right.
class CareTimeline extends StatelessWidget {
  const CareTimeline({required this.events, required this.empty, super.key});

  final List<CareEvent> events;
  final String empty;

  IconData _icon(CareKind kind) => switch (kind) {
    CareKind.vaccine => Icons.vaccines_outlined,
    CareKind.deworm => Icons.bug_report_outlined,
    CareKind.visit => Icons.local_hospital_outlined,
    CareKind.checkup => Icons.fact_check_outlined,
    CareKind.weight => Icons.monitor_weight_outlined,
  };

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return EmptyHint(title: '还没记录', body: empty);
    }
    final colors = AppColors.of(context);
    return QuietCard(
      padding: const EdgeInsets.fromLTRB(8, 4, 14, 4),
      child: Column(
        children: [
          for (var i = 0; i < events.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: colors.brand,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(_icon(events[i].kind), size: 18, color: colors.ink),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${events[i].title} · ${events[i].detail}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: zhuaji.copyWith(fontSize: 15),
                    ),
                  ),
                  Text(
                    formatMonthDay(events[i].on),
                    style: zhuaji.copyWith(fontSize: 12, color: colors.muted),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
