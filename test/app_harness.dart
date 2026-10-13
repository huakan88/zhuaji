import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maokangji/app.dart';
import 'package:maokangji/state/app_controller.dart';

import 'cjk_font.dart';

Future<void> boot(WidgetTester tester, AppController controller) async {
  await tester.runAsync(loadZhuajiFonts);
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ZhuajiApp(controller: controller));
  await frames(tester);
}

Future<void> frames(WidgetTester tester) async {
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 30)),
  );
  await tester.pump(const Duration(milliseconds: 400));
  // A rebuild during the exit animation can restart it. One more beat lets
  // the sheet actually leave the tree.
  await tester.pump(const Duration(milliseconds: 400));
}

Finder downScrollables() {
  return find.byWidgetPredicate((widget) {
    return widget is Scrollable && widget.axisDirection == AxisDirection.down;
  });
}

bool _offstage(Element element) {
  var hidden = false;
  element.visitAncestorElements((ancestor) {
    final widget = ancestor.widget;
    if (widget is Offstage && widget.offstage) {
      hidden = true;
      return false;
    }
    return true;
  });
  return hidden;
}

List<Element> _visibleText(String text) {
  return find
      .text(text)
      .evaluate()
      .where((element) => !_offstage(element))
      .toList();
}

Finder _elementFinder(Element element) {
  return find.byElementPredicate((candidate) => candidate == element);
}

/// Scrolls until [text] is built. List extent grows as later children are laid
/// out, so the offset has to advance in steps instead of jumping to the first
/// reported max.
Future<void> revealText(
  WidgetTester tester,
  String text, {
  int index = 0,
}) async {
  if (_visibleText(text).length <= index) {
    final states = <ScrollableState>[];
    for (final element in downScrollables().evaluate()) {
      if (_offstage(element)) continue;
      states.add(
        tester.state<ScrollableState>(
          find.byElementPredicate((candidate) => candidate == element),
        ),
      );
    }
    for (final state in states.reversed) {
      if (_visibleText(text).length > index) break;
      if (!state.position.hasContentDimensions) continue;
      state.position.jumpTo(0);
      await tester.pump();
      var stalled = 0;
      for (
        var step = 0;
        step < 30 && _visibleText(text).length <= index;
        step++
      ) {
        final position = state.position;
        if (!position.hasContentDimensions) break;
        final next = (position.pixels + 280).clamp(
          0.0,
          position.maxScrollExtent,
        );
        if (next <= position.pixels + 0.5) {
          stalled += 1;
          if (stalled > 1) break;
          await tester.pump();
          continue;
        }
        stalled = 0;
        position.jumpTo(next);
        await tester.pump();
      }
    }
  }
  final matches = _visibleText(text);
  if (matches.length <= index) {
    fail('找不到「$text」');
  }
  final target = _elementFinder(matches[index]);
  await tester.ensureVisible(target);
  await tester.pump();
  final bottom = tester.getBottomLeft(target).dy;
  final height = tester.view.physicalSize.height / tester.view.devicePixelRatio;
  if (bottom > height - 110) {
    final position = Scrollable.maybeOf(tester.element(target))?.position;
    if (position != null && position.maxScrollExtent > 0) {
      position.jumpTo(
        (position.pixels + bottom - (height - 160)).clamp(
          0,
          position.maxScrollExtent,
        ),
      );
      await tester.pump();
    }
  }
}

Future<void> revealFinder(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) return;
  await tester.ensureVisible(finder);
  await tester.pump();
}

Future<void> tapText(WidgetTester tester, String text, {int index = 0}) async {
  final scaffolds = find.byType(Scaffold);
  if (scaffolds.evaluate().isNotEmpty) {
    ScaffoldMessenger.maybeOf(tester.element(scaffolds.last))?.clearSnackBars();
    await tester.pump();
  }
  await revealText(tester, text, index: index);
  final element = _visibleText(text)[index];
  VoidCallback? callback;
  element.visitAncestorElements((ancestor) {
    final widget = ancestor.widget;
    if (widget is ButtonStyleButton) {
      callback = widget.onPressed;
      return false;
    }
    if (widget is IconButton) {
      callback = widget.onPressed;
      return false;
    }
    if (widget is InkResponse && widget.onTap != null) {
      callback = widget.onTap;
      return false;
    }
    if (widget is GestureDetector && widget.onTap != null) {
      callback = widget.onTap;
      return false;
    }
    return true;
  });
  final action = callback;
  if (action != null) {
    action();
  } else {
    await tester.tap(_elementFinder(element), warnIfMissed: false);
  }
  await frames(tester);
}

Future<void> back(WidgetTester tester) async {
  await tester.tap(find.byTooltip('返回'));
  await frames(tester);
}

Future<void> enter(WidgetTester tester, Finder field, String value) async {
  await revealFinder(tester, field);
  await tester.tap(field);
  await tester.enterText(field, value);
  FocusManager.instance.primaryFocus?.unfocus();
  tester.view.viewInsets = FakeViewPadding.zero;
  await tester.pump();
}

Future<void> enterField(WidgetTester tester, String label, String value) async {
  final field = find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label,
  );
  await enter(tester, field, value);
}

Future<void> deleteRow(WidgetTester tester, String title) async {
  final row = find
      .ancestor(of: find.textContaining(title), matching: find.byType(ListTile))
      .first;
  await tester.ensureVisible(row);
  await tester.tap(
    find.descendant(of: row, matching: find.byIcon(Icons.delete_outline)),
  );
  await frames(tester);
  await tapText(tester, '删除');
}
