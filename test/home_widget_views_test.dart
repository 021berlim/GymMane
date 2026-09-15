import 'package:fitiron/theme/app_colors.dart';
import 'package:fitiron/widgets/home_widget_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HeatmapWidgetView renders without overflow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: HeatmapWidgetView(
              gc: GymColors.dark,
              levels: List.generate(182, (i) => i % 4),
              streak: 12,
              size: const Size(320, 150),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('StatsWidgetView renders without overflow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: StatsWidgetView(
              gc: GymColors.dark,
              streak: 12,
              sessionsThisWeek: 4,
              goalPct: 80,
              size: const Size(155, 155),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
