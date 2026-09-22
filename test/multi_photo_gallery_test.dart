import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/l10n/l10n.dart';
import 'package:fitiron/models/workout.dart';
import 'package:fitiron/screens/gallery_screen.dart';
import 'package:fitiron/screens/profile_screen.dart';
import 'package:fitiron/state/fit_state.dart';
import 'package:fitiron/theme/app_theme.dart';

const _sampleBase64Png =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

const _sampleBase64Png2 =
    'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAAFElEQVR42mNk+M9QzwAEjAwIDAAA//8AAwABbH5i3wAAAABJRU5ErkJggg==';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('multi_photo_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => tempDir.path,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/share'),
      (call) async => 'success',
    );

    setAppLanguage('en');
    fit.setLanguage('en');
    fit.sessions.clear();
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/share'),
      null,
    );
    fit.sessions.clear();
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  group('LoggedSession multi-photo support', () {
    test('supports multiple before and after photos', () {
      final session = LoggedSession(
        DateTime(2026, 9, 22),
        1800,
        [],
        photosBefore: ['photoB1', 'photoB2'],
        photosAfter: ['photoA1', 'photoA2', 'photoA3'],
      );

      expect(session.photosBefore, ['photoB1', 'photoB2']);
      expect(session.photosAfter, ['photoA1', 'photoA2', 'photoA3']);
      expect(session.photoBefore, 'photoB1');
      expect(session.photoAfter, 'photoA1');
    });

    test('backward compatibility with single photo constructor and json', () {
      final session = LoggedSession(
        DateTime(2026, 9, 22),
        1800,
        [],
        photoBefore: 'legacyBefore',
        photoAfter: 'legacyAfter',
      );

      expect(session.photosBefore, ['legacyBefore']);
      expect(session.photosAfter, ['legacyAfter']);
      expect(session.photoBefore, 'legacyBefore');
      expect(session.photoAfter, 'legacyAfter');

      final json = session.toJson();
      expect(json['pb'], 'legacyBefore');
      expect(json['pa'], 'legacyAfter');
      expect(json['pbs'], ['legacyBefore']);
      expect(json['pas'], ['legacyAfter']);

      // Deserialize legacy json format without pbs/pas
      final fromLegacy = LoggedSession.fromJson({
        'd': DateTime(2026, 9, 22).toIso8601String(),
        'dur': 1800,
        'ex': [],
        'pb': 'oldBefore',
        'pa': 'oldAfter',
      });
      expect(fromLegacy.photosBefore, ['oldBefore']);
      expect(fromLegacy.photosAfter, ['oldAfter']);

      // Deserialize modern json format with pbs/pas
      final fromModern = LoggedSession.fromJson({
        'd': DateTime(2026, 9, 22).toIso8601String(),
        'dur': 1800,
        'ex': [],
        'pbs': ['p1', 'p2'],
        'pas': ['p3', 'p4'],
      });
      expect(fromModern.photosBefore, ['p1', 'p2']);
      expect(fromModern.photosAfter, ['p3', 'p4']);
    });
  });

  group('WorkoutState attach and delete multiple photos', () {
    test('attachPhotoToSession appends photos without overwriting', () {
      final session = LoggedSession(DateTime.now(), 1200, []);
      fit.sessions.add(session);

      fit.attachPhotoToSession(session, 'photo_after_1', before: false);
      expect(session.photosAfter, ['photo_after_1']);

      fit.attachPhotoToSession(session, 'photo_after_2', before: false);
      expect(session.photosAfter, ['photo_after_1', 'photo_after_2']);

      fit.attachPhotoToSession(session, 'photo_before_1', before: true);
      expect(session.photosBefore, ['photo_before_1']);
    });

    test('deleteSessionPhoto removes specific photoData without clearing all', () {
      final session = LoggedSession(
        DateTime.now(),
        1200,
        [],
        photosAfter: ['photo_1', 'photo_2', 'photo_3'],
      );
      fit.sessions.add(session);

      fit.deleteSessionPhoto(session, before: false, photoData: 'photo_2');
      expect(session.photosAfter, ['photo_1', 'photo_3']);

      // Deleting with null photoData clears all
      fit.deleteSessionPhoto(session, before: false);
      expect(session.photosAfter, isEmpty);
    });
  });

  group('GalleryScreen rendering with multiple photos', () {
    testWidgets('GalleryScreen displays multiple photos from the same session', (tester) async {
      final session = LoggedSession(
        DateTime(2026, 9, 22),
        1500,
        [],
        photosAfter: [_sampleBase64Png, _sampleBase64Png2],
      );
      fit.sessions.add(session);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const GalleryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find images rendered in grid
      expect(find.byType(Image), findsNWidgets(2));
    });
  });

  group('ProfileScreen with multiple photos per session', () {
    testWidgets('ProfileScreen counts and shows multiple photos from single session', (tester) async {
      final session = LoggedSession(
        DateTime.now(),
        1200,
        [],
        photosBefore: [_sampleBase64Png],
        photosAfter: [_sampleBase64Png2],
      );
      fit.sessions.add(session);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(body: ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Total count in heading should show 2
      expect(find.text('2'), findsWidgets);
    });
  });
}
