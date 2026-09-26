import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/fitiron_app.dart';
import 'services/alarm_store.dart';
import 'services/home_widget_bridge.dart';
import 'services/live_workout.dart';
import 'services/local_store.dart';
import 'services/media_store.dart';
import 'services/rest_alarm.dart';
import 'state/fit_state.dart';

void _sessionSideEffects() {
  LiveWorkout.sync();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  timeDilation = 1.0;
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  try {
    await initializeDateFormatting();
    await Store.instance.init();
    await MediaStore.init();
    await AlarmStore.init();
    fit.loadFromStore();
    await RestAlarm.instance.init();
  } catch (e, stack) {
    debugPrint('Erro no carregamento dos dados de inicialização: $e\n$stack');
  }

  fit.addListener(_sessionSideEffects);
  _sessionSideEffects();

  fit.onWidgetsShouldUpdate = HomeWidgetBridge.update;
  runApp(const FitIronApp());

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await RestAlarm.instance.ensurePermission();
      await RestAlarm.instance.ensureExactAlarmPermission();
      await fit.refreshAlarmPermission();
      await HomeWidgetBridge.update();
    } catch (e) {
      debugPrint('Erro nas callbacks pós-frame: $e');
    }
  });
}
