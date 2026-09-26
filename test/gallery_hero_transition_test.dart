import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/l10n/l10n.dart';
import 'package:fitiron/models/workout.dart';
import 'package:fitiron/screens/gallery_screen.dart';
import 'package:fitiron/state/fit_state.dart';
import 'package:fitiron/theme/app_theme.dart';

void main() {
  testWidgets('GalleryScreen uses Hero widgets and opens photo detail with BackdropFilter blur', (tester) async {
    setAppLanguage('pt');
    fit.sessions.clear();

    const dummyPixelBase64 =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

    final session = LoggedSession(
      DateTime(2026, 9, 25),
      1800,
      [],
      photosBefore: [dummyPixelBase64],
    );
    fit.sessions.add(session);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark,
      home: const GalleryScreen(),
    ));
    await tester.pumpAndSettle();

    // Verify thumbnail is wrapped in Hero
    final heroFinder = find.byType(Hero);
    expect(heroFinder, findsWidgets);

    // Tap the thumbnail
    await tester.tap(heroFinder.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify BackdropFilter blur is present during transition
    expect(find.byType(BackdropFilter), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(PageView), findsOneWidget);
  });
}
