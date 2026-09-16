import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/l10n.dart';
import '../models/exercise.dart';
import '../models/goal.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/exercise_media.dart';
import '../widgets/goal_progress_widgets.dart';
import '../widgets/svg_icon.dart';
import '../widgets/ui_kit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fit,
      builder: (context, _) {
        final gc = context.gc;
        final now = DateTime.now();
        final dateLabel = t.longDate(now);
        final recommended = fit.focusRecommendations;

        final celebrationMsg = fit.consumePendingCelebrationMessage();
        if (celebrationMsg != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              AppToast.show(
                context,
                message: celebrationMsg,
                type: AppToastType.celebration,
              );
            }
          });
        }

        final pinnedGoal = fit.pinnedGoal;
        final pinnedProgress = fit.calculateGoalProgress(pinnedGoal);

        Widget goalTrailing;
        String goalValueStr;
        String? goalUnit;

        if (pinnedGoal.type == GoalType.weeklyFrequency || pinnedGoal.type == GoalType.sessionsWeekly) {
          goalValueStr = '${pinnedProgress.currentValue.round()}/${pinnedProgress.targetValue.round()}';
          goalTrailing = GoalProgressRing(
            progressRatio: pinnedProgress.progressRatio,
            currentValue: pinnedProgress.currentValue,
            targetValue: pinnedProgress.targetValue,
            size: 38,
          );
        } else if (pinnedGoal.type == GoalType.weightTarget || pinnedGoal.type == GoalType.bodyweight) {
          goalValueStr = pinnedProgress.hasNoData ? '--' : '${pinnedProgress.progressPercentage}';
          goalUnit = pinnedProgress.hasNoData ? '' : '%';
          goalTrailing = SizedBox(
            width: 76,
            child: GoalProgressBar(
              progressRatio: pinnedProgress.progressRatio,
              currentValue: pinnedProgress.currentValue,
              targetValue: pinnedProgress.targetValue,
              hasNoData: pinnedProgress.hasNoData,
              etaDate: pinnedProgress.etaDate,
            ),
          );
        } else {
          goalValueStr = '${pinnedProgress.progressPercentage}';
          goalUnit = '%';
          goalTrailing = GoalProgressWidget(goal: pinnedGoal, result: pinnedProgress, ringSize: 38);
        }

        return SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 110 + MediaQuery.of(context).padding.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.today,
                            style: AppTheme.s(11, weight: FontWeight.w600, color: gc.textTertiary, letterSpacing: 1.5)),
                        const SizedBox(height: 2),
                        Text(dateLabel, style: AppTheme.d(20, weight: FontWeight.w600, color: gc.text)),
                      ],
                    ),
                    GestureDetector(
                      onTap: fit.goProgress,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: gc.emberSoft, borderRadius: BorderRadius.circular(100)),
                        child: Row(children: [
                          SvgPathIcon(Ic.flame, size: 16, color: gc.accent),
                          const SizedBox(width: 6),
                          Text('${fit.currentStreak}', style: AppTheme.d(14, weight: FontWeight.w600, color: gc.accent)),
                        ]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _FocusHero(),
                const SizedBox(height: 22),
                SoftCard(
                  radius: 20,
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [for (int i = 0; i < 7; i++) _weekDay(gc, i)],
                  ),
                ),
                const SizedBox(height: 22),
                Text(t.thisWeek,
                    style: AppTheme.d(12, weight: FontWeight.w600, color: gc.textSecondary, letterSpacing: 3)),
                const SizedBox(height: 10),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _statCard(
                          gc,
                          label: t.volume,
                          value: fit.volumeValue(fit.volumeThisWeekKg),
                          unit: ' ${fit.volumeUnit}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          gc,
                          label: t.setsCaps,
                          value: '${fit.setsThisWeek}',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _statCard(
                          gc,
                          label: t.prs,
                          value: '${fit.prsThisWeek}',
                          valueColor: gc.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          gc,
                          label: fit.primaryGoalLabel,
                          value: goalValueStr,
                          unit: goalUnit,
                          trailingWidget: goalTrailing,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text(t.recommended,
                    style: AppTheme.d(12, weight: FontWeight.w600, color: gc.textSecondary, letterSpacing: 3)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recommended.length,
                    itemBuilder: (context, i) => _recCard(gc, recommended[i]),
                  ),
                ),
                const SizedBox(height: 22),
                Row(children: [
                  Expanded(child: _quick(gc, Icon(PhosphorIconsRegular.listChecks, size: 22, color: gc.ember), t.routines, fit.goRoutines)),
                  const SizedBox(width: 12),
                  Expanded(child: _quick(gc, Icon(PhosphorIconsRegular.barbell, size: 22, color: gc.ember), t.exercises, fit.goExercises)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _quick(gc, Icon(PhosphorIconsRegular.image, size: 22, color: gc.ember), t.photoGallery, fit.goGallery)),
                  const SizedBox(width: 12),
                  Expanded(child: _quick(gc, SvgPathIcon(Ic.wrench, size: 20, color: gc.ember), t.tools, fit.goTools)),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _weekDay(GymColors gc, int i) {
    final done = fit.isDayDone(i);
    final isToday = i == fit.todayIndex;
    final isFuture = i > fit.todayIndex;
    Color fill = gc.bgRaised2;
    Border? border;
    double opacity = 1;
    if (done) {
      fill = gc.ember;
    } else if (isToday) {
      border = Border.all(color: gc.ember, width: 2);
    } else if (isFuture) {
      fill = gc.bgRaised2;
      opacity = 0.7;
    } else {
      border = Border.all(color: gc.textTertiary, width: 1.5);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isFuture ? null : () => fit.toggleCheckin(i),
      child: Opacity(
        opacity: opacity,
        child: Column(
          children: [
            Text(t.weekdayInitial(i + 1),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isToday ? gc.ember : gc.textTertiary)),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: fill,
                shape: BoxShape.circle,
                border: border,
              ),
              child: done ? Center(child: SvgPathIcon(Ic.checkBold, size: 14, color: gc.onEmber)) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    GymColors gc, {
    required String label,
    required String value,
    String? unit,
    Color? valueColor,
    Widget? trailingWidget,
  }) {
    return SoftCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.s(10, weight: FontWeight.w700, color: gc.textSecondary, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      text: value,
                      style: AppTheme.d(24, weight: FontWeight.w700, color: valueColor ?? gc.text),
                      children: [
                        if (unit != null)
                          TextSpan(
                            text: unit,
                            style: AppTheme.d(14, weight: FontWeight.w700, color: gc.textSecondary),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (trailingWidget != null) ...[
            const SizedBox(width: 8),
            trailingWidget,
          ],
        ],
      ),
    );
  }

  Widget _quick(GymColors gc, Widget iconWidget, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SoftCard(
        radius: 18,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 22, child: iconWidget),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(label,
                  maxLines: 1, style: AppTheme.d(14, weight: FontWeight.w600, color: gc.text, letterSpacing: 1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recCard(GymColors gc, Exercise ex) {
    return GestureDetector(
      onTap: () => fit.openExercise(ex.id),
      child: Container(
        width: 128,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: gc.bgRaised,
          border: Border.all(color: gc.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExerciseMedia(ex: ex, height: 84, radius: 10),
            const SizedBox(height: 8),
            Expanded(
              child: Text(exerciseName(ex),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: AppTheme.s(12, weight: FontWeight.w600, color: gc.text, height: 1.2)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final focus = fit.suggestedFocus;
    final routine = fit.todayRoutine;
    final count = routine == null ? fit.getFilteredExercises(focus.muscles).length : routine.exerciseIds.length;
    final title = routine == null ? focus.title : fit.routineTitle(routine);
    final subtitle = fit.hasData
        ? t.exerciseCount(count)
        : t.firstSessionHint;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: gc.bgRaised,
          border: Border.all(color: gc.border),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            Positioned(
              left: -45,
              bottom: -45,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(color: gc.accentSoft, shape: BoxShape.circle),
              ),
            ),
            Positioned(
              right: -14,
              top: -6,
              bottom: -6,
              child: Opacity(
                opacity: 0.55,
                child: Image.asset('assets/img/runner.png', fit: BoxFit.fitHeight),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.todaysFocus,
                      style: AppTheme.d(12, weight: FontWeight.w600, color: gc.brass, letterSpacing: 3)),
                  const SizedBox(height: 8),
                    Text(title, style: AppTheme.d(48, weight: FontWeight.w700, color: gc.text, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text(subtitle, style: AppTheme.s(14, color: gc.textSecondary)),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: t.startWorkout,
                    icon: Ic.play,
                    onTap: fit.startWorkout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
