import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../catalog/program_templates.dart';
import '../l10n/l10n.dart';
import '../models/live_session.dart';
import '../models/workout.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class WearShell extends StatefulWidget {
  const WearShell({super.key});

  @override
  State<WearShell> createState() => _WearShellState();
}

class _WearShellState extends State<WearShell> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fit.refreshAlarmPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      fit.persistNow();
    }
    if (state == AppLifecycleState.resumed) fit.syncRest();
  }

  Future<void> _back() async {
    switch (fit.route) {
      case 'session':
        if (fit.isSessionComplete) {
          fit.saveAndExit();
        } else {
          fit.parkSession();
        }
      case 'routines':
        fit.popRoute();
      default:
        await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fit,
      builder: (context, _) {
        final gc = context.gc;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _back();
          },
          child: Scaffold(
            backgroundColor: gc.bg,
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: KeyedSubtree(key: ValueKey(fit.route), child: _screen()),
            ),
          ),
        );
      },
    );
  }

  Widget _screen() {
    switch (fit.route) {
      case 'session':
        return WearSession();
      case 'routines':
        return WearRoutines();
      default:
        return WearHome();
    }
  }
}

class WearPage extends StatelessWidget {
  const WearPage({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final side = size.width * 0.13;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(side, size.height * 0.15, side, size.height * 0.18),
      children: children,
    );
  }
}

class WearHome extends StatelessWidget {
  const WearHome({super.key});

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final live = fit.session != null && !fit.session!.complete;
    final planned = fit.todayRoutine;
    final canStart = planned != null && planned.exerciseIds.isNotEmpty;
    return WearPage(children: [
      Center(
        child: Text('GYMMANE',
            style: AppTheme.f(10, weight: FontWeight.w600, color: gc.textTertiary, letterSpacing: 3)),
      ),
      const SizedBox(height: 10),
      Center(child: _WeekRing(gc: gc, done: fit.sessionsThisWeek, goal: fit.weeklyTarget)),
      const SizedBox(height: 8),
      Center(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(PhosphorIconsFill.fire, size: 13, color: gc.accent),
          const SizedBox(width: 4),
          Text('${fit.currentStreak}',
              style: AppTheme.f(15, weight: FontWeight.w700, color: gc.text)),
          const SizedBox(width: 4),
          Text(t.daysUnit(fit.currentStreak),
              style: AppTheme.s(11, weight: FontWeight.w500, color: gc.textSecondary)),
        ]),
      ),
      const SizedBox(height: 14),
      WearButton(
        label: live ? t.continueBtn : t.startWorkout,
        filled: true,
        onTap: () {
          if (live) {
            fit.resumeSession();
          } else if (canStart) {
            fit.startRoutine(planned);
            fit.endCountdown();
          } else {
            fit.goRoutines();
          }
        },
      ),
      const SizedBox(height: 8),
      WearButton(label: t.routines, onTap: fit.goRoutines),
    ]);
  }
}

class _WeekRing extends StatelessWidget {
  const _WeekRing({required this.gc, required this.done, required this.goal});

  final GymColors gc;
  final int done;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final pct = goal <= 0 ? 0.0 : (done / goal).clamp(0.0, 1.0);
    return SizedBox(
      width: 84,
      height: 84,
      child: CustomPaint(
        painter: _RingPainter(track: gc.bgRaised2, fill: gc.accent, pct: pct),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$done/$goal', style: AppTheme.f(19, weight: FontWeight.w700, color: gc.text)),
            Text(t.thisWeek,
                style: AppTheme.f(7.5, weight: FontWeight.w600, color: gc.textTertiary, letterSpacing: 1)),
          ]),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.track, required this.fill, required this.pct});

  final Color track;
  final Color fill;
  final double pct;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 7.0;
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, 0, math.pi * 2, false, paint..color = track);
    if (pct > 0) {
      canvas.drawArc(r, -math.pi / 2, math.pi * 2 * pct, false, paint..color = fill);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.pct != pct || old.track != track || old.fill != fill;
}

