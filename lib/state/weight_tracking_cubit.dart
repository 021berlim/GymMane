import 'package:flutter/foundation.dart';
import '../models/goal.dart';
import '../models/weight_entry.dart';
import '../services/weight_trend_calculator.dart';
import 'fit_state.dart';

class WeightTrackingCubit extends ChangeNotifier {
  WeightTrackingCubit({FitState? fitState}) {
    _fit = fitState ?? fit;
    _fit.addListener(_onFitChanged);
    _recalculate();
  }

  late final FitState _fit;
  TrendResult _result = TrendResult(
    trendSeries: [],
    currentTrendWeight: 0.0,
    weeklyRateKg: 0.0,
    goalEtaDate: null,
    isRateAggressive: false,
  );

  List<WeightEntry> get rawPoints => _fit.bodyweight;
  List<TrendPoint> get trendSeries => _result.trendSeries;
  double get currentTrendWeight => _result.currentTrendWeight;
  double get weeklyRateKg => _result.weeklyRateKg;
  DateTime? get goalEtaDate => _result.goalEtaDate;
  bool get isRateAggressive => _result.isRateAggressive;
  TrendResult get result => _result;

  void _onFitChanged() {
    _recalculate();
  }

  void _recalculate() {
    double? targetWeight;
    final bwGoal = _fit.goals.where((g) => g.type == GoalType.bodyweight).firstOrNull;
    if (bwGoal != null && bwGoal.target > 0) {
      targetWeight = bwGoal.target;
    }

    _result = WeightTrendCalculator.calculate(
      entries: _fit.bodyweight,
      goalWeight: targetWeight,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _fit.removeListener(_onFitChanged);
    super.dispose();
  }
}
