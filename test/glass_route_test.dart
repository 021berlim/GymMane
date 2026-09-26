import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/widgets/glass.dart';

void main() {
  testWidgets('showAppDialog renders content with scale and fade transitions and blur barrier', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () {
                showAppDialog(
                  context: context,
                  builder: (ctx) => const AlertDialog(title: Text('Glass Dialog Test')),
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open Dialog'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Glass Dialog Test'), findsOneWidget);
    expect(find.byType(BlurBarrier), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Glass Dialog Test'), findsOneWidget);
  });

  testWidgets('showAppSheet renders modal sheet with BlurBarrier', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () {
                showAppSheet(
                  context: context,
                  builder: (ctx) => const SizedBox(height: 200, child: Text('Glass Sheet Content')),
                );
              },
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open Sheet'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Glass Sheet Content'), findsOneWidget);
    expect(find.byType(BlurBarrier), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Glass Sheet Content'), findsOneWidget);
  });
}
