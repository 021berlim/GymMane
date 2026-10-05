import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../catalog/exercise_catalog.dart';
import '../l10n/l10n.dart';
import '../models/exercise.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'exercise_category_widgets.dart';
import 'exercise_media.dart';
import 'glass.dart';
import 'ui_kit.dart';

Future<Exercise?> showExercisePickerSheet(
  BuildContext context, {
  Set<String>? excludedIds,
}) {
  return showAppSheet<Exercise>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ExercisePickerSheet(excludedIds: excludedIds),
  );
}

class ExercisePickerSheet extends StatefulWidget {
  const ExercisePickerSheet({super.key, this.excludedIds});

  final Set<String>? excludedIds;

  @override
  State<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<ExercisePickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  int _selectedTab = 0; // 0: Por Músculo, 1: Equipamentos, 2: Favoritos
  String? _selectedMuscle;
  String? _selectedEquipment;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool get _isSearching => _query.trim().isNotEmpty;
  bool get _isCategorySelected => _selectedMuscle != null || _selectedEquipment != null;

  Set<String> get _excluded => widget.excludedIds ?? const {};

  List<Exercise> get _filteredExercises {
    return fit.allExercises.where((ex) {
      if (_excluded.contains(ex.id)) return false;

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
      } else if (_selectedTab == 2) {
        if (fit.favorites[ex.id] != true) return false;
      }

      if (_query.trim().isNotEmpty) {
        if (!matchesExerciseSearch(ex, _query)) return false;
      }

      return true;
    }).toList();
  }

  void _clearCategory() {
    setState(() {
      _selectedMuscle = null;
      _selectedEquipment = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final height = MediaQuery.of(context).size.height * 0.90;

    return PopScope(
      canPop: !_isCategorySelected,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isCategorySelected) {
          _clearCategory();
        }
      },
      child: Container(
        height: height,
        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: gc.bgRaised,
          border: Border.all(color: gc.border),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            const ModalDragHandle(),
            const SizedBox(height: 14),

            // Top Header: Title + Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    t.pickAnExercise.toUpperCase(),
                    style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text, letterSpacing: 1),
                  ),
                ),
                RoundBtn(
                  iconData: PhosphorIconsRegular.x,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search box (sempre visível no topo, igual ExercisesScreen)
            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: gc.bgRaised2,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: gc.border),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIconsRegular.magnifyingGlass, size: 18, color: gc.textTertiary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) {
                        setState(() {
                          _query = v;
                          if (v.trim().isNotEmpty) {
                            _selectedMuscle = null;
                            _selectedEquipment = null;
                          }
                        });
                      },
                      style: AppTheme.s(14, color: gc.text),
                      cursorColor: gc.accent,
                      decoration: InputDecoration(
                        hintText: t.searchExercises,
                        hintStyle: AppTheme.s(13, color: gc.textTertiary),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                      child: Icon(PhosphorIconsRegular.xCircle, size: 18, color: gc.textTertiary),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Category detail header if a category is selected
            if (_isCategorySelected && !_isSearching) ...[
              _categoryHeader(gc),
              const SizedBox(height: 10),
            ] else if (!_isSearching) ...[
              // Tabs: POR MÚSCULO | EQUIPAMENTOS | FAVORITOS
              CategoryTabSelector(
                selectedTab: _selectedTab,
                onTabSelected: (i) {
                  setState(() {
                    _selectedTab = i;
                    _selectedMuscle = null;
                    _selectedEquipment = null;
                  });
                },
              ),
              const SizedBox(height: 12),
            ],

            // Content area
            Expanded(
              child: _buildBody(gc),
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

    final exercises = _filteredExercises;

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

  Widget _buildBody(GymColors gc) {
    // If searching or category is selected, show exercise list
    if (_isSearching || _isCategorySelected) {
      final exercises = _filteredExercises;
      if (exercises.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text(
              t.noExercisesMatch,
              style: AppTheme.s(14, color: gc.textSecondary),
            ),
          ),
        );
      }

      return ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (ctx, i) => _exerciseTile(gc, exercises[i]),
      );
    }

    // Tab 0: POR MÚSCULO
    if (_selectedTab == 0) {
      return ListView.builder(
        itemCount: kFilterMuscles.length,
        itemBuilder: (ctx, i) {
          final muscleId = kFilterMuscles[i];
          final count = fit.allExercises.where((e) {
            if (_excluded.contains(e.id)) return false;
            if (muscleId == 'cardio') return e.isCardio;
            if (muscleId == 'warmup') return e.primary == 'warmup' || e.secondary.contains('warmup');
            return e.primary == muscleId || e.secondary.contains(muscleId) || e.secondaryMuscles.contains(muscleId);
          }).length;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MuscleCategoryCard(
              muscleId: muscleId,
              count: count,
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
    if (_selectedTab == 1) {
      return ListView.builder(
        itemCount: kEquipmentGroups.length,
        itemBuilder: (ctx, i) {
          final group = kEquipmentGroups[i];
          return EquipmentGroupSectionWidget(
            group: group,
            itemBuilder: (item) {
              final count = fit.allExercises.where((e) {
                if (_excluded.contains(e.id)) return false;
                return matchesEquipmentFilter(e, item.filterKey);
              }).length;

              return EquipmentCategoryCard(
                item: item,
                count: count,
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
        .where((e) => fit.favorites[e.id] == true && !_excluded.contains(e.id))
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
      itemCount: favExercises.length,
      itemBuilder: (ctx, i) => _exerciseTile(gc, favExercises[i]),
    );
  }

  Widget _exerciseTile(GymColors gc, Exercise ex) {
    final name = exerciseName(ex);
    final subtitle = ex.isCardio
        ? 'Cardio · ${ex.cardioType.displayNamePt}'
        : '${muscleLabel(ex.primary)} · ${ex.equipment}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: gc.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 40,
            height: 40,
            child: ExerciseMedia(ex: ex, height: 40, width: 40, radius: 10),
          ),
        ),
        title: Text(
          name,
          style: AppTheme.s(14, weight: FontWeight.w600, color: gc.text),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            subtitle,
            style: AppTheme.s(12, color: gc.textSecondary),
          ),
        ),
        trailing: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: gc.accentSoft,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: gc.accent.withValues(alpha: 0.3)),
          ),
          child: Icon(PhosphorIconsRegular.plus, size: 16, color: gc.accent),
        ),
        onTap: () => Navigator.of(context).pop(ex),
      ),
    );
  }
}
