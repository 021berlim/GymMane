import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/widgets/fade_slide_route.dart';

void main() {
  testWidgets('FadeSlidePageRoute animates with FadeTransition and SlideTransition', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () {
                pushFadeSlideRoute(
                  context,
                  (_) => const Scaffold(body: Center(child: Text('Fade Slide Target Screen'))),
                );
              },
              child: const Text('Navigate'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Navigate'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    // Both transitions are in flight
    expect(find.byType(FadeTransition), findsWidgets);
    expect(find.byType(SlideTransition), findsWidgets);
    expect(find.text('Fade Slide Target Screen'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Fade Slide Target Screen'), findsOneWidget);
  });
}
