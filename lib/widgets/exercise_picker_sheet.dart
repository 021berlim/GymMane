import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/l10n.dart';
import '../models/exercise.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'glass.dart';

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
  String? _selectedMuscle;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Exercise> get _filteredExercises {
    final q = _query.trim().toLowerCase();
    final excluded = widget.excludedIds ?? const {};

    return fit.allExercises.where((ex) {
      if (excluded.contains(ex.id)) return false;

      if (_selectedMuscle != null) {
        if (_selectedMuscle == 'cardio') {
          if (!ex.isCardio) return false;
        } else {
          final isMatch = ex.primary == _selectedMuscle ||
              ex.secondary.contains(_selectedMuscle) ||
              ex.secondaryMuscles.contains(_selectedMuscle);
          if (!isMatch) return false;
        }
      }

      if (q.isNotEmpty) {
        final nameMatches = ex.name.toLowerCase().contains(q) ||
            ex.namePt.toLowerCase().contains(q) ||
            exerciseName(ex).toLowerCase().contains(q);
        if (!nameMatches) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final exercises = _filteredExercises;
    final height = MediaQuery.of(context).size.height * 0.82;

    return Container(
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
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: gc.bgRaised2,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.pickAnExercise,
                style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(PhosphorIconsRegular.x, size: 20, color: gc.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search box
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: gc.bgRaised2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: gc.border),
            ),
            child: Row(
              children: [
                Icon(PhosphorIconsRegular.magnifyingGlass, size: 18, color: gc.textTertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    style: AppTheme.s(14, color: gc.text),
                    decoration: InputDecoration(
                      hintText: t.searchAllExercises,
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
          const SizedBox(height: 10),
          // Muscle filters horizontal scroll
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _filterChip(
                  label: t.allCategories.toUpperCase(),
                  selected: _selectedMuscle == null,
                  onTap: () => setState(() => _selectedMuscle = null),
                  gc: gc,
                ),
                const SizedBox(width: 6),
                _filterChip(
                  label: muscleLabel('cardio'),
                  selected: _selectedMuscle == 'cardio',
                  onTap: () => setState(() => _selectedMuscle = 'cardio'),
                  gc: gc,
                ),
                const SizedBox(width: 6),
                _filterChip(
                  label: muscleLabel('chest'),
                  selected: _selectedMuscle == 'chest',
                  onTap: () => setState(() => _selectedMuscle = 'chest'),
                  gc: gc,
                ),
                const SizedBox(width: 6),
                _filterChip(
                  label: muscleLabel('back'),
                  selected: _selectedMuscle == 'back',
                  onTap: () => setState(() => _selectedMuscle = 'back'),
                  gc: gc,
                ),
                const SizedBox(width: 6),
                _filterChip(
                  label: muscleLabel('shoulders'),
                  selected: _selectedMuscle == 'shoulders',
                  onTap: () => setState(() => _selectedMuscle = 'shoulders'),
                  gc: gc,
                ),
                const SizedBox(width: 6),
                _filterChip(
                  label: muscleLabel('biceps'),
                  selected: _selectedMuscle == 'biceps',
                  onTap: () => setState(() => _selectedMuscle = 'biceps'),
                  gc: gc,
                ),
                const SizedBox(width: 6),
                _filterChip(
                  label: muscleLabel('triceps'),
                  selected: _selectedMuscle == 'triceps',
                  onTap: () => setState(() => _selectedMuscle = 'triceps'),
                  gc: gc,
                ),
                const SizedBox(width: 6),
                _filterChip(
                  label: muscleLabel('quads'),
                  selected: _selectedMuscle == 'quads',
                  onTap: () => setState(() => _selectedMuscle = 'quads'),
                  gc: gc,
                ),
                const SizedBox(width: 6),
                _filterChip(
                  label: muscleLabel('hamstrings'),
                  selected: _selectedMuscle == 'hamstrings',
                  onTap: () => setState(() => _selectedMuscle = 'hamstrings'),
                  gc: gc,
                ),
                const SizedBox(width: 6),
                _filterChip(
                  label: muscleLabel('glutes'),
                  selected: _selectedMuscle == 'glutes',
                  onTap: () => setState(() => _selectedMuscle = 'glutes'),
                  gc: gc,
                ),
                const SizedBox(width: 6),
                _filterChip(
                  label: muscleLabel('abdomen'),
                  selected: _selectedMuscle == 'abdomen',
                  onTap: () => setState(() => _selectedMuscle = 'abdomen'),
                  gc: gc,
                ),
                const SizedBox(width: 6),
                _filterChip(
                  label: muscleLabel('calves'),
                  selected: _selectedMuscle == 'calves',
                  onTap: () => setState(() => _selectedMuscle = 'calves'),
                  gc: gc,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Exercise list
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Text(
                      t.noExercisesMatch,
                      style: AppTheme.s(14, color: gc.textSecondary),
                    ),
                  )
                : ListView.separated(
                    itemCount: exercises.length,
                    separatorBuilder: (_, _) => Divider(height: 1, color: gc.border.withValues(alpha: 0.5)),
                    itemBuilder: (ctx, i) {
                      final ex = exercises[i];
                      final name = exerciseName(ex);
                      final muscle = ex.isCardio ? 'Cardio' : muscleLabel(ex.primary);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: ex.isCardio ? gc.accentSoft : gc.bgRaised2,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: ex.isCardio ? gc.accent : gc.border),
                          ),
                          child: Icon(
                            ex.isCardio ? PhosphorIconsRegular.heartStraight : PhosphorIconsRegular.barbell,
                            size: 18,
                            color: ex.isCardio ? gc.accent : gc.textSecondary,
                          ),
                        ),
                        title: Text(
                          name,
                          style: AppTheme.s(14, weight: FontWeight.w600, color: gc.text),
                        ),
                        subtitle: Text(
                          muscle,
                          style: AppTheme.s(12, color: gc.textSecondary),
                        ),
                        trailing: Icon(PhosphorIconsRegular.plus, size: 18, color: gc.accent),
                        onTap: () => Navigator.of(context).pop(ex),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required GymColors gc,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? gc.ember : gc.bgRaised2,
          border: Border.all(color: selected ? gc.ember : gc.border),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: AppTheme.s(
            11,
            weight: FontWeight.w600,
            color: selected ? gc.onEmber : gc.textSecondary,
          ),
        ),
      ),
    );
  }
}
