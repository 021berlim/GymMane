import 'package:flutter/material.dart';
import '../services/alarm_controller.dart';
import '../services/rest_alarm.dart';

/// Wrapper global montado na raiz do MaterialApp.
///
/// Monitora:
/// 1. Qualquer toque na tela (PointerDownEvent) via HitTestBehavior.translucent.
/// 2. Retomada do app ao primeiro plano (AppLifecycleState.resumed).
class GlobalAlarmDismissListener extends StatefulWidget {
  final Widget child;

  const GlobalAlarmDismissListener({super.key, required this.child});

  @override
  State<GlobalAlarmDismissListener> createState() => _GlobalAlarmDismissListenerState();
}

class _GlobalAlarmDismissListenerState extends State<GlobalAlarmDismissListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _dismissAlarmIfActive();
    }
  }

  void _dismissAlarmIfActive() {
    if (AlarmController.instance.isPlaying) {
      AlarmController.instance.stopAlarm();
      RestAlarm.instance.cancelActiveNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _dismissAlarmIfActive(),
      child: widget.child,
    );
  }
}