class WearButton extends StatelessWidget {
  const WearButton({
    super.key,
    required this.label,
    required this.onTap,
    this.filled = false,
    this.height = 44,
    this.color,
  });

  final String label;
  final VoidCallback? onTap;
  final bool filled;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final enabled = onTap != null;
    final bg = filled ? (color ?? gc.accent) : gc.bgRaised;
    final fg = filled ? gc.bg : gc.text;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Container(
            height: height,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label,
                  maxLines: 1,
                  style: AppTheme.f(12.5, weight: FontWeight.w700, color: fg, letterSpacing: 0.6)),
            ),
          ),
        ),
      ),
    );
  }
}

class WearRoutines extends StatelessWidget {
  const WearRoutines({super.key});

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final planned = fit.todayRoutine;
    final list = [...fit.routines]
      ..sort((a, b) => (a.id == planned?.id ? 0 : 1) - (b.id == planned?.id ? 0 : 1));
    return WearPage(children: [
      Center(
        child: Text(t.routines,
            style: AppTheme.f(11, weight: FontWeight.w600, color: gc.textSecondary, letterSpacing: 2)),
      ),
      const SizedBox(height: 10),
      if (list.isEmpty) ...[
        Center(
          child: Text(t.templates,
              style: AppTheme.f(9, weight: FontWeight.w700, color: gc.textTertiary, letterSpacing: 1.2)),
        ),
        const SizedBox(height: 6),
        for (final p in kProgramTemplates) _templateRow(gc, p),
      ],
      for (final r in list) _routineRow(gc, r, r.id == planned?.id),
    ]);
  }

  Widget _templateRow(GymColors gc, ProgramTemplate p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Semantics(
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            fit.applyTemplate(p);
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 9, 10, 9),
            decoration: BoxDecoration(color: gc.bgRaised, borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.f(12.5, weight: FontWeight.w600, color: gc.text)),
                  const SizedBox(height: 1),
                  Text(t.perWeek(p.days.length),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.s(10, weight: FontWeight.w500, color: gc.textSecondary)),
                ]),
              ),
              Icon(PhosphorIconsBold.plus, size: 12, color: gc.accent),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _routineRow(GymColors gc, Routine r, bool today) {
    final enabled = r.exerciseIds.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Semantics(
        button: true,
        enabled: enabled,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled
              ? () {
                  fit.startRoutine(r);
                  fit.endCountdown();
                }
              : null,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 9, 10, 9),
            decoration: BoxDecoration(
              color: gc.bgRaised,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: today ? gc.accent : Colors.transparent),
            ),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.f(12.5, weight: FontWeight.w600, color: gc.text)),
                  const SizedBox(height: 1),
                  Text(t.exerciseCount(r.exerciseIds.length),
                      style: AppTheme.s(10, weight: FontWeight.w500, color: gc.textSecondary)),
                ]),
              ),
              Icon(PhosphorIconsFill.play, size: 12, color: today ? gc.accent : gc.textTertiary),
            ]),
          ),
        ),
      ),
    );
  }
}

