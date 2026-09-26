import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/widgets/media_viewer.dart';

void main() {
  testWidgets('showMediaViewer opens interactive media viewer with FadeTransition and zoom', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () {
                showMediaViewer(
                  context: context,
                  itemCount: 2,
                  itemBuilder: (ctx, idx) => Text('Media Page $idx'),
                );
              },
              child: const Text('Open Viewer'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open Viewer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.byType(FadeTransition), findsWidgets);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.text('Media Page 0'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Media Page 0'), findsOneWidget);
  });
}
