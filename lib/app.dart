import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_actions/quick_actions.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/app_tokens.dart';
import 'core/widgets/common.dart';
import 'features/cats/cat_form_page.dart';
import 'features/cats/cats_page.dart';
import 'features/cats/privacy_page.dart';
import 'features/legal/consent_gate.dart';
import 'features/legal/legal_copy.dart';
import 'features/legal/legal_page.dart';
import 'features/health/checkups_page.dart';
import 'features/health/lab_form_page.dart';
import 'features/health/labs_page.dart';
import 'features/health/deworms_page.dart';
import 'features/health/disease_page.dart';
import 'features/health/health_page.dart';
import 'features/health/scale_page.dart';
import 'features/health/sticker_page.dart';
import 'features/health/vaccines_page.dart';
import 'features/health/visits_page.dart';
import 'features/health/weight_page.dart';
import 'domain/parsing/vaccine_sticker_parser.dart';
import 'features/home/calendar_page.dart';
import 'features/home/home_page.dart';
import 'services/widget_bridge.dart';
import 'features/pantry/bag_page.dart';
import 'features/pantry/catalog_page.dart';
import 'features/pantry/confirm_page.dart';
import 'features/pantry/lookup_page.dart';
import 'features/pantry/food_form_page.dart';
import 'features/pantry/pantry_page.dart';
import 'features/pantry/recipes_page.dart';
import 'features/pantry/scan_page.dart';
import 'features/shell/app_shell.dart';
import 'services/scale_service.dart';
import 'domain/models.dart';
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

/// True when a shortcut, notification payload or `zhuaji://` route should
/// open the camera. The path may arrive as `/scan` or nested in `route`.
bool routeSelectsScan(String route) {
  final trimmed = route.trim();
  final uri = Uri.tryParse(trimmed);
  if (uri == null) return trimmed == '/scan';
  if (uri.path == '/scan') return true;
  final nested = uri.queryParameters['route'];
  if (nested == null || nested == trimmed) return false;
  return routeSelectsScan(nested);
}

/// External entries. A scan target selects 今天 first, then the camera, so
/// closing the camera lands on the page that holds the scan button.
void openAppRoute(GoRouter router, String route) {
  if (routeSelectsScan(route)) {
    router.go('/home');
    router.push('/scan');
    return;
  }
  router.push(route);
}

class ZhuajiApp extends StatefulWidget {
  const ZhuajiApp({
    required this.controller,
    this.initialLocation = '/home',
    this.scaleSource,
    this.gateConsent = true,
    super.key,
  });

  final AppController controller;
  final String initialLocation;

  /// Defaults to the real Bluetooth scale; tests pass a fake.
  final ScaleSource Function()? scaleSource;

  /// Tests that are not about the first-launch choice pass false.
  final bool gateConsent;

  @override
  State<ZhuajiApp> createState() => _ZhuajiAppState();
}

