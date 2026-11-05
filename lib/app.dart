import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

/// DKMP 应用根组件。
class DkmpApp extends StatelessWidget {
  const DkmpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DKMP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
