import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/widgets/entrance.dart';

void main() {
  testWidgets('Rise renders child with delay, translate, scale and opacity animation', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(
          children: const [
            Rise(index: 0, child: Text('Card 0')),
            Rise(index: 1, child: Text('Card 1')),
          ],
        ),
      ),
    ));

    expect(find.byType(Rise), findsNWidgets(2));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Card 0'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Card 0'), findsOneWidget);
    expect(find.text('Card 1'), findsOneWidget);
  });

  testWidgets('ExerciseSlideTransition transitions between indices with AnimatedSwitcher', (tester) async {
    int index = 0;
    late StateSetter updateState;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) {
            updateState = setState;
            return ExerciseSlideTransition(
              index: index,
              child: Text('Exercise $index'),
            );
          },
        ),
      ),
    ));

    expect(find.text('Exercise 0'), findsOneWidget);

    updateState(() => index = 1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Both transitions in flight
    expect(find.byType(SlideTransition), findsWidgets);
    expect(find.byType(ScaleTransition), findsWidgets);
    expect(find.byType(FadeTransition), findsWidgets);

    await tester.pumpAndSettle();
    expect(find.text('Exercise 1'), findsOneWidget);
  });
}
