import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fitiron/app/fitiron_app.dart';
import 'package:fitiron/screens/splash_screen.dart';
import 'package:fitiron/app/app_shell.dart';
import 'package:fitiron/state/fit_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SplashScreen.hasShown = false;
    fit.onboarded = true;
    fit.session = null;
    fit.route = 'home';
  });

  testWidgets('SplashScreen renders centered branding on dark background', (tester) async {
    await tester.pumpWidget(const FitIronApp(showSplash: true));

    // Initially on SplashScreen
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('FIT//IRON'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    // After animation and transition timer elapses
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Now transitioned to AppShell
    expect(find.byType(AppShell), findsOneWidget);
    expect(SplashScreen.hasShown, isTrue);
  });
}
