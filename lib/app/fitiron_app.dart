import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/l10n.dart';
import '../state/fit_state.dart';
import '../theme/app_theme.dart';
import 'dart:io';

import '../screens/splash_screen.dart';
import 'app_shell.dart';

class FitIronApp extends StatelessWidget {
  final bool? showSplash;

  const FitIronApp({super.key, this.showSplash});

  static bool get _defaultShowSplash {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowSplash = (showSplash ?? _defaultShowSplash) && !SplashScreen.hasShown;

    return AnimatedBuilder(
      animation: fit,
      builder: (context, _) => MaterialApp(
        title: 'FIT//IRON',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: fit.themeMode,
        locale: fit.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: shouldShowSplash ? const SplashScreen() : const AppShell(),
      ),
    );
  }
}
