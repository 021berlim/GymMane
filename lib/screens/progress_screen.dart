import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/fitness_translator.dart';
import '../l10n/l10n.dart';
import '../models/exercise.dart';
import '../models/goal.dart';
import '../models/workout.dart';
import '../services/weight_trend_calculator.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/body_map.dart';
import '../widgets/bodyweight_sheet.dart';
import '../widgets/charts.dart';
import '../widgets/goal_progress_widgets.dart';
import '../widgets/svg_icon.dart';
import '../widgets/ui_kit.dart';
import '../widgets/glass.dart';
import 'muscle_distribution_screen.dart';
import 'weekly_progress_detail_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fit,
      builder: (context, _) {
        final gc = context.gc;
        final split = fit.muscleSplit;

        return SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScreenTitle(t.progress),
                const SizedBox(height: 22),
                SoftCard(
                  radius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t.consistency.toUpperCase(),
                              style: AppTheme.d(14, weight: FontWeight.w600, color: gc.text, letterSpacing: 1)),
                          Text(t.sessionsLogged(fit.totalSessions),
                              style: AppTheme.s(12, color: gc.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Heatmap(levels: fit.heatmapLevels, onTapDay: (i) => _showDay(context, i)),
                      const SizedBox(height: 14),
                      Row(children: [
                        SvgPathIcon(Ic.flame, size: 14, color: gc.accent),
                        const SizedBox(width: 6),
                        Text(t.streakDays(fit.currentStreak),
                            style: AppTheme.s(13, weight: FontWeight.w600, color: gc.text)),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const _WeeklyProgressCard(),
                const SizedBox(height: 22),
                const _GoalsCard(),
                const SizedBox(height: 22),
                _BodyweightCard(),
                const SizedBox(height: 22),
                const _MuscleMapCard(),
                const SizedBox(height: 22),
                RadarMuscleChart(
                  entries: split,
                  onExploreDetails: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MuscleDistributionScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDay(BuildContext context, int index) {
    final date = fit.heatmapDate(index);
    showAppSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DaySheet(date: date),
    );
  }
}



class _MuscleMapCard extends StatefulWidget {
  const _MuscleMapCard();

  @override
  State<_MuscleMapCard> createState() => _MuscleMapCardState();
}

class _MuscleMapCardState extends State<_MuscleMapCard> {
  int _days = 7;
  String? _focus;

  void _setDays(int d) => setState(() {
        _days = d;
        _focus = null;
      });

  Widget _modes() => SegToggle(
        [
          SegOption(t.days7, _days == 7, () => _setDays(7)),
          SegOption(t.days30, _days == 30, () => _setDays(30)),
          SegOption(t.recoveryTab, _days == 0, () => _setDays(0)),
        ],
        hPad: 10,
        vPad: 5,
        fontSize: 11,
      );

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final isRecovery = _days == 0;
    final focus = _focus;

    // Recovery data
    final recovery = isRecovery ? fit.muscleRecovery() : const <String, double>{};
    final overall = isRecovery ? fit.overallRecovery() : 0;
    final tired = isRecovery ? fit.stillRecovering() : const <String>[];

    // Volume data
    final sets = !isRecovery ? fit.muscleSetsOver(_days) : const <String, double>{};
    final heat = !isRecovery ? fit.muscleHeatOver(_days) : const <String, double>{};
    final behind = !isRecovery ? fit.neglectedMuscles(_days) : const <String>[];

    final double avgHeat;
    final int heatPct;
    if (!isRecovery) {
      final heatValues = heat.values;
      avgHeat = heatValues.isEmpty
          ? 0.0
          : (heatValues.reduce((a, b) => a + b) / kMuscles.length).clamp(0.0, 1.0);
      heatPct = (avgHeat * 100).round();
    } else {
      avgHeat = 0.0;
      heatPct = 0;
    }

    final ringValue = isRecovery ? (overall / 100).clamp(0.0, 1.0) : avgHeat;
    final ringColor = isRecovery ? recoveryColor(gc, overall / 100) : heatColor(gc, avgHeat);
    final ringLabel = isRecovery ? '$overall' : '$heatPct';

    final summaryTitle = isRecovery
        ? t.recoveryOverall(overall)
        : t.ofTarget(heatPct);

    final summarySubtitle = isRecovery
        ? (tired.isEmpty
            ? t.recoveryAllFresh
            : t.recoveryStill(tired.take(3).map(t.muscle).join(' · ')))
        : (sets.isEmpty
            ? t.muscleMapEmpty
            : (behind.isEmpty
                ? t.muscleMapHint
                : t.muscleMapBehind(behind.take(3).map(t.muscle).join(' · '))));

    return SoftCard(
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.muscleMap.toUpperCase(),
                  style: AppTheme.d(14, weight: FontWeight.w600, color: gc.text, letterSpacing: 1)),
              _modes(),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            child: Row(
              children: [
                SizedBox(
                  width: 46,
                  height: 46,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: ringValue,
                          strokeWidth: 4.5,
                          strokeCap: StrokeCap.round,
                          backgroundColor: gc.bgRaised2,
                          color: ringColor,
                        ),
                      ),
                      Text(
                        ringLabel,
                        style: AppTheme.f(14, weight: FontWeight.w800, color: gc.text),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summaryTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.f(15, weight: FontWeight.w700, color: gc.text),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        summarySubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.s(12, color: gc.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (isRecovery)
            BodyRecoveryMap(
              recovery: recovery,
              focus: focus,
              onTap: (id) => setState(() => _focus = focus == id ? null : id),
            )
          else
            BodyHeatMap(
              intensity: heat,
              focus: focus,
              onTap: (id) => setState(() => _focus = focus == id ? null : id),
            ),
          const SizedBox(height: 16),
          if (isRecovery)
            Row(children: [
              Text(t.recoveryTired, style: AppTheme.s(11, color: gc.textTertiary)),
              const SizedBox(width: 8),
              for (var i = 0; i <= 4; i++) ...[
                if (i > 0) const SizedBox(width: 3),
                Expanded(
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: recoveryColor(gc, i / 4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Text(t.recoveryFresh, style: AppTheme.s(11, color: gc.textTertiary)),
            ])
          else
            Row(children: [
              Text(t.heatLow, style: AppTheme.s(11, color: gc.textTertiary)),
              const SizedBox(width: 8),
              for (int i = 0; i <= heatLevels; i++) ...[
                if (i > 0) const SizedBox(width: 3),
                Expanded(
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: heatLevelColor(gc, i),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Text(t.heatHigh, style: AppTheme.s(11, color: gc.textTertiary)),
            ]),
          const SizedBox(height: 14),
          SizedBox(
            height: 38,
            child: Align(
              alignment: Alignment.centerLeft,
              child: isRecovery
                  ? (focus != null
                      ? _recoveryReadout(gc, focus, recovery[focus] ?? 1)
                      : Text(
                          t.recoveryHint,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.s(12, color: gc.textSecondary),
                        ))
                  : (focus != null
                      ? _readout(gc, focus, sets[focus] ?? 0, heat[focus] ?? 0)
                      : Text(
                          t.muscleMapHint,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.s(12, color: gc.textSecondary),
                        )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recoveryReadout(GymColors gc, String id, double value) {
    final hours = fit.hoursUntilRecovered(id);
    return Row(children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: recoveryColor(gc, value), shape: BoxShape.circle),
      ),
      const SizedBox(width: 8),
      Text(t.muscle(id), style: AppTheme.s(13, weight: FontWeight.w600, color: gc.text)),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
            hours == null
                ? t.recoveryPct((value * 100).round())
                : '${t.recoveryPct((value * 100).round())} · ${t.readyInHours(hours)}',
            style: AppTheme.s(13, color: gc.textSecondary)),
      ),
    ]);
  }

  Widget _readout(GymColors gc, String id, double sets, double heat) {
    return Row(children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: heatColor(gc, heat), shape: BoxShape.circle),
      ),
      const SizedBox(width: 8),
      Text(t.muscle(id), style: AppTheme.s(13, weight: FontWeight.w600, color: gc.text)),
      const SizedBox(width: 8),
      Expanded(
        child: Text('${t.setCount(sets.round())} · ${t.ofTarget((heat * 100).round())}',
            style: AppTheme.s(13, color: gc.textSecondary)),
      ),
    ]);
  }
}

class _DaySheet extends StatelessWidget {
  const _DaySheet({required this.date});

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
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: gc.bgRaised2, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 18),
          Text(t.longDate(date),
              style: AppTheme.d(20, weight: FontWeight.w700, color: gc.text)),
          const SizedBox(height: 14),
          if (s == null)
            Text(t.restDay, style: AppTheme.s(14, color: gc.textSecondary))
          else ...[
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
          ],
        ],
      ),
    );
  }

  Widget _loggedRow(BuildContext context, GymColors gc, LoggedSession s, LoggedExercise e) {
    final name = fit.exerciseById(e.id)?.localizedName(context) ?? (appLanguage == 'pt' ? FitnessTranslator.translateExerciseName(e.name) : t.catalogName(e.id, e.name));
    final detail = '${e.sets.length}×${e.sets.isEmpty ? 0 : e.sets.map((x) => x.reps).reduce((a, b) => a > b ? a : b)}';
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
    final name = fit.exerciseById(e.id)?.localizedName(context) ?? (appLanguage == 'pt' ? FitnessTranslator.translateExerciseName(e.name) : t.catalogName(e.id, e.name));
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

class _LogBodyweightSheet extends StatefulWidget {
  const _LogBodyweightSheet({required this.start});
  final double start;
  @override
  State<_LogBodyweightSheet> createState() => _LogBodyweightSheetState();
}

class _LogBodyweightSheetState extends State<_LogBodyweightSheet> {
  late double _shown = ((fit.toDisplayWeight(widget.start)) * 10).round() / 10;

  void _bump(double d) => setState(() => _shown = ((_shown + d) * 10).round() / 10);

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        border: Border.all(color: gc.border),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: gc.bgRaised2, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 18),
          Text(t.logBodyweight,
              style: AppTheme.d(14, weight: FontWeight.w600, color: gc.text, letterSpacing: 2)),
          const SizedBox(height: 4),
          Text(t.trackWeight, style: AppTheme.s(13, color: gc.textSecondary)),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _round(gc, '–', () => _bump(-0.1)),
              const SizedBox(width: 22),
              SizedBox(
                width: 130,
                child: Text('${fmt(_shown)} ${fit.units}',
                    textAlign: TextAlign.center,
                    style: AppTheme.d(40, weight: FontWeight.w700, color: gc.text)),
              ),
              const SizedBox(width: 22),
              _round(gc, '+', () => _bump(0.1)),
            ],
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: t.save,
            onTap: () {
              fit.addBodyweight(fit.fromDisplayWeight(_shown));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _round(GymColors gc, String glyph, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(color: gc.bgRaised2, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(glyph, style: TextStyle(color: gc.text, fontSize: 26, height: 1)),
      ),
    );
  }
}

class _BodyweightCard extends StatefulWidget {
  const _BodyweightCard();

  @override
  State<_BodyweightCard> createState() => _BodyweightCardState();
}

class _BodyweightCardState extends State<_BodyweightCard> {
  int _days = 30;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;

    final cutoff = DateTime.now().subtract(Duration(days: _days));
    final entriesInPeriod = fit.bodyweight
        .where((e) => !e.timestamp.isBefore(cutoff))
        .toList();

    double? targetWeight;
    final bwGoal = fit.goals.where((g) => g.type == GoalType.bodyweight).firstOrNull;
    if (bwGoal != null && bwGoal.target > 0) {
      targetWeight = bwGoal.target;
    }

    final res = WeightTrendCalculator.calculate(
      entries: entriesInPeriod,
      goalWeight: targetWeight,
    );

    final trendSeries = res.trendSeries;
    final currentTrend = res.currentTrendWeight;

    final rawEligible = entriesInPeriod
        .where((e) => e.context != WeightContext.postWorkout)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    double? trendChange;
    if (trendSeries.length >= 2) {
      trendChange = trendSeries.last.trendKg - trendSeries.first.trendKg;
    }

    return SoftCard(
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  t.trackWeight.toUpperCase(),
                  style: AppTheme.d(14, weight: FontWeight.w600, color: gc.text, letterSpacing: 1),
                ),
              ),
              _buildCardPlusButton(onTap: () => showBodyweightSheet(context), gc: gc),
            ],
          ),
          const SizedBox(height: 14),
          if (trendSeries.isEmpty) ...[
            Align(
              alignment: Alignment.centerRight,
              child: SegToggle(
                [
                  SegOption(t.days7, _days == 7, () => setState(() => _days = 7)),
                  SegOption(t.days30, _days == 30, () => setState(() => _days = 30)),
                ],
                hPad: 11,
                vPad: 5,
                fontSize: 11,
              ),
            ),
            EmptyStateView(
              icon: PhosphorIconsRegular.scales,
              title: t.noWeightLoggedYet,
              subtitle: t.noWeightLoggedYetSub,
            ),
          ]
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: fit.weightValue(currentTrend),
                          style: AppTheme.d(32, weight: FontWeight.w700, color: gc.text),
                          children: [
                            TextSpan(
                              text: ' ${fit.units}',
                              style: AppTheme.d(15, weight: FontWeight.w700, color: gc.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      if (trendChange != null && trendChange.abs() >= 0.05)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: gc.accentSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${trendChange > 0 ? '+' : ''}${fit.weightLabel(trendChange)}',
                            style: AppTheme.s(
                              11,
                              weight: FontWeight.w600,
                              color: gc.accent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SegToggle(
                  [
                    SegOption(t.days7, _days == 7, () => setState(() => _days = 7)),
                    SegOption(t.days30, _days == 30, () => setState(() => _days = 30)),
                  ],
                  hPad: 11,
                  vPad: 5,
                  fontSize: 11,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: _WeightLineChart(
                  trendSeries: trendSeries,
                  rawEntries: rawEligible,
                  gc: gc,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Text(
                  'Ritmo: ${res.weeklyRateKg > 0 ? '+' : ''}${fit.weightLabel(res.weeklyRateKg)}/semana',
                  style: AppTheme.s(13, color: gc.textSecondary),
                ),
                if (res.isRateAggressive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: gc.accentSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      t.rateAggressiveWarning,
                      style: AppTheme.s(
                        11,
                        weight: FontWeight.w600,
                        color: gc.accent,
                      ),
                    ),
                  ),
              ],
            ),
            if (res.goalEtaDate != null) ...[
              const SizedBox(height: 6),
              Builder(builder: (context) {
                final daysLeft = res.goalEtaDate!.difference(trendSeries.last.timestamp).inDays;
                final weeksLeft = (daysLeft / 7).round();
                final weeksStr = weeksLeft <= 1 ? '1 semana' : '$weeksLeft semanas';

                return Text(
                  'No ritmo atual, meta em ~$weeksStr',
                  style: AppTheme.s(13, color: gc.textSecondary),
                );
              }),
            ],
          ],
        ],
      ),
    );
  }
}

