import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:fitiron/l10n/l10n.dart';
import 'package:fitiron/theme/app_theme.dart';
import 'package:fitiron/widgets/share_photo_sheet.dart';

const _sampleBase64Png =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

Widget _buildSheet({String? base64Photo, String? filePath}) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: Scaffold(
      body: SharePhotoSheet(
        durationStr: '45 MIN',
        prCount: 3,
        volumeKg: 12500,
        calories: 380,
        muscleGroupsStr: 'Peito, Tríceps',
        initialImagePath: filePath,
        initialImageBase64: base64Photo,
      ),
    ),
  );
}

void main() {
  late Directory tempDir;
  late File sampleImageFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('share_photo_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => tempDir.path,
    );

    sampleImageFile = File('${tempDir.path}/sample.png');
    await sampleImageFile.writeAsBytes(base64Decode(_sampleBase64Png));
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  testWidgets('SharePhotoSheet renders basic layout without photo', (tester) async {
    await tester.pumpWidget(_buildSheet());
    await tester.pump();

    // Verify header and core controls
    expect(find.text('COMPARTILHAR FOTO'), findsWidgets);
    expect(find.text('Galeria'), findsOneWidget);
    expect(find.text('Câmera'), findsOneWidget);
    expect(find.text('Sem foto'), findsOneWidget);
    expect(find.text('Treino'), findsOneWidget);
    expect(find.text('Sequência'), findsOneWidget);
    expect(find.text('Data'), findsOneWidget);
    expect(find.text(t.save), findsOneWidget);
    expect(find.text('Compartilhar'), findsOneWidget);

    // Verify old separated slider and style presets are removed
    expect(find.text("ESTILO DA MARCA D'ÁGUA"), findsNothing);
    expect(find.text("TAMANHO DA MARCA D'ÁGUA"), findsNothing);
    expect(find.text('Selecione ou tire uma foto'), findsNothing);
    expect(find.text('Trocar Foto'), findsNothing);
    expect(find.text('PROPORÇÃO DA IMAGEM'), findsNothing);
    expect(find.text('POSICIONAMENTO'), findsNothing);
  });

  testWidgets('SharePhotoSheet renders photo with sticker stats and allows switching modes and layouts', (tester) async {
    await tester.pumpWidget(_buildSheet(filePath: sampleImageFile.path));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('45 MIN'), findsOneWidget);
    expect(find.text('FIT//IRON'), findsWidgets);

    // Switch to Sequência (streak mode)
    await tester.tap(find.text('Sequência'));
    await tester.pumpAndSettle();
    expect(find.text('DIAS CONSECUTIVOS'), findsOneWidget);

    // Switch back to Treino
    await tester.tap(find.text('Treino'));
    await tester.pumpAndSettle();
    expect(find.text('45 MIN'), findsOneWidget);

    // Toggle date pill
    await tester.tap(find.text('Data'));
    await tester.pumpAndSettle();

    // Double tap stage to reset rotation
    final stageFinder = find.byType(AspectRatio).first;
    await tester.tap(stageFinder);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(stageFinder);
    await tester.pumpAndSettle();
  });

  testWidgets('SharePhotoSheet loads base64 image and supports Sem foto toggle', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_buildSheet(base64Photo: _sampleBase64Png));
      for (var i = 0; i < 60; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        await tester.pump();
        if (find.text('FIT//IRON').evaluate().isNotEmpty) {
          break;
        }
      }
    });
    await tester.pumpAndSettle();

    expect(find.text('45 MIN'), findsOneWidget);
    expect(find.text('FIT//IRON'), findsWidgets);

    // Tap Sem foto chip
    await tester.tap(find.text('Sem foto'));
    await tester.pumpAndSettle();
    expect(find.text('FIT//IRON'), findsWidgets);
  });

  testWidgets('SharePhotoSheet allows switching layouts and color swatches', (tester) async {
    await tester.pumpWidget(_buildSheet(filePath: sampleImageFile.path));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Verify layout buttons
    // The layout bar has 6 icon toggle buttons with phosphor icons
    // We can tap each icon in the row
    final rowIcons = [
      PhosphorIcons.rows(PhosphorIconsStyle.regular),
      PhosphorIcons.columns(PhosphorIconsStyle.regular),
      PhosphorIcons.textAa(PhosphorIconsStyle.regular),
      PhosphorIcons.squaresFour(PhosphorIconsStyle.regular),
      PhosphorIcons.listBullets(PhosphorIconsStyle.regular),
      PhosphorIcons.equals(PhosphorIconsStyle.regular),
    ];

    for (final icon in rowIcons) {
      final iconFinder = find.byIcon(icon);
      expect(iconFinder, findsOneWidget);
      await tester.tap(iconFinder);
      await tester.pumpAndSettle();
      expect(find.text('FIT//IRON'), findsWidgets);
    }
  });

  testWidgets('SharePhotoSheet drag/pan gesture updates sticker position without error', (tester) async {
    await tester.pumpWidget(_buildSheet(filePath: sampleImageFile.path));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    final stageFinder = find.byType(AspectRatio).first;
    // Perform pan gesture
    await tester.drag(stageFinder, const Offset(-40, 30));
    await tester.pumpAndSettle();

    expect(find.text('FIT//IRON'), findsWidgets);
  });

  testWidgets('SharePhotoSheet preserves native photo aspect ratio and resolution without cropping', (tester) async {
    await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawRect(const Rect.fromLTWH(0, 0, 300, 400), Paint()..color = Colors.green);
      final pic = recorder.endRecording();
      final img = await pic.toImage(300, 400);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final customFile = File('${tempDir.path}/custom_300_400.png');
      await customFile.writeAsBytes(byteData!.buffer.asUint8List());

      await tester.pumpWidget(_buildSheet(filePath: customFile.path));
      for (var i = 0; i < 30; i++) {
        await Future.delayed(const Duration(milliseconds: 30));
        await tester.pump();
        final finder = find.byType(AspectRatio);
        if (finder.evaluate().isNotEmpty) {
          final AspectRatio widget = tester.widget(finder.first);
          if ((widget.aspectRatio - 0.75).abs() < 0.01) break;
        }
      }
    });
    await tester.pumpAndSettle();

    final aspectRatioFinder = find.byType(AspectRatio).first;
    final AspectRatio aspectRatioWidget = tester.widget(aspectRatioFinder);
    expect(aspectRatioWidget.aspectRatio, closeTo(300 / 400, 0.001));
  });
}

