import 'package:flutter/services.dart';

/// Light tap. Tests have no vibrator, so a missing plugin is ignored.
void pawTap() {
  HapticFeedback.selectionClick().then<void>(
    (void _) {},
    onError: (Object _, StackTrace _) {},
  );
}
