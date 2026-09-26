import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/l10n.dart';
import '../screens/about_screen.dart';
import '../screens/awards_screen.dart';
import '../screens/exercise_detail_screen.dart';
import '../screens/exercises_screen.dart';
import '../screens/gallery_screen.dart';
import '../screens/home_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/routine_edit_screen.dart';
import '../screens/routines_screen.dart';
import '../screens/session_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/tool_detail_screen.dart';
import '../screens/tools_screen.dart';
import '../screens/train_screen.dart';
import '../services/update_service.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/award_celebration.dart';
import '../widgets/update_dialog.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  static const _firstAwardWait = Duration(milliseconds: 1200);
  static const _nextAwardWait = Duration(milliseconds: 2000);
  Timer? _awardWait;
  AwardId? _celebrating;
  bool _celebratedOne = false;
  String _lastRoute = '';
  int _lastDepth = 0;
  bool _sideways = false;
  bool _forward = true;

  static int _depthFor(String route) {
    const tabs = {'home', 'progress', 'exercises', 'settings'};
    if (tabs.contains(route)) return 0;
    if (route == 'routine-edit' || route == 'tools-detail') return 2;
    return 1;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fit.refreshAlarmPermission();
    fit.addListener(_queueCelebration);
    _queueCelebration();
    _checkForUpdate();
  }

  void _queueCelebration() {
    if (fit.nextCelebration == null) {
      _celebratedOne = false;
      return;
    }
    if (_celebrating != null || _awardWait != null || fit.route == 'session') return;
    _awardWait = Timer(_celebratedOne ? _nextAwardWait : _firstAwardWait, () {
      _awardWait = null;
      final next = fit.nextCelebration;
      if (!mounted || next == null || fit.route == 'session') return;
      setState(() => _celebrating = next);
    });
  }

  void _closeCelebration() {
    setState(() => _celebrating = null);
    _celebratedOne = true;
    fit.celebrationShown();
  }

  /// Checks GitHub Releases for a newer APK (Android-only, fail-silent).
  void _checkForUpdate() {
    if (!Platform.isAndroid) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final result = await UpdateService.checkForUpdate();
        if (result is UpdateAvailable && mounted) {
          showUpdateDialog(context, result.info);
        }
      } catch (_) {
        // Fail silently — never block the app.
      }
    });
  }

  @override
  void dispose() {
    fit.removeListener(_queueCelebration);
    _awardWait?.cancel();
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
    // al volver de los ajustes del sistema el permiso puede haber cambiado
    if (state == AppLifecycleState.resumed) fit.refreshAlarmPermission();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fit,
      builder: (context, _) {
        if (!fit.onboarded) return const OnboardingScreen();

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (fit.isSessionActive) {
              if (await _confirmDiscard(context)) fit.discardSession();
              return;
            }
            if (fit.isSessionComplete) {
              fit.saveAndExit();
              return;
            }
            if (!fit.handleBack()) await SystemNavigator.pop();
          },
          child: Scaffold(
            backgroundColor: context.gc.bg,
            body: Stack(
              children: [
                Positioned.fill(child: AppBackground(pattern: fit.bgPattern)),
                Positioned.fill(child: _animatedScreen()),
                if (fit.showNav)
                  Positioned(left: 18, right: 18, bottom: 18, child: _NavBar()),
                if (fit.route != 'session' && _celebrating != null)
                  Positioned.fill(
                    child: AwardCelebration(
                      key: ValueKey(_celebrating),
                      id: _celebrating!,
                      onClose: _closeCelebration,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDiscard(BuildContext context) async {
    final gc = context.gc;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        backgroundColor: gc.bgRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t.discardTitle, style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text)),
        content: Text(t.discardBody,
            style: AppTheme.s(13, color: gc.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(false),
            child: Text(t.keepTraining, style: AppTheme.s(14, color: gc.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(true),
            child: Text(t.discard, style: AppTheme.s(14, weight: FontWeight.w700, color: gc.accent)),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Widget _animatedScreen() {
    final route = fit.route;
    if (route != _lastRoute) {
      final from = _NavBar._routes.indexOf(_lastRoute);
      final to = _NavBar._routes.indexOf(route);
      _sideways = from >= 0 && to >= 0;
      final curDepth = _depthFor(route);
      _forward = _sideways ? to > from : curDepth >= _lastDepth;
      _lastRoute = route;
      _lastDepth = curDepth;
    }
    final sideways = _sideways;
    final dir = _forward ? 1.0 : -1.0;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: const Interval(0.3, 1, curve: Curves.easeOutCubic),
      switchOutCurve: const Interval(0.7, 1, curve: Curves.easeInCubic),
      transitionBuilder: (child, animation) {
        final incoming = (child.key as ValueKey?)?.value == fit.route;
        return AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (_, inner) {
            final v = animation.value.clamp(0.0, 1.0);
            final away = 1 - v;
            final shift = sideways
                ? Offset((incoming ? 26 : -18) * dir * away, 0)
                : Offset(0, incoming ? 22 * dir * away : -8 * dir * away);
            final blur = 10 * away;
            return Opacity(
              opacity: v,
              child: ImageFiltered(
                enabled: blur > 0.25,
                imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur, tileMode: TileMode.decal),
                child: Transform.translate(
                  offset: shift,
                  child: Transform.scale(
                    scale: incoming ? 1 + 0.03 * away : 1 - 0.04 * away,
                    child: inner,
                  ),
                ),
              ),
            );
          },
        );
      },
      layoutBuilder: (currentChild, previousChildren) => Stack(
        children: <Widget>[
          for (final c in previousChildren) Positioned.fill(key: c.key, child: c),
          if (currentChild != null) Positioned.fill(key: currentChild.key, child: currentChild),
        ],
      ),
      child: KeyedSubtree(key: ValueKey(fit.route), child: _screen()),
    );
  }

  Widget _screen() {
    switch (fit.route) {
      case 'progress':
        return ProgressScreen();
      case 'gallery':
        return const GalleryScreen();
      case 'routine-choice':
      case 'train':
        return TrainScreen();
      case 'session':
        return SessionScreen();
      case 'exercises':
        return ExercisesScreen();
      case 'exercise-detail':
        return ExerciseDetailScreen();
      case 'tools':
        return ToolsScreen();
      case 'tools-detail':
        return ToolDetailScreen();
      case 'settings':
        return const ProfileScreen();
      case 'preferences':
        return const SettingsScreen();
      case 'awards':
        return const AwardsScreen();
      case 'about':
        return AboutScreen();
      case 'routines':
        return RoutinesScreen();
      case 'routine-edit':
        return RoutineEditScreen();
      case 'home':
      default:
        return HomeScreen();
    }
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar();

  static const _iw = 58.0;
  static const _fabW = 54.0;
  static const _routes = ['home', 'progress', 'exercises', 'settings'];

  int get _selectedIndex {
    final route = (fit.route == 'preferences' || fit.route == 'awards') ? 'settings' : fit.route;
    final i = _routes.indexOf(route);
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: gc.bgRaised,
        border: Border.all(color: gc.border),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: const Color(0x59000000), blurRadius: 32, offset: const Offset(0, 12))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final gap = ((w - 4 * _iw - _fabW) / 4).clamp(0.0, 40.0);

            double slotX(int i) {
              switch (i) {
                case 0:
                  return 0;
                case 1:
                  return _iw + gap;
                case 2:
                  return 2 * _iw + 3 * gap + _fabW;
                default:
                  return 3 * _iw + 4 * gap + _fabW;
              }
            }

            return Stack(
              alignment: Alignment.center,
              children: [
                _LiquidPill(
                  left: slotX(_selectedIndex),
                  width: _iw,
                  color: gc.bgRaised2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _item(context, 0, PhosphorIconsRegular.house, PhosphorIconsFill.house, t.home, fit.goHome),
                    _item(context, 1, PhosphorIconsRegular.chartLineUp, PhosphorIconsFill.chartLineUp, t.progress, fit.goProgress),
                    _fab(context),
                    _item(context, 2, PhosphorIconsRegular.barbell, PhosphorIconsFill.barbell, t.exercises, fit.goExercises),
                    _item(context, 3, PhosphorIconsRegular.userCircle, PhosphorIconsFill.userCircle, t.profile, fit.goSettings),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int index, IconData icon, IconData iconFill, String label, VoidCallback onTap) {
    final gc = context.gc;
    final selected = _selectedIndex == index;
    const dur = Duration(milliseconds: 300);

    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: _iw,
          height: double.infinity,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: selected ? 1 : 0, end: selected ? 1 : 0),
              duration: dur,
              curve: Curves.easeOut,
              builder: (context, t, _) => Icon(
                selected ? iconFill : icon,
                size: 24,
                color: Color.lerp(gc.textTertiary, gc.text, t),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fab(BuildContext context) {
    final gc = context.gc;
    return GestureDetector(
      onTap: fit.startWorkout,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gc.accent, gc.brass],
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(PhosphorIconsFill.play, size: 24, color: gc.bg),
      ),
    );
  }
}

class _LiquidPill extends StatefulWidget {
  const _LiquidPill({required this.left, required this.width, required this.color});

  final double left;
  final double width;
  final Color color;

  @override
  State<_LiquidPill> createState() => _LiquidPillState();
}

class _LiquidPillState extends State<_LiquidPill> with TickerProviderStateMixin {
  late final AnimationController _move =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 460), value: 1);
  late final AnimationController _lift = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    reverseDuration: const Duration(milliseconds: 380),
  );
  late double _from = widget.left;
  late double _shown = widget.left;

  @override
  void didUpdateWidget(_LiquidPill old) {
    super.didUpdateWidget(old);
    if (old.left == widget.left) return;
    _from = _shown;
    _move.forward(from: 0);
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  static const _liftCurve = Cubic(0.3, 1.25, 0.5, 1);

  @override
  void dispose() {
    _move.dispose();
    _lift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_move, _lift]),
      builder: (context, _) {
        final lift = _liftCurve.transform(_lift.value.clamp(0.0, 1.0));
        final t = _move.value;
        final to = widget.left;
        final right = to >= _from;
        final lead = Curves.easeOutCubic.transform(t);
        final trail = Curves.easeInOutCubic.transform(t);
        final l = _lerp(_from, to, right ? trail : lead);
        final r = _lerp(_from + widget.width, to + widget.width, right ? lead : trail);
        final squash = 1 - 0.14 * (1 - (2 * t - 1).abs()) * (to == _from ? 0 : 1);
        _shown = l;
        final base = Color.lerp(
          widget.color,
          widget.color.withValues(alpha: (widget.color.a * 2.4).clamp(0.0, 1.0)),
          lift,
        )!;
        final grow = 6 * lift;
        final inset = 8 + 10 * (1 - squash) - 4 * lift;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: l - grow,
              width: r - l + 2 * grow,
              top: inset,
              bottom: inset,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18 + grow),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.16 * lift), width: 1),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.alphaBlend(Colors.white.withValues(alpha: 0.12 * lift), base),
                      base,
                    ],
                  ),
                  boxShadow: lift <= 0
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.28 * lift),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
