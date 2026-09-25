import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/models/exercise.dart';
import 'package:fitiron/theme/app_theme.dart';
import 'package:fitiron/widgets/exercise_gif_player.dart';
import 'package:fitiron/widgets/exercise_media.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testExercise = Exercise(
    id: '0001',
    name: '3/4 Sit-up',
    bodyPart: 'waist',
    target: 'abs',
    equipment: 'body weight',
    gifPath: 'assets/exercises/0001.gif',
    secondaryMuscles: ['hip flexors'],
    instructions: ['Lie flat on your back...'],
  );

  testWidgets('ExerciseMedia with aspectRatio creates an AspectRatio widget', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: ExerciseMedia(
                ex: testExercise,
                aspectRatio: 1.0,
                live: true,
              ),
            ),
          ),
        ),
      ),
    );

    final aspectRatioFinder = find.byType(AspectRatio);
    expect(aspectRatioFinder, findsWidgets);

    final AspectRatio aspectRatioWidget = tester.widget(aspectRatioFinder.first);
    expect(aspectRatioWidget.aspectRatio, 1.0);

    final gifViewFinder = find.byType(ExerciseGifView);
    expect(gifViewFinder, findsOneWidget);
    final ExerciseGifView gifView = tester.widget(gifViewFinder);
    expect(gifView.aspectRatio, 1.0);
  });

  testWidgets('ExerciseMedia without aspectRatio retains fixed height layout', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Center(
            child: ExerciseMedia(
              ex: testExercise,
              height: 210,
              live: false,
            ),
          ),
        ),
      ),
    );

    final gifViewFinder = find.byType(ExerciseGifView);
    expect(gifViewFinder, findsOneWidget);
    final ExerciseGifView gifView = tester.widget(gifViewFinder);
    expect(gifView.height, 210);
    expect(gifView.aspectRatio, isNull);
  });
}
