import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../catalog/exercise_catalog.dart';
import '../l10n/l10n.dart';
import '../models/exercise.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/exercise_category_widgets.dart';
import '../widgets/exercise_media.dart';
import '../widgets/svg_icon.dart';
import '../widgets/ui_kit.dart';

class RoutineEditScreen extends StatefulWidget {
  const RoutineEditScreen({super.key});

  @override
  State<RoutineEditScreen> createState() => _RoutineEditScreenState();
}

class _RoutineEditScreenState extends State<RoutineEditScreen> {
  late final String _id = fit.activeRoutineId!;
  late final TextEditingController _name =
      TextEditingController(text: fit.activeRoutine?.name ?? '');
  final TextEditingController _search = TextEditingController();
  String _q = '';
  String? _muscleFilter;
  String? _equipmentFilter;
  String? _difficultyFilter;
  bool _favouritesOnly = false;
  int _tab = 0; // 0: POR MÚSCULO, 1: EQUIPAMENTOS, 2: FAVORITOS

  @override
  void dispose() {
    _name.dispose();
    _search.dispose();
    super.dispose();
  }

  bool get _isCategorySelected =>
      _muscleFilter != null || _equipmentFilter != null;

  bool get _isSearching => _q.trim().isNotEmpty;

  bool get _hasActiveFilters =>
      _q.isNotEmpty || _muscleFilter != null || _equipmentFilter != null || _difficultyFilter != null || _favouritesOnly;

  void _clearFilters() {
    _search.clear();
    setState(() {
      _q = '';
      _muscleFilter = null;
      _equipmentFilter = null;
      _difficultyFilter = null;
      _favouritesOnly = false;
    });
  }

