import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../catalog/exercise_catalog.dart';
import '../l10n/l10n.dart';
import '../models/exercise.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/body_map.dart';
import '../widgets/exercise_category_widgets.dart';
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
  int _trainTab = 0; // 0: Por Músculo, 1: Equipamentos, 2: Favoritos
  String? _selectedMuscle;
  String? _selectedEquipment;

  bool get _isSearching => _q.trim().isNotEmpty;
  bool get _isCategorySelected => _selectedMuscle != null || _selectedEquipment != null;

  void _clearCategory() {
    setState(() {
      _selectedMuscle = null;
      _selectedEquipment = null;
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() {
      _q = '';
      _selectedMuscle = null;
      _selectedEquipment = null;
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
            child: choosingRoutine
                ? SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: _routineChoice(gc),
                  )
                : review
                    ? _review(context, gc)
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        child: _select(context, gc),
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
          bg: gc.ember,
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

    return fit.allExercises.where((ex) {
      if (_selectedMuscle != null) {
        if (_selectedMuscle == 'cardio') {
          if (!ex.isCardio) return false;
        } else if (_selectedMuscle == 'warmup') {
          if (ex.primary != 'warmup' && !ex.secondary.contains('warmup')) return false;
        } else {
          final isMatch = ex.primary == _selectedMuscle ||
              ex.secondary.contains(_selectedMuscle) ||
              ex.secondaryMuscles.contains(_selectedMuscle);
          if (!isMatch) return false;
        }
      } else if (_selectedEquipment != null) {
        if (!matchesEquipmentFilter(ex, _selectedEquipment!)) return false;
      } else if (_trainTab == 2) {
        if (fit.favorites[ex.id] != true) return false;
      }

      if (q.isNotEmpty) {
        final nameMatches = ex.name.toLowerCase().contains(q) ||
            ex.namePt.toLowerCase().contains(q) ||
            ex.localizedName().toLowerCase().contains(q) ||
            exerciseName(ex).toLowerCase().contains(q);
        if (!nameMatches) return false;
      }

      return true;
    }).toList();
  }

  Widget _review(BuildContext context, GymColors gc) {
    return PopScope(
      canPop: !_isCategorySelected,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isCategorySelected) {
          _clearCategory();
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (_isCategorySelected) {
                      _clearCategory();
                    } else {
                      _clearSearch();
                      fit.trainBack();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: SvgPathIcon(Ic.chevronLeft, size: 20, color: gc.textSecondary),
                  ),
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
            const SizedBox(height: 12),
            if (_isCategorySelected && !_isSearching) ...[
              _categoryHeader(gc),
              const SizedBox(height: 10),
            ] else if (!_isSearching) ...[
              CategoryTabSelector(
                selectedTab: _trainTab,
                onTabSelected: (i) {
                  setState(() {
                    _trainTab = i;
                    _selectedMuscle = null;
                    _selectedEquipment = null;
                  });
                },
              ),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: _reviewBody(context, gc),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryHeader(GymColors gc) {
    String title = '';
    if (_selectedMuscle != null) {
      title = _selectedMuscle == 'cardio' ? 'CARDIO' : muscleLabel(_selectedMuscle!).toUpperCase();
    } else if (_selectedEquipment != null) {
      title = _selectedEquipment!.toUpperCase();
    }

    final exercises = _reviewFilteredExercises;

    return Row(
      children: [
        RoundBtn(iconData: PhosphorIconsRegular.caretLeft, onTap: _clearCategory),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.d(16, weight: FontWeight.w700, color: gc.text),
              ),
              Text(
                '${exercises.length} ${exercises.length == 1 ? "exercício" : "exercícios"}',
                style: AppTheme.s(12, color: gc.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewBody(BuildContext context, GymColors gc) {
    if (_isSearching || _isCategorySelected) {
      final exercises = _reviewFilteredExercises;
      if (exercises.isEmpty) {
        return _emptyReview(context, gc);
      }
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: exercises.length,
        itemBuilder: (ctx, i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _pickRow(gc, exercises[i]),
        ),
      );
    }

    // Tab 0: POR MÚSCULO
    if (_trainTab == 0) {
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: kFilterMuscles.length,
        itemBuilder: (ctx, i) {
          final muscleId = kFilterMuscles[i];
          final count = fit.allExercises.where((e) {
            if (muscleId == 'cardio') return e.isCardio;
            if (muscleId == 'warmup') return e.primary == 'warmup' || e.secondary.contains('warmup');
            return e.primary == muscleId || e.secondary.contains(muscleId) || e.secondaryMuscles.contains(muscleId);
          }).length;
          final pickedCount = _pickedCountForMuscle(muscleId);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MuscleCategoryCard(
              muscleId: muscleId,
              count: count,
              trailing: _categoryTrailing(gc, pickedCount),
              onTap: () {
                setState(() {
                  _selectedMuscle = muscleId;
                  _selectedEquipment = null;
                });
              },
            ),
          );
        },
      );
    }

    // Tab 1: EQUIPAMENTOS
    if (_trainTab == 1) {
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: kEquipmentGroups.length,
        itemBuilder: (ctx, i) {
          final group = kEquipmentGroups[i];
          return EquipmentGroupSectionWidget(
            group: group,
            itemBuilder: (item) {
              final count = fit.allExercises.where((e) {
                return matchesEquipmentFilter(e, item.filterKey);
              }).length;
              final pickedCount = _pickedCountForEquipment(item.filterKey);

              return EquipmentCategoryCard(
                item: item,
                count: count,
                trailing: _categoryTrailing(gc, pickedCount),
                onTap: () {
                  setState(() {
                    _selectedEquipment = item.filterKey;
                    _selectedMuscle = null;
                  });
                },
              );
            },
          );
        },
      );
    }

    // Tab 2: FAVORITOS
    final favExercises = fit.allExercises
        .where((e) => fit.favorites[e.id] == true)
        .toList();

    if (favExercises.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIconsRegular.heart, size: 44, color: gc.textTertiary),
              const SizedBox(height: 12),
              Text(
                t.noExercisesMatch,
                style: AppTheme.s(14, color: gc.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: favExercises.length,
      itemBuilder: (ctx, i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _pickRow(gc, favExercises[i]),
      ),
    );
  }

  int _pickedCountForMuscle(String muscleId) {
    return fit.sessionPicks.where((id) {
      final ex = fit.exerciseById(id);
      if (ex == null) return false;
      if (muscleId == 'cardio') return ex.isCardio;
      if (muscleId == 'warmup') return ex.primary == 'warmup' || ex.secondary.contains('warmup');
      return ex.primary == muscleId || ex.secondary.contains(muscleId) || ex.secondaryMuscles.contains(muscleId);
    }).length;
  }

  int _pickedCountForEquipment(String filterKey) {
    return fit.sessionPicks.where((id) {
      final ex = fit.exerciseById(id);
      if (ex == null) return false;
      return matchesEquipmentFilter(ex, filterKey);
    }).length;
  }

  Widget _categoryTrailing(GymColors gc, int pickedCount) {
    if (pickedCount <= 0) {
      return Icon(PhosphorIconsRegular.caretRight, size: 18, color: gc.textTertiary);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: gc.emberSoft,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '$pickedCount',
            style: AppTheme.d(11, weight: FontWeight.w700, color: gc.ember),
          ),
        ),
        const SizedBox(width: 8),
        Icon(PhosphorIconsRegular.caretRight, size: 18, color: gc.textTertiary),
      ],
    );
  }

  Widget _searchRow(BuildContext context, GymColors gc) {
    final hasQuery = _q.isNotEmpty;
    return Container(
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
            onChanged: (v) {
              setState(() {
                _q = v;
                if (v.trim().isNotEmpty) {
                  _selectedMuscle = null;
                  _selectedEquipment = null;
                }
              });
            },
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
    );
  }

  Widget _emptyReview(BuildContext context, GymColors gc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
}
