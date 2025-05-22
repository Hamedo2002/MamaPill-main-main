enum AppRoutes {
  splash,
  welcome,
  login,
  register,
  home,
  setting,
  dashboard,
  reports,
}

extension AppRoutesX on AppRoutes {
  String get path {
    switch (this) {
      case AppRoutes.splash:
        return '/';
      case AppRoutes.welcome:
        return '/welcome';
      case AppRoutes.login:
        return 'login';
      case AppRoutes.register:
        return 'register';
      case AppRoutes.home:
        return '/home';
      case AppRoutes.setting:
        return 'setting';
      case AppRoutes.dashboard:
        return '/dashboard';
      case AppRoutes.reports:
        return 'reports';
      }
  }

  String get name {
    switch (this) {
      case AppRoutes.splash:
        return 'Splash';
      case AppRoutes.welcome:
        return 'Welcome';
      case AppRoutes.login:
        return 'Login';
      case AppRoutes.register:
        return 'Register';
      case AppRoutes.home:
        return 'Home';
      case AppRoutes.setting:
        return 'Setting';
      case AppRoutes.dashboard:
        return 'Dashboard';
      case AppRoutes.reports:
        return 'Reports';
      }
  }
}
