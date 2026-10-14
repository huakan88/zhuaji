import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/common.dart';
import 'features/cats/cat_form_page.dart';
import 'features/cats/cats_page.dart';
import 'features/health/checkups_page.dart';
import 'features/health/deworms_page.dart';
import 'features/health/disease_page.dart';
import 'features/health/health_page.dart';
import 'features/health/vaccines_page.dart';
import 'features/health/visits_page.dart';
import 'features/health/weight_page.dart';
import 'features/home/home_page.dart';
import 'features/pantry/bag_page.dart';
import 'features/pantry/confirm_page.dart';
import 'features/pantry/pantry_page.dart';
import 'features/pantry/scan_page.dart';
import 'features/shell/app_shell.dart';
import 'state/app_controller.dart';

class ZhuajiApp extends StatefulWidget {
  const ZhuajiApp({
    required this.controller,
    this.initialLocation = '/home',
    super.key,
  });

  final AppController controller;
  final String initialLocation;

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
  Widget build(BuildContext context) {
    return AppScope(
      controller: widget.controller,
      child: MaterialApp.router(
        title: '爪记',
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