  List<Exercise> get _filtered {
    final q = _q.trim().toLowerCase();
    return fit.allExercises.where((ex) {
      if (_favouritesOnly && fit.favorites[ex.id] != true) return false;

      if (q.isNotEmpty &&
          !ex.name.toLowerCase().contains(q) &&
          !ex.localizedName().toLowerCase().contains(q) &&
          !exerciseName(ex).toLowerCase().contains(q)) {
        return false;
      }
      if (_muscleFilter != null &&
          ex.primary != _muscleFilter &&
          !ex.secondary.contains(_muscleFilter)) {
        return false;
      }
      if (_equipmentFilter != null && !matchesEquipmentFilter(ex, _equipmentFilter!)) {
        return false;
      }
      if (_difficultyFilter != null && ex.difficulty != _difficultyFilter) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final routine = fit.activeRoutine;
    if (routine == null) {
      return const SizedBox.shrink();
    }

    final list = _filtered;
    final isCatSelected = _isCategorySelected;
    final isSearchActive = _isSearching;

    int extraItemsCount = 0;
    if (isCatSelected || isSearchActive) {
      extraItemsCount = list.isEmpty ? 1 : list.length;
    } else if (_tab == 0) {
      extraItemsCount = kFilterMuscles.length;
    } else if (_tab == 1) {
      extraItemsCount = kEquipmentGroups.length;
    } else {
      final favsCount = fit.allExercises.where((e) => fit.favorites[e.id] == true).length;
      extraItemsCount = favsCount == 0 ? 1 : favsCount;
    }

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              itemCount: extraItemsCount + 1,
              itemBuilder: (context, i) {
                if (i == 0) return _header(gc, routine.exerciseIds.length, list.length);
                final itemIndex = i - 1;

                if (isCatSelected || isSearchActive) {
                  if (list.isEmpty) {
                    return _empty(gc);
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _pickRow(gc, list[itemIndex]),
                  );
                } else if (_tab == 0) {
                  final muscleId = kFilterMuscles[itemIndex];
                  final count = fit.allExercises
                      .where((e) => e.primary == muscleId || e.secondary.contains(muscleId))
                      .length;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MuscleCategoryCard(
                      muscleId: muscleId,
                      count: count,
                      onTap: () {
                        setState(() {
                          _muscleFilter = muscleId;
                        });
                      },
                    ),
                  );
                } else if (_tab == 1) {
                  final group = kEquipmentGroups[itemIndex];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: EquipmentGroupSectionWidget(
                      group: group,
                      itemBuilder: (item) {
                        final count = fit.allExercises
                            .where((ex) => matchesEquipmentFilter(ex, item.filterKey))
                            .length;
                        return EquipmentCategoryCard(
                          item: item,
                          count: count,
                          onTap: () {
                            setState(() {
                              _equipmentFilter = item.filterKey;
                            });
                          },
                        );
                      },
                    ),
                  );
                } else {
                  final favs = fit.allExercises.where((e) => fit.favorites[e.id] == true).toList();
                  if (favs.isEmpty) {
                    return _emptyFavorites(gc);
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _pickRow(gc, favs[itemIndex]),
                  );
                }
              },
            ),
          ),
          if (routine.exerciseIds.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + MediaQuery.of(context).padding.bottom),
              child: PrimaryButton(
                label: t.startWorkout,
                icon: Ic.play,
                onTap: () => fit.startRoutine(routine),
              ),
            ),
        ],
      ),
    );
  }

  Widget _header(GymColors gc, int routineExerciseCount, int categoryExerciseCount) {
    final routine = fit.activeRoutine!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          RoundBtn(icon: Ic.chevronLeft, onTap: fit.closeRoutineEdit),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _name,
              autofocus: fit.activeRoutine?.name.isEmpty ?? false,
              style: AppTheme.d(22, weight: FontWeight.w700, color: gc.text, letterSpacing: 0.5),
              cursorColor: gc.accent,
              textCapitalization: TextCapitalization.words,
              onChanged: (v) => fit.renameRoutine(_id, v),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: t.routineName,
                hintStyle: AppTheme.d(22, weight: FontWeight.w700, color: gc.textTertiary),
              ),
            ),
          ),
          GestureDetector(
            onTap: _confirmDelete,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(PhosphorIconsRegular.trash, size: 20, color: gc.textTertiary),
            ),
          ),
        ]),
        const SizedBox(height: 20),
        Text(t.schedule, style: AppTheme.d(12, weight: FontWeight.w600, color: gc.textSecondary, letterSpacing: 3)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [for (int i = 0; i < 7; i++) _dayToggle(gc, i)],
        ),
        const SizedBox(height: 24),
        Text(t.exercisesWithCount(routineExerciseCount), style: AppTheme.d(12, weight: FontWeight.w600, color: gc.textSecondary, letterSpacing: 3)),
        const SizedBox(height: 10),
        if (routine.exerciseIds.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(t.addFromList, style: AppTheme.s(13, color: gc.textTertiary)),
          )
        else ...[
          if (routine.exerciseIds.length > 1) ...[
            Text(t.dragToReorder, style: AppTheme.s(11, color: gc.textTertiary)),
            const SizedBox(height: 8),
          ],
          ReorderableListView(
            shrinkWrap: true,
            buildDefaultDragHandles: false,
            physics: const NeverScrollableScrollPhysics(),
            // ignore: deprecated_member_use
            onReorder: (from, to) => fit.reorderRoutineExercise(routine.id, from, to),
            children: [
              for (int i = 0; i < fit.routineExercises(routine).length; i++)
                _chosenRow(gc, fit.routineExercises(routine)[i], i),
            ],
          ),
        ],
        const SizedBox(height: 20),
        if (_isCategorySelected) ...[
          _categoryDetailHeader(gc, categoryExerciseCount),
        ] else if (_isSearching) ...[
          _searchHeader(gc, categoryExerciseCount),
        ] else ...[
          // Search exercises input
          Container(
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
                  controller: _search,
                  onChanged: (v) => setState(() => _q = v),
                  style: AppTheme.s(14, color: gc.text),
                  cursorColor: gc.accent,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: t.addExercises,
                    hintStyle: AppTheme.s(14, color: gc.textSecondary),
                  ),
                ),
              ),
              if (_hasActiveFilters)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _clearFilters,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: SvgPathIcon(Ic.closeThin, size: 14, color: gc.textSecondary),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 14),
          CategoryTabSelector(
            selectedTab: _tab,
            onTabSelected: (i) {
              setState(() {
                _tab = i;
                _favouritesOnly = (i == 2);
              });
            },
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _categoryDetailHeader(GymColors gc, int count) {
    String categoryName = '';
    if (_muscleFilter != null) {
      categoryName = muscleLabel(_muscleFilter!).toUpperCase();
    } else if (_equipmentFilter != null) {
      categoryName = _equipmentFilter!.toUpperCase();
    }

    final secondaryLabel = _equipmentFilter == null
        ? t.equipment('all')
        : (kFilterEquipment.contains(_equipmentFilter)
            ? t.equipment(_equipmentFilter!)
            : _equipmentFilter!);

    return CategoryDetailHeaderWidget(
      categoryName: categoryName,
      count: count,
      onBack: () {
        setState(() {
          _muscleFilter = null;
          _equipmentFilter = null;
          _difficultyFilter = null;
        });
      },
      difficultyFilter: _difficultyFilter,
      secondaryFilterLabel: secondaryLabel,
      onDifficultyTap: () {
        showFilterSelectorBottomSheet<String>(
          context: context,
          title: t.levelFilter,
          currentValue: _difficultyFilter,
          options: [
            MapEntry(null, t.difficulty('all')),
            for (final d in kDifficulties) MapEntry(d, t.difficulty(d)),
          ],
          onSelected: (val) {
            setState(() {
              _difficultyFilter = val;
            });
          },
        );
      },
      onSecondaryFilterTap: () {
        showFilterSelectorBottomSheet<String>(
          context: context,
          title: t.equipmentLabel,
          currentValue: _equipmentFilter,
          options: [
            MapEntry(null, t.equipment('all')),
            for (final eq in kFilterEquipment) MapEntry(eq, t.equipment(eq)),
          ],
          onSelected: (val) {
            setState(() {
              _equipmentFilter = val;
            });
          },
        );
      },
    );
  }

  Widget _searchHeader(GymColors gc, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
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
                controller: _search,
                onChanged: (v) => setState(() => _q = v),
                style: AppTheme.s(14, color: gc.text),
                cursorColor: gc.accent,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: t.addExercises,
                  hintStyle: AppTheme.s(14, color: gc.textSecondary),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _search.clear();
                setState(() => _q = '');
              },
              child: Icon(PhosphorIconsRegular.xCircle, size: 18, color: gc.textSecondary),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Text(
          '$count exercícios encontrados',
          style: AppTheme.s(13, color: gc.textSecondary),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _empty(GymColors gc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          SvgPathIcon(const [IconPath('M11 11m-7 0a7 7 0 1 0 14 0a7 7 0 1 0 -14 0', strokeWidth: 1.5), IconPath('M21 21l-4.35-4.35', strokeWidth: 1.5)], size: 40, color: gc.textTertiary),
          const SizedBox(height: 10),
          Text(t.noExercisesFound, style: AppTheme.s(15, weight: FontWeight.w600, color: gc.text)),
          const SizedBox(height: 4),
          Text(t.noExercisesHint, textAlign: TextAlign.center, style: AppTheme.s(13, color: gc.textSecondary)),
          const SizedBox(height: 16),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _clearFilters,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(t.clearFilters, style: AppTheme.s(13, weight: FontWeight.w600, color: gc.accent)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyFavorites(GymColors gc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          _star(gc, false),
          const SizedBox(height: 10),
          Text(t.noFavouritesYet, style: AppTheme.s(15, weight: FontWeight.w600, color: gc.text)),
          const SizedBox(height: 4),
          Text(t.noFavouritesHint, textAlign: TextAlign.center, style: AppTheme.s(13, color: gc.textSecondary)),
        ],
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

  Widget _dayToggle(GymColors gc, int i) {
    final weekday = i + 1;
    final on = fit.weeklyPlan[weekday] == _id;
    return GestureDetector(
      onTap: () => fit.assignRoutineToDay(weekday, on ? null : _id),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: on ? gc.ember : gc.bgRaised2,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(t.weekdayInitial(i + 1),
            style: AppTheme.d(14, weight: FontWeight.w700, color: on ? gc.onEmber : gc.textSecondary)),
      ),
    );
  }

  Widget _chosenRow(GymColors gc, Exercise ex, int index) {
    final routine = fit.activeRoutine!;
    final cfg = routine.configFor(ex.id);
    final weightStr = cfg.targetWeight > 0 ? fit.weightLabel(cfg.targetWeight) : '0 ${fit.units}';

    return Container(
      key: ValueKey(ex.id),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        border: Border.all(color: gc.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            ReorderableDragStartListener(
              index: index,
              child: Semantics(
                label: t.reorderHandle(ex.localizedName(context)),
                child: SizedBox(
                  width: 34,
                  height: 44,
                  child: Icon(PhosphorIconsRegular.dotsSixVertical, size: 18, color: gc.textTertiary),
                ),
              ),
            ),
            SizedBox(width: 44, child: ExerciseMedia(ex: ex, height: 44, radius: 10)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ex.localizedName(context), style: AppTheme.s(14, weight: FontWeight.w600, color: gc.text)),
                  const SizedBox(height: 2),
                  Text('${ex.getLocalizedTarget(context)} · ${ex.getLocalizedEquipment(context)}',
                      style: AppTheme.s(12, color: gc.textSecondary)),
                ],
              ),
            ),
            Semantics(
              button: true,
              label: t.removeFromRoutine,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  final ok = await showConfirmDeleteModal(
                    context: context,
                    title: t.removeFromRoutine,
                    message: t.deleteEntryBody(ex.localizedName(context)),
                  );
                  if (ok) fit.toggleRoutineExercise(_id, ex.id);
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: gc.bgRaised2, shape: BoxShape.circle),
                  child: SvgPathIcon(Ic.close, size: 14, color: gc.textSecondary),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: gc.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: gc.border),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${t.setsCaps}:',
                        style: AppTheme.s(11, weight: FontWeight.w700, color: gc.textSecondary, letterSpacing: 1)),
                    const SizedBox(width: 6),
                    _miniStepBtn(gc, PhosphorIconsRegular.minus, () {
                      fit.setRoutineExerciseSets(_id, ex.id, (cfg.targetSets - 1).clamp(1, 20));
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text('${cfg.targetSets}',
                          style: AppTheme.d(14, weight: FontWeight.w700, color: gc.text)),
                    ),
                    _miniStepBtn(gc, PhosphorIconsRegular.plus, () {
                      fit.setRoutineExerciseSets(_id, ex.id, (cfg.targetSets + 1).clamp(1, 20));
                    }),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${t.weightCol(fit.units.toUpperCase())}:',
                        style: AppTheme.s(11, weight: FontWeight.w700, color: gc.textSecondary, letterSpacing: 1)),
                    const SizedBox(width: 6),
                    _miniStepBtn(gc, PhosphorIconsRegular.minus, () {
                      final currentShown = fit.toDisplayWeight(cfg.targetWeight);
                      final nextShown = math.max(0.0, (currentShown - fit.weightStep * 10).round() / 10);
                      fit.setRoutineExerciseWeight(_id, ex.id, fit.fromDisplayWeight(nextShown));
                    }),
                    GestureDetector(
                      onTap: () {
                        _editTargetWeight(
                          context,
                          gc,
                          initial: fit.weightValue(cfg.targetWeight),
                          onSave: (shownVal) {
                            fit.setRoutineExerciseWeight(_id, ex.id, fit.fromDisplayWeight(shownVal));
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          weightStr,
                          style: AppTheme.d(13, weight: FontWeight.w700, color: gc.text),
                        ),
                      ),
                    ),
                    _miniStepBtn(gc, PhosphorIconsRegular.plus, () {
                      final currentShown = fit.toDisplayWeight(cfg.targetWeight);
                      final nextShown = ((currentShown + fit.weightStep) * 10).round() / 10;
                      fit.setRoutineExerciseWeight(_id, ex.id, fit.fromDisplayWeight(nextShown));
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStepBtn(GymColors gc, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: gc.bgRaised2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: gc.border),
        ),
        child: Icon(icon, size: 13, color: gc.text),
      ),
    );
  }

  Future<void> _editTargetWeight(
    BuildContext context,
    GymColors gc, {
    required String initial,
    required void Function(double) onSave,
  }) async {
    final controller = TextEditingController(text: initial)
      ..selection = TextSelection(baseOffset: 0, extentOffset: initial.length);

    final raw = await showDialog<String>(
      context: context,
      builder: (dctx) => AlertDialog(
        backgroundColor: gc.bgRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t.weightTitle(fit.units.toUpperCase()),
            style: AppTheme.d(14, weight: FontWeight.w700, color: gc.text, letterSpacing: 2)),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
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

    final parsed = double.tryParse((raw ?? '').trim().replaceAll(',', '.'));
    if (parsed != null) onSave(parsed);
  }

  Widget _pickRow(GymColors gc, Exercise ex) {
    final inRoutine = fit.routineHas(_id, ex.id);
    return GestureDetector(
      onTap: () => fit.toggleRoutineExercise(_id, ex.id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: gc.bgRaised,
          border: Border.all(color: inRoutine ? gc.ember : gc.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          SizedBox(width: 44, child: ExerciseMedia(ex: ex, height: 44, radius: 10)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exerciseName(ex), style: AppTheme.s(14, weight: FontWeight.w600, color: gc.text)),
                const SizedBox(height: 2),
                Text('${muscleLabel(ex.primary)} · ${t.equipment(ex.equipment)}', style: AppTheme.s(12, color: gc.textSecondary)),
              ],
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: inRoutine ? gc.ember : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: inRoutine ? gc.ember : gc.border, width: 2),
            ),
            child: inRoutine
                ? SvgPathIcon(Ic.checkBold, size: 14, color: gc.onEmber)
                : Icon(PhosphorIconsRegular.plus, size: 15, color: gc.textSecondary),
          ),
        ]),
      ),
    );
  }

  void _confirmDelete() {
    final gc = context.gc;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: gc.bgRaised,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.deleteRoutine, style: AppTheme.s(15, weight: FontWeight.w600, color: gc.text)),
              const SizedBox(height: 18),
              PrimaryButton(
                label: t.deleteCaps,
                bg: gc.accent,
                onTap: () {
                  Navigator.pop(context);
                  fit.deleteRoutine(_id);
                  fit.closeRoutineEdit();
                },
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  child: Text(t.cancelCaps,
                      style: AppTheme.d(14, weight: FontWeight.w600, color: gc.textSecondary, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
