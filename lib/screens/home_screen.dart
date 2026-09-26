import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/l10n.dart';
import '../models/exercise.dart';
import '../models/goal.dart';
import '../services/goal_progress_calculator.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/charts.dart';
import '../widgets/exercise_media.dart';
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
                const SizedBox(height: 24),
                Text(
                  _titleCase(t.thisWeek),
                  style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text),
                ),
                const SizedBox(height: 12),
                _thisWeekCard(gc, pinnedGoal, pinnedProgress),
                const SizedBox(height: 24),
                _activityHeader(gc),
                const SizedBox(height: 12),
                _activityCard(gc),
                const SizedBox(height: 24),
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isFuture ? null : () => fit.toggleCheckin(i),
      child: Column(
        children: [
          Text(
            t.weekdayInitial(i + 1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              color: isToday ? gc.text : gc.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: done ? gc.text : gc.bgRaised2,
              shape: BoxShape.circle,
            ),
            child: done
                ? Center(
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: gc.bg,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _thisWeekCard(GymColors gc, Goal pinnedGoal, GoalProgressResult pinnedProgress) {
    return SoftCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Stack(
        children: [
          SizedBox(
            width: 0,
            height: 0,
            child: OverflowBox(
              maxWidth: 0,
              maxHeight: 0,
              child: Text(
                fit.primaryGoalLabel,
                style: const TextStyle(fontSize: 0, color: Colors.transparent),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t.volume.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.s(10, weight: FontWeight.w700, color: gc.textTertiary, letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        text: fit.volumeValue(fit.volumeThisWeekKg),
                        style: AppTheme.d(24, weight: FontWeight.w700, color: gc.text),
                        children: [
                          TextSpan(
                            text: ' ${fit.volumeUnit}',
                            style: AppTheme.d(13, weight: FontWeight.w600, color: gc.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t.setsToday.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.s(10, weight: FontWeight.w700, color: gc.textTertiary, letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${fit.setsToday}',
                      style: AppTheme.d(24, weight: FontWeight.w700, color: gc.text),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t.personalRecords.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.s(10, weight: FontWeight.w700, color: gc.textTertiary, letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${fit.prsThisWeek}',
                      style: AppTheme.d(24, weight: FontWeight.w700, color: gc.text),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 38,
                    height: 38,
                    child: CustomPaint(
                      painter: _MiniGoalRingPainter(
                        pct: pinnedProgress.progressRatio.clamp(0.0, 1.0),
                        trackColor: gc.bgRaised2,
                        accentColor: gc.accent,
                        strokeWidth: 4.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (pinnedGoal.type == GoalType.weeklyFrequency || pinnedGoal.type == GoalType.sessionsWeekly)
                        ? '${pinnedProgress.currentValue.round()}/${pinnedProgress.targetValue.round()}'
                        : '${pinnedProgress.progressPercentage}%',
                    style: AppTheme.d(11, weight: FontWeight.w700, color: gc.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activityHeader(GymColors gc) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: fit.goProgress,
      child: Row(
        children: [
          Text(
            _titleCase(t.activityLabel),
            style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text),
          ),
          const Spacer(),
          Icon(
            PhosphorIconsRegular.caretRight,
            size: 16,
            color: gc.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _activityCard(GymColors gc) {
    return GestureDetector(
      onTap: fit.goProgress,
      child: SoftCard(
        radius: 20,
        padding: const EdgeInsets.all(18),
        child: Heatmap(levels: fit.heatmapLevels),
      ),
    );
  }

  String _titleCase(String text) {
    if (text.isEmpty) return text;
    final lower = text.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
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

class _MiniGoalRingPainter extends CustomPainter {
  _MiniGoalRingPainter({
    required this.pct,
    required this.trackColor,
    required this.accentColor,
    required this.strokeWidth,
  });

  final double pct;
  final Color trackColor;
  final Color accentColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    if (pct > 0) {
      final accentPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = accentColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        pct * 2 * math.pi,
        false,
        accentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_MiniGoalRingPainter old) =>
      old.pct != pct ||
      old.trackColor != trackColor ||
      old.accentColor != accentColor ||
      old.strokeWidth != strokeWidth;
}
