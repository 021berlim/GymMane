import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/app/fitiron_app.dart';
import 'package:fitiron/l10n/l10n.dart';
import 'package:fitiron/state/fit_state.dart';

import 'package:fitiron/widgets/ui_kit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    fit.onboarded = true;
    fit.session = null;
    setAppLanguage('pt');
  });

  test('showNav returns true for preferences, awards, about, tools, routines, and main tabs', () {
    const screensWithNav = [
      'home',
      'progress',
      'gallery',
      'exercises',
      'settings',
      'preferences',
      'awards',
      'about',
      'tools',
      'routines',
    ];

    for (final route in screensWithNav) {
      fit.route = route;
      expect(fit.showNav, isTrue, reason: 'Route $route should show nav bar');
    }

    const screensWithoutNav = [
      'session',
      'routine-edit',
      'tools-detail',
      'train',
      'routine-choice',
    ];

    for (final route in screensWithoutNav) {
      fit.route = route;
      expect(fit.showNav, isFalse, reason: 'Route $route should NOT show nav bar');
    }
  });

  testWidgets('SettingsScreen (preferences) displays navbar and allows navigation', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));

    fit.route = 'preferences';
    await tester.pumpWidget(const FitIronApp());
    await tester.pumpAndSettle();

    // Verify SettingsScreen title
    expect(find.text(t.settings), findsOneWidget);

    // Verify navbar items are present
    expect(find.bySemanticsLabel(t.home), findsOneWidget);
    expect(find.bySemanticsLabel(t.progress), findsOneWidget);
    expect(find.bySemanticsLabel(t.exercises), findsOneWidget);
    expect(find.bySemanticsLabel(t.profile), findsOneWidget);

    // Tap on Início (home) tab
    await tester.tap(find.bySemanticsLabel(t.home));
    await tester.pumpAndSettle();

    expect(fit.route, 'home');

    // Go back to preferences
    fit.goPreferences();
    await tester.pumpAndSettle();
    expect(fit.route, 'preferences');

    // Tap on Perfil (settings) tab
    await tester.tap(find.bySemanticsLabel(t.profile));
    await tester.pumpAndSettle();

    expect(fit.route, 'settings');
  });

  testWidgets('SettingsScreen header back button returns to previous screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));

    fit.route = 'settings';
    await tester.pumpWidget(const FitIronApp());
    await tester.pumpAndSettle();

    // Open preferences
    fit.goPreferences();
    await tester.pumpAndSettle();
    expect(fit.route, 'preferences');

    // Tap back button in header
    final backBtn = find.byType(RoundBtn).first;
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    expect(fit.route, 'settings');
  });
}