class WearSession extends StatelessWidget {
  const WearSession({super.key});

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return fit.isSessionComplete ? _complete(gc) : _active(gc);
  }

  Widget _active(GymColors gc) {
    final s = fit.session!;
    final ex = fit.currentExercise;
    final exIdx = s.currentIndex;
    final repsOnly = ex != null && fit.isRepsOnly(ex.id);
    final mode = ex == null ? '' : fit.modeOf(ex.id);
    final pending = ex == null ? -1 : ex.sets.indexWhere((st) => !st.done);
    final resting = s.restRemaining != null;

    final holding = fit.holding && fit.holdEx == exIdx;

    return WearPage(children: [
      Row(children: [
        Expanded(
          child: Text(fit.sessionProgressLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.f(9.5, weight: FontWeight.w600, color: gc.textSecondary, letterSpacing: 0.6)),
        ),
        Semantics(
          button: true,
          label: fit.sessionPaused ? t.resumeWorkout : t.pauseWorkout,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: fit.toggleSessionPause,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(fit.sessionPaused ? PhosphorIconsFill.play : PhosphorIconsFill.pause,
                  size: 10, color: fit.sessionPaused ? gc.warn : gc.textTertiary),
              const SizedBox(width: 3),
              Text(fit.elapsedLabel,
                  style: AppTheme.f(11,
                      weight: FontWeight.w700, color: fit.sessionPaused ? gc.warn : gc.textSecondary)),
            ]),
          ),
        ),
      ]),
      const SizedBox(height: 3),
      _WearStage(
        index: exIdx,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (fit.inSuperset) ...[
              Row(children: [
                Icon(PhosphorIconsBold.link, size: 10, color: gc.brass),
                const SizedBox(width: 4),
                Text(t.superset,
                    style: AppTheme.f(9, weight: FontWeight.w700, color: gc.brass, letterSpacing: 0.5)),
              ]),
              const SizedBox(height: 2),
            ],
            Text(ex == null ? '' : t.catalogName(ex.id, ex.name),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.f(16, weight: FontWeight.w700, color: gc.text, height: 1.1)),
            const SizedBox(height: 10),
            if (holding) ...[
              _holdCard(gc),
              const SizedBox(height: 10),
            ] else if (resting) ...[
              _restCard(gc, s),
              const SizedBox(height: 10),
            ],
            if (ex != null)
              for (int j = 0; j < ex.sets.length; j++) _setRow(gc, exIdx, j, ex.sets[j], repsOnly, j == pending),
          ],
        ),
      ),
      if (ex != null && pending >= 0 && mode == 'cardio') ...[
        const SizedBox(height: 8),
        _stepper(gc, fit.distanceUnit.toUpperCase(), fit.distanceValue(ex.sets[pending].km ?? 0),
            () => fit.bumpSessionDistance(exIdx, pending, -1), () => fit.bumpSessionDistance(exIdx, pending, 1)),
        const SizedBox(height: 6),
        _stepper(gc, t.timeCol, durationLabel(ex.sets[pending].sec ?? 0),
            () => fit.bumpSessionSeconds(exIdx, pending, -60), () => fit.bumpSessionSeconds(exIdx, pending, 60)),
      ] else if (ex != null && pending >= 0 && mode == 'time') ...[
        const SizedBox(height: 8),
        _stepper(gc, t.timeCol, durationLabel(ex.sets[pending].sec ?? 0),
            () => fit.bumpSessionSeconds(exIdx, pending, -15), () => fit.bumpSessionSeconds(exIdx, pending, 15)),
      ] else if (ex != null && pending >= 0) ...[
        const SizedBox(height: 8),
        _stepper(gc, t.repsCol, '${ex.sets[pending].reps}',
            () => fit.bumpSessionReps(exIdx, pending, -1), () => fit.bumpSessionReps(exIdx, pending, 1)),
        if (!repsOnly) ...[
          const SizedBox(height: 6),
          _stepper(gc, fit.units.toUpperCase(), fit.weightValue(ex.sets[pending].weight),
              () => fit.bumpSessionWeight(exIdx, pending, -1), () => fit.bumpSessionWeight(exIdx, pending, 1)),
        ],
      ],
      const SizedBox(height: 12),
      _mainAction(gc, ex, exIdx, s.exercises.length, pending),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(
          child: WearButton(
            label: '‹',
            height: 36,
            onTap: exIdx > 0 ? fit.prevExercise : null,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: WearButton(
            label: '›',
            height: 36,
            onTap: exIdx < s.exercises.length - 1 ? fit.nextExercise : null,
          ),
        ),
      ]),
      const SizedBox(height: 8),
      _textAction(gc, t.addSet, () => fit.addSet(exIdx)),
      _textAction(gc, t.finishSession, fit.finishSession),
    ]);
  }

  Widget _restCard(GymColors gc, WorkoutSession s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(color: gc.bgRaised, borderRadius: BorderRadius.circular(18)),
      child: Column(children: [
        Text(t.rest,
            style: AppTheme.f(8.5, weight: FontWeight.w700, color: gc.textTertiary, letterSpacing: 1.5)),
        Text('${s.restRemaining}s', style: AppTheme.f(30, weight: FontWeight.w800, color: gc.text)),
        const SizedBox(height: 4),
        Row(children: [
          Expanded(child: _tiny(gc, '−15', () => fit.nudgeRest(-15))),
          const SizedBox(width: 4),
          Expanded(child: _tiny(gc, t.skip, fit.skipRest, strong: true)),
          const SizedBox(width: 4),
          Expanded(child: _tiny(gc, '+15', () => fit.nudgeRest(15))),
        ]),
      ]),
    );
  }

  Widget _holdCard(GymColors gc) {
    final lead = fit.holdLead;
    final left = fit.holdRemaining ?? 0;
    final total = fit.holdTotal <= 0 ? 1 : fit.holdTotal;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(color: gc.bgRaised, borderRadius: BorderRadius.circular(18)),
      child: Column(children: [
        Text(lead > 0 ? t.getReady : t.timeCol,
            style: AppTheme.f(8.5, weight: FontWeight.w700, color: gc.textTertiary, letterSpacing: 1.5)),
        Text(lead > 0 ? '$lead' : durationLabel(left),
            style: AppTheme.f(30, weight: FontWeight.w800, color: lead > 0 ? gc.accent : gc.text)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: lead > 0 ? 0 : 1 - left / total,
            minHeight: 4,
            backgroundColor: gc.bgRaised2,
            valueColor: AlwaysStoppedAnimation(gc.accent),
          ),
        ),
      ]),
    );
  }

  Widget _tiny(GymColors gc, String label, VoidCallback onTap, {bool strong = false}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: strong ? gc.bgRaised2 : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: gc.border),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, style: AppTheme.f(10.5, weight: FontWeight.w700, color: gc.text)),
        ),
      ),
    );
  }

  Widget _setRow(GymColors gc, int exIdx, int j, SessionSet st, bool repsOnly, bool current) {
    final load = st.sec != null || st.km != null
        ? fit.loggedSetLabel(st.logged)
        : repsOnly
            ? '${st.reps}'
            : '${st.reps} × ${fit.weightValue(st.weight)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Semantics(
        button: true,
        checked: st.done,
        label: t.markSet(j + 1),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => fit.toggleSet(exIdx, j),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
            decoration: BoxDecoration(
              color: st.done ? gc.sageSoft : gc.bgRaised,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: current ? gc.accent : Colors.transparent),
            ),
            child: Row(children: [
              SizedBox(
                width: 18,
                child: Text(st.kind == SetKind.warmup ? 'W' : '${j + 1}',
                    style: AppTheme.f(12, weight: FontWeight.w700, color: gc.textSecondary)),
              ),
              Expanded(
                child: Text(load,
                    maxLines: 1,
                    style: AppTheme.f(13, weight: FontWeight.w600, color: gc.text)),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: st.done ? gc.sage : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: st.done ? gc.sage : gc.textTertiary, width: 1.5),
                ),
                child: st.done ? const Icon(Icons.check_rounded, size: 13, color: Colors.white) : null,
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _stepper(GymColors gc, String label, String value, VoidCallback dec, VoidCallback inc) {
    Widget b(String g, String semantic, VoidCallback onTap) => Semantics(
          button: true,
          label: semantic,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              width: 36,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: gc.bgRaised2, borderRadius: BorderRadius.circular(10)),
              child: Text(g, style: TextStyle(color: gc.text, fontSize: 18, height: 1)),
            ),
          ),
        );
    return Row(children: [
      b('–', t.decrease, dec),
      Expanded(
        child: Column(children: [
          Text(value, style: AppTheme.f(17, weight: FontWeight.w700, color: gc.text)),
          Text(label,
              style: AppTheme.f(7.5, weight: FontWeight.w600, color: gc.textTertiary, letterSpacing: 1)),
        ]),
      ),
      b('+', t.increase, inc),
    ]);
  }

  Widget _mainAction(GymColors gc, SessionExercise? ex, int exIdx, int total, int pending) {
    if (pending >= 0 && ex != null && fit.isTimed(ex.id)) {
      if (fit.holding && fit.holdEx == exIdx) {
        return WearButton(label: t.stopLabel, filled: true, onTap: fit.stopHold);
      }
      return WearButton(
        label: t.startHold(durationLabel(ex.sets[pending].sec ?? 30)),
        filled: true,
        onTap: () => fit.startHold(exIdx, pending),
      );
    }
    if (pending >= 0) {
      return WearButton(label: t.setDone, filled: true, onTap: () => fit.toggleSet(exIdx, pending));
    }
    if (fit.pendingAfter(exIdx) != null) {
      return WearButton(label: t.nextExercise, filled: true, onTap: fit.goNextPending);
    }
    if (exIdx < total - 1) {
      return WearButton(label: t.nextExercise, filled: true, onTap: fit.nextExercise);
    }
    return WearButton(label: t.finishSession, filled: true, onTap: fit.finishSession);
  }

  Widget _textAction(GymColors gc, String label, VoidCallback onTap) => Semantics(
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Center(
              child: Text(label,
                  style: AppTheme.f(10.5, weight: FontWeight.w600, color: gc.textTertiary, letterSpacing: 0.4)),
            ),
          ),
        ),
      );

  Widget _complete(GymColors gc) {
    final s = fit.session!;
    return WearPage(children: [
      Center(
        child: Text(t.sessionComplete,
            textAlign: TextAlign.center,
            style: AppTheme.f(10.5, weight: FontWeight.w600, color: gc.brass, letterSpacing: 1.4)),
      ),
      const SizedBox(height: 8),
      Center(
        child: Text(t.finishHeadline(prs: fit.summaryPrs, streak: fit.currentStreak, goalHit: fit.goalPct >= 100),
            textAlign: TextAlign.center,
            style: AppTheme.f(17, weight: FontWeight.w700, color: gc.text, height: 1.1)),
      ),
      const SizedBox(height: 12),
      _stat(gc, t.duration, fit.summaryDurationLabel),
      _stat(gc, t.setsCaps, '${s.summarySets ?? 0}'),
      _stat(gc, t.volume, fit.volumeLabel(fit.summaryVolumeKg)),
      const SizedBox(height: 12),
      WearButton(label: t.saveAndExit, filled: true, onTap: fit.saveAndExit),
    ]);
  }

  Widget _stat(GymColors gc, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: gc.bgRaised, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Expanded(
            child: Text(label,
                style: AppTheme.f(9, weight: FontWeight.w600, color: gc.textSecondary, letterSpacing: 0.6)),
          ),
          Text(value, style: AppTheme.f(14, weight: FontWeight.w700, color: gc.text)),
        ]),
      ),
    );
  }
}

class _WearStage extends StatefulWidget {
  const _WearStage({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_WearStage> createState() => _WearStageState();
}

class _WearStageState extends State<_WearStage> {
  double _dir = 1;

  @override
  void didUpdateWidget(_WearStage old) {
    super.didUpdateWidget(old);
    if (old.index == widget.index) return;
    _dir = widget.index > old.index ? 1 : -1;
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.index;
    final dir = _dir;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: const Interval(0.3, 1, curve: Curves.easeOutCubic),
      switchOutCurve: const Interval(0.55, 1, curve: Curves.easeInCubic),
      transitionBuilder: (child, animation) {
        final incoming = (child.key as ValueKey?)?.value == current;
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: Offset(incoming ? 0.4 * dir : -0.4 * dir, 0), end: Offset.zero)
                .animate(animation),
            child: child,
          ),
        );
      },
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.topCenter,
        children: [...previousChildren, ?currentChild],
      ),
      child: KeyedSubtree(key: ValueKey(current), child: widget.child),
    );
  }
}
