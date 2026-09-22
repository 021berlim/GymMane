import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/l10n/l10n.dart';
import 'package:fitiron/models/workout.dart';
import 'package:fitiron/screens/profile_screen.dart';
import 'package:fitiron/state/fit_state.dart';
import 'package:fitiron/theme/app_theme.dart';

const _sampleBase64Png =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

Widget _host() {
  return MaterialApp(
    theme: AppTheme.dark,
    locale: fit.locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: const Scaffold(body: ProfileScreen()),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    setAppLanguage('en');
    fit.setLanguage('en');
    fit.sessions.clear();
  });

  tearDown(() {
    fit.sessions.clear();
    fit.persistNow();
  });

  group('imageProviderFromSrc', () {
    test('returns null on empty string', () {
      expect(imageProviderFromSrc(''), isNull);
    });

    test('returns null on completely invalid string', () {
      expect(imageProviderFromSrc('not_a_valid_image_string!!!???'), isNull);
    });

    test('decodes standard base64 string into MemoryImage', () {
      final provider = imageProviderFromSrc(_sampleBase64Png);
      expect(provider, isA<MemoryImage>());
      final mem = provider as MemoryImage;
      expect(mem.bytes, isNotEmpty);
    });

    test('decodes data URI base64 string', () {
      final dataUri = 'data:image/png;base64,$_sampleBase64Png';
      final provider = imageProviderFromSrc(dataUri);
      expect(provider, isA<MemoryImage>());
    });

    test('handles base64 with spaces and newlines', () {
      final dirty = '\n  $_sampleBase64Png \r\n ';
      final provider = imageProviderFromSrc(dirty);
      expect(provider, isA<MemoryImage>());
    });

    test('handles base64 with missing padding', () {
      final unpadded = _sampleBase64Png.replaceAll('=', '');
      final provider = imageProviderFromSrc(unpadded);
      expect(provider, isA<MemoryImage>());
    });

    test('handles network URLs', () {
      final provider = imageProviderFromSrc('https://example.com/photo.jpg');
      expect(provider, isA<NetworkImage>());
    });
  });

  group('ProfileScreen Photo Carousel & 1vh Layout', () {
    testWidgets('renders empty state when there are no workout photos', (tester) async {
      fit.sessions.clear();

      await tester.pumpWidget(_host());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Snapshots section heading exists
      expect(find.text(t.snapshots), findsOneWidget);
      // Empty card with photos label exists
      expect(find.text(t.photosCard), findsOneWidget);
      // Camera button "Tirar foto" / snapNow is NOT present
      expect(find.text(t.snapNow), findsNothing);
    });

    testWidgets('renders carousel when workout photos are present', (tester) async {
      fit.sessions.clear();
      fit.sessions.addAll([
        LoggedSession(
          DateTime(2026, 1, 1),
          1800,
          [LoggedExercise('bench', 'Bench Press', 'chest', [LoggedSet(10, 80)])],
          photoAfter: _sampleBase64Png,
        ),
        LoggedSession(
          DateTime(2026, 1, 2),
          1800,
          [LoggedExercise('squat', 'Squat', 'quads', [LoggedSet(10, 100)])],
          photoBefore: _sampleBase64Png,
          photoAfter: _sampleBase64Png,
        ),
      ]);

      await tester.pumpWidget(_host());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(t.snapshots), findsOneWidget);
      // Camera button "Tirar foto" / snapNow is NOT present
      expect(find.text(t.snapNow), findsNothing);
      // PageView carousel exists
      expect(find.byType(PageView), findsOneWidget);
    });
  });
}
