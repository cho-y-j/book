import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes.dart';
import 'theme/app_theme.dart';

class BookBridgeApp extends ConsumerWidget {
  const BookBridgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: '책다리',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
