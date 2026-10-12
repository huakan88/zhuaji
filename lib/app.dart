import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/common.dart';
import 'features/cats/cat_form_page.dart';
import 'features/cats/cat_profile_page.dart';
import 'features/cats/cats_page.dart';
import 'features/cats/photo_page.dart';
import 'features/feeding/feeding_page.dart';
import 'features/health/health_page.dart';
import 'features/home/home_page.dart';
import 'features/pantry/pantry_page.dart';
import 'features/pantry/product_form_page.dart';
import 'features/pantry/product_page.dart';
import 'features/pantry/scan_page.dart';
import 'features/reminders/reminders_page.dart';
import 'features/shell/app_shell.dart';
import 'state/app_controller.dart';

class ZhuajiApp extends StatefulWidget {
  const ZhuajiApp({required this.controller, super.key});

  final AppController controller;

  @override
  State<ZhuajiApp> createState() => _ZhuajiAppState();
}

class _ZhuajiAppState extends State<ZhuajiApp> {
  late final GoRouter _router = GoRouter(
    initialLocation: '/home',
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
              GoRoute(path: '/me', builder: (_, _) => const CatsPage()),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) =>
            ScanPage(mode: state.uri.queryParameters['mode'] ?? 'product'),
      ),
      GoRoute(
        path: '/product',
        builder: (context, state) => ProductPage(
          productId: int.parse(state.uri.queryParameters['productId']!),
          pantryId: int.tryParse(state.uri.queryParameters['pantryId'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/product-form',
        builder: (context, state) => ProductFormPage(
          barcode: state.uri.queryParameters['barcode'],
        ),
      ),
      GoRoute(
        path: '/cat',
        builder: (context, state) =>
            CatProfilePage(catId: int.parse(state.uri.queryParameters['id']!)),
      ),
      GoRoute(
        path: '/cat-form',
        builder: (context, state) => CatFormPage(
          catId: int.tryParse(state.uri.queryParameters['id'] ?? ''),
        ),
      ),
      GoRoute(path: '/photos', builder: (_, _) => const PhotoPage()),
      GoRoute(path: '/feeding', builder: (_, _) => const FeedingPage()),
      GoRoute(path: '/reminders', builder: (_, _) => const RemindersPage()),
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