Widget _buildCardPlusButton({required VoidCallback onTap, required GymColors gc}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: gc.bgRaised2,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: gc.accent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          '+',
          style: AppTheme.d(11, weight: FontWeight.w700, color: gc.bg),
        ),
      ),
    ),
  );
}

class _WeightLineChart extends StatelessWidget {
  const _WeightLineChart({
    required this.trendSeries,
    required this.rawEntries,
    required this.gc,
  });

  final List<TrendPoint> trendSeries;
  final List<WeightEntry> rawEntries;
  final GymColors gc;

  @override
  Widget build(BuildContext context) {
    if (trendSeries.isEmpty) return const SizedBox.shrink();

    final t0 = trendSeries.first.timestamp;
    final tN = trendSeries.last.timestamp;
    final totalSpanDays = math.max(
      1.0,
      tN.difference(t0).inMilliseconds / (1000.0 * 3600.0 * 24.0),
    );

    final trendSpots = <FlSpot>[];
    for (final p in trendSeries) {
      final x = p.timestamp.difference(t0).inMilliseconds / (1000.0 * 3600.0 * 24.0);
      trendSpots.add(FlSpot(x, p.trendKg));
    }

    final rawSpots = <FlSpot>[];
    for (final p in rawEntries) {
      final x = p.timestamp.difference(t0).inMilliseconds / (1000.0 * 3600.0 * 24.0);
      rawSpots.add(FlSpot(x, p.weightKg));
    }

    double minY = trendSeries.map((p) => p.trendKg).reduce(math.min);
    double maxY = trendSeries.map((p) => p.trendKg).reduce(math.max);

    if (rawSpots.isNotEmpty) {
      final minRaw = rawEntries.map((p) => p.weightKg).reduce(math.min);
      final maxRaw = rawEntries.map((p) => p.weightKg).reduce(math.max);
      minY = math.min(minY, minRaw);
      maxY = math.max(maxY, maxRaw);
    }

    final yPadding = (maxY - minY).abs() < 1e-4 ? 1.0 : (maxY - minY) * 0.15;
    minY -= yPadding;
    maxY += yPadding;

    final minX = 0.0;
    final maxX = totalSpanDays;

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        clipData: const FlClipData.none(),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => gc.bgRaised2,
            tooltipBorder: BorderSide(color: gc.accent.withValues(alpha: 0.4)),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final valStr = fit.weightValue(spot.y);
                final unitStr = fit.units;
                return LineTooltipItem(
                  '$valStr $unitStr',
                  AppTheme.s(12, weight: FontWeight.w700, color: gc.accent),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
          getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((spotIndex) {
              return TouchedSpotIndicatorData(
                FlLine(color: gc.accent.withValues(alpha: 0.5), strokeWidth: 1.5, dashArray: [3, 3]),
                FlDotData(
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4.5,
                      color: gc.accent,
                      strokeColor: gc.bgRaised,
                      strokeWidth: 2,
                    );
                  },
                ),
              );
            }).toList();
          },
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          drawHorizontalLine: true,
          checkToShowHorizontalLine: (value) {
            return (value - minY).abs() < (yPadding * 1.2) || (value - maxY).abs() < (yPadding * 1.2);
          },
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: gc.border.withValues(alpha: 0.5),
              strokeWidth: 1,
              dashArray: [4, 4],
            );
          },
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                if (trendSeries.length < 2) return const SizedBox.shrink();
                if (value == minX) {
                  return SideTitleWidget(
                    meta: meta,
                    fitInside: SideTitleFitInsideData.fromTitleMeta(meta, distanceFromEdge: 0),
                    child: Text(
                      t.shortDate(t0),
                      style: AppTheme.s(10, color: gc.textSecondary, weight: FontWeight.w600),
                    ),
                  );
                } else if ((value - maxX).abs() < 0.01) {
                  return SideTitleWidget(
                    meta: meta,
                    fitInside: SideTitleFitInsideData.fromTitleMeta(meta, distanceFromEdge: 0),
                    child: Text(
                      t.shortDate(tN),
                      style: AppTheme.s(10, color: gc.textSecondary, weight: FontWeight.w600),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: rawSpots,
            barWidth: 0,
            isCurved: false,
            color: Colors.transparent,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3.5,
                  color: gc.accent,
                  strokeColor: gc.bgRaised,
                  strokeWidth: 1.5,
                );
              },
            ),
          ),
          LineChartBarData(
            spots: trendSpots,
            barWidth: 3.0,
            isCurved: true,
            color: gc.accent,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  gc.accent.withValues(alpha: 0.25),
                  gc.accent.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

typedef _WeeklyProgressCard = WeeklyProgressCardWidget;

class WeeklyProgressCardWidget extends StatefulWidget {
  const WeeklyProgressCardWidget({
    super.key,
    this.weekStart,
    this.showExploreDetails = true,
  });

  final DateTime? weekStart;
  final bool showExploreDetails;

  @override
  State<WeeklyProgressCardWidget> createState() => _WeeklyProgressCardWidgetState();
}

class _WeeklyProgressCardWidgetState extends State<WeeklyProgressCardWidget> {
  String _metric = 'TEMPO';
  int _weekOffset = 0;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final now = DateTime.now();
    final todayKey = DateTime(now.year, now.month, now.day);
    final currentWeekStart = todayKey.subtract(Duration(days: todayKey.weekday - 1));
    final weekStart = widget.weekStart ?? currentWeekStart.add(Duration(days: _weekOffset * 7));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final hasData = fit.weekHasData(weekStart);

    final dateRangeStr = '${t.shortDate(weekStart)} - ${t.shortDate(weekEnd)}';

    final earliestDate = fit.earliestActivityDate;
    final earliestDayKey = DateTime(earliestDate.year, earliestDate.month, earliestDate.day);
    final earliestWeekStart = earliestDayKey.subtract(Duration(days: earliestDayKey.weekday - 1));

    final maxPastWeeks = math.max(0, (currentWeekStart.difference(earliestWeekStart).inDays / 7.0).ceil());
    final minWeekOffset = -maxPastWeeks;

    final canGoBack = _weekOffset > minWeekOffset;
    final canGoForward = _weekOffset < 0;

    final workoutCount = fit.weeklySessionsCount(weekStart);

    String totalValStr;
    String totalSub = 'Total esta semana';
    String avgValStr;
    String avgSub = 'Média por treino';
    String subHeaderLabel;
    String avgLabelText;
    Color metricAccent;

    switch (_metric) {
      case 'CALORIAS':
        final totalCal = fit.weeklyCalories(weekStart).fold(0.0, (a, b) => a + b).round();
        final avgCal = fit.weeklyAvgCaloriesPerWorkout(weekStart).round();
        totalValStr = '$totalCal kcal';
        avgValStr = '$avgCal kcal';
        subHeaderLabel = 'Calorias por dia';
        avgLabelText = 'Média de calorias';
        metricAccent = const Color(0xFFFF6B4A);
        break;
      case 'VOLUME':
        final totalVol = fit.volumeWeekKg(weekStart);
        final avgVol = fit.weeklyAvgVolumePerWorkout(weekStart);
        totalValStr = '${fit.volumeValue(totalVol)} ${fit.volumeUnit}';
        avgValStr = '${fit.volumeValue(avgVol)} ${fit.volumeUnit}';
        subHeaderLabel = 'Volume por dia';
        avgLabelText = 'Média de volume';
        metricAccent = const Color(0xFFA855F7);
        break;
      case 'REPS':
        final totalReps = fit.repsWeekTotal(weekStart);
        final avgReps = fit.weeklyAvgRepsPerWorkout(weekStart).round();
        totalValStr = '$totalReps';
        avgValStr = '$avgReps';
        subHeaderLabel = 'Reps por dia';
        avgLabelText = 'Média de reps';
        metricAccent = const Color(0xFFEAB308);
        break;
      case 'TEMPO':
      default:
        final totalDur = fit.durationWeekMin(weekStart);
        final avgDur = fit.weeklyAvgDurationPerWorkout(weekStart).round();
        totalValStr = '${totalDur}min';
        avgValStr = '${avgDur}min';
        subHeaderLabel = 'Tempo por dia';
        avgLabelText = 'Média de tempo';
        metricAccent = gc.accent;
        break;
    }

    return SoftCard(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROGRESSO SEMANAL',
                style: AppTheme.d(14, weight: FontWeight.w600, color: gc.text, letterSpacing: 1),
              ),
              if (widget.showExploreDetails)
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WeeklyProgressDetailScreen()),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        'Explorar detalhes',
                        style: AppTheme.s(12, color: gc.textSecondary, weight: FontWeight.w500),
                      ),
                      const SizedBox(width: 4),
                      SvgPathIcon(Ic.chevronRight, size: 14, color: gc.textSecondary),
                    ],
                  ),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: canGoBack ? () => setState(() => _weekOffset--) : null,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: SvgPathIcon(
                          Ic.chevronLeft,
                          size: 14,
                          color: canGoBack ? gc.textSecondary : gc.textTertiary.withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                    Text(
                      dateRangeStr,
                      style: AppTheme.s(12, color: gc.textSecondary, weight: FontWeight.w500),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: canGoForward ? () => setState(() => _weekOffset++) : null,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: SvgPathIcon(
                          Ic.chevronRight,
                          size: 14,
                          color: canGoForward ? gc.textSecondary : gc.textTertiary.withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 14),
              if (!hasData) ...[
                const SizedBox(height: 36),
                Center(child: _BarChartEmptyIcon(gc: gc)),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Nada para mostrar ainda',
                    style: AppTheme.d(17, weight: FontWeight.w700, color: gc.text),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 270),
                    child: Text(
                      'Os resultados aparecerão após o seu primeiro treino.',
                      textAlign: TextAlign.center,
                      style: AppTheme.s(13, color: gc.textSecondary, height: 1.35),
                    ),
                  ),
                ),
                const SizedBox(height: 44),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          totalValStr,
                          style: AppTheme.d(22, weight: FontWeight.w700, color: metricAccent),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          totalSub,
                          style: AppTheme.s(12, color: gc.textSecondary),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          avgValStr,
                          style: AppTheme.d(22, weight: FontWeight.w700, color: metricAccent),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          avgSub,
                          style: AppTheme.s(12, color: gc.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  subHeaderLabel,
                  style: AppTheme.s(12, color: gc.textTertiary, weight: FontWeight.w500),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 150,
                  child: _buildMetricChart(gc, weekStart, metricAccent),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: gc.bgRaised2,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '$workoutCount TREINOS ESTA SEMANA',
                        style: AppTheme.d(10, weight: FontWeight.w700, color: gc.text, letterSpacing: 0.8),
                      ),
                    ),
                    Text(
                      workoutCount > 0 ? '$avgValStr  $avgLabelText' : '- - - -  $avgLabelText',
                      style: AppTheme.s(11, color: gc.textSecondary, weight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: gc.bgRaised2.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    _tabButton(gc, 'TEMPO'),
                    _tabButton(gc, 'CALORIAS'),
                    _tabButton(gc, 'VOLUME'),
                    _tabButton(gc, 'REPS'),
                  ],
                ),
              ),
            ],
          ),
        );
  }

  Widget _tabButton(GymColors gc, String label) {
    final selected = _metric == label;
    final activePillColor = gc.accent.withValues(alpha: 0.18);
    final activeTextColor = gc.accent;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _metric = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? activePillColor : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            label,
            style: AppTheme.d(
              11,
              weight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? activeTextColor : gc.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChart(GymColors gc, DateTime weekStart, Color metricAccent) {
    List<double> values;
    switch (_metric) {
      case 'CALORIAS':
        values = fit.weeklyCalories(weekStart);
      case 'VOLUME':
        values = fit.weeklyVolumeKg(weekStart);
      case 'REPS':
        values = fit.weeklyReps(weekStart);
      case 'TEMPO':
      default:
        values = fit.weeklyDurationMinutes(weekStart);
    }

    final maxVal = values.fold<double>(0.0, math.max);
    final displayMax = maxVal > 0 ? maxVal : 10.0;
    const daysLabel = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    final yLabels = [
      displayMax.round(),
      (displayMax * 0.75).round(),
      (displayMax * 0.5).round(),
      (displayMax * 0.25).round(),
      0,
    ];

    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final val in yLabels)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: gc.border.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '$val',
                        textAlign: TextAlign.end,
                        style: AppTheme.s(10, color: gc.textTertiary),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 36, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < 7; i++) ...[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 16,
                            height: displayMax > 0 ? (100 * (values[i] / displayMax)).clamp(6.0, 100.0) : 0,
                            decoration: BoxDecoration(
                              color: values[i] > 0 ? metricAccent : gc.bgRaised2.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        daysLabel[i],
                        style: AppTheme.s(10, color: gc.textTertiary, weight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BarChartEmptyIcon extends StatelessWidget {
  const _BarChartEmptyIcon({required this.gc});
  final GymColors gc;

  @override
  Widget build(BuildContext context) {
    final barColor = gc.textTertiary.withValues(alpha: 0.35);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 9,
          height: 30,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 5),
        Container(
          width: 9,
          height: 44,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 5),
        Container(
          width: 9,
          height: 22,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }
}

class _GoalsCard extends StatelessWidget {
  const _GoalsCard();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fit,
      builder: (context, _) {
        final gc = context.gc;
        final goals = fit.goals;

        return SoftCard(
          radius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.notifGoalChannel.toUpperCase(),
                    style: AppTheme.d(14, weight: FontWeight.w600, color: gc.text, letterSpacing: 1),
                  ),
                  _buildCardPlusButton(
                    onTap: () => _showAddGoalSheet(context),
                    gc: gc,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (goals.isEmpty)
                EmptyStateView(
                  icon: PhosphorIconsRegular.target,
                  title: t.notifGoalChannel,
                  subtitle: t.onbGoalWhy,
                )
              else
                Column(
                  children: [
                    for (int i = 0; i < goals.length; i++)
                      _goalItem(context, gc, goals[i], i < goals.length - 1),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _goalItem(BuildContext context, GymColors gc, Goal g, bool hasBorder) {
    final progress = fit.calculateGoalProgress(g);
    final isPinned = g.pinnedToHome;

    String typeLabel(Goal g) {
      switch (g.type) {
        case GoalType.weeklyFrequency:
        case GoalType.sessionsWeekly:
          return '${t.weeklyGoal} (${g.targetValue.round()}×)';
        case GoalType.weightTarget:
        case GoalType.bodyweight:
          return '${t.trackWeight} (${fit.weightLabel(g.targetValue)})';
        case GoalType.volumeMonthly:
          return '${t.totalVolume30d} (${fit.volumeValue(g.targetValue)} ${fit.volumeUnit})';
        case GoalType.setsWeekly:
          return '${t.setsCaps} / sem (${g.targetValue.round()})';
        case GoalType.durationMonthly:
          return '${t.timeCaps} / mês (${g.targetValue.round()}h)';
        case GoalType.strength:
          final name = fit.exerciseById(g.exerciseId ?? '')?.localizedName(context) ?? 'PR';
          return '$name (${fit.weightLabel(g.targetValue)})';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: hasBorder ? Border(bottom: BorderSide(color: gc.border)) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        typeLabel(g),
                        style: AppTheme.s(13, weight: FontWeight.w600, color: gc.text),
                      ),
                    ),
                    if (isPinned) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: gc.accentSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          t.today.toUpperCase(),
                          style: AppTheme.s(9, weight: FontWeight.w700, color: gc.accent),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  progress.isCompleted
                      ? t.goalReachedTitle
                      : '${progress.progressPercentage}%',
                  style: AppTheme.s(11,
                      color: progress.isCompleted ? gc.sage : gc.textSecondary,
                      weight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GoalProgressWidget(goal: g, result: progress, ringSize: 36),
          const SizedBox(width: 6),
          IconButton(
            icon: Icon(
              isPinned ? PhosphorIconsFill.star : PhosphorIconsRegular.star,
              size: 18,
              color: isPinned ? gc.brass : gc.textTertiary,
            ),
            onPressed: () => fit.setPrimaryGoal(g.id),
          ),
          IconButton(
            icon: Icon(PhosphorIconsRegular.trash, size: 18, color: gc.textTertiary),
            onPressed: () => fit.deleteGoal(g.id),
          ),
        ],
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    showAppSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddGoalSheet(),
    );
  }
}

class _AddGoalSheet extends StatefulWidget {
  const _AddGoalSheet();

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  GoalType _selectedType = GoalType.weeklyFrequency;
  late double _targetValue = 4;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;

    void updateDefaultTarget(GoalType type) {
      setState(() {
        _selectedType = type;
        switch (type) {
          case GoalType.weeklyFrequency:
          case GoalType.sessionsWeekly:
            _targetValue = 4;
          case GoalType.weightTarget:
          case GoalType.bodyweight:
            _targetValue = fit.latestBodyweight?.kg ?? fit.profile.weightKg;
          case GoalType.volumeMonthly:
            _targetValue = 10000;
          case GoalType.setsWeekly:
            _targetValue = 40;
          case GoalType.durationMonthly:
            _targetValue = 10;
          case GoalType.strength:
            _targetValue = 80;
        }
      });
    }

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        border: Border.all(color: gc.border),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: gc.bgRaised2, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            t.notifGoalChannel,
            textAlign: TextAlign.center,
            style: AppTheme.d(16, weight: FontWeight.w700, color: gc.text, letterSpacing: 2),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _typeChip(gc, GoalType.weeklyFrequency, t.weeklyGoal, () => updateDefaultTarget(GoalType.weeklyFrequency)),
                const SizedBox(width: 8),
                _typeChip(gc, GoalType.weightTarget, t.trackWeight, () => updateDefaultTarget(GoalType.weightTarget)),
                const SizedBox(width: 8),
                _typeChip(gc, GoalType.volumeMonthly, t.volume, () => updateDefaultTarget(GoalType.volumeMonthly)),
                const SizedBox(width: 8),
                _typeChip(gc, GoalType.setsWeekly, t.setsCaps, () => updateDefaultTarget(GoalType.setsWeekly)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _btn(gc, '–', () {
                setState(() {
                  if (_selectedType == GoalType.weeklyFrequency) {
                    _targetValue = (_targetValue - 1).clamp(1, 7);
                  } else {
                    _targetValue = math.max(1, _targetValue - 5);
                  }
                });
              }),
              const SizedBox(width: 20),
              SizedBox(
                width: 140,
                child: Text(
                  _selectedType == GoalType.weeklyFrequency
                      ? '${_targetValue.round()}× / sem'
                      : _selectedType == GoalType.weightTarget
                          ? fit.weightLabel(_targetValue)
                          : fmt(_targetValue),
                  textAlign: TextAlign.center,
                  style: AppTheme.d(32, weight: FontWeight.w700, color: gc.text),
                ),
              ),
              const SizedBox(width: 20),
              _btn(gc, '+', () {
                setState(() {
                  if (_selectedType == GoalType.weeklyFrequency) {
                    _targetValue = (_targetValue + 1).clamp(1, 7);
                  } else {
                    _targetValue += 5;
                  }
                });
              }),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: t.save,
            onTap: () {
              fit.addGoal(_selectedType, _targetValue);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _typeChip(GymColors gc, GoalType type, String label, VoidCallback onTap) {
    final sel = _selectedType == type;
    return Pill(
      label: label,
      bg: sel ? gc.ember : gc.bgRaised2,
      fg: sel ? gc.onEmber : gc.textSecondary,
      onTap: onTap,
      hPad: 14,
      vPad: 8,
      fontSize: 12,
    );
  }

  Widget _btn(GymColors gc, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: gc.bgRaised2, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(text, style: TextStyle(color: gc.text, fontSize: 24, height: 1)),
      ),
    );
  }
}
