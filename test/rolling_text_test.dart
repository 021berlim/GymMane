import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/widgets/rolling_text.dart';

void main() {
  testWidgets('SubtleTextSwitcher renders text with AnimatedSwitcher', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SubtleTextSwitcher(
          text: 'Peitoral · 4 séries',
          style: const TextStyle(fontSize: 14),
        ),
      ),
    ));

    expect(find.byType(AnimatedSwitcher), findsOneWidget);
    expect(find.text('Peitoral · 4 séries'), findsOneWidget);
  });

  testWidgets('RollingText renders digits with animated slot wheels', (tester) async {
    String text = '100';
    late StateSetter updateState;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) {
            updateState = setState;
            return RollingText(
              text,
              style: const TextStyle(fontSize: 20),
            );
          },
        ),
      ),
    ));

    expect(find.bySemanticsLabel('100'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));

    updateState(() => text = '105');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(AnimatedSize), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('105'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('RollInCounter counts up to target value', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RollInCounter(
          value: 50,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    ));

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('50'), findsOneWidget);
  });
}
