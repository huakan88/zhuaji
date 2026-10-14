import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_actions/quick_actions.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/common.dart';
import 'features/cats/cat_form_page.dart';
import 'features/cats/cats_page.dart';
import 'features/cats/privacy_page.dart';
import 'features/health/checkups_page.dart';
import 'features/health/deworms_page.dart';
import 'features/health/disease_page.dart';
import 'features/health/health_page.dart';
import 'features/health/scale_page.dart';
import 'features/health/vaccines_page.dart';
import 'features/health/visits_page.dart';
import 'features/health/weight_page.dart';
import 'features/home/home_page.dart';
import 'features/pantry/bag_page.dart';
import 'features/pantry/confirm_page.dart';
import 'features/pantry/pantry_page.dart';
import 'features/pantry/scan_page.dart';
import 'features/shell/app_shell.dart';
import 'services/scale_service.dart';
import 'state/app_controller.dart';

/// Lets work that happens outside a page (notification taps) show a message.
final zhuajiMessenger = GlobalKey<ScaffoldMessengerState>();

/// Long-press launcher shortcuts and the page each one opens.
const appShortcuts = [
  (type: 'weight', title: '称体重', icon: 'ic_shortcut_weight', route: '/weight'),
  (type: 'deworm', title: '记驱虫', icon: 'ic_shortcut_deworm', route: '/deworms'),
  (type: 'scan', title: '扫粮', icon: 'ic_shortcut_scan', route: '/scan'),
];

String? shortcutRoute(String type) {
  for (final item in appShortcuts) {
    if (item.type == type) return item.route;
  }
  return null;
}

class ZhuajiApp extends StatefulWidget {
  const ZhuajiApp({
    required this.controller,
    this.initialLocation = '/home',
    this.scaleSource,
    super.key,
  });

  final AppController controller;
  final String initialLocation;

  /// Defaults to the real Bluetooth scale; tests pass a fake.
  final ScaleSource Function()? scaleSource;

  @override
  State<ZhuajiApp> createState() => _ZhuajiAppState();
}

class _ZhuajiAppState extends State<ZhuajiApp> {
  late final GoRouter _router = GoRouter(
    initialLocation: widget.initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/health', builder: (_, _) => const HealthPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/pantry', builder: (_, _) => const PantryPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/cats', builder: (_, _) => const CatsPage()),
            ],
          ),
        ],
      ),
      GoRoute(path: '/scan', builder: (_, _) => const ScanPage()),
      GoRoute(
        path: '/confirm',
        builder: (context, state) =>
            ConfirmPage(code: state.uri.queryParameters['code'] ?? ''),
      ),
      GoRoute(
        path: '/bag',
        builder: (context, state) =>
            BagPage(pantryId: int.parse(state.uri.queryParameters['id']!)),
      ),
      GoRoute(
        path: '/cat-form',
        builder: (context, state) => CatFormPage(
          catId: int.tryParse(state.uri.queryParameters['id'] ?? ''),
        ),
      ),
      GoRoute(path: '/weight', builder: (_, _) => const WeightPage()),
      GoRoute(
        path: '/scale',
        builder: (_, _) => ScalePage(
          source: (widget.scaleSource ?? BleScaleSource.new).call(),
        ),
      ),
      GoRoute(path: '/privacy', builder: (_, _) => const PrivacyPage()),
      GoRoute(path: '/vaccines', builder: (_, _) => const VaccinesPage()),
      GoRoute(path: '/deworms', builder: (_, _) => const DewormsPage()),
      GoRoute(path: '/visits', builder: (_, _) => const VisitsPage()),
      GoRoute(path: '/checkups', builder: (_, _) => const CheckupsPage()),
      GoRoute(path: '/diseases', builder: (_, _) => const DiseaseLibraryPage()),
      GoRoute(
        path: '/disease',
        builder: (context, state) =>
            DiseaseDetailPage(diseaseId: state.uri.queryParameters['id'] ?? ''),
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _shortcuts();
  }

  Future<void> _shortcuts() async {
    const actions = QuickActions();
    try {
      await actions.initialize((type) {
        final route = shortcutRoute(type);
        if (route != null) _router.push(route);
      });
      await actions.setShortcutItems([
        for (final item in appShortcuts)
          ShortcutItem(
            type: item.type,
            localizedTitle: item.title,
            icon: item.icon,
          ),
      ]);
    } catch (error) {
      debugPrint('长按快捷方式没有装上：$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: widget.controller,
      child: MaterialApp.router(
        title: '爪记',
        scaffoldMessengerKey: zhuajiMessenger,
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: const Locale('zh', 'CN'),
        supportedLocales: const [Locale('zh', 'CN'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: _router,
        builder: (context, child) => RepaintBoundary(
          key: const Key('shot'),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
