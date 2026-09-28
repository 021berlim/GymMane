part of 'fit_state.dart';

String fmt(num n) {
  if (n == n.round()) return n.round().toString();
  return n.toString();
}

double _round1(double n) => (n * 10).round() / 10;
double _round3(double n) => (n * 1000).round() / 1000;
double _roundTo(double n, double step) => (n / step).round() * step;
DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

const int kHeatmapDays = 84;

abstract class FitCore extends ChangeNotifier {
  Map<String, dynamic> toJson();

  String route = 'home';
  String prevRoute = 'home';
  final Map<String, bool> favorites = {};

  Profile profile = Profile();

  final List<LoggedSession> sessions = [];
  final List<BodyweightEntry> bodyweight = [];
  final Map<String, List<ExerciseNote>> exNotes = {};
  final Set<String> checkins = {};
  final List<Routine> routines = [];
  final Map<int, String> weeklyPlan = {};

  Set<int> get scheduledWeekdays {
    final result = <int>{};
    for (final entry in weeklyPlan.entries) {
      if (entry.value.isNotEmpty && routines.any((r) => r.id == entry.value)) {
        result.add(entry.key);
      }
    }
    return result;
  }

  final List<Exercise> customExercises = [];
  final List<Goal> goals = [];
  VoidCallback? onWidgetsShouldUpdate;

  void _refreshWidgets() {
    try {
      onWidgetsShouldUpdate?.call();
    } catch (_) {}
  }

  String units = 'kg';
  bool _loading = false;
  Timer? _saveDebounce;

  void _persist() {
    if (_loading) return;
    if (Platform.environment.containsKey('FLUTTER_TEST') && !SqliteStore.instance.isOpen) {
      return;
    }
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), () => unawaited(persistNow()));
  }

  Future<void> persistNow() async {
    _saveDebounce?.cancel();
    _saveDebounce = null;
    if (_loading) return;
    final data = toJson();
    if (data.isNotEmpty) {
      await Store.instance.save(data);
    }
  }

  void goHome() => _setRoute('home', reset: true);

  void goProgress() => _setRoute('progress', reset: true);

  void goExercises() => _setRoute('exercises', reset: true);

  void goSettings() => _setRoute('settings', reset: true);

  void goGallery() => _setRoute('gallery', reset: true);

  final List<String> _routeHistory = [];

  void pushRoute(String r) {
    _routeHistory.add(route);
    _setRoute(r);
  }

  void popRoute({String fallback = 'home'}) {
    if (_routeHistory.isNotEmpty) {
      _setRoute(_routeHistory.removeLast());
    } else {
      _setRoute(fallback);
    }
  }

  void goPreferences() => pushRoute('preferences');
  void backFromPreferences() => popRoute(fallback: 'settings');
  void refreshAwards({bool silent = false}) {}

  void _setRoute(String r, {bool reset = false}) {
    if (reset) _routeHistory.clear();
    route = r;
    if (reset) prevRoute = r;
    notifyListeners();
  }

  bool get showNav => const ['home', 'progress', 'gallery', 'exercises', 'settings'].contains(route);

  void setUnits(String u) {
    units = u;
    _persist();
    notifyListeners();
  }

  static const _lbPerKg = 2.20462;
  bool get isLb => units == 'lb';

  double toDisplayWeight(double kg) => isLb ? kg * _lbPerKg : kg;

  double fromDisplayWeight(double shown) => isLb ? shown / _lbPerKg : shown;

  String weightLabel(double kg) => '${fmt(_round1(toDisplayWeight(kg)))} $units';

  String weightValue(double kg) => fmt(_round1(toDisplayWeight(kg)));

  double get weightStep => isLb ? 5 : 1.0;
  String get volumeUnit => isLb ? 'k lb' : 't';

  String volumeValue(double kg) => fmt(_round1(toDisplayWeight(kg) / 1000));

  String volumeLabel(double kg) => '${volumeValue(kg)} $volumeUnit';
}
