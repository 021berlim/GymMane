import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/l10n.dart';
import '../state/fit_state.dart';
import '../theme/app_theme.dart';
import 'dart:io';

import '../screens/splash_screen.dart';
import '../widgets/global_alarm_dismiss_listener.dart';
import 'app_shell.dart';

class FitIronApp extends StatefulWidget {
  final bool? showSplash;

  const FitIronApp({super.key, this.showSplash});

  @override
  State<FitIronApp> createState() => _FitIronAppState();
}

class _FitIronAppState extends State<FitIronApp> {
  late ThemeMode _themeMode = fit.themeMode;
  late Locale _locale = fit.locale;

  static bool get _defaultShowSplash {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    fit.addListener(_onFitChanged);
  }

  @override
  void dispose() {
    fit.removeListener(_onFitChanged);
    super.dispose();
  }

  void _onFitChanged() {
    if (_themeMode != fit.themeMode || _locale != fit.locale) {
      setState(() {
        _themeMode = fit.themeMode;
        _locale = fit.locale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowSplash = (widget.showSplash ?? _defaultShowSplash) && !SplashScreen.hasShown;

    return MaterialApp(
      title: 'FIT//IRON',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => GlobalAlarmDismissListener(
        child: child ?? const SizedBox.shrink(),
      ),
      home: shouldShowSplash ? const SplashScreen() : const AppShell(),
    );
  }
}
