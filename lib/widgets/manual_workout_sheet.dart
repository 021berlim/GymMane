import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/l10n.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'exercise_media.dart';
import 'exercise_picker_sheet.dart';
import 'glass.dart';
import 'ui_kit.dart';

Future<bool?> showManualWorkoutSheet(
  BuildContext context, {
  DateTime? initialDate,
}) {
  return showAppSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ManualWorkoutSheet(initialDate: initialDate),
  );
}

class ManualWorkoutSheet extends StatefulWidget {
  const ManualWorkoutSheet({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  State<ManualWorkoutSheet> createState() => _ManualWorkoutSheetState();
}

class _ManualExerciseDraft {
  _ManualExerciseDraft({
    required this.exercise,
    List<_ManualSetDraft>? sets,
  }) : sets = sets ?? [_ManualSetDraft.initial(exercise)];

  final Exercise exercise;
  final List<_ManualSetDraft> sets;
  bool isExpanded = false;
  bool get isCardio => exercise.isCardio;
}

class _ManualSetDraft {
  _ManualSetDraft({
    this.reps = 10,
    this.weight = 0.0,
    this.rpe,
    this.durationMin = 15,
    this.durationSecRemainder = 0,
    this.cardioParam = 1.0,
    this.speed = 8.0,
  }) {
    repsCtrl = TextEditingController(text: reps > 0 ? '$reps' : '10');
    weightCtrl = TextEditingController(text: weight > 0 ? (weight % 1 == 0 ? '${weight.toInt()}' : '$weight') : '0');
    rpeCtrl = TextEditingController(text: rpe != null ? '$rpe' : '');
    durMinCtrl = TextEditingController(text: '$durationMin');
    durSecCtrl = TextEditingController(text: '$durationSecRemainder');
    paramCtrl = TextEditingController(text: cardioParam % 1 == 0 ? '${cardioParam.toInt()}' : '$cardioParam');
    speedCtrl = TextEditingController(text: speed % 1 == 0 ? '${speed.toInt()}' : '$speed');
  }

  int reps;
  double weight;
  double? rpe;
  int durationMin;
  int durationSecRemainder;
  double cardioParam;
  double speed;

  late final TextEditingController repsCtrl;
  late final TextEditingController weightCtrl;
  late final TextEditingController rpeCtrl;
  late final TextEditingController durMinCtrl;
  late final TextEditingController durSecCtrl;
  late final TextEditingController paramCtrl;
  late final TextEditingController speedCtrl;

  int get totalDurationSec => (durationMin * 60) + durationSecRemainder;

  void dispose() {
    repsCtrl.dispose();
    weightCtrl.dispose();
    rpeCtrl.dispose();
    durMinCtrl.dispose();
    durSecCtrl.dispose();
    paramCtrl.dispose();
    speedCtrl.dispose();
  }

  factory _ManualSetDraft.initial(Exercise ex) {
    if (ex.isCardio) {
      final ct = ex.cardioType;
      return _ManualSetDraft(
        durationMin: ct.defaultSeconds ~/ 60,
        durationSecRemainder: ct.defaultSeconds % 60,
        cardioParam: ct.defaultParam,
        speed: ct.hasSpeed ? ct.defaultSpeed : 0.0,
      );
    }
    return _ManualSetDraft(reps: 10, weight: 20.0);
  }

  factory _ManualSetDraft.fromConfig(Exercise ex, RoutineExerciseConfig cfg) {
    if (ex.isCardio) {
      final totalSec = cfg.effectiveTimeSeconds;
      return _ManualSetDraft(
        durationMin: totalSec ~/ 60,
        durationSecRemainder: totalSec % 60,
        cardioParam: cfg.effectiveCardioParam,
        speed: cfg.effectiveCardioSpeed,
      );
    }
    return _ManualSetDraft(
      reps: cfg.targetReps,
      weight: cfg.targetWeight,
    );
  }
}

class _ManualWorkoutSheetState extends State<ManualWorkoutSheet> {
  late DateTime _selectedDate;
  int _sourceMode = 0; // 0: Rotina Salva, 1: Exercícios Avulsos
  String? _selectedRoutineId;
  final List<_ManualExerciseDraft> _exercises = [];
  final TextEditingController _durationCtrl = TextEditingController(text: '45');

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();

    // Default to existing routine if user has routines
    if (fit.routines.isNotEmpty) {
      _sourceMode = 0;
      _loadRoutine(fit.routines.first);
    } else {
      _sourceMode = 1;
    }
  }

  @override
  void dispose() {
    _durationCtrl.dispose();
    for (final ex in _exercises) {
      for (final st in ex.sets) {
        st.dispose();
      }
    }
    super.dispose();
  }

  void _loadRoutine(Routine routine) {
    setState(() {
      _selectedRoutineId = routine.id;
      // Dispose existing
      for (final ex in _exercises) {
        for (final st in ex.sets) {
          st.dispose();
        }
      }
      _exercises.clear();

      for (final exId in routine.exerciseIds) {
        final def = fit.exerciseById(exId);
        if (def != null) {
          final cfg = routine.configFor(exId);
          final setCount = math.max(1, cfg.targetSets);
          final sets = List.generate(setCount, (_) => _ManualSetDraft.fromConfig(def, cfg));
          _exercises.add(_ManualExerciseDraft(exercise: def, sets: sets));
        }
      }

      _autoCalculateDuration();
    });
  }

  void _autoCalculateDuration() {
    int totalMins = 0;
    for (final draft in _exercises) {
      if (draft.isCardio) {
        for (final s in draft.sets) {
          totalMins += math.max(1, s.totalDurationSec ~/ 60);
        }
      } else {
        // ~2 minutes per strength set estimation
        totalMins += (draft.sets.length * 2);
      }
    }
    final finalMins = math.max(15, totalMins);
    _durationCtrl.text = '$finalMins';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 365)),
      locale: Locale(appLanguage),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  Future<void> _addExercise() async {
    final excluded = _exercises.map((e) => e.exercise.id).toSet();
    final ex = await showExercisePickerSheet(context, excludedIds: excluded);
    if (ex != null && mounted) {
      setState(() {
        _exercises.add(_ManualExerciseDraft(exercise: ex));
        _autoCalculateDuration();
      });
    }
  }

