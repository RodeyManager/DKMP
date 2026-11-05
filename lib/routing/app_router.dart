import 'package:go_router/go_router.dart';

import '../features/auth/presentation/pages/register_page.dart';

/// 应用路由表。当前仅注册页；登录 / 首页等路由待后续模块补充。
class AppRoutes {
  AppRoutes._();

  /// 注册页（暂作为启动页，登录页就绪后调整为 `/register`）。
  static const String register = '/';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.register,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
  ],
);
