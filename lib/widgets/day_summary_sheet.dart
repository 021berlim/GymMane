import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/fitness_translator.dart';
import '../l10n/l10n.dart';
import '../models/cardio_config.dart';
import '../models/workout.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'glass.dart';
import 'manual_workout_sheet.dart';
import 'ui_kit.dart';

Future<void> showDaySummarySheet(BuildContext context, DateTime date) {
  return showAppSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => DaySummarySheet(date: date),
  );
}

class DaySummarySheet extends StatelessWidget {
  const DaySummarySheet({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: fit, builder: (context, _) => _body(context));
  }

  Widget _body(BuildContext context) {
    final gc = context.gc;
    final s = fit.daySummary(date);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: gc.bgRaised,
        border: Border.all(color: gc.border),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ModalDragHandle(),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  t.longDate(date).toUpperCase(),
                  style: AppTheme.d(20, weight: FontWeight.w700, color: gc.text, letterSpacing: 1),
                ),
              ),
              RoundBtn(
                iconData: PhosphorIconsRegular.x,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (s == null) ...[
            Text(t.restDay, style: AppTheme.s(14, color: gc.textSecondary)),
            const SizedBox(height: 20),
            PrimaryButton(
              label: t.registerWorkout.toUpperCase(),
              onTap: () => showManualWorkoutSheet(context, initialDate: date),
            ),
          ] else ...[
            Row(children: [
              Expanded(child: _stat(gc, t.exercisesCaps, '${s.exercises}')),
              const SizedBox(width: 10),
              Expanded(child: _stat(gc, t.setsCaps, '${s.sets}')),
              const SizedBox(width: 10),
              Expanded(child: _stat(gc, t.volume, fit.volumeLabel(s.volume))),
              if (s.durationSec > 0) ...[
                const SizedBox(width: 10),
                Expanded(child: _stat(gc, t.timeCaps, '${s.durationSec ~/ 60}m')),
              ],
            ]),
            const SizedBox(height: 16),
            Text(t.tapToDelete, style: AppTheme.s(11, color: gc.textTertiary)),
            const SizedBox(height: 8),
            for (final logged in fit.sessionsOn(date))
              for (final ex in [...logged.exercises])
                _loggedRow(context, gc, logged, ex),
            const SizedBox(height: 16),
            PrimaryButton(
              label: t.registerWorkout.toUpperCase(),
              onTap: () => showManualWorkoutSheet(context, initialDate: date),
            ),
          ],
        ],
      ),
    );
  }

  Widget _loggedRow(BuildContext context, GymColors gc, LoggedSession s, LoggedExercise e) {
    final def = fit.exerciseById(e.id);
    final isCardio = (def != null && def.isCardio) || e.isCardio;
    final name = def?.localizedName(context) ??
        (appLanguage == 'pt' ? FitnessTranslator.translateExerciseName(e.name) : t.catalogName(e.id, e.name));

    final String detail;
    if (isCardio) {
      final totalSec = e.sets.fold<int>(0, (sum, st) => sum + (st.sec ?? 0));
      final mins = totalSec ~/ 60;
      final timeStr = mins > 0 ? '${mins}m' : '${totalSec}s';
      final ct = def?.cardioType ?? CardioCategoryType.general;
      final speed = e.sets.map((st) => st.speed).firstWhere((sp) => sp != null && sp > 0, orElse: () => null);
      final param = e.sets.map((st) => st.cardioParam).firstWhere((cp) => cp != null && cp > 0, orElse: () => null);

      if (ct.hasSpeed && speed != null) {
        detail = '$timeStr · ${speed.toStringAsFixed(1)} km/h · ${param != null ? ct.formatParamWithUnit(param) : ct.paramLabel}';
      } else if (param != null) {
        detail = '$timeStr · ${ct.formatParamWithUnit(param)}';
      } else {
        detail = '$timeStr · ${ct.displayNamePt}';
      }
    } else {
      detail = '${e.sets.length}×${e.sets.isEmpty ? 0 : e.sets.map((x) => x.reps).reduce((a, b) => a > b ? a : b)}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: gc.accent, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.s(13, weight: FontWeight.w600, color: gc.text)),
                const SizedBox(height: 2),
                Text(detail, style: AppTheme.s(11, color: gc.textSecondary)),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: '${t.deleteCaps} $name',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _confirmDelete(context, s, e),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(PhosphorIconsRegular.trash, size: 16, color: gc.textTertiary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, LoggedSession s, LoggedExercise e) async {
    final gc = context.gc;
    final def = fit.exerciseById(e.id);
    final name = def?.localizedName(context) ??
        (appLanguage == 'pt' ? FitnessTranslator.translateExerciseName(e.name) : t.catalogName(e.id, e.name));

    final ok = await showAppDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        backgroundColor: gc.bgRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t.deleteEntry, style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text)),
        content: Text(t.deleteEntryBody(name), style: AppTheme.s(13, color: gc.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(false),
            child: Text(t.cancel, style: AppTheme.s(14, color: gc.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(true),
            child: Text(t.delete, style: AppTheme.s(14, weight: FontWeight.w700, color: gc.accent)),
          ),
        ],
      ),
    );
    if (ok == true) fit.deleteLoggedExercise(s, e);
  }

  Widget _stat(GymColors gc, String label, String value) {
    Widget fit1(Widget child) =>
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: child);
    return SoftCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          fit1(Text(label,
              maxLines: 1,
              softWrap: false,
              style: AppTheme.s(9, weight: FontWeight.w600, color: gc.textSecondary, letterSpacing: 1))),
          const SizedBox(height: 4),
          fit1(Text(value,
              maxLines: 1, softWrap: false, style: AppTheme.d(17, weight: FontWeight.w700, color: gc.text))),
        ],
      ),
    );
  }
}
