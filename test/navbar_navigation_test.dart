import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/app/fitiron_app.dart';
import 'package:fitiron/l10n/l10n.dart';
import 'package:fitiron/models/live_session.dart';
import 'package:fitiron/state/fit_state.dart';
import 'package:fitiron/widgets/ui_kit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    fit.onboarded = true;
    fit.session = null;
    setAppLanguage('pt');
  });

  test('showNav returns true ONLY for home, progress, gallery, exercises, settings', () {
    const mainTabs = [
      'home',
      'progress',
      'gallery',
      'exercises',
      'settings',
    ];

    for (final route in mainTabs) {
      fit.route = route;
      expect(fit.showNav, isTrue, reason: 'Route $route should show nav bar');
    }

    const secondaryAndModalRoutes = [
      'preferences',
      'awards',
      'about',
      'tools',
      'routines',
      'session',
      'routine-edit',
      'tools-detail',
      'train',
      'routine-choice',
    ];

    for (final route in secondaryAndModalRoutes) {
      fit.route = route;
      expect(fit.showNav, isFalse, reason: 'Route $route should NOT show nav bar');
    }
  });

  testWidgets('SettingsScreen (preferences) hides navbar and header back button returns to settings', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));

    fit.route = 'settings';
    await tester.pumpWidget(const FitIronApp());
    await tester.pumpAndSettle();

    // In settings (ProfileScreen), navbar is visible
    expect(fit.showNav, isTrue);
    expect(find.bySemanticsLabel(t.home), findsOneWidget);

    // Navigate to preferences
    fit.goPreferences();
    await tester.pumpAndSettle();
    expect(fit.route, 'preferences');
    expect(fit.showNav, isFalse);

    // Navbar items should NOT be present on preferences screen
    expect(find.bySemanticsLabel(t.home), findsNothing);

    // Verify SettingsScreen title
    expect(find.text(t.settings), findsOneWidget);

    // Tap back button in header
    final backBtn = find.byType(RoundBtn).first;
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Successfully returned to settings (ProfileScreen)
    expect(fit.route, 'settings');
    expect(fit.showNav, isTrue);
    expect(find.bySemanticsLabel(t.home), findsOneWidget);
  });

  testWidgets('Awards screen back button returns to settings', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));

    fit.route = 'settings';
    await tester.pumpWidget(const FitIronApp());
    await tester.pumpAndSettle();

    fit.goAwards();
    await tester.pumpAndSettle();
    expect(fit.route, 'awards');
    expect(fit.showNav, isFalse);

    final backBtn = find.byType(RoundBtn).first;
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    expect(fit.route, 'settings');
  });

  testWidgets('Tools, Routines, and About screens have clear back navigation', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));

    fit.route = 'home';
    await tester.pumpWidget(const FitIronApp());
    await tester.pumpAndSettle();

    // Tools
    fit.goTools();
    await tester.pumpAndSettle();
    expect(fit.route, 'tools');
    expect(fit.showNav, isFalse);
    await tester.tap(find.byType(RoundBtn).first);
    await tester.pumpAndSettle();
    expect(fit.route, 'home');

    // Routines
    fit.goRoutines();
    await tester.pumpAndSettle();
    expect(fit.route, 'routines');
    expect(fit.showNav, isFalse);
    await tester.tap(find.byType(RoundBtn).first);
    await tester.pumpAndSettle();
    expect(fit.route, 'home');

    // About
    fit.goAbout();
    await tester.pumpAndSettle();
    expect(fit.route, 'about');
    expect(fit.showNav, isFalse);
    await tester.tap(find.byType(RoundBtn).first);
    await tester.pumpAndSettle();
    expect(fit.route, 'home');
  });

  testWidgets('Active workout resumption: start buttons and play return to running session', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));

    // Simulate an active workout session in the background
    final s = WorkoutSession()
      ..exercises = [
        SessionExercise('bench-press', 'Supino Reto', 'chest', [
          SessionSet(10, 60, true),
        ]),
      ]
      ..complete = false;
    fit.session = s;

    expect(fit.hasActiveSession, isTrue);

    // When at Home with active session minimized
    fit.route = 'home';
    await tester.pumpWidget(const FitIronApp());
    await tester.pumpAndSettle();

    // Home screen hero shows "EM ANDAMENTO" and "RETOMAR TREINO"
    expect(find.text(t.inProgress), findsOneWidget);
    expect(find.text(t.resumeWorkout.toUpperCase()), findsOneWidget);

    // Calling fit.startWorkout() directly returns to 'session'
    fit.startWorkout();
    expect(fit.route, 'session');

    // Go back to home
    fit.goHome();
    await tester.pumpAndSettle();
    expect(fit.route, 'home');

    // Tapping the resume button returns to 'session'
    await tester.tap(find.text(t.resumeWorkout.toUpperCase()));
    await tester.pumpAndSettle();
    expect(fit.route, 'session');

    // Also verify startCustomWorkout returns to session
    fit.goHome();
    await tester.pumpAndSettle();
    fit.startCustomWorkout();
    expect(fit.route, 'session');
  });
}