  void _removeExercise(int index) {
    setState(() {
      final removed = _exercises.removeAt(index);
      for (final st in removed.sets) {
        st.dispose();
      }
      _autoCalculateDuration();
    });
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      final exDraft = _exercises[exerciseIndex];
      final lastSet = exDraft.sets.lastOrNull;
      if (lastSet != null) {
        exDraft.sets.add(_ManualSetDraft(
          reps: lastSet.reps,
          weight: lastSet.weight,
          rpe: lastSet.rpe,
          durationMin: lastSet.durationMin,
          durationSecRemainder: lastSet.durationSecRemainder,
          cardioParam: lastSet.cardioParam,
          speed: lastSet.speed,
        ));
      } else {
        exDraft.sets.add(_ManualSetDraft.initial(exDraft.exercise));
      }
      _autoCalculateDuration();
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      final exDraft = _exercises[exerciseIndex];
      if (exDraft.sets.length > 1) {
        final removed = exDraft.sets.removeAt(setIndex);
        removed.dispose();
        _autoCalculateDuration();
      }
    });
  }

  void _saveWorkout() {
    if (_exercises.isEmpty) {
      AppToast.show(context, message: t.selectAtLeastOneExercise, type: AppToastType.error);
      return;
    }

    // Validate metrics
    for (final exDraft in _exercises) {
      if (exDraft.sets.isEmpty) {
        AppToast.show(context, message: t.fillAllMetricsWarning, type: AppToastType.error);
        return;
      }

      for (final st in exDraft.sets) {
        if (exDraft.isCardio) {
          final mins = int.tryParse(st.durMinCtrl.text) ?? 0;
          final secs = int.tryParse(st.durSecCtrl.text) ?? 0;
          final totalSec = (mins * 60) + secs;
          if (totalSec <= 0) {
            AppToast.show(context, message: t.fillAllMetricsWarning, type: AppToastType.error);
            return;
          }
          final param = double.tryParse(st.paramCtrl.text) ?? 0.0;
          final speed = double.tryParse(st.speedCtrl.text) ?? 0.0;
          st.durationMin = mins;
          st.durationSecRemainder = secs;
          st.cardioParam = param;
          st.speed = speed;
        } else {
          final reps = int.tryParse(st.repsCtrl.text) ?? 0;
          if (reps <= 0) {
            AppToast.show(context, message: t.fillAllMetricsWarning, type: AppToastType.error);
            return;
          }
          final weight = double.tryParse(st.weightCtrl.text.replaceAll(',', '.')) ?? 0.0;
          final rpeText = st.rpeCtrl.text.trim().replaceAll(',', '.');
          final rpe = rpeText.isNotEmpty ? double.tryParse(rpeText) : null;
          st.reps = reps;
          st.weight = weight;
          st.rpe = rpe;
        }
      }
    }

    final durationMin = int.tryParse(_durationCtrl.text) ?? 45;
    final durationSec = math.max(60, durationMin * 60);

    // Build LoggedExercises
    final loggedExercises = <LoggedExercise>[];
    for (final exDraft in _exercises) {
      final loggedSets = <LoggedSet>[];
      for (final st in exDraft.sets) {
        if (exDraft.isCardio) {
          loggedSets.add(LoggedSet(
            st.totalDurationSec,
            st.cardioParam,
            sec: st.totalDurationSec,
            cardioParam: st.cardioParam,
            speed: exDraft.exercise.cardioType.hasSpeed ? st.speed : null,
          ));
        } else {
          loggedSets.add(LoggedSet(
            st.reps,
            st.weight,
            rpe: st.rpe,
          ));
        }
      }
      loggedExercises.add(LoggedExercise(
        exDraft.exercise.id,
        exDraft.exercise.name,
        exDraft.exercise.primary,
        loggedSets,
      ));
    }

    final session = LoggedSession(_selectedDate, durationSec, loggedExercises);
    fit.addLoggedSession(session);

    Navigator.of(context).pop(true);
    AppToast.show(context, message: t.workoutSaved, type: AppToastType.success);
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final height = MediaQuery.of(context).size.height * 0.90;

    return Container(
      height: height,
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        border: Border.all(color: gc.border),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
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
          const SizedBox(height: 14),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.registerWorkout,
                style: AppTheme.d(20, weight: FontWeight.w700, color: gc.text),
              ),
              RoundBtn(
                iconData: PhosphorIconsRegular.x,
                onTap: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Date and Duration Card
                  _dateAndDurationCard(gc),
                  const SizedBox(height: 14),
                  // Source Mode Selector
                  _sourceSelector(gc),
                  const SizedBox(height: 14),
                  // Routine picker if mode == 0
                  if (_sourceMode == 0) ...[
                    _routinePicker(gc),
                    const SizedBox(height: 14),
                  ],
                  // Exercises list
                  ..._exercisesList(gc),
                  const SizedBox(height: 12),
                  // Add Exercise Button
                  GestureDetector(
                    onTap: _addExercise,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: gc.bgRaised2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: gc.border, style: BorderStyle.solid),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIconsRegular.plus, size: 16, color: gc.accent),
                          const SizedBox(width: 8),
                          Text(
                            t.addExercise,
                            style: AppTheme.s(14, weight: FontWeight.w600, color: gc.accent),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Save button
          PrimaryButton(
            label: t.saveWorkout.toUpperCase(),
            onTap: _saveWorkout,
          ),
        ],
      ),
    );
  }

  Widget _dateAndDurationCard(GymColors gc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: gc.bgRaised2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gc.border),
      ),
      child: Column(
        children: [
          // Date selection row
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _pickDate,
            child: Row(
              children: [
                Icon(PhosphorIconsRegular.calendar, size: 20, color: gc.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.workoutDate,
                        style: AppTheme.s(11, weight: FontWeight.w500, color: gc.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.longDate(_selectedDate),
                        style: AppTheme.s(14, weight: FontWeight.w600, color: gc.text),
                      ),
                    ],
                  ),
                ),
                Icon(PhosphorIconsRegular.caretDown, size: 16, color: gc.textTertiary),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: gc.border.withValues(alpha: 0.6)),
          const SizedBox(height: 10),
          // Duration row
          Row(
            children: [
              Icon(PhosphorIconsRegular.clock, size: 20, color: gc.brass),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t.sessionDuration,
                  style: AppTheme.s(13, weight: FontWeight.w500, color: gc.text),
                ),
              ),
              SizedBox(
                width: 70,
                height: 36,
                child: TextField(
                  controller: _durationCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: AppTheme.d(15, weight: FontWeight.w700, color: gc.text),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    filled: true,
                    fillColor: gc.bgRaised,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: gc.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: gc.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: gc.accent),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sourceSelector(GymColors gc) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: gc.bgRaised2, borderRadius: BorderRadius.circular(100)),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _sourceMode = 0;
                  if (_selectedRoutineId != null) {
                    final r = fit.routines.firstWhere(
                      (x) => x.id == _selectedRoutineId,
                      orElse: () => fit.routines.first,
                    );
                    _loadRoutine(r);
                  } else if (fit.routines.isNotEmpty) {
                    _loadRoutine(fit.routines.first);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _sourceMode == 0 ? gc.ember : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    t.existingRoutine,
                    style: AppTheme.s(
                      12,
                      weight: FontWeight.w600,
                      color: _sourceMode == 0 ? gc.onEmber : gc.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _sourceMode = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _sourceMode == 1 ? gc.ember : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    t.manualExercises,
                    style: AppTheme.s(
                      12,
                      weight: FontWeight.w600,
                      color: _sourceMode == 1 ? gc.onEmber : gc.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _routinePicker(GymColors gc) {
    if (fit.routines.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: gc.bgRaised2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: gc.border),
        ),
        child: Text(
          t.noRoutinesAvailable,
          style: AppTheme.s(12, color: gc.textSecondary),
        ),
      );
    }

    // Se tiver apenas 1 treino, exibe o card direto sem dropdown
    if (fit.routines.length == 1) {
      final routine = fit.routines.first;
      final displayName = routine.name.trim().isEmpty ? t.newRoutineName : routine.name;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.selectRoutineHint,
            style: AppTheme.s(12, weight: FontWeight.w600, color: gc.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: gc.bgRaised2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: gc.border),
            ),
            child: Row(
              children: [
                Icon(PhosphorIconsRegular.clipboardText, size: 16, color: gc.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    displayName,
                    style: AppTheme.s(14, weight: FontWeight.w600, color: gc.text),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${routine.exerciseIds.length} ex.',
                  style: AppTheme.s(12, color: gc.textSecondary),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Mais de 1 treino: exibe como Dropdown
    final selectedId = fit.routines.any((r) => r.id == _selectedRoutineId)
        ? _selectedRoutineId
        : fit.routines.first.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.selectRoutineHint,
          style: AppTheme.s(12, weight: FontWeight.w600, color: gc.textSecondary),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: gc.bgRaised2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: gc.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedId,
              isExpanded: true,
              dropdownColor: gc.bgRaised,
              icon: Icon(PhosphorIconsRegular.caretDown, size: 18, color: gc.accent),
              style: AppTheme.s(14, weight: FontWeight.w600, color: gc.text),
              borderRadius: BorderRadius.circular(14),
              items: [
                for (final routine in fit.routines)
                  DropdownMenuItem<String>(
                    value: routine.id,
                    child: Row(
                      children: [
                        Icon(PhosphorIconsRegular.clipboardText, size: 16, color: gc.accent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            routine.name.trim().isEmpty ? t.newRoutineName : routine.name,
                            style: AppTheme.s(14, weight: FontWeight.w600, color: gc.text),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${routine.exerciseIds.length} ex.',
                          style: AppTheme.s(12, color: gc.textSecondary),
                        ),
                      ],
                    ),
                  ),
              ],
              onChanged: (id) {
                if (id != null) {
                  final r = fit.routines.firstWhere((x) => x.id == id);
                  _loadRoutine(r);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _exercisesList(GymColors gc) {
    if (_exercises.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              t.selectAtLeastOneExercise,
              style: AppTheme.s(13, color: gc.textSecondary),
            ),
          ),
        ),
      ];
    }

    return List.generate(_exercises.length, (exIdx) {
      final draft = _exercises[exIdx];
      final ex = draft.exercise;
      final name = exerciseName(ex);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: gc.bgRaised2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gc.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Exercise header (tappable to expand / collapse)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  draft.isExpanded = !draft.isExpanded;
                });
              },
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 38,
                      height: 38,
                      child: ExerciseMedia(ex: ex, height: 38, width: 38, radius: 10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTheme.s(14, weight: FontWeight.w700, color: gc.text),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          draft.isCardio
                              ? 'Cardio · ${ex.cardioType.displayNamePt} (${draft.sets.length} ${draft.sets.length == 1 ? "etapa" : "etapas"})'
                              : '${draft.sets.length} ${draft.sets.length == 1 ? "série" : "séries"} · ${muscleLabel(ex.primary)}',
                          style: AppTheme.s(11, color: gc.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(PhosphorIconsRegular.trash, size: 16, color: gc.textTertiary),
                    onPressed: () => _removeExercise(exIdx),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: draft.isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      PhosphorIconsRegular.caretDown,
                      size: 18,
                      color: draft.isExpanded ? gc.accent : gc.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (draft.isExpanded) ...[
              const SizedBox(height: 12),
              Divider(height: 1, color: gc.border.withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              // Sets or Cardio stages
              if (draft.isCardio)
                _cardioSetsEditor(gc, exIdx, draft)
              else
                _strengthSetsEditor(gc, exIdx, draft),
            ],
          ],
        ),
      );
    });
  }

  Widget _strengthSetsEditor(GymColors gc, int exIdx, _ManualExerciseDraft draft) {
    final unit = fit.units.toUpperCase();

    return Column(
      children: [
        // Column headers
        Row(
          children: [
            SizedBox(
              width: 28,
              child: Text('#', style: AppTheme.s(11, weight: FontWeight.w600, color: gc.textSecondary)),
            ),
            Expanded(
              flex: 3,
              child: Text(t.repsCol, textAlign: TextAlign.center, style: AppTheme.s(11, weight: FontWeight.w600, color: gc.textSecondary)),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 4,
              child: Text(t.weightTitle(unit), textAlign: TextAlign.center, style: AppTheme.s(11, weight: FontWeight.w600, color: gc.textSecondary)),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 3,
              child: Text(t.rpeTitle, textAlign: TextAlign.center, style: AppTheme.s(11, weight: FontWeight.w600, color: gc.textSecondary)),
            ),
            const SizedBox(width: 32),
          ],
        ),
        const SizedBox(height: 6),
        // Set rows
        for (int setIdx = 0; setIdx < draft.sets.length; setIdx++)
          _strengthSetRow(gc, exIdx, setIdx, draft.sets[setIdx], draft.sets.length > 1),
        const SizedBox(height: 8),
        // Add set button
        GestureDetector(
          onTap: () => _addSet(exIdx),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIconsRegular.plus, size: 14, color: gc.accent),
                const SizedBox(width: 4),
                Text(
                  t.addSet,
                  style: AppTheme.s(12, weight: FontWeight.w600, color: gc.accent),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _strengthSetRow(GymColors gc, int exIdx, int setIdx, _ManualSetDraft st, bool canDelete) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${setIdx + 1}',
              style: AppTheme.d(13, weight: FontWeight.w600, color: gc.textSecondary),
            ),
          ),
          // Reps input
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: st.repsCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: AppTheme.d(14, weight: FontWeight.w600, color: gc.text),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  filled: true,
                  fillColor: gc.bgRaised,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: gc.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: gc.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: gc.accent),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Weight input
          Expanded(
            flex: 4,
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: st.weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: AppTheme.d(14, weight: FontWeight.w600, color: gc.text),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  filled: true,
                  fillColor: gc.bgRaised,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: gc.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: gc.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: gc.accent),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // RPE input
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: st.rpeCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: AppTheme.d(14, weight: FontWeight.w600, color: gc.text),
                decoration: InputDecoration(
                  hintText: '-',
                  hintStyle: AppTheme.s(12, color: gc.textTertiary),
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  filled: true,
                  fillColor: gc.bgRaised,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: gc.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: gc.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: gc.accent),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Delete set
          SizedBox(
            width: 28,
            child: canDelete
                ? GestureDetector(
                    onTap: () => _removeSet(exIdx, setIdx),
                    child: Icon(PhosphorIconsRegular.minusCircle, size: 18, color: gc.textTertiary),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _cardioSetsEditor(GymColors gc, int exIdx, _ManualExerciseDraft draft) {
    final ct = draft.exercise.cardioType;

    return Column(
      children: [
        for (int setIdx = 0; setIdx < draft.sets.length; setIdx++) ...[
          _cardioSetCard(gc, exIdx, setIdx, draft.sets[setIdx], ct, draft.sets.length > 1),
          if (setIdx < draft.sets.length - 1) const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _addSet(exIdx),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIconsRegular.plus, size: 14, color: gc.accent),
                const SizedBox(width: 4),
                Text(
                  t.stage,
                  style: AppTheme.s(12, weight: FontWeight.w600, color: gc.accent),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _cardioSetCard(
    GymColors gc,
    int exIdx,
    int setIdx,
    _ManualSetDraft st,
    CardioCategoryType ct,
    bool canDelete,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gc.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${t.stage} ${setIdx + 1}',
                style: AppTheme.s(11, weight: FontWeight.w700, color: gc.accent),
              ),
              if (canDelete)
                GestureDetector(
                  onTap: () => _removeSet(exIdx, setIdx),
                  child: Icon(PhosphorIconsRegular.minusCircle, size: 16, color: gc.textTertiary),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Time input (min and sec)
          Row(
            children: [
              Expanded(
                child: Text(
                  t.duration,
                  style: AppTheme.s(12, weight: FontWeight.w600, color: gc.textSecondary),
                ),
              ),
              SizedBox(
                width: 55,
                height: 34,
                child: TextField(
                  controller: st.durMinCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: AppTheme.d(13, weight: FontWeight.w700, color: gc.text),
                  decoration: InputDecoration(
                    suffixText: 'm',
                    suffixStyle: AppTheme.s(10, color: gc.textSecondary),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    filled: true,
                    fillColor: gc.bgRaised2,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: gc.border)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 55,
                height: 34,
                child: TextField(
                  controller: st.durSecCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: AppTheme.d(13, weight: FontWeight.w700, color: gc.text),
                  decoration: InputDecoration(
                    suffixText: 's',
                    suffixStyle: AppTheme.s(10, color: gc.textSecondary),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    filled: true,
                    fillColor: gc.bgRaised2,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: gc.border)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Machine parameter input
          Row(
            children: [
              Expanded(
                child: Text(
                  ct.paramLabel,
                  style: AppTheme.s(12, weight: FontWeight.w600, color: gc.textSecondary),
                ),
              ),
              SizedBox(
                width: 116,
                height: 34,
                child: TextField(
                  controller: st.paramCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: AppTheme.d(13, weight: FontWeight.w700, color: gc.text),
                  decoration: InputDecoration(
                    suffixText: ct.paramUnit,
                    suffixStyle: AppTheme.s(10, color: gc.textSecondary),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    filled: true,
                    fillColor: gc.bgRaised2,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: gc.border)),
                  ),
                ),
              ),
            ],
          ),
          // Treadmill speed input
          if (ct.hasSpeed) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    ct.speedLabel,
                    style: AppTheme.s(12, weight: FontWeight.w600, color: gc.textSecondary),
                  ),
                ),
                SizedBox(
                  width: 116,
                  height: 34,
                  child: TextField(
                    controller: st.speedCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: AppTheme.d(13, weight: FontWeight.w700, color: gc.text),
                    decoration: InputDecoration(
                      suffixText: ct.speedUnit,
                      suffixStyle: AppTheme.s(10, color: gc.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      filled: true,
                      fillColor: gc.bgRaised2,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: gc.border)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
