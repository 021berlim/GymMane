import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/app/fitiron_app.dart';
import 'package:fitiron/state/fit_state.dart';
import 'package:fitiron/theme/app_colors.dart';
import 'package:fitiron/widgets/ui_kit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('EmptyStateView renders icon, title and subtitle correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark().copyWith(
          extensions: const [GymColors.dark],
        ),
        home: const Scaffold(
          body: EmptyStateView(
            icon: Icons.scale,
            title: 'Nenhum peso registrado ainda',
            subtitle: 'Registre seu peso para acompanhar sua evolução aqui',
          ),
        ),
      ),
    );

    expect(find.text('Nenhum peso registrado ainda'), findsOneWidget);
    expect(find.text('Registre seu peso para acompanhar sua evolução aqui'), findsOneWidget);
    expect(find.byIcon(Icons.scale), findsOneWidget);
  });

  testWidgets('Progress screen displays weight card empty state in PT when bodyweight is empty', (tester) async {
    fit.onboarded = true;
    fit.bodyweight.clear();
    fit.setLanguage('pt');
    fit.route = 'progress';

    await tester.pumpWidget(const FitIronApp());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Nenhum peso registrado ainda'), findsOneWidget);
    expect(find.text('Registre seu peso para acompanhar sua evolução aqui'), findsOneWidget);
  });

  testWidgets('Progress screen displays weight card empty state in EN when bodyweight is empty', (tester) async {
    fit.onboarded = true;
    fit.bodyweight.clear();
    fit.setLanguage('en');
    fit.route = 'progress';

    await tester.pumpWidget(const FitIronApp());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('No weight logged yet'), findsOneWidget);
    expect(find.text('Log your weight to track your evolution here'), findsOneWidget);
  });
}
