import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../catalog/exercise_catalog.dart';
import '../l10n/fitness_translator.dart';
import '../l10n/l10n.dart';
import '../models/exercise.dart';
import '../models/live_session.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/bodyweight_sheet.dart';
import '../widgets/entrance.dart';
import '../widgets/exercise_media.dart';
import '../widgets/share_photo_sheet.dart';
import '../widgets/svg_icon.dart';
import '../widgets/ui_kit.dart';
import '../widgets/glass.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late PageController _pageController;
  final Map<int, int> _activeSetIndices = {};
  final Map<int, Stopwatch> _cardioStopwatches = {};
  Timer? _cardioTicker;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: fit.session?.currentIndex ?? 0);
    fit.addListener(_onFitChange);
  }

  @override
  void dispose() {
    fit.removeListener(_onFitChange);
    _cardioTicker?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _toggleCardioStopwatch(int exIdx) {
    final sw = _cardioStopwatches.putIfAbsent(exIdx, () => Stopwatch());
    setState(() {
      if (sw.isRunning) {
        sw.stop();
        if (_cardioStopwatches.values.every((s) => !s.isRunning)) {
          _cardioTicker?.cancel();
          _cardioTicker = null;
        }
      } else {
        sw.start();
        _cardioTicker ??= Timer.periodic(const Duration(milliseconds: 500), (_) {
          if (mounted) setState(() {});
        });
      }
    });
  }

  void _resetCardioStopwatch(int exIdx) {
    setState(() {
      final sw = _cardioStopwatches[exIdx];
      sw?.stop();
      sw?.reset();
      if (_cardioStopwatches.values.every((s) => !s.isRunning)) {
        _cardioTicker?.cancel();
        _cardioTicker = null;
      }
    });
  }

  void _onFitChange() {
    if (!mounted || fit.session == null || !_pageController.hasClients) return;
    final targetPage = fit.session!.currentIndex;
    if ((_pageController.page ?? 0).round() != targetPage) {
      _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  int _getActiveSet(int exIdx, SessionExercise ex) {
    if (_activeSetIndices.containsKey(exIdx)) {
      final idx = _activeSetIndices[exIdx]!;
      if (idx >= 0 && idx < ex.sets.length) return idx;
    }
    final undone = ex.sets.indexWhere((s) => !s.done);
    return undone != -1 ? undone : (ex.sets.isNotEmpty ? ex.sets.length - 1 : 0);
  }

  String? _lastSetLabel(String exId, int setIdx) {
    final lastSets = fit.lastSetsFor(exId);
    if (lastSets.isEmpty) return null;
    final ex = fit.exerciseById(exId);
    if (ex != null && ex.isCardio) {
      final target = lastSets.first;
      final durSec = target.sec ?? (target.reps > 30 ? target.reps : target.reps * 60);
      final param = target.cardioParam ?? target.weight;
      final mins = (durSec / 60).round();
      final speed = target.speed;
      if (ex.cardioType.hasSpeed && speed != null && speed > 0) {
        return 'semana passada $mins min · ${ex.cardioType.formatSpeedWithUnit(speed)} · ${ex.cardioType.formatParamWithUnit(param)}';
      }
      return 'semana passada $mins min · ${ex.cardioType.formatParamWithUnit(param)}';
    }
    final target = (setIdx < lastSets.length) ? lastSets[setIdx] : lastSets.last;
    return 'semana passada ${fit.weightValue(target.weight)} ${fit.units} × ${target.reps}';
  }

  @override
  Widget build(BuildContext context) {
    if (fit.isSessionComplete && !fit.bodyweightFinishPromptShown) {
      fit.bodyweightFinishPromptShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showBodyweightSheet(context, beforeWorkout: false);
      });
    } else if (!fit.isSessionComplete && !fit.bodyweightStartPromptShown) {
      fit.bodyweightStartPromptShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showBodyweightSheet(context, beforeWorkout: true);
      });
    }

    final gc = context.gc;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SafeArea(
      bottom: false,
      child: fit.isSessionComplete
          ? SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 32 + bottomInset),
              child: _complete(context, gc),
            )
          : _active(context, gc),
    );
  }

  Widget _active(BuildContext context, GymColors gc) {
    final s = fit.session!;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final currentExIdx = s.currentIndex.clamp(0, s.exercises.length - 1);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
          child: _sessionHeader(gc),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => PageView.builder(
              controller: _pageController,
              onPageChanged: (idx) {
                fit.goToExercise(idx);
              },
              itemCount: s.exercises.length,
              itemBuilder: (context, i) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                child: _exercisePage(context, gc, i, constraints),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 16 + bottomInset),
          child: _sessionFooter(gc, currentExIdx),
        ),
      ],
    );
  }

  Widget _sessionHeader(GymColors gc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Chevron down to minimize session
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _confirmExit(context, gc),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: gc.bgRaised,
              shape: BoxShape.circle,
              border: Border.all(color: gc.border),
            ),
            child: Icon(Icons.keyboard_arrow_down_rounded, color: gc.text, size: 24),
          ),
        ),
        // Center floating timer pill
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: fit.toggleSessionPause,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: gc.bgRaised,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: fit.sessionPaused ? gc.ember : gc.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: fit.sessionPaused ? gc.textTertiary : Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  fit.elapsedLabel,
                  style: AppTheme.d(
                    15,
                    weight: FontWeight.w700,
                    color: fit.sessionPaused ? gc.textSecondary : gc.text,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  fit.sessionPaused ? PhosphorIconsFill.play : PhosphorIconsFill.pause,
                  size: 13,
                  color: fit.sessionPaused ? gc.ember : gc.textTertiary,
                ),
              ],
            ),
          ),
        ),
        // Symmetrical balance spacer for centered timer
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _exercisePage(BuildContext context, GymColors gc, int exIdx, [BoxConstraints? constraints]) {
    final s = fit.session!;
    final ex = s.exercises[exIdx];
    final def = fit.exerciseById(ex.id) ?? kExercises.first;
    final isCardio = def.isCardio || ex.primary == 'cardio';
    final displayName = def.localizedName(context).isNotEmpty
        ? def.localizedName(context)
        : (ex.name.isNotEmpty ? FitnessTranslator.translateExerciseName(ex.name) : def.name);

    final activeSetIdx = _getActiveSet(exIdx, ex);
    final st = (activeSetIdx >= 0 && activeSetIdx < ex.sets.length)
        ? ex.sets[activeSetIdx]
        : (ex.sets.isNotEmpty ? ex.sets.first : SessionSet(10, 20.0, false));
    final prevPerf = _lastSetLabel(ex.id, activeSetIdx);

    // Dynamic sizing to maximize GIF while guaranteeing all standard content fits within 1vh (without scrolling)
    // The rest timer card is deliberately excluded from this calculation per design specs.
    double gifSize = 250.0;
    if (constraints != null && constraints.maxHeight.isFinite) {
      final nonGifHeight = 286.0 + (prevPerf != null ? 18.0 : 0.0) + (s.exercises.length > 1 ? 34.0 : 0.0);
      final available = constraints.maxHeight - nonGifHeight;
      final maxW = (constraints.maxWidth - 40.0).clamp(200.0, 310.0);
      gifSize = available.clamp(200.0, maxW);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress bar indicator
        LayoutBuilder(
          builder: (context, constraints) {
            final pct = ((exIdx + 1) / s.exercises.length).clamp(0.0, 1.0);
            return Container(
              height: 3.5,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: gc.bgRaised2,
                borderRadius: BorderRadius.circular(2),
              ),
              alignment: Alignment.centerLeft,
              child: Container(
                width: constraints.maxWidth * pct,
                height: 3.5,
                decoration: BoxDecoration(
                  color: gc.ember,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          },
        ),

        // Subtitle: EXERCÍCIO X DE Y
        Text(
          t.exerciseXofY(exIdx + 1, s.exercises.length).toUpperCase(),
          style: AppTheme.s(
            11,
            weight: FontWeight.w700,
            color: gc.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 3),

        // Title: Exercise Name (Bold, all-caps, impactful)
        Text(
          displayName.toUpperCase(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.d(
            20,
            weight: FontWeight.w800,
            color: gc.text,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),

        // Hero Visual Card (Dynamically sized 1:1 proportion with info button on top right)
        Center(
          child: SizedBox(
            height: gifSize,
            width: gifSize,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showExecutionSheet(context, def),
                      child: ExerciseMedia(
                        ex: def,
                        aspectRatio: 1.0,
                        live: true,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showExecutionSheet(context, def),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.65),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                        ),
                        child: const Icon(
                          PhosphorIconsRegular.info,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        if (isCardio) ...[
          // Header de Cardio: sem séries, exibindo modalidade e status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(PhosphorIconsRegular.heartbeat, size: 20, color: gc.ember),
                  const SizedBox(width: 8),
                  Text(
                    'CARDIO · ${def.cardioType.displayNamePt.toUpperCase()}',
                    style: AppTheme.d(
                      14,
                      weight: FontWeight.w800,
                      color: gc.text,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (st.done) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.check_circle_rounded, size: 16, color: gc.sage),
                  ],
                ],
              ),
              if (st.done)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: gc.sage.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: gc.sage.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    t.done,
                    style: AppTheme.s(11, weight: FontWeight.w700, color: gc.sage),
                  ),
                ),
            ],
          ),
          if (prevPerf != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                prevPerf,
                style: AppTheme.s(12, weight: FontWeight.w500, color: gc.textTertiary),
              ),
            ),
          ],
          const SizedBox(height: 10),
          _cardioStopwatchWidget(gc, exIdx),
          const SizedBox(height: 12),
          _cardioControlBoxes(context, gc, exIdx, activeSetIdx, def, st),
        ] else ...[
          // Set Navigator: < SÉRIE X DE Y > with + Série button and previous performance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      button: true,
                      label: 'Série anterior',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: activeSetIdx > 0
                            ? () => setState(() => _activeSetIndices[exIdx] = activeSetIdx - 1)
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
                          child: Icon(
                            Icons.chevron_left_rounded,
                            size: 24,
                            color: activeSetIdx > 0 ? gc.text : gc.textTertiary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'SÉRIE ${activeSetIdx + 1} DE ${ex.sets.length}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.d(
                          13,
                          weight: FontWeight.w800,
                          color: gc.text,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    if (st.done) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.check_circle_rounded, size: 15, color: gc.sage),
                    ],
                    Semantics(
                      button: true,
                      label: 'Próxima série',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: activeSetIdx < ex.sets.length - 1
                            ? () => setState(() => _activeSetIndices[exIdx] = activeSetIdx + 1)
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 24,
                            color: activeSetIdx < ex.sets.length - 1
                                ? gc.text
                                : gc.textTertiary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Right side: + Série button
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  fit.addSet(exIdx);
                  setState(() => _activeSetIndices[exIdx] = ex.sets.length - 1);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: gc.bgRaised2,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: gc.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 14, color: gc.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        t.addSet,
                        style: AppTheme.s(11, weight: FontWeight.w600, color: gc.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (prevPerf != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                prevPerf,
                style: AppTheme.s(12, weight: FontWeight.w500, color: gc.textTertiary),
              ),
            ),
          ],

          // Rest timer banner (positioned above weight and reps cards)
          if (s.restRemaining != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: gc.bgRaised,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: gc.ember),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIconsRegular.timer, color: gc.ember, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${t.rest}: ${s.restRemaining}s',
                          style: AppTheme.d(15, weight: FontWeight.w700, color: gc.text),
                        ),
                        Text(
                          t.restDefault(fit.restSeconds),
                          style: AppTheme.s(11, color: gc.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  _restNudge(gc, '−15', t.decrease, () => fit.nudgeRest(-15)),
                  const SizedBox(width: 6),
                  _restNudge(gc, '+15', t.increase, () => fit.nudgeRest(15)),
                  const SizedBox(width: 6),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: fit.skipRest,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: gc.bgRaised2,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        t.skip,
                        style: AppTheme.s(12, weight: FontWeight.w700, color: gc.text),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Two large numeric control boxes side-by-side: CARGA & REPETIÇÕES
          Row(
            children: [
              // Left Box: CARGA
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                  decoration: BoxDecoration(
                    color: gc.bgRaised,
                    border: Border.all(color: gc.border),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 18,
                        child: Center(
                          child: Text(
                            t.weightTitle(fit.units.toUpperCase()).toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.s(
                              11,
                              weight: FontWeight.w700,
                              color: gc.textTertiary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _editValue(
                          context,
                          title: t.weightTitle(fit.units.toUpperCase()),
                          initial: fit.weightValue(st.weight),
                          decimal: true,
                          onSave: (v) => fit.setSessionWeightShown(exIdx, activeSetIdx, v),
                        ),
                        child: SizedBox(
                          height: 48,
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    fit.weightValue(st.weight),
                                    style: AppTheme.d(38, weight: FontWeight.w800, color: gc.text, height: 1.0),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  fit.units.toUpperCase(),
                                  style: AppTheme.s(12, weight: FontWeight.w700, color: gc.textTertiary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _stepperBtn(
                              gc,
                              Icons.remove_rounded,
                              () => fit.bumpSessionWeight(exIdx, activeSetIdx, -1),
                            ),
                            _stepperBtn(
                              gc,
                              Icons.add_rounded,
                              () => fit.bumpSessionWeight(exIdx, activeSetIdx, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Right Box: REPETIÇÕES
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                  decoration: BoxDecoration(
                    color: gc.bgRaised,
                    border: Border.all(color: gc.border),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 18,
                        child: Center(
                          child: Text(
                            t.repsTitle.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.s(
                              11,
                              weight: FontWeight.w700,
                              color: gc.textTertiary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _editValue(
                          context,
                          title: t.repsTitle,
                          initial: '${st.reps}',
                          decimal: false,
                          onSave: (v) => fit.setSessionReps(exIdx, activeSetIdx, v.round()),
                        ),
                        child: SizedBox(
                          height: 48,
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${st.reps}',
                                style: AppTheme.d(38, weight: FontWeight.w800, color: gc.text, height: 1.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _stepperBtn(
                              gc,
                              Icons.remove_rounded,
                              () => fit.bumpSessionReps(exIdx, activeSetIdx, -1),
                            ),
                            _stepperBtn(
                              gc,
                              Icons.add_rounded,
                              () => fit.bumpSessionReps(exIdx, activeSetIdx, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],

        // Drop exercise text link below cards
        if (s.exercises.length > 1) ...[
          const SizedBox(height: 8),
          Center(
            child: Semantics(
              button: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _confirmDrop(context, exIdx, displayName),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    t.dropExercise,
                    style: AppTheme.s(12, weight: FontWeight.w600, color: gc.textTertiary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _sessionFooter(GymColors gc, int exIdx) {
    final s = fit.session!;
    final ex = s.exercises.isNotEmpty ? s.exercises[exIdx] : null;
    final def = ex != null ? fit.exerciseById(ex.id) : null;
    final isCardio = (def != null && def.isCardio) || (ex?.primary == 'cardio');
    final activeSetIdx = ex != null ? _getActiveSet(exIdx, ex) : 0;
    final st = (ex != null && activeSetIdx < ex.sets.length) ? ex.sets[activeSetIdx] : null;
    final isDone = st?.done ?? false;
    final allExerciseDone = ex != null && ex.sets.every((set) => set.done);

    final buttonText = isCardio
        ? (isDone
            ? (allExerciseDone
                ? (exIdx < s.exercises.length - 1 ? 'PRÓXIMO EXERCÍCIO' : 'FINALIZAR TREINO')
                : 'CARDIO CONCLUÍDO')
            : 'CONCLUIR CARDIO')
        : (isDone
            ? (allExerciseDone
                ? (exIdx < s.exercises.length - 1 ? 'PRÓXIMO EXERCÍCIO' : 'FINALIZAR TREINO')
                : 'SÉRIE ${activeSetIdx + 1} CONCLUÍDA')
            : 'CONCLUIR SÉRIE ${activeSetIdx + 1}');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Exercise pager switcher: < 1 / 5 >
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: exIdx > 0 ? fit.prevExercise : null,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: exIdx > 0 ? gc.bgRaised : gc.bgRaised2.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: gc.border),
                  ),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    color: exIdx > 0 ? gc.text : gc.textTertiary,
                    size: 22,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${exIdx + 1} / ${s.exercises.length}',
                  style: AppTheme.d(14, weight: FontWeight.w700, color: gc.textSecondary),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: exIdx < s.exercises.length - 1 ? fit.nextExercise : null,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: exIdx < s.exercises.length - 1
                        ? gc.bgRaised
                        : gc.bgRaised2.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: gc.border),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: exIdx < s.exercises.length - 1 ? gc.text : gc.textTertiary,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Big Primary Action Button: Progress Complete Button with Inner Fill Animation
        _ProgressCompleteButton(
          key: ValueKey('complete-btn-$exIdx-$activeSetIdx-$isDone'),
          isDone: isDone,
          text: buttonText.toUpperCase(),
          onComplete: () {
            if (ex == null) return;
            if (isCardio) {
              fit.toggleSet(exIdx, activeSetIdx);
              return;
            }
            fit.toggleSet(exIdx, activeSetIdx);
            if (activeSetIdx + 1 < ex.sets.length) {
              setState(() => _activeSetIndices[exIdx] = activeSetIdx + 1);
            }
          },
          onTapWhenDone: () {
            if (ex == null) return;
            HapticFeedback.lightImpact();
            if (allExerciseDone) {
              if (exIdx < s.exercises.length - 1) {
                fit.nextExercise();
              } else {
                fit.finishSession();
              }
            } else {
              fit.toggleSet(exIdx, activeSetIdx);
            }
          },
        ),
      ],
    );
  }

  Widget _cardioStopwatchWidget(GymColors gc, int exIdx) {
    final sw = _cardioStopwatches[exIdx];
    final isRunning = sw?.isRunning ?? false;
    final elapsedSec = sw?.elapsed.inSeconds ?? 0;
    final timeStr = formatCardioDuration(elapsedSec);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isRunning ? gc.ember : gc.border),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIconsRegular.timer,
            size: 18,
            color: isRunning ? gc.ember : gc.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            'CRONÔMETRO: ',
            style: AppTheme.s(11, weight: FontWeight.w700, color: gc.textSecondary, letterSpacing: 1),
          ),
          Text(
            timeStr,
            style: AppTheme.d(15, weight: FontWeight.w800, color: isRunning ? gc.ember : gc.text),
          ),
          const Spacer(),
          if (elapsedSec > 0) ...[
            GestureDetector(
              onTap: () => _resetCardioStopwatch(exIdx),
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  t.reset,
                  style: AppTheme.s(12, weight: FontWeight.w600, color: gc.textSecondary),
                ),
              ),
            ),
          ],
          GestureDetector(
            onTap: () => _toggleCardioStopwatch(exIdx),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isRunning ? gc.bgRaised2 : gc.ember,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isRunning ? PhosphorIconsFill.pause : PhosphorIconsFill.play,
                    size: 12,
                    color: isRunning ? gc.text : gc.onEmber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isRunning ? 'Pausar' : (elapsedSec > 0 ? 'Continuar' : 'Iniciar'),
                    style: AppTheme.s(
                      11,
                      weight: FontWeight.w700,
                      color: isRunning ? gc.text : gc.onEmber,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardioControlBoxes(
    BuildContext context,
    GymColors gc,
    int exIdx,
    int activeSetIdx,
    Exercise def,
    SessionSet st,
  ) {
    final cardioType = def.cardioType;
    final cardioSeconds = st.effectiveTimeSeconds;
    final cardioParam = st.effectiveCardioParam > 0 ? st.effectiveCardioParam : cardioType.defaultParam;
    final cardioSpeed = st.effectiveCardioSpeed > 0 ? st.effectiveCardioSpeed : cardioType.defaultSpeed;

    return Column(
      children: [
        Row(
          children: [
            // Left Box: TEMPO
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                decoration: BoxDecoration(
                  color: gc.bgRaised,
                  border: Border.all(color: gc.border),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 18,
                      child: Center(
                        child: Text(
                          'TEMPO',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.s(
                            11,
                            weight: FontWeight.w700,
                            color: gc.textTertiary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _editCardioTime(
                        context,
                        title: t.duration,
                        initialSeconds: cardioSeconds,
                        onSave: (sec) => fit.setSessionCardioTime(exIdx, activeSetIdx, sec),
                      ),
                      child: SizedBox(
                        height: 48,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  formatCardioDuration(cardioSeconds),
                                  style: AppTheme.d(34, weight: FontWeight.w800, color: gc.text, height: 1.0),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'min',
                                style: AppTheme.s(11, weight: FontWeight.w700, color: gc.textTertiary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _stepperBtn(
                            gc,
                            Icons.remove_rounded,
                            () => fit.bumpSessionCardioTime(exIdx, activeSetIdx, -60),
                          ),
                          _stepperBtn(
                            gc,
                            Icons.add_rounded,
                            () => fit.bumpSessionCardioTime(exIdx, activeSetIdx, 60),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Right Box: VELOCIDADE (se esteira) ou PARÂMETRO DA MÁQUINA (se outra)
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                decoration: BoxDecoration(
                  color: gc.bgRaised,
                  border: Border.all(color: gc.border),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 18,
                      child: Center(
                        child: Text(
                          cardioType.hasSpeed ? cardioType.speedLabel : cardioType.paramLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.s(
                            11,
                            weight: FontWeight.w700,
                            color: gc.textTertiary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (cardioType.hasSpeed) {
                          _editCardioSpeed(
                            context,
                            initial: cardioSpeed,
                            onSave: (v) => fit.setSessionCardioSpeed(exIdx, activeSetIdx, v),
                          );
                        } else {
                          _editCardioParam(
                            context,
                            title: cardioType.paramLabel,
                            initial: cardioParam,
                            type: cardioType,
                            onSave: (v) => fit.setSessionCardioParam(exIdx, activeSetIdx, v),
                          );
                        }
                      },
                      child: SizedBox(
                        height: 48,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  cardioType.hasSpeed
                                      ? cardioType.formatSpeed(cardioSpeed)
                                      : cardioType.formatParam(cardioParam),
                                  style: AppTheme.d(38, weight: FontWeight.w800, color: gc.text, height: 1.0),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                cardioType.hasSpeed ? cardioType.speedUnit : cardioType.paramUnit,
                                style: AppTheme.s(12, weight: FontWeight.w700, color: gc.textTertiary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _stepperBtn(
                            gc,
                            Icons.remove_rounded,
                            () {
                              if (cardioType.hasSpeed) {
                                fit.bumpSessionCardioSpeed(
                                  exIdx,
                                  activeSetIdx,
                                  -cardioType.speedStep,
                                  min: cardioType.minSpeed,
                                  max: cardioType.maxSpeed,
                                );
                              } else {
                                fit.bumpSessionCardioParam(
                                  exIdx,
                                  activeSetIdx,
                                  -cardioType.paramStep,
                                  min: cardioType.minParam,
                                  max: cardioType.maxParam,
                                );
                              }
                            },
                          ),
                          _stepperBtn(
                            gc,
                            Icons.add_rounded,
                            () {
                              if (cardioType.hasSpeed) {
                                fit.bumpSessionCardioSpeed(
                                  exIdx,
                                  activeSetIdx,
                                  cardioType.speedStep,
                                  min: cardioType.minSpeed,
                                  max: cardioType.maxSpeed,
                                );
                              } else {
                                fit.bumpSessionCardioParam(
                                  exIdx,
                                  activeSetIdx,
                                  cardioType.paramStep,
                                  min: cardioType.minParam,
                                  max: cardioType.maxParam,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Faixa de INCLINAÇÃO dedicada caso seja Esteira
        if (cardioType.hasSpeed) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: gc.bgRaised,
              border: Border.all(color: gc.border),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(PhosphorIconsRegular.trendUp, size: 20, color: gc.accent),
                const SizedBox(width: 10),
                Text(
                  cardioType.paramLabel,
                  style: AppTheme.s(
                    11,
                    weight: FontWeight.w700,
                    color: gc.textTertiary,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                _stepperBtn(
                  gc,
                  Icons.remove_rounded,
                  () => fit.bumpSessionCardioParam(
                    exIdx,
                    activeSetIdx,
                    -cardioType.paramStep,
                    min: cardioType.minParam,
                    max: cardioType.maxParam,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _editCardioParam(
                    context,
                    title: cardioType.paramLabel,
                    initial: cardioParam,
                    type: cardioType,
                    onSave: (v) => fit.setSessionCardioParam(exIdx, activeSetIdx, v),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 64),
                    alignment: Alignment.center,
                    child: Text(
                      '${cardioType.formatParam(cardioParam)}%',
                      style: AppTheme.d(22, weight: FontWeight.w800, color: gc.text),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _stepperBtn(
                  gc,
                  Icons.add_rounded,
                  () => fit.bumpSessionCardioParam(
                    exIdx,
                    activeSetIdx,
                    cardioType.paramStep,
                    min: cardioType.minParam,
                    max: cardioType.maxParam,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _editCardioSpeed(
    BuildContext context, {
    required double initial,
    required ValueChanged<double> onSave,
  }) async {
    final gc = context.gc;
    final initialStr = (initial % 1 == 0) ? '${initial.toInt()}' : initial.toStringAsFixed(1);
    final controller = TextEditingController(text: initialStr)
      ..selection = TextSelection(baseOffset: 0, extentOffset: initialStr.length);

    String? raw;
    try {
      raw = await showAppDialog<String>(
        context: context,
        builder: (dctx) => AlertDialog(
          backgroundColor: gc.bgRaised,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: gc.border),
          ),
          title: Text(
            'VELOCIDADE',
            style: AppTheme.d(14, weight: FontWeight.w700, color: gc.text, letterSpacing: 2),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: AppTheme.d(32, weight: FontWeight.w700, color: gc.text),
            cursorColor: gc.accent,
            onSubmitted: (v) => Navigator.of(dctx).pop(v),
            decoration: InputDecoration(
              filled: true,
              fillColor: gc.bgRaised2,
              suffixText: 'km/h',
              suffixStyle: AppTheme.s(14, color: gc.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(),
              child: Text(t.cancel, style: AppTheme.s(14, color: gc.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(controller.text),
              child: Text(t.set, style: AppTheme.s(14, weight: FontWeight.w700, color: gc.accent)),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }

    if (raw != null) {
      final parsed = double.tryParse(raw.trim().replaceAll(',', '.'));
      if (parsed != null && parsed >= 0.1 && parsed <= 50.0) {
        onSave((parsed * 10).round() / 10);
      }
    }
  }

  Future<void> _editCardioTime(
    BuildContext context, {
    required String title,
    required int initialSeconds,
    required ValueChanged<int> onSave,
  }) async {
    final gc = context.gc;
    final initialMinutes = (initialSeconds / 60).round();
    final controller = TextEditingController(text: '$initialMinutes')
      ..selection = TextSelection(baseOffset: 0, extentOffset: '$initialMinutes'.length);

    String? raw;
    try {
      raw = await showAppDialog<String>(
        context: context,
        builder: (dctx) => AlertDialog(
          backgroundColor: gc.bgRaised,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: gc.border),
          ),
          title: Text(
            title,
            style: AppTheme.d(14, weight: FontWeight.w700, color: gc.text, letterSpacing: 2),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: AppTheme.d(32, weight: FontWeight.w700, color: gc.text),
            cursorColor: gc.accent,
            onSubmitted: (v) => Navigator.of(dctx).pop(v),
            decoration: InputDecoration(
              filled: true,
              fillColor: gc.bgRaised2,
              suffixText: 'MIN',
              suffixStyle: AppTheme.s(14, color: gc.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(),
              child: Text(t.cancel, style: AppTheme.s(14, color: gc.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(controller.text),
              child: Text(t.set, style: AppTheme.s(14, weight: FontWeight.w700, color: gc.accent)),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }

    if (raw != null) {
      final parsed = int.tryParse(raw.trim());
      if (parsed != null && parsed > 0) {
        onSave(parsed * 60);
      }
    }
  }

  Future<void> _editCardioParam(
    BuildContext context, {
    required String title,
    required double initial,
    required CardioCategoryType type,
    required ValueChanged<double> onSave,
  }) async {
    final gc = context.gc;
    final isDecimal = type == CardioCategoryType.treadmill;
    final controller = TextEditingController(text: type.formatParam(initial))
      ..selection = TextSelection(baseOffset: 0, extentOffset: type.formatParam(initial).length);

    String? raw;
    try {
      raw = await showAppDialog<String>(
        context: context,
        builder: (dctx) => AlertDialog(
          backgroundColor: gc.bgRaised,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: gc.border),
          ),
          title: Text(
            title,
            style: AppTheme.d(14, weight: FontWeight.w700, color: gc.text, letterSpacing: 2),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
            textAlign: TextAlign.center,
            style: AppTheme.d(32, weight: FontWeight.w700, color: gc.text),
            cursorColor: gc.accent,
            onSubmitted: (v) => Navigator.of(dctx).pop(v),
            decoration: InputDecoration(
              filled: true,
              fillColor: gc.bgRaised2,
              suffixText: type.paramUnit,
              suffixStyle: AppTheme.s(14, color: gc.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(),
              child: Text(t.cancel, style: AppTheme.s(14, color: gc.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(controller.text),
              child: Text(t.set, style: AppTheme.s(14, weight: FontWeight.w700, color: gc.accent)),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }

    if (raw != null) {
      final parsed = double.tryParse(raw.trim().replaceAll(',', '.'));
      if (parsed != null) {
        onSave(_round1(parsed.clamp(type.minParam, type.maxParam)));
      }
    }
  }

  static double _round1(double v) => (v * 10).round() / 10;

  Widget _stepperBtn(GymColors gc, IconData icon, VoidCallback onTap) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 38,
          child: Center(
            child: Icon(icon, color: gc.text, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _restNudge(GymColors gc, String glyph, String semantic, VoidCallback onTap) {
    return Semantics(
      button: true,
      label: semantic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: gc.bgRaised2,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            glyph,
            style: AppTheme.s(12, weight: FontWeight.w600, color: gc.text),
          ),
        ),
      ),
    );
  }

  void _showExecutionSheet(BuildContext context, Exercise def) {
    final gc = context.gc;
    showAppSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: gc.bgRaised,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bctx) {
        final steps = def.instructionsPt.isNotEmpty ? def.instructionsPt : def.instructions;
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (sctx, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: gc.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            def.localizedName(context),
                            style: AppTheme.d(22, weight: FontWeight.w700, color: gc.text),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: gc.emberSoft,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              def.getLocalizedTarget(context),
                              style: AppTheme.s(12, weight: FontWeight.w600, color: gc.ember),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: gc.textSecondary),
                      onPressed: () => Navigator.of(bctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: Colors.white,
                    child: ExerciseMedia(ex: def, height: 240, live: true),
                  ),
                ),
                if (steps.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'EXECUÇÃO PASSO A PASSO',
                    style: AppTheme.d(
                      13,
                      weight: FontWeight.w700,
                      color: gc.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (int i = 0; i < steps.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: gc.accentSoft,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${i + 1}',
                              style: AppTheme.s(12, weight: FontWeight.w700, color: gc.accent),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              steps[i],
                              style: AppTheme.s(14, color: gc.text, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Voltar ao Treino',
                  onTap: () => Navigator.of(bctx).pop(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmExit(BuildContext context, GymColors gc) async {
    await showAppSheet<void>(
      context: context,
      backgroundColor: gc.bgRaised,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: gc.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Opções da Sessão',
              style: AppTheme.d(20, weight: FontWeight.w700, color: gc.text),
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha como deseja prosseguir com seu treino em andamento.',
              style: AppTheme.s(13, color: gc.textSecondary),
            ),
            const SizedBox(height: 18),
            ListTile(
              leading: Icon(Icons.arrow_downward_rounded, color: gc.text),
              title: Text(
                'Minimizar Treino',
                style: AppTheme.s(15, weight: FontWeight.w600, color: gc.text),
              ),
              subtitle: Text(
                'Continua contando o tempo enquanto você navega no app',
                style: AppTheme.s(12, color: gc.textTertiary),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: gc.bgRaised2,
              onTap: () {
                Navigator.of(bctx).pop();
                fit.goHome();
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.check_circle_outline_rounded, color: gc.accent),
              title: Text(
                t.finishSession,
                style: AppTheme.s(15, weight: FontWeight.w600, color: gc.accent),
              ),
              subtitle: Text(
                'Salva suas séries e exibe o resumo completo',
                style: AppTheme.s(12, color: gc.textTertiary),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: gc.bgRaised2,
              onTap: () {
                Navigator.of(bctx).pop();
                fit.finishSession();
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: gc.ember),
              title: Text(
                'Descartar Treino',
                style: AppTheme.s(15, weight: FontWeight.w600, color: gc.ember),
              ),
              subtitle: Text(
                'Cancela a sessão sem salvar no histórico',
                style: AppTheme.s(12, color: gc.textTertiary),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: gc.bgRaised2,
              onTap: () async {
                Navigator.of(bctx).pop();
                final ok = await showAppDialog<bool>(
                  context: context,
                  builder: (dctx) => AlertDialog(
                    backgroundColor: gc.bgRaised,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text(
                      'Descartar treino?',
                      style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text),
                    ),
                    content: Text(
                      'Todo o progresso desta sessão será perdido.',
                      style: AppTheme.s(13, color: gc.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dctx).pop(false),
                        child: Text(t.cancel, style: AppTheme.s(14, color: gc.textSecondary)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(dctx).pop(true),
                        child: Text(
                          'Descartar',
                          style: AppTheme.s(14, weight: FontWeight.w700, color: gc.ember),
                        ),
                      ),
                    ],
                  ),
                );
                if (ok == true) fit.discardSession();
              },
            ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDrop(BuildContext context, int exIdx, String name) async {
    final gc = context.gc;
    final ok = await showAppDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        backgroundColor: gc.bgRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t.dropExercise, style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text)),
        content: Text(t.dropExerciseBody(name), style: AppTheme.s(13, color: gc.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(false),
            child: Text(t.cancel, style: AppTheme.s(14, color: gc.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(true),
            child: Text(t.drop, style: AppTheme.s(14, weight: FontWeight.w700, color: gc.accent)),
          ),
        ],
      ),
    );
    if (ok == true) fit.removeSessionExercise(exIdx);
  }

  Future<void> _editValue(
    BuildContext context, {
    required String title,
    required String initial,
    required bool decimal,
    required void Function(double) onSave,
  }) async {
    final gc = context.gc;
    final controller = TextEditingController(text: initial)
      ..selection = TextSelection(baseOffset: 0, extentOffset: initial.length);

    String? raw;
    try {
      raw = await showAppDialog<String>(
        context: context,
        builder: (dctx) => AlertDialog(
          backgroundColor: gc.bgRaised,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            title,
            style: AppTheme.d(14, weight: FontWeight.w700, color: gc.text, letterSpacing: 2),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.numberWithOptions(decimal: decimal),
            textAlign: TextAlign.center,
            style: AppTheme.d(32, weight: FontWeight.w700, color: gc.text),
            cursorColor: gc.accent,
            onSubmitted: (v) => Navigator.of(dctx).pop(v),
            decoration: InputDecoration(
              filled: true,
              fillColor: gc.bgRaised2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(),
              child: Text(t.cancel, style: AppTheme.s(14, color: gc.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(controller.text),
              child: Text(t.set, style: AppTheme.s(14, weight: FontWeight.w700, color: gc.accent)),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }

    final parsed = double.tryParse((raw ?? '').trim().replaceAll(',', '.'));
    if (parsed != null) onSave(parsed);
  }

  Widget _complete(BuildContext context, GymColors gc) {
    final prs = fit.summaryPrs;
    final streak = fit.currentStreak;
    final goalHit = fit.goalPct >= 100;
    final vsLast = fit.summaryVsLast;
    final vol = fit.summaryVolumeKg;
    final beforeWeight = fit.session?.bodyweightBeforeKg;
    final afterWeight = fit.session?.bodyweightAfterKg;

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Rise(index: 0, child: _finishHero(gc, prs: prs, streak: streak, goalHit: goalHit)),
          const SizedBox(height: 18),
          Rise(
            index: 1,
            child: Row(
              children: [
                Expanded(child: _sumCard(gc, t.duration, fit.summaryDurationLabel)),
                const SizedBox(width: 10),
                Expanded(child: _sumCard(gc, t.setsCaps, '${fit.session?.summarySets ?? 0}')),
                const SizedBox(width: 10),
                Expanded(child: _sumCard(gc, t.volume, fit.volumeLabel(vol))),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Rise(
            index: 2,
            child: (vsLast != null && vsLast > 0) ? _vsLastCard(gc, vol, vsLast) : _firstTimeCard(gc),
          ),
          if (beforeWeight != null && afterWeight != null) ...[
            const SizedBox(height: 18),
            Rise(index: 3, child: _bodyweightComparison(gc, beforeWeight, afterWeight)),
          ],
          const SizedBox(height: 18),
          Rise(
            index: 4,
            child: OutlinedButton.icon(
              onPressed: () {
                final durStr = fit.summaryDurationLabel;
                final prCount = prs;
                final volKg = vol;
                final durSec = fit.session?.summaryDuration ?? 0;
                final durationMins = durSec > 0 ? (durSec / 60).round() : 30;
                final calories = (durationMins * 5 + volKg * 0.02).round().clamp(20, 2000);
                final muscles = fit.activeRoutine?.name ?? 'Treino Completo';

                String? photoData = fit.session?.photosAfter.lastOrNull ??
                    fit.session?.photosBefore.lastOrNull ??
                    (fit.sessions.isNotEmpty ? fit.sessions.last.photosAfter.lastOrNull : null) ??
                    (fit.sessions.isNotEmpty ? fit.sessions.last.photosBefore.lastOrNull : null);

                final isPath = photoData != null &&
                    (photoData.startsWith('/') ||
                        photoData.startsWith('file://') ||
                        (photoData.length > 2 && photoData[1] == ':'));

                var cleanPath = photoData?.replaceFirst('file://', '');
                if (cleanPath != null && Platform.isWindows && cleanPath.startsWith('/') && cleanPath.length > 2 && cleanPath[2] == ':') {
                  cleanPath = cleanPath.substring(1);
                }

                showSharePhotoSheet(
                  context,
                  durationStr: durStr,
                  prCount: prCount,
                  volumeKg: volKg,
                  calories: calories,
                  muscleGroupsStr: muscles,
                  initialImagePath: isPath ? cleanPath : null,
                  initialImageBase64: !isPath ? photoData : null,
                );
              },
              icon: Icon(Icons.camera_alt, size: 18, color: gc.accent),
              label: Text(
                'Compartilhar Foto',
                style: AppTheme.s(14, weight: FontWeight.w700, color: gc.text),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: gc.accent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Rise(index: 5, child: PrimaryButton(label: t.saveAndExit, onTap: fit.saveAndExit)),
        ],
      ),
    );
  }

  Widget _bodyweightComparison(GymColors gc, double before, double after) {
    final delta = after - before;
    final percent = before == 0 ? 0 : (delta / before) * 100;
    final color = delta <= 0 ? gc.sage : gc.accent;
    final sign = delta > 0 ? '+' : '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        border: Border.all(color: gc.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.bodyweightComparison,
            style: AppTheme.d(12, weight: FontWeight.w600, color: gc.textSecondary, letterSpacing: 2),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _weightPoint(gc, t.bodyweightBeforeWorkout, before)),
              Text('→', style: AppTheme.d(20, weight: FontWeight.w700, color: gc.textTertiary)),
              Expanded(child: _weightPoint(gc, t.bodyweightAfterWorkout, after, alignEnd: true)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$sign${fmt(fit.toDisplayWeight(delta))} ${fit.units} · $sign${fmt(percent)}%',
            style: AppTheme.s(14, weight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _weightPoint(GymColors gc, String label, double kg, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.s(10, weight: FontWeight.w600, color: gc.textTertiary, letterSpacing: 1),
        ),
        const SizedBox(height: 3),
        Text(fit.weightLabel(kg), style: AppTheme.d(20, weight: FontWeight.w700, color: gc.text)),
      ],
    );
  }

  Widget _finishHero(GymColors gc, {required int prs, required int streak, required bool goalHit}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: gc.bgRaised,
          border: Border.all(color: prs > 0 ? gc.accent : gc.border),
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
                opacity: 0.45,
                child: Image.asset('assets/img/runner.png', fit: BoxFit.fitHeight),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        t.sessionComplete,
                        style: AppTheme.d(11, weight: FontWeight.w600, color: gc.brass, letterSpacing: 3),
                      ),
                      if (prs > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration:
                              BoxDecoration(color: gc.accentSoft, borderRadius: BorderRadius.circular(100)),
                          child: Text(
                            t.prCount(prs),
                            style: AppTheme.s(10, weight: FontWeight.w700, color: gc.accent),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 210),
                    child: Text(
                      t.finishHeadline(prs: prs, streak: streak, goalHit: goalHit),
                      style: AppTheme.d(28, weight: FontWeight.w700, color: gc.text, height: 1.05),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 230),
                    child: Text(
                      t.finishBody(prs: prs, streak: streak, goalHit: goalHit),
                      style: AppTheme.s(13, color: gc.textSecondary, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vsLastCard(GymColors gc, double now, double before) {
    final diff = now - before;
    final up = diff >= 0;
    final pct = ((diff / before) * 100).round();
    return SoftCard(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SvgPathIcon(Ic.trendUp, size: 16, color: up ? gc.sage : gc.textTertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t.vsLastTime,
              style: AppTheme.s(11, weight: FontWeight.w600, color: gc.textSecondary, letterSpacing: 1),
            ),
          ),
          Text(
            '${up ? '+' : ''}$pct%',
            style: AppTheme.d(16, weight: FontWeight.w700, color: up ? gc.sage : gc.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _firstTimeCard(GymColors gc) {
    return SoftCard(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SvgPathIcon(Ic.flame, size: 16, color: gc.accent),
          const SizedBox(width: 12),
          Expanded(child: Text(t.firstTime, style: AppTheme.s(13, color: gc.textSecondary))),
        ],
      ),
    );
  }

  Widget _sumCard(GymColors gc, String label, String value) {
    return SoftCard(
      radius: 16,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.s(10, weight: FontWeight.w600, color: gc.textSecondary, letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text)),
        ],
      ),
    );
  }
}

class _ProgressCompleteButton extends StatefulWidget {
  const _ProgressCompleteButton({
    super.key,
    required this.isDone,
    required this.text,
    required this.onComplete,
    this.onTapWhenDone,
  });

  final bool isDone;
  final String text;
  final VoidCallback onComplete;
  final VoidCallback? onTapWhenDone;

  @override
  State<_ProgressCompleteButton> createState() => _ProgressCompleteButtonState();
}

class _ProgressCompleteButtonState extends State<_ProgressCompleteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _completedTriggered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_completedTriggered) {
        _completedTriggered = true;
        HapticFeedback.mediumImpact();
        widget.onComplete();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _ProgressCompleteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDone != oldWidget.isDone) {
      _completedTriggered = false;
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startFill() {
    if (widget.isDone || _completedTriggered || _controller.isAnimating) return;
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
    _controller.forward(from: 0.0);
  }

  void _onTapDown(TapDownDetails details) {
    _startFill();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    if (widget.isDone) {
      widget.onTapWhenDone?.call();
    }
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    if (widget.isDone || _completedTriggered) return;
    _controller.reverse();
  }

  void _onTap() {
    setState(() => _isPressed = false);
    if (widget.isDone) {
      widget.onTapWhenDone?.call();
      return;
    }
    if (!_completedTriggered && !_controller.isAnimating) {
      _startFill();
    }
  }

  Widget _buildContent({
    required IconData icon,
    required Color iconColor,
    required Color textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Text(
          widget.text,
          style: AppTheme.d(
            16,
            weight: FontWeight.w700,
            color: textColor,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;

    if (widget.isDone) {
      return Semantics(
        button: true,
        label: widget.text,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTapWhenDone,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: gc.bgRaised2,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: gc.border),
            ),
            alignment: Alignment.center,
            child: _buildContent(
              icon: Icons.check_circle_rounded,
              iconColor: gc.accent,
              textColor: gc.text,
            ),
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      label: widget.text,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.985 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              final progress = _animation.value;
              final isAnimating = progress > 0.0;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  final progressWidth = totalWidth * progress;

                  if (!isAnimating) {
                    return Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: gc.ember,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: gc.ember),
                      ),
                      alignment: Alignment.center,
                      child: _buildContent(
                        icon: Icons.check_rounded,
                        iconColor: gc.onEmber,
                        textColor: gc.onEmber,
                      ),
                    );
                  }

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: gc.bgRaised2,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: gc.accent.withValues(alpha: 0.7),
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Base layer: dark track with light text
                          Positioned.fill(
                            child: Center(
                              child: _buildContent(
                                icon: Icons.check_rounded,
                                iconColor: gc.accent,
                                textColor: gc.text,
                              ),
                            ),
                          ),

                          // Fill layer: lime green progress bar filling from left to right
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: progressWidth,
                            child: ClipRect(
                              child: Container(
                                width: totalWidth,
                                decoration: BoxDecoration(
                                  color: gc.accent,
                                ),
                                child: OverflowBox(
                                  alignment: Alignment.centerLeft,
                                  minWidth: totalWidth,
                                  maxWidth: totalWidth,
                                  minHeight: 56,
                                  maxHeight: 56,
                                  child: Center(
                                    child: _buildContent(
                                      icon: Icons.check_rounded,
                                      iconColor: Colors.black,
                                      textColor: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