class _ZhuajiAppState extends State<ZhuajiApp> with WidgetsBindingObserver {
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
        path: '/lookup',
        builder: (context, state) =>
            LookupPage(code: state.uri.queryParameters['code'] ?? ''),
      ),
      GoRoute(
        path: '/confirm',
        builder: (context, state) => ConfirmPage(
          code: state.uri.queryParameters['code'] ?? '',
          productId: int.tryParse(state.uri.queryParameters['product'] ?? ''),
          blank: state.uri.queryParameters['blank'] == '1',
          plain: state.uri.queryParameters['plain'] == '1',
        ),
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
      GoRoute(
        path: '/agreement',
        builder: (_, _) =>
            const LegalPage(title: '用户协议', sections: agreementSections),
      ),
      GoRoute(
        path: '/permissions',
        builder: (_, _) =>
            const LegalPage(title: '权限说明', sections: permissionSections),
      ),
      GoRoute(path: '/vaccines', builder: (_, _) => const VaccinesPage()),
      GoRoute(path: '/calendar', builder: (_, _) => const CalendarPage()),
      GoRoute(
        path: '/sticker',
        builder: (context, state) {
          final demo = state.uri.queryParameters['demo'] == '1';
          return StickerPage(
            initial: demo
                ? VaccineStickerRead(
                    name: '猫三联',
                    knownName: true,
                    batch: 'A12B-3391',
                    givenOn: DateTime(2026, 3, 12),
                  )
                : null,
          );
        },
      ),
      GoRoute(path: '/deworms', builder: (_, _) => const DewormsPage()),
      GoRoute(path: '/visits', builder: (_, _) => const VisitsPage()),
      GoRoute(path: '/checkups', builder: (_, _) => const CheckupsPage()),
      GoRoute(path: '/labs', builder: (_, _) => const LabsPage()),
      GoRoute(
        path: '/lab',
        builder: (context, state) {
          final query = state.uri.queryParameters;
          final kindName = query['kind'];
          return LabFormPage(
            reportId: int.tryParse(query['id'] ?? ''),
            kind: kindName == null || kindName.isEmpty
                ? null
                : parseLabKind(kindName),
            checkupItemId: query['checkup'],
          );
        },
      ),
      GoRoute(path: '/catalog', builder: (_, _) => const CatalogPage()),
      GoRoute(path: '/recipes', builder: (_, _) => const RecipesPage()),
      GoRoute(
        path: '/recipe',
        builder: (context, state) =>
            RecipeDetailPage(cardId: state.uri.queryParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/food',
        builder: (context, state) {
          final query = state.uri.queryParameters;
          return FoodFormPage(
            productId: int.tryParse(query['id'] ?? ''),
            barcode: query['code'] ?? '',
            openCamera: query['shot'] == '1',
            addBag: query['bag'] == '1',
          );
        },
      ),
      GoRoute(path: '/diseases', builder: (_, _) => const DiseaseLibraryPage()),
      GoRoute(
        path: '/disease',
        builder: (context, state) =>
            DiseaseDetailPage(diseaseId: state.uri.queryParameters['id'] ?? ''),
      ),
    ],
  );

  var _armed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final choice = widget.controller.privacyChoice;
    if (!widget.gateConsent || choice != PrivacyChoice.unset) {
      _armIntegrations();
    }
  }

  void _armIntegrations() {
    if (_armed) return;
    _armed = true;
    _shortcuts();
    WidgetBridge.listen((route) => openAppRoute(_router, route));
    _openWidgetRoute();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Coming back online should send corrections that were queued offline.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (widget.controller.privacyChoice != PrivacyChoice.accepted) return;
    widget.controller.flushBarcodeShare();
  }

  Future<void> _acceptConsent() async {
    await widget.controller.acceptPrivacy();
    await widget.controller.init();
    await widget.controller.enableNotifications();
    _armIntegrations();
  }

  Future<void> _basicConsent() async {
    await widget.controller.useBasicMode();
    await widget.controller.init();
    _armIntegrations();
  }

  Future<void> _openWidgetRoute() async {
    final route = await WidgetBridge.takeRoute();
    if (route != null) openAppRoute(_router, route);
  }

  Future<void> _shortcuts() async {
    const actions = QuickActions();
    try {
      await actions.initialize((type) {
        final route = shortcutRoute(type);
        if (route != null) openAppRoute(_router, route);
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
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) => AppScope(
        controller: widget.controller,
        child: MaterialApp.router(
          title: '花爪',
          scaffoldMessengerKey: zhuajiMessenger,
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(AppColors.light),
          darkTheme: buildAppTheme(AppColors.dark),
          themeMode: widget.controller.themeMode.material,
          locale: const Locale('zh', 'CN'),
          supportedLocales: const [Locale('zh', 'CN'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: _router,
          builder: (context, child) {
            final waiting =
                widget.gateConsent &&
                widget.controller.privacyChoice == PrivacyChoice.unset;
            return RepaintBoundary(
              key: const Key('shot'),
              child: waiting
                  ? ConsentGate(
                      onAccept: _acceptConsent,
                      onBasic: _basicConsent,
                    )
                  : (child ?? const SizedBox.shrink()),
            );
          },
        ),
      ),
    );
  }
}
