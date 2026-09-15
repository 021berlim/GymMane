import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../catalog/exercise_catalog.dart';
import '../l10n/l10n.dart';
import '../models/exercise.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/body_map.dart';
import '../widgets/exercise_media.dart';
import '../widgets/svg_icon.dart';
import '../widgets/ui_kit.dart';
import 'exercises_screen.dart' show showCreateExerciseSheet;

class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _q = '';
  String? _muscleFilter;
  String? _difficultyFilter;
  bool _favouritesOnly = false;

  bool get _hasActiveFilters =>
      _q.isNotEmpty || _muscleFilter != null || _difficultyFilter != null || _favouritesOnly;

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() {
      _q = '';
      _muscleFilter = null;
      _difficultyFilter = null;
      _favouritesOnly = false;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final review = fit.trainStep == 'review';
    final choosingRoutine = fit.route == 'routine-choice';
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RoundBtn(icon: Ic.closeThin, onTap: fit.closeTrain),
                Text(choosingRoutine ? t.chooseRoutineTitle : t.train,
                  style: AppTheme.d(16, weight: FontWeight.w700, color: gc.text, letterSpacing: 2)),
                const SizedBox(width: 36),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: choosingRoutine ? _routineChoice(gc) : review ? _review(context, gc) : _select(context, gc),
            ),
          ),
          if (review) _startBar(context, gc),
        ],
      ),
    );
  }

  Widget _routineChoice(GymColors gc) {
    final routines = fit.routines.where((routine) => routine.exerciseIds.isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.chooseRoutineTitle, style: AppTheme.d(26, weight: FontWeight.w700, color: gc.text, letterSpacing: 1)),
        const SizedBox(height: 8),
        Text(t.chooseRoutineBody, style: AppTheme.s(14, color: gc.textSecondary, height: 1.4)),
        const SizedBox(height: 20),
        for (final routine in routines) ...[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => fit.startRoutine(routine),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: gc.bgRaised,
                border: Border.all(color: gc.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fit.routineTitle(routine), style: AppTheme.s(15, weight: FontWeight.w600, color: gc.text)),
                        const SizedBox(height: 3),
                        Text(
                          fit.todayRoutine?.id == routine.id
                              ? '${t.todaysRoutine} · ${t.exerciseCount(routine.exerciseIds.length)}'
                              : t.exerciseCount(routine.exerciseIds.length),
                          style: AppTheme.s(12, color: gc.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  SvgPathIcon(Ic.chevronRight, size: 18, color: gc.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 8),
        PrimaryButton(
          label: t.logWorkout,
          bg: gc.accent,
          fg: gc.onEmber,
          onTap: () => fit.openRoutine(fit.createRoutine()),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: t.customWorkout,
          bg: gc.bgRaised2,
          fg: gc.text,
          onTap: fit.startCustomWorkout,
        ),
      ],
    );
  }

  Widget _startBar(BuildContext context, GymColors gc) {
    final n = fit.sessionPicks.length;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        border: Border(top: BorderSide(color: gc.border)),
      ),
      child: PrimaryButton(
        label: n == 0 ? t.pickAnExercise : t.startCount(n),
        bg: n == 0 ? gc.bgRaised2 : gc.ember,
        fg: n == 0 ? gc.textTertiary : gc.onEmber,
        onTap: fit.startSession,
      ),
    );
  }

  Widget _select(BuildContext context, GymColors gc) {
    final hasSel = fit.selectedMuscles.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.step1, style: AppTheme.d(11, weight: FontWeight.w600, color: gc.brass, letterSpacing: 3)),
        const SizedBox(height: 4),
        Text(t.chooseFocus, style: AppTheme.d(26, weight: FontWeight.w700, color: gc.text, letterSpacing: 1)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: gc.bgRaised,
            border: Border.all(color: gc.border),
            borderRadius: BorderRadius.circular(24),
          ),
          child: BodyMap(
            selected: fit.selectedMuscles.toSet(),
            onToggle: fit.toggleMuscle,
          ),
        ),
        const SizedBox(height: 6),
        Text(t.tapMuscles,
            textAlign: TextAlign.center, style: AppTheme.s(12, color: gc.textTertiary)),
        const SizedBox(height: 14),
        Container(
          constraints: const BoxConstraints(minHeight: 38),
          alignment: Alignment.centerLeft,
          child: hasSel
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final id in fit.selectedMuscles) _chip(gc, id)],
                )
              : Text(t.noMusclesYet,
                  style: AppTheme.s(13, color: gc.textTertiary)),
        ),
        if (!hasSel && fit.focusRecommendations.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(t.recommended,
              style: AppTheme.d(12, weight: FontWeight.w600, color: gc.textSecondary, letterSpacing: 3)),
          const SizedBox(height: 12),
          for (final ex in fit.focusRecommendations.take(3)) ...[
            _pickRow(gc, ex),
            const SizedBox(height: 10),
          ],
        ],
        const SizedBox(height: 18),
        PrimaryButton(
          label: t.continueBtn,
          bg: hasSel ? gc.ember : gc.bgRaised2,
          fg: hasSel ? gc.onEmber : gc.textTertiary,
          onTap: fit.trainContinue,
        ),
      ],
    );
  }

  Widget _chip(GymColors gc, String id) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: gc.emberSoft, borderRadius: BorderRadius.circular(100)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(t.muscle(id), style: AppTheme.s(13, weight: FontWeight.w600, color: gc.ember)),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => fit.toggleMuscle(id),
          child: SvgPathIcon(Ic.closeThin, size: 12, color: gc.ember),
        ),
      ]),
    );
  }

  List<Exercise> get _reviewFilteredExercises {
    final q = _q.trim().toLowerCase();
    List<Exercise> base;
    if (_hasActiveFilters) {
      base = fit.allExercises;
    } else {
      base = fit.reviewExercises();
    }
    return base.where((ex) {
      if (_favouritesOnly && fit.favorites[ex.id] != true) return false;
      if (q.isNotEmpty &&
          !ex.name.toLowerCase().contains(q) &&
          !exerciseName(ex).toLowerCase().contains(q)) {
        return false;
      }
      if (_muscleFilter != null &&
          ex.primary != _muscleFilter &&
          !ex.secondary.contains(_muscleFilter)) {
        return false;
      }
      if (_difficultyFilter != null && ex.difficulty != _difficultyFilter) return false;
      return true;
    }).toList();
  }

  Widget _review(BuildContext context, GymColors gc) {
    final activeFilters = _hasActiveFilters;
    final exercises = _reviewFilteredExercises;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: fit.trainBack,
              child: SvgPathIcon(Ic.chevronLeft, size: 20, color: gc.textSecondary),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.step2, style: AppTheme.d(11, weight: FontWeight.w600, color: gc.brass, letterSpacing: 3)),
                Text(t.buildSession, style: AppTheme.d(20, weight: FontWeight.w700, color: gc.text)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        _searchRow(context, gc),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _favouritesOnly = !_favouritesOnly),
                child: Container(
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _favouritesOnly ? gc.accentSoft : Colors.transparent,
                    border: Border.all(color: _favouritesOnly ? gc.accent : gc.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _star(gc, _favouritesOnly),
                      const SizedBox(width: 6),
                      Text(
                        fit.favouriteCount > 0
                            ? '${t.favouritesOnly.toUpperCase()} (${fit.favouriteCount})'
                            : t.favouritesOnly.toUpperCase(),
                        style: AppTheme.d(11,
                            weight: FontWeight.w600,
                            color: _favouritesOnly ? gc.accent : gc.text,
                            letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (activeFilters) ...[
              const SizedBox(width: 10),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _clearSearch,
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: gc.border),
                  ),
                  child: Text(t.clearFilters,
                      style: AppTheme.s(12, weight: FontWeight.w600, color: gc.accent)),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        _filterLabel(gc, t.muscleFilter),
        const SizedBox(height: 6),
        _chipRow([
          for (final id in kFilterMuscles)
            _FilterChipData(muscleLabel(id), _muscleFilter == id,
                () => setState(() => _muscleFilter = _muscleFilter == id ? null : id)),
        ], gc, hPad: 12, vPad: 6, fontSize: 12),
        const SizedBox(height: 10),
        _filterLabel(gc, t.levelFilter),
        const SizedBox(height: 6),
        _chipRow([
          for (final d in kDifficulties)
            _FilterChipData(t.difficulty(d), _difficultyFilter == d,
                () => setState(() => _difficultyFilter = _difficultyFilter == d ? null : d)),
        ], gc, hPad: 10, vPad: 5, fontSize: 11),
        const SizedBox(height: 14),
        if (!activeFilters && exercises.isNotEmpty) ...[
          Text(t.pickedHint(exercises.length),
              style: AppTheme.s(12, color: gc.textTertiary)),
          const SizedBox(height: 12),
        ],
        if (exercises.isEmpty)
          _emptyReview(context, gc, activeFilters)
        else
          for (final ex in exercises) ...[
            _pickRow(gc, ex),
            const SizedBox(height: 10),
          ],
      ],
    );
  }

  Widget _searchRow(BuildContext context, GymColors gc) {
    final hasQuery = _q.isNotEmpty;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: gc.bgRaised,
              border: Border.all(color: gc.border),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(children: [
              SvgPathIcon(Ic.search, size: 16, color: gc.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _q = v),
                  style: AppTheme.s(14, color: gc.text),
                  cursorColor: gc.accent,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: t.searchAllExercises,
                    hintStyle: AppTheme.s(14, color: gc.textSecondary),
                  ),
                ),
              ),
              if (hasQuery)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _clearSearch,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: SvgPathIcon(Ic.closeThin, size: 14, color: gc.textSecondary),
                  ),
                ),
            ]),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => showCreateExerciseSheet(context, onCreated: (id) {
            fit.togglePick(id);
            _clearSearch();
          }),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: gc.emberSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: gc.border),
            ),
            child: Icon(PhosphorIconsRegular.plus, size: 20, color: gc.ember),
          ),
        ),
      ],
    );
  }

  Widget _emptyReview(BuildContext context, GymColors gc, bool searching) {
    if (searching) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
        child: Column(
          children: [
            Text(t.noExercisesMatch,
                style: AppTheme.s(15, weight: FontWeight.w600, color: gc.text)),
            const SizedBox(height: 10),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => showCreateExerciseSheet(context, onCreated: (id) {
                fit.togglePick(id);
                _clearSearch();
              }),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(t.createItInstead,
                    style: AppTheme.s(13, weight: FontWeight.w600, color: gc.accent)),
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 8),
      child: Column(
        children: [
          Text(t.nothingForFocus,
              style: AppTheme.s(15, weight: FontWeight.w600, color: gc.text)),
          const SizedBox(height: 4),
          Text(t.goBackPick,
              textAlign: TextAlign.center, style: AppTheme.s(13, color: gc.textSecondary)),
        ],
      ),
    );
  }

  Widget _pickRow(GymColors gc, Exercise ex) {
    final picked = fit.isPicked(ex.id);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => fit.togglePick(ex.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: gc.bgRaised,
          border: Border.all(color: picked ? gc.ember : gc.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          SizedBox(width: 44, child: ExerciseMedia(ex: ex, height: 44, radius: 12)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exerciseName(ex), style: AppTheme.s(14, weight: FontWeight.w600, color: gc.text)),
                const SizedBox(height: 2),
                Text(fit.lastSummaryFor(ex.id) ?? muscleLabel(ex.primary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.s(12, color: gc.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: picked ? gc.ember : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: picked ? gc.ember : gc.border, width: 2),
            ),
            child: picked ? Center(child: SvgPathIcon(Ic.checkBold, size: 13, color: gc.onEmber)) : null,
          ),
        ]),
      ),
    );
  }

  Widget _star(GymColors gc, bool fav) {
    return SizedBox(
      width: 16,
      height: 16,
      child: Stack(children: [
        if (fav) SvgPathIcon(const [IconPath('M12 2l3.09 6.26L22 9.27l-5 4.87L18.18 21 12 17.77 5.82 21 7 14.14l-5-4.87 6.91-1.01z', fill: true)], size: 16, color: gc.accent),
        SvgPathIcon(Ic.star, size: 16, color: fav ? gc.accent : gc.textTertiary),
      ]),
    );
  }

  Widget _filterLabel(GymColors gc, String text) =>
      Text(text, style: AppTheme.s(10, weight: FontWeight.w700, color: gc.textTertiary, letterSpacing: 1.5));

  Widget _chipRow(List<_FilterChipData> chips, GymColors gc,
      {required double hPad, required double vPad, required double fontSize}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (int i = 0; i < chips.length; i++) ...[
          Pill(
            label: chips[i].label,
            bg: chips[i].active ? gc.ember : gc.bgRaised2,
            fg: chips[i].active ? gc.onEmber : gc.textSecondary,
            onTap: chips[i].onTap,
            hPad: hPad,
            vPad: vPad,
            fontSize: fontSize,
          ),
          if (i < chips.length - 1) const SizedBox(width: 6),
        ],
      ]),
    );
  }
}

class _FilterChipData {
  _FilterChipData(this.label, this.active, this.onTap);
  final String label;
  final bool active;
  final VoidCallback onTap;
}
