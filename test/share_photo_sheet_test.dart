import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
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

    expect(find.text('COMPARTILHAR FOTO'), findsWidgets);
    expect(find.text("ESTILO DA MARCA D'ÁGUA"), findsOneWidget);
    expect(find.text("TAMANHO DA MARCA D'ÁGUA"), findsOneWidget);
    expect(find.text('Selecione ou tire uma foto'), findsOneWidget);

    // Verify aspect ratio bar and position preset chips are removed
    expect(find.text('PROPORÇÃO DA IMAGEM'), findsNothing);
    expect(find.text('POSICIONAMENTO'), findsNothing);
    expect(find.text('Top-Left'), findsNothing);
    expect(find.text('Bottom-Right'), findsNothing);
  });

  testWidgets('SharePhotoSheet renders photo with watermark stats and draggable controls', (tester) async {
    await tester.pumpWidget(_buildSheet(filePath: sampleImageFile.path));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text("Arraste a marca d'água na foto"), findsOneWidget);
    expect(find.text('Trocar Foto'), findsOneWidget);
    expect(find.text('45 MIN'), findsOneWidget);
    expect(find.text('FIT//IRON'), findsWidgets);

    // Switch styles
    await tester.tap(find.text('Compacto'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mínimo'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Completo'));
    await tester.pumpAndSettle();
  });

  testWidgets('SharePhotoSheet loads base64 image and displays watermark', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_buildSheet(base64Photo: _sampleBase64Png));
      for (var i = 0; i < 60; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        await tester.pump();
        if (find.text('Trocar Foto').evaluate().isNotEmpty) {
          break;
        }
      }
    });
    await tester.pumpAndSettle();

    expect(find.text("Arraste a marca d'água na foto"), findsOneWidget);
    expect(find.text('Trocar Foto'), findsOneWidget);
    expect(find.text('45 MIN'), findsOneWidget);
  });
}
