import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import 'package:mama_pill/core/presentation/view/dashboard_view.dart';
import 'package:mama_pill/core/presentation/view/settings_view.dart';
import 'package:mama_pill/core/presentation/view/splash_view.dart';
import 'package:mama_pill/core/presentation/view/welcome_view.dart';
import 'package:mama_pill/core/resources/routes.dart';
import 'package:mama_pill/core/utils/route_utils.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/features/authentication/presentation/view/login_view.dart';
import 'package:mama_pill/features/authentication/presentation/view/register_view.dart';

class AppRouter {
  final AuthBloc authBloc;
  late GoRouter router;

  AppRouter(this.authBloc) {
    router = GoRouter(
      debugLogDiagnostics: true,
      initialLocation: AppRoutes.splash.path,
      routes: [
        GoRoute(
          path: AppRoutes.splash.path,
          name: AppRoutes.splash.name,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SplashView()),
        ),
        GoRoute(
          path: AppRoutes.welcome.path,
          name: AppRoutes.welcome.name,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: WelcomeView()),
          routes: [
            GoRoute(
              path: 'register',
              name: AppRoutes.register.name,
              pageBuilder: (context, state) => CupertinoPage(
                child: RegisterView(),
              ),
            ),
            GoRoute(
              path: 'login',
              name: AppRoutes.login.name,
              pageBuilder: (context, state) =>
                  const CupertinoPage(child: LoginView()),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.dashboard.path,
          name: AppRoutes.dashboard.name,
          pageBuilder: (context, state) =>
              NoTransitionPage(child: DashboardView(authBloc: authBloc)),
          routes: [
            GoRoute(
              path: AppRoutes.setting.path,
              name: AppRoutes.setting.name,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: SettingsView(authBloc: state.extra as AuthBloc),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 200),
                reverseTransitionDuration: const Duration(milliseconds: 200),
              ),
            ),
          ],
        ),
      ],
      redirect: (context, state) =>
          RouteUtils.handleRedirect(authBloc, context, state),
      refreshListenable: GoRouterRefreshStream(authBloc),
    );
  }
}
