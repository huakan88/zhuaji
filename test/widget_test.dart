import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/core/theme/app_theme.dart';
import 'package:maokangji/core/theme/app_tokens.dart';
import 'package:maokangji/core/widgets/common.dart';

void main() {
  testWidgets('disclaimer says the app is not a vet', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(AppColors.light),
        home: const Scaffold(body: DisclaimerBanner()),
      ),
    );
    expect(find.text('仅供参考，请遵医嘱。'), findsOneWidget);
  });

  testWidgets('food date card shows production, countdown and storage', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(AppColors.light),
        home: Scaffold(
          body: FoodDateCard(
            brand: '皇家 Royal Canin',
            name: '室内成猫全价粮',
            spec: '2kg · 示例规格',
            form: '干粮',
            storage: '阴凉干燥处密封保存',
            now: DateTime(2026, 10, 12),
            isSample: true,
            production: DateTime(2026, 8, 1),
            expiry: DateTime(2026, 11, 1),
            batch: 'DEMO',
            source: '手动填写',
            openedAt: DateTime(2026, 10, 1),
            afterOpenDays: 42,
          ),
        ),
      ),
    );

    expect(find.text('室内成猫全价粮'), findsOneWidget);
    expect(find.text('2026年8月1日'), findsOneWidget);
    expect(find.text('2026年11月1日'), findsOneWidget);
    expect(find.text('还剩 20 天'), findsOneWidget);
    expect(find.textContaining('阴凉干燥'), findsOneWidget);
    expect(find.text('示例数据'), findsOneWidget);
  });
}
