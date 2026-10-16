import 'package:flutter/material.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import 'legal_copy.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({required this.title, required this.sections, super.key});

  final String title;
  final List<({String title, String body})> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: zhuajiBar(title),
      body: LegalBody(sections: sections),
    );
  }
}

class LegalBody extends StatelessWidget {
  const LegalBody({required this.sections, super.key});

  final List<({String title, String body})> sections;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          legalVersionLabel,
          style: zhuaji.copyWith(
            fontSize: 13,
            color: AppColors.of(context).muted,
          ),
        ),
        const SizedBox(height: 16),
        for (final section in sections) ...[
          QuietCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: zhuaji.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  section.body,
                  style: zhuaji.copyWith(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
